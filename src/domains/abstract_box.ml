open Bot
open Bound_sig
open Itv_sig
open Syntax
    
(*******************)
(* GENERIC FUNCTOR *)
(*******************)
  
module Box(I:ITV) = (struct


  (************************************************************************)
  (* TYPES *)
  (************************************************************************)


  (* interval and bound inheritance *)
  module I = I
  module B = I.B
  type bound = B.t
  type i = I.t

  (* maps from variables *)
  module Env = Mapext.Make(struct type t=var let compare=compare end)
      
  (* maps each variable to a (non-empty) interval *)
  type t = i Env.t

  (* boxes split along variables *)
  type split = var

  let find v a =
    try (Env.find v a, v) with
      Not_found -> (Env.find (v^"%") a, v^"%")
        
      
  (************************************************************************)
  (* PRINTING *)
  (************************************************************************)

  let print fmt a =
    let first = ref true in
    Env.iter
      (fun v i ->
	Format.fprintf fmt "%s%s:%a" 
	  (if !first then "" else " ") 
	  v
	  I.print i;
	first := false
      ) a

  let to_polygon a v1 v2 =
    let ((l1,h1), _),((l2,h2), _) = find v1 a, find v2 a in
    let l1,h1 = B.to_float_down l1, B.to_float_up h1
    and l2,h2 = B.to_float_down l2, B.to_float_up h2 in
    [l1,l2; h1,l2; h1,h2; l1,h2]

  let points_to_draw a = function
    | None -> to_polygon a (Env.min_binding a |> fst) (Env.max_binding a |> fst)
    | Some (v1,v2) -> to_polygon a v1 v2
        
      
  (************************************************************************)
  (* SET-THEORETIC *)
  (************************************************************************)
  (* NOTE: all binary operations assume that both boxes are defined on
     the same set of variables;
     otherwise, an Invalid_argument exception will be raised
   *)
 
  let join (a:t) (b:t) : t = 
    Env.map2z (fun _ x y -> I.join x y) a b
 
  (* predicates *)
  (* ---------- *)

  let is_bottom (a:t) =
    Env.exists (fun _ v -> I.check_bot v = Bot.Bot) a

  let subseteq (a:t) (b:t) : bool =
    Env.for_all2z (fun _ x y -> I.subseteq x y) a b
      
  (* mesure *)
  (* ------ *)
      
  (* diameter *)
  let diameter (a:t) : bound =
    Env.fold (fun _ x v -> B.max (I.range x) v) a B.zero

  (* variable with maximal range *)
  let max_range (a:t) : var * i =
    Env.fold
      (fun v i (vo,io) -> 
        if B.geq (I.range i) (I.range io) then v,i else vo,io
      ) a (Env.min_binding a)
      
  let is_small (a:t) (f:float) : (bool * split list)=
    let (v,i) = max_range a in
    (B.to_float_up (I.range i) <= f), [v]


  (* split *)
  (* ----- *)
  let is_integer var =
    var.[String.length var - 1] = '%'

  let filter_bounds (a:t) : t =
    let b = Env.mapi (fun v i -> 
		      if is_integer v then 
			match I.filter_bounds i with
			| Bot -> raise Bot_found
			| Nb e -> e
		      else 
			i
		     ) a in
    b

  let to_bot (a:I.t bot Env.t) : t bot =
    let is_bot = Env.exists (fun v i -> is_Bot i) a in
    if is_bot then Bot
    else Nb (Env.map (fun v -> match v with
    | Nb e -> e
    | _ -> failwith "should not occur"
    ) a)
      
  let filter_bounds_bot (a:t bot) : t bot =
    match a with
    | Bot -> Bot
    | Nb e -> Env.mapi (fun v i ->
      if is_integer v then I.filter_bounds i
      else Nb i
    ) e
    |> to_bot	      

  let split (a:t) (vars:var list) : t list =
    match vars with
    | [v] ->
      let (i, _) = find v a in
      let i_list = 
        if is_integer v then I.split_integer i (I.mean i) 
        else I.split i (I.mean i) 
      in
      List.fold_left (fun acc b -> 
	match b with
	| Nb e -> (Env.add v e a)::acc
	| Bot -> acc
      ) [] i_list
    | _ -> failwith "split need to be done on one variable"

  (************************************************************************)
  (* ABSTRACT OPERATIONS *)
  (************************************************************************)
        
  (* trees with nodes annotated with evaluation *)
  type bexpr =
    | BUnary of unop * bexpri
    | BBinary of binop * bexpri * bexpri
    | BVar of var
    | BCst of i
          
  and bexpri = bexpr * i

  (* interval evaluation of an expression;
     returns the interval result but also an expression tree annotated with
     intermediate results (useful for test transfer functions
     
     errors (e.g. division by zero) return no result, so:
     - we raies Bot_found in case the expression only evaluates to error values
     - otherwise, we return only the non-error values
   *)
  let rec eval (a:t) (e:expr) : bexpri =
    match e with
    | Var v ->
        let (r, n) =
          try find v a
          with Not_found -> failwith ("variable not found: "^v)
        in
        BVar n, r
    | Cst c ->
        let r = I.of_float c in
        BCst r, r
    | Unary (o,e1) -> 
        let _,i1 as b1 = eval a e1 in
        let r = match o with
        | NEG -> I.neg i1
	| ABS -> I.abs i1
        | SQRT -> debot (I.sqrt i1)
	| COS -> I.cos i1
	| SIN -> I.sin i1
        in
        BUnary (o,b1), r
    | Binary (o,e1,e2) ->
        let _,i1 as b1 = eval a e1
        and _,i2 as b2 = eval a e2 in
        let r = match o with
        | ADD -> I.add i1 i2
        | SUB -> I.sub i1 i2
        | DIV -> debot (fst (I.div i1 i2))
        | MUL -> 
            let r = I.mul i1 i2 in
            if e1=e2 then
              (* special case: squares are positive *)
              debot (I.meet r I.positive)
            else r
	| POW -> I.pow i1 i2
        in
        BBinary (o,b1,b2), r


  (* returns a box included in its argument, by removing points such that
     the evaluation is not in the interval;
     not all such points are removed, due to interval abstraction;
     iterating eval and refine can lead to better reults (but is more costly);
     can raise Bot_found *)
  let rec refine (a:t) (e:bexpr) (x:i) : t =
    match e with
    | BVar v -> 
        (try Env.add v (debot (I.meet x (fst (find v a)))) a
        with Not_found -> failwith ("variable not found: "^v))
    | BCst i -> ignore (debot (I.meet x i)); a
    | BUnary (o,(e1,i1)) ->
        let j = match o with
        | NEG -> I.filter_neg i1 x
        | ABS -> I.filter_abs i1 x
        | SQRT -> I.filter_sqrt i1 x
	| COS -> I.filter_cos i1 x
	| SIN -> I.filter_sin i1 x
        in
        refine a e1 (debot j)
    | BBinary (o,(e1,i1),(e2,i2)) ->
        let j = match o with
        | ADD -> I.filter_add i1 i2 x
        | SUB -> I.filter_sub i1 i2 x
        | MUL -> I.filter_mul i1 i2 x
        | DIV -> I.filter_div i1 i2 x
	| POW -> I.filter_pow i1 i2 x
        in
        let j1,j2 = debot j in
        refine (refine a e1 j1) e2 j2
          

  (* test transfer function *)
  let test (a:t) (e1:expr) (o:cmpop) (e2:expr) : t bot =
    let (b1,i1), (b2,i2) = eval a e1, eval a e2 in
    let j = match o with
    | EQ -> I.filter_eq i1 i2
    | LEQ -> I.filter_leq i1 i2
    | GEQ -> I.filter_geq i1 i2
    | NEQ -> I.filter_neq i1 i2
    (*| NEQ_INT -> I.filter_neq_int i1 i2*)
    | GT -> I.filter_gt i1 i2 
    (*| GT_INT -> I.filter_gt_int i1 i2*) 
    | LT -> I.filter_lt i1 i2
    (*| LT_INT -> I.filter_lt_int i1 i2*)
    in
    let aux = rebot 
      (fun a ->
        let j1,j2 = debot j in
        refine (refine a b1 j1) b2 j2
      ) a
    in
    filter_bounds_bot aux

  let rec meet (a:t) (b:Syntax.bexpr) : t = 
    match b with
    | And (b1,b2) -> meet (meet a b2) b1
    | Or (b1,b2) ->
      let a1 = try Some(meet a b1) with Bot.Bot_found -> None
      and a2 = try Some(meet a b2) with Bot.Bot_found -> None in
      (match (a1,a2) with
      | (Some a1),(Some a2) -> join a1 a2
      | None, (Some x) | (Some x), None -> x
      | _ -> raise Bot.Bot_found)
    | Not b -> meet a (neg_bexpr b)
    | Cmp (binop,e1,e2) ->
      (match test a e1 binop e2 with
      | Bot -> raise Bot_found
      | Nb e -> e)
	
  let of_problem (p:Syntax.prog) =
    let interval_of_domain dom =
      let open Syntax in
      match dom with
      | Finite(a,b) -> I.of_floats a b
      | Minf i -> I.of_bounds B.minus_inf (B.of_float_up i)
      | Inf i -> I.of_bounds (B.of_float_down i) B.inf
      | Top -> I.of_bounds B.minus_inf B.inf 
    in
    let abs = 
      List.fold_left (fun a (typ,var,dom) ->
        match typ with
	| INT -> Env.add (var^"%") (interval_of_domain dom) a
	| REAL -> Env.add var (interval_of_domain dom) a 
      ) Env.empty p.init
    in Format.printf "%a\n" print abs;
    abs

  let is_enumerated a =
    let int_vars = Env.filter (fun v i -> is_integer v) a in
    let is_e = Env.for_all (fun v i -> I.is_singleton i) int_vars in
    Env.cardinal int_vars = 0 || is_e
    
  let sat_cons (a:t) (constr:Syntax.bexpr) : bool =
    try is_bottom (meet a (Syntax.Not constr)) && is_enumerated a
    with Bot.Bot_found -> true

  let forward_eval abs cons =
    let (_, bounds) = eval abs cons in
    (B.to_float_down (fst bounds), B.to_float_up (snd bounds))

end)


    
(*************)
(* INSTANCES *)
(*************)
    
module BoxF = Box(Itv.ItvF)
