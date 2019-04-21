open Nocrypto.Cipher_block.AES.CBC

let cxor = Nocrypto.Uncommon.Cs.xor

(* we assume input as a 512-bits string *)
let __compute_key_and_iv input =
  let bytes = Cstruct.of_string input in
  let left, right = Cstruct.split bytes 32 in
  let first, second = Cstruct.split left 16 in
  let third, fourth = Cstruct.split right 16 in
  let key = cxor left right in
  let iv = cxor (cxor first second) @@ cxor third fourth in
  (of_secret key, iv)


let encrypt msg ~pass =
  let key, iv = __compute_key_and_iv pass in
  let padded = Helpers.pad ~basis:16 msg in
  let result = encrypt ~iv ~key @@ Cstruct.of_string padded in
  Encoding.encode @@ Cstruct.to_string result


let decrypt cipher ~pass =
  let key, iv = __compute_key_and_iv pass in
  let bytes = Cstruct.of_string @@ Encoding.decode cipher in
  Helpers.unpad @@ Cstruct.to_string @@ decrypt ~iv ~key bytes
