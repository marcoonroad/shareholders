(* hashing of secret *)

module BLAKE2B = Digestif.BLAKE2B

let __hash text = BLAKE2B.digest_string text

let hex_hash text = BLAKE2B.to_hex @@ __hash text

let raw_hash text = BLAKE2B.to_raw_string @@ __hash text

let __hmac key text = BLAKE2B.hmac_string ~key text

let raw_hmac key text = BLAKE2B.to_raw_string @@ __hmac key text

let hex_hmac key text = BLAKE2B.to_hex @@ __hmac key text
