open Base
open Stdio

open Ocamlwm23


let main () =
  let width = 640 in
  let height = 480 in
  let default_ratio = 0.5 in

  let active_color = Color.white in
  let inactive_color = Color.black in

  (* never increase ration above 0.95 or decrease below 0.05 *)
  let inc_ratio ratio = Float.min 0.95 (ratio +. 0.05) in
  let dec_ratio ratio = Float.max 0.05 (ratio -. 0.05) in
  (* create a new window *)
  let init_win count () =
    let w = Wm.Win("W" ^ (Int.to_string count), Color.random ()) in
    let c = Wm.Coord {px=0; py=0; sx=width;sy=height} in
    Tree.return  (w,c)  |> Tree.focus_first_leaf
  in

  (* create the canvas to draw windows *)
  let f = Printf.sprintf " %dx%d" width height in
  let () = Graphics.open_graph f in


  (* event loop *)
  let rec loop oz count =
    (match oz with
     | None -> Stdio.printf "\nZERO WINDOW\n%!"
     | Some z -> Stdio.printf "\n%s\n%!" (Wm.show_wmzipper z)
    );

    match Graphics.read_key () with
    | 'q' ->
      Stdio.printf "Total number of created windows: %d\nBye\n%!" count;
      raise Caml.Exit
    | 'h' ->
      Stdio.printf "\nhorizontal\n%!";
      begin
        let newzipoption = let (>>=) = Option.(>>=) in 
        match oz with None -> Option.return (init_win count ()) >>= (fun x -> Wm.draw_wmzipper active_color x;Option.return x)
        | _ ->  begin 
          let snd = fun (Tree.TZ(_,b)) -> b in 
          oz >>= (fun x -> Option.return (snd x)) >>= (fun y-> Option.return (Wm.update_coord (Wm.get_coord y) (Tree.combine (Wm.Split(Wm.Horizontal,default_ratio),Wm.get_coord y) (y) (snd (init_win count ()))))) >>=
        (fun z -> oz >>=(fun w -> Option.return (Tree.change w z) )) >>= (fun x ->  Wm.draw_wmzipper inactive_color x ; Option.return x) >>=
        Tree.go_down >>=Tree.go_right>>=
         (fun x -> Wm.draw_wmzipper active_color x ; Option.return x) 
        end
         in(* compute new zipper after insertion  *)
        (); (* update display *)
        loop newzipoption (count+1) (* loop *)
      end

    | 'v' ->
      Stdio.printf "\nvertical\n%!";
      begin
        let newzipoption = let (>>=) = Option.(>>=) in 
        match oz with None -> Option.return (init_win count ()) >>= (fun x -> Wm.draw_wmzipper active_color x;Option.return x)
        | _ ->  begin 
          let snd = fun (Tree.TZ(_,b)) -> b in 
          oz >>= (fun x -> Option.return (snd x)) >>= (fun y-> Option.return (Wm.update_coord (Wm.get_coord y) (Tree.combine (Wm.Split(Wm.Vertical,default_ratio),Wm.get_coord y) (y) (snd (init_win count ()))))) >>=
        (fun z -> oz >>=(fun w -> Option.return (Tree.change w z) )) >>= (fun x ->  Wm.draw_wmzipper inactive_color x ; Option.return x) >>=
        Tree.go_down >>=Tree.go_right>>=
         (fun x -> Wm.draw_wmzipper active_color x ; Option.return x) 
        end
         in(* compute new zipper after insertion  *)
        (); (* update display *)
        loop newzipoption (count+1) (* loop *)
      end

    | 'n' ->
      Stdio.printf "\nnext\n%!";
      begin
        let newzipoption = let (>>=) = Option.(>>=) in 
        oz>>=(fun x -> Wm.draw_wmzipper inactive_color x; Option.return x) >>=Tree.next_leaf>>=(fun x -> Wm.draw_wmzipper active_color x ;Option.return x) in 
        ();
        loop newzipoption (count)
      end
    | 'p' ->
      Stdio.printf "\nprevious\n%!";
      begin
        let newzipoption = let (>>=) = Option.(>>=) in 
        oz>>=(fun x -> Wm.draw_wmzipper inactive_color x; Option.return x) >>=Tree.previous_leaf>>=(fun x -> Wm.draw_wmzipper active_color x ;Option.return x) in 
        ();
        loop newzipoption (count)
      end
    | '+' ->
      Stdio.printf "\nincrement size\n%!";(*(direction,ratio)* coordinate*)
      begin
        let (>>=) = Option.(>>=) in let return = Option.return in
        let parent z = Tree.remove_leaf z in
        let snd_z = fun (Tree.TZ(_,b)) -> b in 
        let update_ratio (z:Wm.wmzipper) = match (Tree.is_right_context z) with true -> 
          begin 
          parent z >>= (fun x ->  return (snd x)) >>= (fun x -> match x with ((Wm.Split(a,b),c)) -> return (Wm.Split(a,dec_ratio b),c) )  
          end
        |false -> 
          begin 
          parent z >>= (fun x ->  return (snd x)) >>= (fun x -> match x with ((Wm.Split(a,b),c)) -> return (Wm.Split(a,inc_ratio b),c) )
          end in
        let curr_win = oz>>=(fun x -> Tree.get_leaf_data (snd_z x)) >>= (fun x -> match fst x with Wm.Win(a,_) -> return a) in
        let win = Option.value_exn curr_win in 
        let check = fun (Tree.TZ(_,s)) -> match s with Node _ -> false | Leaf (Wm.Win(x,_),_) -> if String.(win = x) then true else false in
        let newzipoption = 
        oz>>=update_ratio>>=(fun x -> oz >>=(fun y -> return (Tree.change_up y x)))>>=Tree.go_up>>=(fun x -> let wtree = snd_z x in let w = (Wm.update_coord (Wm.get_coord wtree) (wtree)) in return (Tree.change x w)) >>=
        (fun x -> Wm.draw_wmzipper inactive_color x; return x) >>= Tree.move_until Tree.next_leaf check >>= (fun x -> Wm.draw_wmzipper active_color x ; return x)
      in
      ();
      loop newzipoption (count)
      end
    | '-' ->
      Stdio.printf "\ndecrement size\n%!";
      begin
        let (>>=) = Option.(>>=) in let return = Option.return in
        let parent z = Tree.remove_leaf z in
        let snd_z = fun (Tree.TZ(_,b)) -> b in 
        let update_ratio (z:Wm.wmzipper) = match (Tree.is_right_context z) with true -> 
          begin 
          parent z >>= (fun x ->  return (snd x)) >>= (fun x -> match x with ((Wm.Split(a,b),c)) -> return (Wm.Split(a,inc_ratio b),c) )  
          end
        |false -> 
          begin 
          parent z >>= (fun x ->  return (snd x)) >>= (fun x -> match x with ((Wm.Split(a,b),c)) -> return (Wm.Split(a,dec_ratio b),c) )
          end in
        let curr_win = oz>>=(fun x -> Tree.get_leaf_data (snd_z x)) >>= (fun x -> match fst x with Wm.Win(a,_) -> return a) in
        let win = Option.value_exn curr_win in 
        let check = fun (Tree.TZ(_,s)) -> match s with Node _ -> false | Leaf (Wm.Win(x,_),_) -> if String.(win = x) then true else false in
        let newzipoption = 
        oz>>=update_ratio>>=(fun x -> oz >>=(fun y -> return (Tree.change_up y x)))>>=Tree.go_up>>=(fun x -> let wtree = snd_z x in let w = (Wm.update_coord (Wm.get_coord wtree) (wtree)) in return (Tree.change x w)) >>=
        (fun x -> Wm.draw_wmzipper inactive_color x; return x) >>= Tree.move_until Tree.next_leaf check >>= (fun x -> Wm.draw_wmzipper active_color x ; return x)
      in
      ();
      loop newzipoption (count)
      end

    | 'r' ->
      Stdio.printf "\nremove\n%!";
      begin
        let coord_init = Wm.Coord{px=0;py=0;sx=Graphics.size_x ();sy=Graphics.size_y ()}in
        let return = Option.return in 
        let (>>=) = Option.(>>=) in
        let snd_z = fun (Tree.TZ(_,b)) -> b in 
        let p = fun (Tree.TZ(_,s)) -> match Tree.get_leaf_data s with None -> false | _ -> true in
        let swap z v =  match z with 
        Tree.TZ(Tree.Top,Tree.Node((a,_),l,r)) ->  Tree.TZ(Tree.Top,Tree.Node((a,coord_init),l,r)) |  
        Tree.TZ(Tree.Top,Tree.Leaf _) ->  Tree.TZ(Tree.Top,Wm.change_coord coord_init (snd_z z)) |
        Tree.TZ(Tree.LNContext((a,_),Tree.Top,x),y) ->  Tree.TZ(Tree.LNContext((a,coord_init),Tree.Top,x),y)
        |Tree.TZ(Tree.RNContext(x,(a,_),Tree.Top),y) -> Tree.TZ(Tree.RNContext(x,(a,coord_init),Tree.Top),y)|
        Tree.TZ(_,_) -> Tree.change_up z v 
       in
        let update_zipper z = let zipper = snd_z z in let coords =  Wm.get_coord (snd_z z) in return (Tree.change z (Wm.update_coord coords zipper)) in 
        let newzipoption =oz>>=Tree.remove_leaf>>=
        (fun x -> return (swap (fst(x)) (snd(x)),snd(x)) ) >>=(fun x -> Tree.move_until Tree.next_leaf  p (fst(x)) >>=( fun y -> Tree.get_leaf_data (snd_z y))  >>= (fun z -> match (fst z) with Wm.Win(a,_) -> return ((fst(x)),a)))>>=
        (fun x -> Tree.move_until Tree.go_up Tree.is_top_context (fst(x)) 
        >>= (fun y -> return (y,snd(x)))) >>= (fun x -> update_zipper (fst(x)) >>= (fun y -> return (y,snd(x)))) 
        >>= ( fun x -> Wm.draw_wmzipper inactive_color (fst x) ; return x ) >>= 
        (fun x -> Tree.move_until Tree.next_leaf  (fun (Tree.TZ(_,s)) -> match s with Node _ -> false | Leaf (Wm.Win(y,_),_) -> if String.(snd(x) = y) then true else false) (fst(x)) )
        >>= (fun x -> Wm.draw_wmzipper active_color x ; return x)
        
      in 
      ();
      loop newzipoption (count)
      end
    | c ->
      printf "cannot process command '%c'\n%!" c;
      loop oz count

  in
  try
    loop None 0
  with
  | Stdlib.Exit -> ()

let () = main ()
