(* random number generation *)

module List = Core.List
module Int = Core.Int
module Random = Core.Random

(* avoids generation of zero to not break things on XOR *)
let byte () = 1 + Nocrypto.Rng.Int.gen 255

(* TODO: review security of that *)
let permute list =
  let seed = Nocrypto.Rng.Int.gen_bits 31 in
  Random.init seed ;
  List.permute list


(* avoids collision of random numbers *)
let rec __unique_random list =
  let random = byte () in
  if List.mem ~equal:Int.( = ) list random
  then __unique_random list
  else random


let _ =
  Core.Random.self_init () ;
  Nocrypto_entropy_unix.initialize ()
