open Syntax

exception Error of string

let err s = raise (Error s)

(* Type Environment *)
type tyenv = ty Environment.t

type subst = (tyvar * ty) list

let rec subst_type subst t = match t with 
    TyInt -> t
  | TyBool -> t
  | TyVar tv -> subst_type subst (List.assoc tv subst) 
                      (* (match subst with
                          [] -> t
                        | (tv', t') :: rest -> if tv = tv' then (subst_type subst t') else (subst_type rest t)
                      ) *)
  | TyFun (t1, t2) -> TyFun (subst_type subst t1, subst_type subst t2)
 
(* eqs_of_subst : subst -> (ty * ty) list
型代入を型の等式集合に変換 *)
let rec eqs_of_subst s = match s with
    [] -> []
  | (tv, ty) :: rest -> (TyVar tv, ty) :: (eqs_of_subst rest)

(* subst_eqs: subst -> (ty * ty) list -> (ty * ty) list
型の等式集合に型代入を適用 *)
let rec subst_eqs s eqs = match eqs with
    [] -> []
  | (t1, t2) :: rest -> (subst_type s t1, subst_type s t2) :: (subst_eqs s rest)

let rec unify l = match l with
    [] -> []
  | (t1, t2) :: rest -> if t1 = t2 then unify rest else 
                              (match (t1, t2) with
                                   (TyFun(t11, t12), TyFun(t21, t22)) -> unify ((t11, t21) :: (t12, t22) :: rest)
                                 | (TyVar tv, ty) 
                                     -> (tv, ty) :: (unify (subst_eqs [(tv, ty)] rest))
                                    (* -> List.map (subst_type [(tv, t2)]) (unify (List.map (subst_type [(tv, t2)]) rest)) *)
                                 | (_, _) -> err ("type error") 
                              )
  
let ty_prim op ty1 ty2 = match op with
    Plus -> (match ty1, ty2 with
                 TyInt, TyInt -> TyInt
               | _ -> err ("Argument must be of integer: +"))
  | Mult -> (match ty1, ty2 with
                 TyInt, TyInt -> TyInt
               | _ -> err ("Argument must be of integer: *"))
  | Lt -> (match ty1, ty2 with
                 TyInt, TyInt -> TyBool
               | _ -> err ("Argument must be of integer: <"))
  | _ -> err "Not Implemented!"

let rec ty_exp tyenv = function
    Var x ->
      (try Environment.lookup x tyenv with
          Environment.Not_bound -> err ("variable not bound: " ^ x))
  | ILit _ -> TyInt
  | BLit _ -> TyBool
  | BinOp (op, exp1, exp2) ->
      let tyarg1 = ty_exp tyenv exp1 in
      let tyarg2 = ty_exp tyenv exp2 in
        ty_prim op tyarg1 tyarg2
  | IfExp (exp1, exp2, exp3) ->
      let test1 = ty_exp tyenv exp1 in
      let test2 = ty_exp tyenv exp2 in
      let test3 = ty_exp tyenv exp3 in
        (match test1 with
            TyBool -> if test2 = test3 then test2 else err ("Both arguments must be same: if")
          | _ -> err ("Test expression must be boolean: if"))
  | LetExp (id, exp1, exp2) ->
      let value = ty_exp tyenv exp1 in
      ty_exp (Environment.extend id value tyenv) exp2
  | _ -> err ("Not Implemented!")

let ty_decl tyenv = function
    Exp e -> ty_exp tyenv e
  | _ -> err ("Not Implemented!")
  