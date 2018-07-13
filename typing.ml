open Syntax

exception Error of string

let err s = raise (Error s)

(* Type Environment *)
type tyenv = ty Environment.t

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