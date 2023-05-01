(** Color abstraction for our window manager.
    Can provide back and forth operations with RGB and internal representations
*)

open Base

type t = Int.t [@@deriving show]

let from_rgb r g b = 
  let color = (Int.shift_left r 16) + (Int.shift_left g 8) + b in color

let to_rgb t = 
let r = Int.shift_right (Int.bit_and t (Int.shift_left 255 16)) 16 in
let g = Int.shift_right (Int.bit_and t (Int.shift_left 255 8)) 8 in 
let b = Int.bit_and t 255 in (r,g,b)

let to_int t  = t

let inverse t = let (r,g,b) = to_rgb t in from_rgb (255 -r) (255 - g) (255 - b)

let random () = let r = Random.int 256 in let g = Random.int 256  in let b = Random.int 256  in from_rgb r g b


(** add 2 color component-wise: *)
(** the result is a valid color  *)
let (+) c1 c2 = let (r,g,b) = to_rgb c1 in let (r',g',b') = to_rgb c2 in 
from_rgb (Int.clamp_exn (r+r') ~min:0 ~max:255) (Int.clamp_exn (g+g') ~min:0 ~max:255) (Int.clamp_exn (b+b') ~min:0 ~max:255)

let white = from_rgb 255 255 255
let black = from_rgb 0 0 0
let red   = from_rgb 255 0 0
let green = from_rgb 0 255 0
let blue  = from_rgb 0 0 255


let%test "idint" =
  let c = random () in
  to_int c = c

let%test "idrgb" =
  let c = random () in
  let (r,g,b) = to_rgb c in
  from_rgb  r g b = c

let%test "white" =
  let (r,g,b) = to_rgb white in
  (r = 255) && (g=255) && (b=255)

let%test "black/white" = white = inverse black

let%test "whitecolors" = (red + green + blue) = white

let%test "addwhite" =
  white = white + white
