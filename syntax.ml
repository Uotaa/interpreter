(* ML interpreter / type reconstruction *)
type id = string

type binOp = Plus | Mult | Lt | Eq

type binLogOp = And | Or

type exp =
  | Var of id (* Var "x" --> x *)
  | ILit of int (* ILit 3 --> 3 *)
  | BLit of bool (* BLit true --> true *)
  | BinOp of binOp * exp * exp
  (* BinOp(Plus, ILit 4, Var "x") --> 4 + x *)
  | BinLogOp of binLogOp * exp * exp
  | IfExp of exp * exp * exp
  (* IfExp(BinOp(Lt, Var "x", ILit 4), 
           ILit 3, 
           Var "x") --> 
     if x<4 then 3 else x *)
  | LetExp of id * exp * exp
  | FunExp of id * exp
  | AppExp of exp * exp
  | LetRecExp of id * id * exp * exp

type program = 
    Exp of exp
  | Decl of id * exp
  | RecDecl of id * id * exp
  | MultiDecl of id * exp * program
  
type tyvar = int

type ty =
    TyInt
  | TyBool
  | TyVar of tyvar
  | TyFun of ty * ty

let pp_ty = function
    TyInt -> print_string "int"
  | TyBool -> print_string "bool"
  | TyVar tv -> print_string " tyvar "
  | TyFun (t1, t2) -> print_string " tyfun "

let fresh_tyvar = 
  let counter = ref 0 in
  let body () =
    let v = !counter in
      counter := v + 1; v
    in body

let rec freevar_ty ty = match ty with
    TyInt -> MySet.empty
  | TyBool -> MySet.empty
  | TyVar tv -> MySet.singleton tv
  | TyFun (t1, t2) -> MySet.union (freevar_ty t1) (freevar_ty t2)