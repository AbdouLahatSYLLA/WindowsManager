open Base

type ('v, 'w) t =
  | Node of 'v * ('v,'w) t * ('v,'w) t
  | Leaf of 'w [@@deriving show]

let return w = Leaf w

let combine v l1 l2 = Node(v,l1,l2)

let%test "n" =
  let l1 = return 1 in
  let l2 = return 2 in
  let l3 = return 3 in
  let n1 = combine 4 l1 l2 in
  let n2 = combine 5 n1 l3 in
  Stdlib.(n2 = (Node(5,Node(4, Leaf 1, Leaf 2), Leaf 3)))

let is_leaf w = match w with Leaf _ -> true | _ -> false

let%test "leaf1" = is_leaf (Leaf 1)
let%test "leaf2" = is_leaf (Node (1, Leaf 1, Leaf 1)) |> not



let get_leaf_data  w = match w with Leaf x -> Some x | _ ->  None

let%test "gld1" =  match get_leaf_data (Leaf 1) with
  | None -> false
  | Some o -> Int.(o = 1)


let%test "gld2" = match get_leaf_data (Node (1, Leaf 2, Leaf 3)) with
  | None -> true
  | _ -> false


let get_node_data w = match w with Node(x,_,_) -> Some x | _ ->  None

let%test "gnd1" =  match get_node_data (Leaf 1) with
  | None -> true
  | _ -> false


let%test "gnd2" = match get_node_data (Node (1, Leaf 2, Leaf 3)) with
  | None -> false
  | Some o -> Int.(o = 1)


let rec map (f,g) d = match d with Leaf x -> Leaf (g x) | Node(x,y,z) -> Node(f x,map (f,g) y , map (f,g) z)

let%test "map" =
  let l1 = return 1 in
  let l2 = return 2 in
  let l3 = return 3 in
  let n1 = combine "four" l1 l2 in
  let n2 = combine "five" n1 l3 in
  let g x = x * 2 in
  let f x = x ^ x in
  let n3 = map (f,g) n2 in
  Stdlib.(n3 = (Node("fivefive",Node("fourfour", Leaf 2, Leaf 4), Leaf 6)))


let rec iter (f,g) d = match d with Leaf x -> g x | Node(x,y,z) -> f x ; iter (f,g) y ; iter (f,g) z  


type ('v, 'w) z = TZ of ('v,'w) context * ('v,'w) t
and ('v,'w) context =
  | Top
  | LNContext of 'v * ('v,'w) context * ('v,'w) t
  | RNContext of ('v,'w) t * 'v * ('v,'w) context [@@deriving show]



let from_tree d = TZ(Top,d) 



let change z s = match z with TZ (x,_) -> TZ(x,s)

let change_up z v = match z with TZ(Top,_) -> failwith "changing above root" | 
TZ(LNContext(_,b,c),s) -> TZ(LNContext(v,b,c),s)
|TZ(RNContext(a,_,c),s) -> TZ(RNContext(a,v,c),s)


let go_down z = match z with TZ(_,Leaf _) -> None | TZ(c,Node(x,y,z)) -> Some (TZ(LNContext(x,c,z),y)) 

let%test "gd1" =
  let l1 = return 1 in
  let l2 = return 2 in
  let l3 = return 3 in
  let n1 = combine "four" l1 l2 in
  let n2 = combine "five" n1 l3 in
  let z = from_tree n2 in
  match go_down z with
  | Some z' -> Stdlib.(z' = TZ (LNContext ("five", Top,Leaf 3),Node("four", Leaf 1, Leaf 2)))
  | None -> false

let%test "gd2" =
  let l1 = return 1 in
  let l2 = return 2 in
  let l3 = return 3 in
  let n1 = combine "four" l1 l2 in
  let n2 = combine "five" n1 l3 in
  let z = from_tree n2 in
  match Option.(Some z >>= go_down >>= go_down) with
  | Some z' -> Stdlib.(z' = TZ(LNContext("four", LNContext ("five", Top,Leaf 3), Leaf 2), Leaf 1))
  | None -> false


let%test "gd3" =
  let l1 = return 1 in
  let l2 = return 2 in
  let l3 = return 3 in
  let n1 = combine "four" l1 l2 in
  let n2 = combine "five" n1 l3 in
  let z = from_tree n2 in
  match Option.(Some z >>= go_down >>= go_down >>= go_down) with
  | Some _ -> false
  | None -> true

let go_up z = match z with TZ(Top,_) -> None 
|TZ(LNContext(a,b,c),l) -> Some (TZ(b,Node(a,l,c))) 
|TZ(RNContext(a,b,c),r) -> Some(TZ(c,Node(b,a,r)))


let%test "gu1" =
  let z = TZ(RNContext(Leaf 1, "four", LNContext ("five", Top,Leaf 3)), Leaf 2) in
  match go_up z with
  | Some z' -> Stdlib.(z' = TZ (LNContext ("five", Top,Leaf 3),Node("four", Leaf 1, Leaf 2)))
  | None -> false

let%test "gu2" =
  let z = TZ(RNContext(Leaf 1, "four", LNContext ("five", Top,Leaf 3)), Leaf 2) in
  match Option.(Some z >>= go_up >>= go_up) with
  | Some z' -> Stdlib.(z' = TZ( Top,  Node("five",Node("four", Leaf 1, Leaf 2), Leaf 3)))
  | None -> false

let%test "gu3" =
  let z = TZ(RNContext(Leaf 1, "four", LNContext ("five", Top,Leaf 3)), Leaf 2) in
  match Option.(Some z >>= go_up >>= go_up >>= go_up) with
  | Some _  -> false
  | None -> true

let go_left z = match z with TZ(Top,_) -> None 
|TZ(LNContext(_,_,_),_) -> None 
|TZ(RNContext(a,b,c),r) -> let ctx = LNContext(b,c,r) in  Some(TZ(ctx,a))

let%test "gl1" =
  let z = TZ(RNContext(Leaf 1, "four", LNContext ("five", Top,Leaf 3)), Leaf 2) in
  match go_left z with
  | Some z' -> Stdlib.(z' = TZ(LNContext("four", LNContext ("five", Top,Leaf 3), Leaf 2), Leaf 1))
  | None -> false

let%test "gl2" =
  let z = TZ(LNContext("four", LNContext ("five", Top,Leaf 3), Leaf 2), Leaf 1) in
  match go_left z with
  | Some _ -> false
  | None -> true

let go_right z = match z with TZ(Top,_) -> None 
|TZ(RNContext(_,_,_),_) -> None 
|TZ(LNContext(a,b,c),l) -> let ctx = RNContext(l,a,b) in  Some(TZ(ctx,c)) 


let%test "gr1" =
  let z = TZ(LNContext("four", LNContext ("five", Top,Leaf 3), Leaf 2), Leaf 1) in
  match go_right z with
  | Some z' -> Stdlib.(z' = TZ(RNContext(Leaf 1, "four", LNContext ("five", Top,Leaf 3)), Leaf 2))
  | None -> false

let%test "gl2" =
  let z = TZ(RNContext(Leaf 1, "four", LNContext ("five", Top,Leaf 3)), Leaf 2) in
  match go_right z with
  | Some _ -> false
  | None -> true


let rec reflexive_transitive f d = match f d with None ->  d | Some x -> reflexive_transitive f x

let%test "rf1" =
  let z = TZ(RNContext(Leaf 1, "four", LNContext ("five", Top,Leaf 3)), Leaf 2) in
  Stdlib.(reflexive_transitive go_up z = TZ( Top,  Node("five",Node("four", Leaf 1, Leaf 2), Leaf 3)))

let%test "rf2" =
  let z =   TZ(LNContext("four", LNContext ("five", Top,Leaf 3), Leaf 2), Leaf 1) in
  Stdlib.(reflexive_transitive go_up z = TZ( Top,  Node("five",Node("four", Leaf 1, Leaf 2), Leaf 3)))


let%test "rf3" =
  let z = TZ( Top,  Node("five",Node("four", Leaf 1, Leaf 2), Leaf 3)) in
  Stdlib.(reflexive_transitive go_up z = z)

let  focus_first_leaf t = reflexive_transitive go_down (from_tree t)


let%test "ffl1" =
  let t = Node("five",Node("four", Leaf 1, Leaf 2), Leaf 3) in
  Stdlib.(focus_first_leaf t = TZ(LNContext("four", LNContext ("five", Top,Leaf 3), Leaf 2), Leaf 1))


let remove_leaf z = match z with TZ(_,Node _) ->  None 
| TZ(LNContext(a,b,c),Leaf _) -> Some (TZ(b,c),a) 
| TZ(RNContext(a,b,c),Leaf _) -> Some (TZ(c,a),b)
| TZ(Top,_) -> None


let%test "rl1" =
  let z = TZ(LNContext("four", LNContext ("five", Top,Leaf 3), Leaf 2), Leaf 1) in
  match remove_leaf z with
  | None -> false
  | Some (z, v) -> Stdlib.((z = TZ (LNContext ("five", Top, Leaf 3), Leaf 2)) && (v="four"))


let%test "rl2" =
  let z = TZ (LNContext ("five", Top,Leaf 3),Node("four", Leaf 1, Leaf 2)) in
  match remove_leaf z with
  | None -> true
  | _ -> false


let is_left_context  z = match z with TZ(LNContext(_,_,_),_) -> true | _ -> false
let is_right_context z = match z with TZ(RNContext(_,_,_),_) -> true | _ -> false
let is_top_context   z = match z with TZ(Top,_) -> true | _ -> false

let rec move_until f p (z:('v,'w) z) = let (>>=) = Option.(>>=) in
  match p z  with true -> Some z | false ->  f z >>= (fun x -> move_until f p x)


let%test "mv1" =
  let z = TZ(LNContext("four", LNContext ("five", Top,Leaf 3), Leaf 2), Leaf 1) in
  let p = fun (TZ(_,s)) -> match get_node_data s with | None -> false | Some v -> String.(v = "five") in
  match move_until go_up p z with
  | None -> false
  | Some z -> Stdlib.(z = TZ( Top,  Node("five",Node("four", Leaf 1, Leaf 2), Leaf 3)))

let%test "mv2" =
  let z = TZ(LNContext("four", LNContext ("five", Top,Leaf 3), Leaf 2), Leaf 1) in
  let p = fun (TZ(_,s)) -> match get_node_data s with | None -> false | Some v -> String.(v = "four") in
  match move_until go_up p z with
  | None -> false
  | Some z -> Stdlib.(z = TZ (LNContext ("five", Top,Leaf 3),Node("four", Leaf 1, Leaf 2)))



let next_leaf z = let (>>=) = Option.(>>=) in 
let p = fun (TZ(_,s)) -> match get_leaf_data s with None -> false | _ -> true in
let fd = fun t -> match go_right t with None -> false | _ ->true in 
match  z with TZ(LNContext _,Leaf _) -> go_right z >>= (fun x -> move_until go_down p x)
|TZ(RNContext _ , Leaf _ ) -> move_until go_up fd z  >>= go_right >>= (fun x -> move_until go_down p x)
|TZ (_,_) -> move_until go_down p z




let%test "nl1" =
  let z = TZ(LNContext("four", LNContext ("five", Top,Leaf 3), Leaf 2), Leaf 1) in
  match next_leaf z with
  | None -> false
  | Some z -> Stdlib.(z = TZ(RNContext(Leaf 1, "four", LNContext ("five", Top,Leaf 3)), Leaf 2))

let%test "nl2" =
  let z = TZ(LNContext("four", LNContext ("five", Top,Leaf 3), Leaf 2), Leaf 1) in
  match Option.(Some z >>= next_leaf >>= next_leaf) with
  | None -> false
  | Some z -> Stdlib.(z = TZ (RNContext (Node ("four", Leaf 1, Leaf 2), "five", Top), Leaf 3))


let%test "nl3" =
  let z = TZ(LNContext("four", LNContext ("five", Top,Leaf 3), Leaf 2), Leaf 1) in
  match Option.(Some z >>= next_leaf >>= next_leaf >>= next_leaf) with
  | None -> true
  | _ -> false


let previous_leaf z = let (>>=) = Option.(>>=) in 
let p = fun (TZ(_,s)) -> match get_leaf_data s with None -> false | _ -> true in 
let fg = fun t -> match go_left t with None -> false | _ ->true in 
match  z with TZ(RNContext _,Leaf _) -> go_left z >>= (fun x -> move_until (fun x -> go_down x >>= go_right) p x)
|TZ(LNContext _ , Leaf _ ) ->  move_until go_up fg z >>= go_left >>= move_until (fun x -> go_down x >>= go_right) p 
|TZ (_,_) -> move_until (fun x -> go_left x >>= go_down) p z

let%test "pl1" =
  let z = TZ (RNContext (Node ("four", Leaf 1, Leaf 2), "five", Top), Leaf 3) in
  match previous_leaf z with
  | None -> false
  | Some z -> Stdlib.(z = TZ(RNContext(Leaf 1, "four", LNContext ("five", Top,Leaf 3)), Leaf 2))

let%test "pl2" =
  let z = TZ (RNContext (Node ("four", Leaf 1, Leaf 2), "five", Top), Leaf 3) in
  match Option.(Some z >>= previous_leaf >>= previous_leaf) with
  | None -> false
  | Some z -> Stdlib.(z = TZ(LNContext("four", LNContext ("five", Top,Leaf 3), Leaf 2), Leaf 1))


let%test "pl3" =
  let z = TZ (RNContext (Node ("four", Leaf 1, Leaf 2), "five", Top), Leaf 3) in
  match Option.(Some z >>= previous_leaf >>= previous_leaf >>= previous_leaf) with
  | None -> true
  | _ -> false
