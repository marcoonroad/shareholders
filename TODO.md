TODO
====

- [x] Secret Sharing on string-level (either plain-text or binary).
- [x] Checksum using a strong hashing algorithm.
- [x] Base-64 encoding of shares.
- [x] Implement threshold for secret recovering.
- [x] Encrypt the shares with the private checksum to avoid colluding attacks.
- [ ] Perform XOR on random streams instead of random characters (implies unlimited
  number of shares and threshold).
- [ ] Command-line interface.
- [ ] Security analysis, review and audit of this kind of Secret Sharing scheme.
- [ ] `Verify` operation which takes the message `secret` and a single `share` to
  validate that either the `share` was recovered by the shares or the dealer
  leaked the secret outside this Secret Sharing scheme.
- [ ] Higher-level encryption using random key. This encryption generates this
  random key on-the-fly, encrypts the message, generates shares for this random
  key and destroys that key after. The output of this encryption will be the
  cipher / encrypted text and the shares of the random key.
