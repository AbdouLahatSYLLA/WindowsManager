open Base
type direction = Vertical | Horizontal [@@deriving show]
type window = Win of string * Color.t [@@deriving show]


type coordinate = Coord of {px: int; py: int; sx: int; sy: int} [@@deriving show]
type split = Split of direction * float (* ratio between 0 and 1 *) [@@deriving show]


let draw_win w coord (bc:Color.t) = let gray = Color.to_int(Color.from_rgb 0 0 0)  in match w with Win(str,color) ->  match coord with Coord{px;py;sx;sy} -> Graphics.set_text_size 25;
Graphics.set_color (Color.to_int color) ;Graphics.set_line_width 5; Graphics.fill_rect (px) (py) (sx - 4) (sy - 4) ;Graphics.set_color (Color.to_int bc);  Graphics.draw_rect (px) (py) (sx-3) (sy-3);  let a,b = (px+sx,py+sy ) in Graphics.moveto ((a+px) /2) ((b+py )/2);Graphics.set_color gray;Graphics.draw_string str;
type wmtree = ((split * coordinate), (window * coordinate)) Tree.t [@@deriving show]

type wmzipper = ((split * coordinate), (window * coordinate)) Tree.z [@@deriving show]

let get_coord (wt:wmtree) = match wt with Tree.Leaf(_,b) -> b | Tree.Node((_a,b),_,_)->b

let change_coord c (wt:wmtree) = match wt with Tree.Leaf(a,_) -> Tree.Leaf(a,c)| Tree.Node((a,_),l,r)->Tree.Node((a,c),l,r)

let rec draw_wmtree bc (wt:wmtree) = match wt with Tree.Leaf(w,c) -> draw_win w c bc | Tree.Node(_,l,r) -> draw_wmtree bc l ; draw_wmtree bc r  

let draw_wmzipper bc (wz:wmzipper) = match wz with Tree.TZ(_,s) -> draw_wmtree bc s

let rec update_coord c t =
let split_coord (Coord {px;py;sx;sy}) direction ratio = match direction with 
Vertical -> (Coord {px=px;py=py;sx=sx;sy=Int.of_float((Float.of_int sy *. ratio)) },Coord {px=px;py=py+(Int.of_float((Float.of_int (sy) *.ratio))  );sx=sx;sy=Int.of_float((Float.of_int sy) *. (1. -.ratio))})
|Horizontal -> (Coord {px=px;py=py;sx= Int.of_float (Float.of_int sx *. ratio);sy=sy},Coord { px=px+(Int.of_float((Float.of_int (sx) *.ratio)));py=py;sx=Int.of_float (Float.of_int sx *. (1. -.ratio));sy=sy}) in
  match change_coord c t with Tree.Leaf _ -> change_coord c t 
  | Tree.Node ((Split(direction,ratio),d),l,r) -> let c1,c2 = split_coord d direction ratio in 
                                                          Tree.Node((Split(direction,ratio),d),update_coord c1 l,update_coord c2 r)
