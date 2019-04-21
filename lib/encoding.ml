(* base 64 format *)

module Option = Core.Option
module Base64 = Nocrypto.Base64
module Error = Core.Error

let encode message =
  Cstruct.to_string @@ Base64.encode @@ Cstruct.of_string message


let error = Error.of_exn Reasons.InvalidSharesFormat

let decode encoded =
  let nullable = Base64.decode @@ Cstruct.of_string encoded in
  let bytes = Option.value_exn ~error nullable in
  Cstruct.to_string bytes
