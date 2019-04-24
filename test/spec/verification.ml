module Sh = Shareholders
module List = Core.List

(*

  It's impossible for you folks to know my secret crush in this cry of love.
  It's BLAKE2B! It's far more easy to become rich and powerful.

*)
let _SECRET =
  "42eebafdd403af4dcb441bf1b41f7775f2114a13ff5223c1a3cd1be0ed1db1c0ddbfa0b8a75d2276d1fc65b40bf6aa091e9853f7f12e33cb87a1a0557b30ac48"


let __successful_verify () =
  let amount, threshold = (8, 8) in
  let _, shares = Sh.share ~secret:_SECRET ~amount ~threshold in
  let procedure share =
    let verification = Sh.verify ~secret:_SECRET ~share in
    Alcotest.(check bool) "secret generated this share" true verification
  in
  List.iter ~f:procedure shares


let __failed_verify () =
  let secret = "Nobody will save you but yourself." in
  let amount, threshold = (3, 3) in
  let _, shares = Sh.share ~secret ~threshold ~amount in
  let procedureA share =
    let ok = Sh.verify ~secret:_SECRET ~share in
    Alcotest.(check bool) "secret doesn't generated that share" false ok
  in
  List.iter ~f:procedureA shares ;
  let procedureB () =
    ignore @@ Sh.verify ~secret ~share:"Invalid share data!"
  in
  let reason = Sh.InvalidSharesFormat in
  Alcotest.check_raises "breaks on invalid shares" reason procedureB


let suite =
  [ ("succeeds if share was made from secret", `Quick, __successful_verify)
  ; ("fails if share was made by other secret", `Quick, __failed_verify)
  ]
