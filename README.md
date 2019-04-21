shareholders
============

Secret Sharing/Splitting library for OCaml.

This cryptography abstraction is used when you have important secrets and want
to balance the trade-offs of _reliability/availability_ and _secrecy/privacy_. Do
you have to protect missile launch codes, your Bitcoin's private key of Satoshi's
public key or even a really deep love letter (or perhaps _all of them_)? No
problem, secret shares are the perfect solution for that!

Often employed on Secure Multiparty Computations, secret sharing mechanisms can
be used in various domains, such as online voting and credit card encryption on
your fintech's legacy database full of stored SQL procedures (don't even dare to
refactor that, million of dollars flow there in).

### Example

```ocaml
module Sh = Shareholders

let secret = "If this is really secret, it must not be committed on Git."

let threshold, amount = (100, 100)

let commitment, shares = Sh.share ~secret ~threshold ~amount

let secret' = Sh.recover ~commitment ~shares

let _ =
  assert (secret = secret') ;
  print_endline commitment
```

### Installation

Through OPAM (if available):

```shell
$ opam install shareholders
```

Locally (the development version):

```shell
$ opam install . --deps-only
$ dune install
```

### Disclaimer

Oh no, that boring disclaimer again. Well, let's keep going... So, in simpler
words, I'm not responsible for the damages that you could create either
accidentally or intentionally. Also, don't forget to check your country laws
regarding cryptography, all the problems you could have in your life by just
having the local government chasing you is just your own regards and not my
concerns (but I may pray for your luck besides).

### Remarks

Have fun! Pull-Requests and Issues are welcome. But remind that with great powers
come great responsibilities, don't abuse this power in the Black Market or even
in the ways of Script-kiddo attacks. I don't want to see your exploit listed on
CWE/CVE tomorrow, you have been warned -- otherwise I will reveal your Swiss bank
account.
