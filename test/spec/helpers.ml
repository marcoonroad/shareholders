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


let is_header header =
  let raw_hash = ShEnc.decode header in
  let hex_hash = Hex.show @@ Hex.of_string raw_hash in
  is_hash hex_hash


let is_share share =
  match String.split ~on:'.' share with
  | [ commitment; encrypted ] ->
      is_header commitment && is_base64 encrypted
  | _ ->
      false


let is_checksum checksum =
  match String.split ~on:'.' @@ ShEnc.decode checksum with
  | [ prefix; data ] ->
      let hex_hash = Hex.show @@ Hex.of_string @@ ShEnc.decode data in
      String.length prefix = 1 && is_hash hex_hash
  | _ ->
      false
