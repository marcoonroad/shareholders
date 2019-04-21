module Sh = Shareholders

let secret = "If this is really secret, it must not be committed on Git."

let threshold, amount = (100, 100)

let checksum, shares = Sh.share ~secret ~threshold ~amount

let secret' = Sh.recover ~checksum ~shares

let _ =
  assert (secret = secret') ;
  print_endline checksum
