module List = Core.List
module String = Core.String
module Char = Core.Char

let __string_get ~index string = string.[index]

let __string_of_byte byte = String.make 1 @@ Char.of_int_exn byte

let __list_get ~index list = List.nth_exn list index
