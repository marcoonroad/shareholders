module List = Core.List
module String = Core.String
module Char = Core.Char
module Int = Core.Int

let __string_get ~index string = string.[index]

let __string_of_byte byte = String.make 1 @@ Char.of_int_exn byte

let __string_to_byte string =
  assert (String.length string = 1) ;
  Char.to_int @@ __string_get ~index:0 string


let __list_get ~index list = List.nth_exn list index

let nullchar = Char.of_int_exn 0

let pad ~basis msg =
  let length = String.length msg in
  let remainder = Int.( % ) length basis in
  if remainder = 0 then msg else
  let zerofill = String.make (basis - remainder) nullchar in
  msg ^ zerofill


let nonzero char = char != nullchar

let unpad msg = String.filter ~f:nonzero msg

let to_hex data = Hex.show @@ Hex.of_cstruct @@ Cstruct.of_string data
