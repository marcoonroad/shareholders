module Sh = Shareholders

let secret = "If this is really secret, it must not be committed on Git."

let threshold, amount = (100, 100)

let commitment, shares = Sh.share ~secret ~threshold ~amount

let secret' = Sh.recover ~commitment ~shares

let _ =
  assert (secret = secret') ;
  print_endline commitment
