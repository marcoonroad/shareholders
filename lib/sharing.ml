(* generating the shares/pieces *)

module List = Core.List
module String = Core.String
module Int = Core.Int

let __list_get = Helpers.__list_get

let __string_of_byte = Helpers.__string_of_byte

let __unique_random = Entropy.__unique_random

let __validate amount threshold =
  if 2 <= threshold
     && amount / 2 <= threshold
     && threshold <= amount
     && threshold <= 128
  then ()
  else raise Reasons.UnsafeSharesThreshold


let rec __loop byte length buffer =
  if length <= 0
  then byte :: buffer
  else
    (* avoids collision with byte being zero *)
    let random = __unique_random (byte :: buffer) in
    let share = Int.( lxor ) byte random in
    let next = random :: buffer in
    if List.mem ~equal:Int.( = ) next share
    then __loop byte length buffer
    else __loop share (length - 1) next


let pair a b = (a, b)

let __share_byte byte ~amount ~threshold =
  let list = __loop byte (threshold - 1) [] in
  let uniq = List.mapi ~f:pair list in
  let plus =
    List.sub ~pos:0 ~len:(amount - threshold) @@ Entropy.permute uniq
  in
  Entropy.permute (uniq @ plus)


let __show_entry (a, b) = __string_of_byte (a + 1) ^ __string_of_byte b

let __char_to_pieces ~amount ~threshold char =
  List.map ~f:__show_entry @@ __share_byte ~amount ~threshold @@ Char.code char


let share ~secret ~amount ~threshold =
  __validate amount threshold ;
  let encoded = Encoding.encode secret in
  let __make_pieces = __char_to_pieces ~amount ~threshold in
  let shares = List.map ~f:__make_pieces @@ String.to_list encoded in
  let __gather index =
    List.reduce_exn ~f:( ^ ) @@ List.map ~f:(__list_get ~index) shares
  in
  List.init ~f:__gather amount
