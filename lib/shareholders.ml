(* library entry-point *)

module List = Core.List
include Reasons

let __share = Sharing.share

let __recover = Recovering.recover

let share ~secret ~amount ~threshold =
  let commitment = Hashing.digest secret in
  let shares = __share ~secret ~amount ~threshold in
  (commitment, List.map ~f:Encoding.encode shares)


let recover ~commitment ~shares =
  let secret = __recover @@ List.map ~f:Encoding.decode shares in
  let fingerprint = Hashing.digest secret in
  if commitment = fingerprint
  then secret
  else raise Reasons.RecoverChecksumMismatch
