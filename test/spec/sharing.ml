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


let _SECRET_SIZE = String.length _SECRET

let __shares_validation () =
  let _, shares = Sh.share ~secret:_SECRET ~threshold:10 ~amount:15 in
  let validation share =
    let decoded = ShEnc.decode share in
    Alcotest.(check int)
      "valid share size"
      (String.length decoded)
      _SECRET_SIZE
  in
  List.iter ~f:validation shares ;
  Alcotest.(check int) "valid shares size" (List.length shares) 15


let __shares_threshold_failures () =
  let reason = Sh.UnsafeSharesThreshold in
  let procedureA () =
    ignore @@ Sh.share ~secret:_SECRET ~amount:40 ~threshold:10
  in
  let procedureB () =
    ignore @@ Sh.share ~secret:_SECRET ~amount:200 ~threshold:150
  in
  Alcotest.check_raises "threshold lower than 50%" reason procedureA ;
  Alcotest.check_raises "threshold greater than 128 shares" reason procedureB


let suite =
  [ ("shares validation and format", `Quick, __shares_validation)
  ; ("threshold must be in a safe basis", `Quick, __shares_threshold_failures)
  ]
