(* hashing of secret *)

module BLAKE2B = Digestif.BLAKE2B

let digest text = BLAKE2B.to_hex @@ BLAKE2B.digest_string text

let compute text = BLAKE2B.to_raw_string @@ BLAKE2B.digest_string text
