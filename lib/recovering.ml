(* recovering the secret from pieces *)

module List = Core.List
module Int = Core.Int
module String = Core.String

let __validate_range number = assert (0 < number && number <= 255)

let __recover_byte shares =
  let uniq = List.dedup_and_sort ~compare:Int.compare shares in
  List.iter ~f:__validate_range uniq ;
  List.reduce_exn ~f:Int.( lxor ) uniq


let __validate_length shares =
  let lengths = List.map ~f:String.length shares in
  let first = List.hd_exn lengths in
  let rest = List.tl_exn lengths in
  let valid = List.for_all ~f:(( = ) first) rest in
  assert valid


let __string_get ~index string =
  let position = Helpers.__string_get string ~index:(index * 2) in
  let byte = Helpers.__string_get string ~index:((index * 2) + 1) in
  (position, byte)


let __string_of_byte = Helpers.__string_of_byte

let __code_of_byte (_, byte) = Char.code byte

let recover shares =
  __validate_length shares ;
  let secret_size = (String.length @@ List.nth_exn shares 0) / 2 in
  let __gather index =
    let bytes = List.map ~f:(__string_get ~index) shares in
    let codes = List.map ~f:__code_of_byte bytes in
    __string_of_byte @@ __recover_byte codes
  in
  let bytes = List.init ~f:__gather secret_size in
  let secret = List.reduce_exn ~f:( ^ ) bytes in
  try Encoding.decode secret with _ -> ""
