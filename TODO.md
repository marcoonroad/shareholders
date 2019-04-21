TODO
====

- [x] Secret Sharing on string-level (either plain-text or binary).
- [x] Checksum using a strong hashing algorithm.
- [x] Base-64 encoding of shares.
- [x] Implement threshold for secret recovering.
- [ ] Encrypt the shares with the private checksum to avoid colluding attacks.
- [ ] Perform XOR on random streams instead of random characters (implies unlimited
  number of shares and threshold).
- [ ] Command-line interface.
- [ ] Security analysis, review and audit of this kind of Secret Sharing scheme.
