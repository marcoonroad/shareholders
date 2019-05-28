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

let checksum, shares = Sh.share ~secret ~threshold ~amount

let secret' = Sh.recover ~checksum ~shares

let _ =
  assert (secret = secret') ;
  print_endline checksum
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

### How it works?

The Black Magic implemented here is not too complex. No prior advanced Math
background is required to understand that. Suppose:

```
  m    is the secret message
  r    is the matrix of random numbers
  o    is the xor operation on integer level (bitwise)
  n    is the number of shares to generate
  k    is the threshold of minimum shares needed to recover the secret
  c    is the checksum of the secret message
  H    is a strong/collision-resistant hash algorithm
```

The initial idea to generate our shares revolves around the relations about the
XOR operation (mainly the commutative and associative ones). It means that
the equations below help us:

```
        a o b = b o a
  (x o y) o z = x o (y o z)
        x o x = 0
        x o 0 = x
```

Said that, to build the shares from the secret, we just do for every character:

```
  m[i] = r[i][1] o r[i][2] o ... o r[i][k]
```

Where every element in this row of the matrix `r` is unique within this row and
also non-null (i.e, not zero). This is important when we use `k != n`. In this
case, we just add some redundancy here, in simpler words, we take a subset of
this matrix row at `i`, let's call this subset as `p[i]`. The length of `p[i]` will
be `n - k`. The subset `p[i]` contains random elements from `r[i]`, and the final shares are
the random permutation/"sorting" of the list concatenation of both of them.
Let's call the shares as `s`, so every secret character `m[i]` yields shares
pieces at `s[i]`.

```
  s[i] = Permute(Concat(r[i], p[i]))
```

To explain this idea graphically, we initially have (assume a threshold of 3 and
the secret length of 4):

   \* | s1 | s2 | s3
------|----|----|-----
 m[1] |  A |  B |  C
 m[2] |  D |  E |  F
 m[3] |  G |  H |  I
 m[4] |  J |  K |  L

Here, columns are shares and rows are the pieces which on applying XOR together,
we generate the secret character. Redundancy will be, therefore (assuming the
number of shares as 5):

   \* | s1 | s2 | s3 | s4    | s5
------|----|----|----|-------|-------
 m[1] |  A |  B |  C | **B** | **A**
 m[2] |  D |  E |  F | **F** | **E**
 m[3] |  G |  H |  I | **G** | **I**
 m[4] |  J |  K |  L | **J** | **K**

This setup is not "threshold-secure", tho. If one player quits the game, we have only 80%
of shares, it should work (in theory) with 60%, but due the "fairness" of
permutation, it won't. If either shareholder `s4` or `s5` quit the game, we
can recover the secret, but if either `s1`, `s2` or `s3` quit, we're doomed.
If `s1` quits, we lost `D`. If `s2` quits, we lost `H`. If `s3` quits, we lost
`C`.

During secret recovering, we just need to remove duplicate entries to generate
the secret back again. Taking the example above which duplicates don't cover the
missing pieces if someone quits, for that case we can use a checksum `c` of the
secret `m`:

```
  c = H(m)
```

This checksum ensures if we have recovered the original secret with success. It's
also possible to brute-force the missing pieces against the checksum, it's in the
roadmap of this library. To ensure that players will not collude to recover the
secret out this game, we can also encrypt their shares. The encryption key `Ek`
can be just the hash of the checksum `c`:

```
  Ek = H(c) = H(H(m))
```

And to avoid shareholders from adding noise in their own shares, we can sign
their shares in a "HMAC"/keyed-hash style (~~although I still not using HMAC,
I know, some hashes are weak against length-extension attacks, but it's not the
case for Blake2B - I guess~~ **update:** I'm already using Blake2B-HMAC for
standard compliance of HMAC algorithms):

```
  Hk = H(Ek) = H(H(c)) = H(H(H(m)))
```

Here, the `Hk` is our keyed-hash secret. To sign the encrypted shares, we just do:

```
  sig(s) = H(Hk, H(s))
```

Shares distributed (i.e, `sd`) are, therefore (assuming `#m` as the length of the
secret):

```
   d[i] = Ek(s[1][i] || s[2][i] || ... || s[#m][i])
  sd[i] = sig(d[i]) || d[i]
```

Where `||` stands for the string concatenation operator and `d[i]` is the
intermediary encrypted share.

So everything is complete to run the whole stuff. The `Share` operation yields
a checksum `c` and the complete list of shares `sd`. To recover the secret `m`,
we just call `Recover(c, sd')`. It fails if `sd'` doesn't comply with the threshold
used to generate the original shares set `sd`. The threshold `k` ensures a safe
subset relation between `sd'` (acquired shares during recover) and `sd` (shares
generated during secret split). There's still some probability of failing even
if threshold `k` passes, it's due the missing of both original and duplicate
share pieces, tho.

This scheme is also publicly verifiable in the sense that once you (as the dealer)
reveal the secret `m`, players/shareholders can verify their own signatures
without even need to run the recover algorithm again with the major number of
shares.

### Disclaimer

Oh no, that boring disclaimer again. Well, let's keep going... So, in simpler
words, I'm not responsible for the damages that you could create either
accidentally or intentionally by using this library. Also, don't forget to check
your country laws regarding cryptography, all the problems you could have in
your life by just having the local government chasing you is just your own
regards and not my concerns (but I may pray for your luck besides).

### Remarks

Have fun! Pull-Requests and Issues are welcome. But remind that with great powers
come great responsibilities, don't abuse this power in the Black Market or even
in the ways of Script-kiddo attacks. I don't want to see your exploit listed on
CWE/CVE tomorrow, you have been warned -- otherwise I will reveal your Swiss bank
account.
