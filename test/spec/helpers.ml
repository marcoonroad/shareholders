module String = Core.String
module Str = Re.Str
module ShEnc = Shareholders__Encoding

let _HASH_LENGTH = 128

let regexp = Str.regexp "^[a-f0-9]+$"

let is_hash text =
  Str.string_match regexp text 0 && String.length text = _HASH_LENGTH


let is_base64 data =
  try
    ignore @@ ShEnc.decode data ;
    true
  with
  | _ ->
      false


let is_share share =
  match String.split ~on:'\n' share with
  | [ commitment; encrypted ] ->
      is_hash commitment && is_base64 encrypted
  | _ ->
      false
