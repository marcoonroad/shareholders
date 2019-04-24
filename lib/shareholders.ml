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

let __generate_checksum threshold checksum =
  let prefix = Helpers.__string_of_byte threshold in
  let data = Encoding.encode checksum in
  Encoding.encode (prefix ^ "." ^ data)


let share ~secret ~amount ~threshold =
  let checksum = Hashing.compute secret in
  let pass = Hashing.compute checksum in
  let commitment = Hashing.compute pass in
  let closure data =
    let encrypted = Encryption.encrypt ~pass data in
    let buffer = commitment ^ Encoding.decode encrypted in
    let commitment' = Encoding.encode @@ Hashing.compute buffer in
    commitment' ^ "." ^ encrypted
  in
  let shares = List.map ~f:closure @@ __share ~secret ~amount ~threshold in
  (__generate_checksum threshold checksum, shares)


let __verify_share commitment share =
  match String.split ~on:'.' share with
  | [ commitment'; encrypted ] ->
      let buffer = commitment ^ Encoding.decode encrypted in
      let signature = Helpers.to_hex @@ Encoding.decode commitment' in
      if signature = Hashing.digest buffer
      then encrypted
      else raise Reasons.RecoverChecksumMismatch
  | _ ->
      raise Reasons.InvalidSharesFormat


let __generate_commitment secret =
  Hashing.(compute @@ compute @@ compute secret)


let verify ~secret ~share =
  match __verify_share (__generate_commitment secret) share with
  | exception Reasons.RecoverChecksumMismatch ->
      false
  | _ ->
      true


let __decode ~pass data =
  let commitment = Hashing.compute pass in
  let encrypted = __verify_share commitment data in
  Encryption.decrypt ~pass encrypted


let __decode_checksum encoded =
  let result = String.split ~on:'.' @@ Encoding.decode encoded in
  if List.length result = 2
  then
    let threshold = Helpers.__string_to_byte @@ List.nth_exn result 0 in
    let checksum = Encoding.decode @@ List.nth_exn result 1 in
    (threshold, checksum)
  else raise Reasons.InvalidSharesFormat


let recover ~checksum ~shares =
  let threshold, checksum_bytes = __decode_checksum checksum in
  ignore threshold ;
  let checksum_hex = Helpers.to_hex checksum_bytes in
  let pass = Hashing.compute checksum_bytes in
  let closure = __decode ~pass in
  let decrypted = List.map ~f:closure shares in
  let secret = __recover decrypted in
  let fingerprint = Hashing.digest secret in
  if checksum_hex = fingerprint
  then secret
  else raise Reasons.RecoverChecksumMismatch
