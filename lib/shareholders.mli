(**

   Secret Sharing/Splitting library for OCaml.
   @author Marco Aurélio da Silva
   @version 0.0.1

*)

(**

   Shareholders is a library for Multi-party Computations using Secret Sharing
   schemes. The actual implementation is based on One-Time PRNG Pads instead
   whole polynomials, but the security is roughly the same - in this case we
   depend on the security of the Nocrypto's PRNG implementation of Fortuna.

*)

val share :
  secret:string -> amount:int -> threshold:int -> string * string list
(**

   The setup operation to split the secret. The [threshold] must be at least 50% of
   the total [amount] of issued shares, and also must be below 128 to not break
   things - that is, we deal with characters under an 8-bits basis (upto 255).
   The result of this operation is the checksum of the message and the complete
   list of all issued shares.

   If the [threshold] is lower than the [amount], we can still rebuild the
   [secret] with some missing shares nevertheless - but keep in mind that we're
   {e speaking of probabilities} and sort of that, so sometimes it might fail
   if the provided shares can't fill all the gaps.

   @raise UnsafeSharesThreshold Raised when [threshold] is lower than 50% amount,
   higher than [amount], lower than 2 or higher than 128.

*)

val recover : checksum:string -> shares:string list -> string
(**

   The operation to be used on the reconstruction phase. Here, the dealer would
   take a list of secret [shares] and a [checksum] hash to validate that
   the reconstruction passes, that is, there's enough shares to rebuild the
   secret and no share was modified by the shareholders.

   @raise InvalidSharesFormat Raised when the shares are under an inconsistent
   format.

   @raise RecoverChecksumMismatch Raised when the recover phase fails.

*)

(**

   Exception thrown when the recover phase fails.

*)
exception RecoverChecksumMismatch

(**

   Exception thrown when the threshold is an unsafe number.

*)
exception UnsafeSharesThreshold

(**

   Exception thrown when the shares are under an invalid format.

*)
exception InvalidSharesFormat
