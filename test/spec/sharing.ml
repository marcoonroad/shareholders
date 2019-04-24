module Sh = Shareholders
module ShEnc = Shareholders__Encoding
module List = Core.List
module String = Core.String

let _SECRET =
  "\n\
  \  E eu ainda gosto dela\n\
  \  Mas ela já não gosta tanto assim\n\
  \  A porta ainda está aberta\n\
  \  Mas da janela já não entra luz\n"


let __shares_validation () =
  let checksum, shares = Sh.share ~secret:_SECRET ~threshold:10 ~amount:15 in
  let validation share =
    Alcotest.(check bool) "valid share format" true @@ Helpers.is_share share
  in
  List.iter ~f:validation shares ;
  Alcotest.(check int) "valid shares size" (List.length shares) 15 ;
  let valid_checksum = Helpers.is_checksum checksum in
  Alcotest.(check bool) "valid checksum format" true valid_checksum


let __shares_threshold_failures () =
  let reason = Sh.UnsafeSharesThreshold in
  let procedureA () =
    ignore @@ Sh.share ~secret:_SECRET ~amount:40 ~threshold:10
  in
  let procedureB () =
    ignore @@ Sh.share ~secret:_SECRET ~amount:200 ~threshold:150
  in
  let procedureC () =
    ignore @@ Sh.share ~secret:_SECRET ~amount:1 ~threshold:1
  in
  Alcotest.check_raises "threshold lower than 50%" reason procedureA ;
  Alcotest.check_raises "threshold greater than 128 shares" reason procedureB ;
  Alcotest.check_raises "threshold lower than 2 shares" reason procedureC


let __shares_uniqueness () =
  let secret, amount, threshold = (_SECRET, 10, 5) in
  let commitmentA, sharesA = Sh.share ~secret ~amount ~threshold in
  let commitmentB, sharesB = Sh.share ~secret ~amount ~threshold in
  let sortedA = List.dedup_and_sort ~compare:String.compare sharesA in
  let sortedB = List.dedup_and_sort ~compare:String.compare sharesB in
  let lengthA, lengthA' = (List.length sharesA, List.length sortedA) in
  let lengthB, lengthB' = (List.length sharesB, List.length sortedB) in
  Alcotest.(check string) "commitments are the same" commitmentA commitmentB ;
  Alcotest.(check int) "shares are unique within A" lengthA lengthA' ;
  Alcotest.(check int) "shares are unique within B" lengthB lengthB' ;
  Alcotest.(check @@ neg @@ list string)
    "new shares are completely different from older ones"
    sortedA
    sortedB


let suite =
  [ ("shares validation and format", `Quick, __shares_validation)
  ; ("threshold must be in a safe basis", `Quick, __shares_threshold_failures)
  ; ("shares are random if generated again", `Quick, __shares_uniqueness)
  ]
