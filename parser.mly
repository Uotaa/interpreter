%{
open Syntax
%}

%token LPAREN RPAREN SEMISEMI
%token PLUS MULT LT
%token IF THEN ELSE TRUE FALSE
%token LET IN EQ
%token RARROW FUN
%token REC
%token ANDAND OROR

%token <int> INTV
%token <Syntax.id> ID

%start toplevel
%type <Syntax.program> toplevel
%%

toplevel :
    e=Expr SEMISEMI { Exp e }
  | LET x=ID EQ e=Expr SEMISEMI { Decl (x, e) }
  | LET REC x=ID y=ID EQ e=Expr SEMISEMI { RecDecl (x, y, e) }

Expr :
    e=IfExpr { e }
  | e=LetExpr { e }
  | e=OrExpr { e }
  | e=FunExpr { e }
  | e=LetRecExpr { e }

LetExpr :
    LET x=ID EQ e1=Expr IN e2=Expr { LetExp (x, e1, e2) }

OrExpr : 
    e1=OrExpr OROR e2=AndExpr { BinOp (Or, e1, e2) }
  | e=AndExpr { e }

AndExpr : 
    e1=AndExpr ANDAND e2=EqExpr { BinOp (And, e1, e2) }
  | e=EqExpr { e }

EqExpr : 
    l=EqExpr EQ r=LTExpr { BinOp (Eq, l, r) }
  | e=LTExpr { e }

LTExpr : 
    l=PExpr LT r=PExpr { BinOp (Lt, l, r) }
  | e=PExpr { e }

PExpr :
    l=PExpr PLUS r=MExpr { BinOp (Plus, l, r) }
  | e=MExpr { e }

MExpr : 
    e1=MExpr MULT e2=AppExpr { BinOp (Mult, e1, e2) }
  | e=AppExpr { e }

AppExpr :
    e1=AppExpr e2=AExpr { AppExp (e1, e2) }
  | e=AExpr { e }

AExpr :
    i=INTV { ILit i }
  | TRUE   { BLit true }
  | FALSE  { BLit false }
  | i=ID   { Var i }
  | LPAREN e=Expr RPAREN { e }

IfExpr :
    IF c=Expr THEN t=Expr ELSE e=Expr { IfExp (c, t, e) }

FunExpr :
    FUN x=ID RARROW e=Expr { FunExp (x, e) }

LetRecExpr :
    LET REC x=ID y=ID EQ e1=Expr IN e2=Expr { LetRecExp (x, y, e1, e2) }