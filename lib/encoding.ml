(* base 64 format *)

module Base64 = Nocrypto.Base64

let encode message =
  Cstruct.to_string @@ Base64.encode @@ Cstruct.of_string message


let decode encoded =
  match Base64.decode @@ Cstruct.of_string encoded with
  | None ->
      raise Reasons.InvalidBase64Data
  | Some bytes ->
      Cstruct.to_string bytes
