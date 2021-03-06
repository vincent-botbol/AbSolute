(* Module that handles solution of the abstract solver *)

(* the abstract result type we'll be manipulating *)
type 'a t = {
  sure       : 'a list;   (* elements that satisfy the constraints *)
  unsure     : 'a list;   (* elements that MAY satisfy the constraints *)
  nb_sure    : int;       (* size of sure list *)
  nb_unsure  : int;       (* size of unsure list *)
  vol_sure   : float;     (* volume of the elements in the sure list *)
  vol_unsure : float;     (* volume of the elements in the unsure list *)
  nb_steps   : int        (* number of steps of the solving process *)
}

(* the empty result *)
let empty_res = {
  sure       = [];
  unsure     = [];
  nb_sure    = 0;
  nb_unsure  = 0;
  vol_sure   = 0.;
  vol_unsure = 0.;
  nb_steps   = 0
}

  (* adds an unsure element to a result *)
let add_u res u v =
  {res with unsure=(u::res.unsure); nb_unsure=res.nb_unsure+1; vol_unsure=res.vol_unsure+.v}

  (* adds a sure element to a result *)
let add_s res s v=
  {res with sure=(s::res.sure); nb_sure=res.nb_sure+1; vol_sure=res.vol_sure+.v}

  (* tests if a result can't be splitted anymore *)
let stop res abs =
  res.nb_sure + res.nb_unsure > !Constant.max_sol
  || res.nb_steps > !Constant.max_iter

(* prints a result *)
let print fmt res =
  Format.fprintf fmt "\n#inner boxes: %d\n#boundary boxes: %d\n#created nodes: %d\n\ninner volume = %f\nboundary volume = %f\ntotal volume = %f%!\n"
    res.nb_sure
    (if !Constant.sure then 0
     else res.nb_unsure)
    res.nb_steps
    res.vol_sure
    (if !Constant.sure then 0.
     else res.vol_unsure)
    (if !Constant.sure then res.vol_sure
     else res.vol_sure +. res.vol_unsure)
