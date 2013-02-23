(* utilities *)

let test_bit n x = 
  Int32.logand (Int32.shift_right_logical x n) Int32.one = Int32.one
let clear_bit n x =
  Int32.logand x (Int32.lognot (Int32.shift_left Int32.one n))
let set_bit n x = 
  Int32.logor x (Int32.shift_left Int32.one n)
let bit (x : int32) (n : int) (v : bool) : int32 = 
  if v then set_bit n x else clear_bit n x

let mac_of_bytes (str:string) : int64 = 
  let str = Format.sprintf "\x00\x00%s" str in 
  if String.length str != 8 then
    raise (Invalid_argument "mac_of_bytes expected eight-byte string");
  let n = ref 0L in
  for i = 0 to 7 do
    let b = Int64.of_int (Char.code (String.get str i)) in
    n := Int64.logor !n (Int64.shift_left b (8 * i))
  done;
  !n  

let get_byte (n:int64) (i:int) : char = 
  if i < 0 or i > 5 then
    raise (Invalid_argument "Int64.get_byte index out of range");
  let n = Int64.to_int (Int64.logand 0xFFL (Int64.shift_right_logical n (8 * i))) in 
  Char.chr n

let bytes_of_mac (x:int64) : string = 
  Format.sprintf "%c%c%c%c%c%c"
    (get_byte x 5) (get_byte x 4) (get_byte x 3)
    (get_byte x 2) (get_byte x 1) (get_byte x 0)

module type SAFESOCKET = sig
  type t = Lwt_unix.file_descr
  val create : Lwt_unix.file_descr -> t
  val recv : t -> string -> int -> int -> bool Lwt.t
end

module SafeSocket : SAFESOCKET = struct
  open Lwt
  open Lwt_unix

  type t = Lwt_unix.file_descr

  let create fd = fd

  let rec recv fd buf off len = 
    if len = 0 then 
      return true
    else 
      lwt n = Lwt_unix.recv fd buf off len [] in  
      if n = 0 then 
	return false
      else if n = len then 
	return true
      else
	recv fd buf (off + n) (len - n)
end
