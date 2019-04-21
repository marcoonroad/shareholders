(* library entry-point *)

module String = Core.String
module List = Core.List
include Reasons

let __share = Sharing.share

let __recover = Recovering.recover

(*

  TODO: rethink carefully if I should use HMAC (keyed hashing) with Blake2B
  instead simple concatenation to generate commitment tags on encrypted shares.

*)

let share ~secret ~amount ~threshold =
  let checksum = Hashing.compute secret in
  let pass = Hashing.compute checksum in
  let commitment = Hashing.compute pass in
  let closure data =
    let encrypted = Encryption.encrypt ~pass data in
    let buffer = commitment ^ Encoding.decode encrypted in
    let commitment' = Hashing.digest buffer in
    commitment' ^ "\n" ^ encrypted
  in
  let shares = List.map ~f:closure @@ __share ~secret ~amount ~threshold in
  (Helpers.to_hex checksum, shares)


let __decode ~commitment ~pass data =
  match String.split ~on:'\n' data with
  | [ commitment'; encrypted ] ->
      let buffer = commitment ^ Encoding.decode encrypted in
      if commitment' = Hashing.digest buffer
      then Encryption.decrypt ~pass encrypted
      else raise Reasons.InvalidSharesFormat
  | _ ->
      raise Reasons.InvalidSharesFormat


let recover ~checksum ~shares =
  let pass = Hashing.compute @@ Helpers.of_hex checksum in
  let commitment = Hashing.compute pass in
  let closure = __decode ~commitment ~pass in
  let secret = __recover @@ List.map ~f:closure shares in
  let fingerprint = Hashing.digest secret in
  if checksum = fingerprint
  then secret
  else raise Reasons.RecoverChecksumMismatch
