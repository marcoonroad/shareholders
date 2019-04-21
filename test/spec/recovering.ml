module Sh = Shareholders
module List = Core.List

let _SECRET =
  "Elon Musk is Satoshi Nakamoto, he plans to buy Twitter Co. with Bitcoins."


let __secret_recovering () =
  let amount, threshold = (20, 20) in
  let commitment, shares = Sh.share ~secret:_SECRET ~threshold ~amount in
  let secret' = Sh.recover ~commitment ~shares in
  Alcotest.(check string) "both secret strings match" _SECRET secret'


let __secret_recovering_failing () =
  let amount, threshold = (32, 32) in
  let commitment, shares = Sh.share ~secret:_SECRET ~threshold ~amount in
  let shares' = List.tl_exn @@ List.permute shares in
  let reason = Sh.RecoverChecksumMismatch in
  let procedure () = ignore @@ Sh.recover ~commitment ~shares:shares' in
  Alcotest.check_raises "secrets don't match" reason procedure


let __secret_recovering_format () =
  let commitment = "deadbeef" in
  let shares =
    [ "This is clearly not a valid Base-64 data."
    ; "I mean, this is not fun to test every f#&$ing thing!"
    ]
  in
  let reason = Sh.InvalidBase64Data in
  let procedure () = ignore @@ Sh.recover ~commitment ~shares in
  Alcotest.check_raises "invalid base-64 shares" reason procedure


let suite =
  [ ("always completes if threshold = amount", `Quick, __secret_recovering)
  ; ( "fails if missing shares on threshold = amount"
    , `Quick
    , __secret_recovering_failing )
  ; ("fails on invalid shares format", `Quick, __secret_recovering_format)
  ]
