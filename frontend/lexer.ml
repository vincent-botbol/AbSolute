# 2 "frontend/lexer.mll"
 
 open Lexing
 open Syntax
 open Parser


(* keyword table *)
let kwd_table = Hashtbl.create 10
let _ = 
  List.iter (fun (a,b) -> Hashtbl.add kwd_table a b)
    [
      "init",           TOK_INIT;
      "constraints",    TOK_CONSTR;
      "sqrt",           TOK_SQRT;
      "cos",            TOK_COS;
      "sin",            TOK_SIN;
      "int",            TOK_INT;
      "real",           TOK_REAL
   ]


(* (exact) parsing of decimal constants constants *)
let parse_const c =
  let rec div10 x n =
    if n <= 0 then x else div10 (x /. (float_of_int 10)) (n-1)
  in
  try
    let p = String.index c '.' in
    let p' = String.length c - p - 1 in
    let x = (String.sub c 0 p)^(String.sub c (p+1) p') in
    div10 (float_of_string x) p'
  with Not_found ->
    float_of_string c

# 37 "frontend/lexer.ml"
let __ocaml_lex_tables = {
  Lexing.lex_base = 
   "\000\000\227\255\002\000\007\000\229\255\078\000\090\000\013\000\
    \020\000\002\000\003\000\031\000\033\000\106\000\244\255\106\000\
    \246\255\247\255\248\255\249\255\250\255\251\255\252\255\253\255\
    \254\255\127\000\255\255\008\000\231\255\240\255\239\255\238\255\
    \237\255\235\255\234\255\117\000\217\000\176\000\002\000\253\255\
    \254\255\049\000\255\255";
  Lexing.lex_backtrk = 
   "\255\255\255\255\027\000\026\000\255\255\255\255\023\000\255\255\
    \255\255\022\000\019\000\014\000\013\000\012\000\255\255\010\000\
    \255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
    \255\255\000\000\255\255\025\000\255\255\255\255\255\255\255\255\
    \255\255\255\255\255\255\023\000\023\000\255\255\002\000\255\255\
    \255\255\001\000\255\255";
  Lexing.lex_default = 
   "\255\255\000\000\255\255\255\255\000\000\255\255\255\255\255\255\
    \255\255\255\255\255\255\255\255\255\255\255\255\000\000\255\255\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\255\255\000\000\027\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\255\255\255\255\040\000\255\255\000\000\
    \000\000\255\255\000\000";
  Lexing.lex_trans = 
   "\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\002\000\004\000\002\000\039\000\003\000\000\000\002\000\
    \002\000\004\000\255\255\000\000\002\000\255\255\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \002\000\009\000\002\000\000\000\000\000\000\000\008\000\002\000\
    \024\000\023\000\014\000\016\000\018\000\015\000\005\000\013\000\
    \006\000\006\000\006\000\006\000\006\000\006\000\006\000\006\000\
    \006\000\006\000\033\000\017\000\012\000\010\000\011\000\032\000\
    \031\000\025\000\025\000\025\000\025\000\025\000\025\000\025\000\
    \025\000\025\000\025\000\025\000\025\000\025\000\025\000\025\000\
    \025\000\025\000\025\000\025\000\025\000\025\000\025\000\025\000\
    \025\000\025\000\025\000\020\000\030\000\019\000\029\000\025\000\
    \042\000\025\000\025\000\025\000\025\000\025\000\025\000\025\000\
    \025\000\025\000\025\000\025\000\025\000\025\000\025\000\025\000\
    \025\000\025\000\025\000\025\000\025\000\025\000\025\000\025\000\
    \025\000\025\000\025\000\022\000\007\000\021\000\036\000\036\000\
    \036\000\036\000\036\000\036\000\036\000\036\000\036\000\036\000\
    \035\000\034\000\006\000\006\000\006\000\006\000\006\000\006\000\
    \006\000\006\000\006\000\006\000\028\000\000\000\000\000\000\000\
    \005\000\027\000\006\000\006\000\006\000\006\000\006\000\006\000\
    \006\000\006\000\006\000\006\000\026\000\035\000\035\000\035\000\
    \035\000\035\000\035\000\035\000\035\000\035\000\035\000\025\000\
    \025\000\025\000\025\000\025\000\025\000\025\000\025\000\025\000\
    \025\000\000\000\039\000\000\000\000\000\038\000\000\000\000\000\
    \025\000\025\000\025\000\025\000\025\000\025\000\025\000\025\000\
    \025\000\025\000\025\000\025\000\025\000\025\000\025\000\025\000\
    \025\000\025\000\025\000\025\000\025\000\025\000\025\000\025\000\
    \025\000\025\000\041\000\000\000\000\000\000\000\025\000\000\000\
    \025\000\025\000\025\000\025\000\025\000\025\000\025\000\025\000\
    \025\000\025\000\025\000\025\000\025\000\025\000\025\000\025\000\
    \025\000\025\000\025\000\025\000\025\000\025\000\025\000\025\000\
    \025\000\025\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \001\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \255\255\036\000\036\000\036\000\036\000\036\000\036\000\036\000\
    \036\000\036\000\036\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \255\255\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000";
  Lexing.lex_check = 
   "\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
    \255\255\000\000\000\000\002\000\038\000\000\000\255\255\002\000\
    \003\000\003\000\027\000\255\255\003\000\027\000\255\255\255\255\
    \255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
    \000\000\000\000\002\000\255\255\255\255\255\255\000\000\003\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\008\000\000\000\000\000\000\000\000\000\009\000\
    \010\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\011\000\000\000\012\000\000\000\
    \041\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\005\000\005\000\
    \005\000\005\000\005\000\005\000\005\000\005\000\005\000\005\000\
    \006\000\007\000\006\000\006\000\006\000\006\000\006\000\006\000\
    \006\000\006\000\006\000\006\000\013\000\255\255\255\255\255\255\
    \015\000\013\000\015\000\015\000\015\000\015\000\015\000\015\000\
    \015\000\015\000\015\000\015\000\025\000\035\000\035\000\035\000\
    \035\000\035\000\035\000\035\000\035\000\035\000\035\000\025\000\
    \025\000\025\000\025\000\025\000\025\000\025\000\025\000\025\000\
    \025\000\255\255\037\000\255\255\255\255\037\000\255\255\255\255\
    \025\000\025\000\025\000\025\000\025\000\025\000\025\000\025\000\
    \025\000\025\000\025\000\025\000\025\000\025\000\025\000\025\000\
    \025\000\025\000\025\000\025\000\025\000\025\000\025\000\025\000\
    \025\000\025\000\037\000\255\255\255\255\255\255\025\000\255\255\
    \025\000\025\000\025\000\025\000\025\000\025\000\025\000\025\000\
    \025\000\025\000\025\000\025\000\025\000\025\000\025\000\025\000\
    \025\000\025\000\025\000\025\000\025\000\025\000\025\000\025\000\
    \025\000\025\000\255\255\255\255\255\255\255\255\255\255\255\255\
    \000\000\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
    \027\000\036\000\036\000\036\000\036\000\036\000\036\000\036\000\
    \036\000\036\000\036\000\255\255\255\255\255\255\255\255\255\255\
    \255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
    \255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
    \255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
    \255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
    \255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
    \255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
    \255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
    \255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
    \255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
    \255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
    \255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
    \255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
    \255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
    \255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
    \255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
    \255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
    \255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
    \255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
    \255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
    \037\000\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
    \255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
    \255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
    \255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
    \255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
    \255\255\255\255";
  Lexing.lex_base_code = 
   "";
  Lexing.lex_backtrk_code = 
   "";
  Lexing.lex_default_code = 
   "";
  Lexing.lex_trans_code = 
   "";
  Lexing.lex_check_code = 
   "";
  Lexing.lex_code = 
   "";
}

let rec token lexbuf =
    __ocaml_lex_token_rec lexbuf 0
and __ocaml_lex_token_rec lexbuf __ocaml_lex_state =
  match Lexing.engine __ocaml_lex_tables __ocaml_lex_state lexbuf with
      | 0 ->
let
# 48 "frontend/lexer.mll"
                                                               id
# 204 "frontend/lexer.ml"
= Lexing.sub_lexeme lexbuf lexbuf.Lexing.lex_start_pos lexbuf.Lexing.lex_curr_pos in
# 49 "frontend/lexer.mll"
( try Hashtbl.find kwd_table id with Not_found -> TOK_id id )
# 208 "frontend/lexer.ml"

  | 1 ->
# 53 "frontend/lexer.mll"
         ( TOK_LPAREN )
# 213 "frontend/lexer.ml"

  | 2 ->
# 54 "frontend/lexer.mll"
         ( TOK_RPAREN )
# 218 "frontend/lexer.ml"

  | 3 ->
# 55 "frontend/lexer.mll"
         ( TOK_LBRACE )
# 223 "frontend/lexer.ml"

  | 4 ->
# 56 "frontend/lexer.mll"
         ( TOK_RBRACE )
# 228 "frontend/lexer.ml"

  | 5 ->
# 57 "frontend/lexer.mll"
         ( TOK_LBRACKET )
# 233 "frontend/lexer.ml"

  | 6 ->
# 58 "frontend/lexer.mll"
         ( TOK_RBRACKET )
# 238 "frontend/lexer.ml"

  | 7 ->
# 59 "frontend/lexer.mll"
         ( TOK_COMMA )
# 243 "frontend/lexer.ml"

  | 8 ->
# 60 "frontend/lexer.mll"
         ( TOK_SEMICOLON )
# 248 "frontend/lexer.ml"

  | 9 ->
# 61 "frontend/lexer.mll"
         ( TOK_PLUS )
# 253 "frontend/lexer.ml"

  | 10 ->
# 62 "frontend/lexer.mll"
         ( TOK_MINUS )
# 258 "frontend/lexer.ml"

  | 11 ->
# 63 "frontend/lexer.mll"
         ( TOK_MULTIPLY )
# 263 "frontend/lexer.ml"

  | 12 ->
# 64 "frontend/lexer.mll"
         ( TOK_DIVIDE )
# 268 "frontend/lexer.ml"

  | 13 ->
# 65 "frontend/lexer.mll"
         ( TOK_LESS )
# 273 "frontend/lexer.ml"

  | 14 ->
# 66 "frontend/lexer.mll"
         ( TOK_GREATER )
# 278 "frontend/lexer.ml"

  | 15 ->
# 67 "frontend/lexer.mll"
         ( TOK_LESS_EQUAL )
# 283 "frontend/lexer.ml"

  | 16 ->
# 68 "frontend/lexer.mll"
         ( TOK_GREATER_EQUAL )
# 288 "frontend/lexer.ml"

  | 17 ->
# 69 "frontend/lexer.mll"
         ( TOK_EQUAL_EQUAL )
# 293 "frontend/lexer.ml"

  | 18 ->
# 70 "frontend/lexer.mll"
         ( TOK_NOT_EQUAL )
# 298 "frontend/lexer.ml"

  | 19 ->
# 71 "frontend/lexer.mll"
         ( TOK_ASSIGN )
# 303 "frontend/lexer.ml"

  | 20 ->
# 72 "frontend/lexer.mll"
         ( TOK_AND )
# 308 "frontend/lexer.ml"

  | 21 ->
# 73 "frontend/lexer.mll"
         ( TOK_OR )
# 313 "frontend/lexer.ml"

  | 22 ->
# 74 "frontend/lexer.mll"
         ( TOK_NOT )
# 318 "frontend/lexer.ml"

  | 23 ->
let
# 77 "frontend/lexer.mll"
           c
# 324 "frontend/lexer.ml"
= Lexing.sub_lexeme lexbuf lexbuf.Lexing.lex_start_pos lexbuf.Lexing.lex_curr_pos in
# 77 "frontend/lexer.mll"
             ( TOK_const (float_of_string c) )
# 328 "frontend/lexer.ml"

  | 24 ->
# 80 "frontend/lexer.mll"
       ( comment lexbuf; token lexbuf )
# 333 "frontend/lexer.ml"

  | 25 ->
# 81 "frontend/lexer.mll"
                      ( token lexbuf )
# 338 "frontend/lexer.ml"

  | 26 ->
# 82 "frontend/lexer.mll"
          ( new_line lexbuf; token lexbuf )
# 343 "frontend/lexer.ml"

  | 27 ->
# 83 "frontend/lexer.mll"
        ( token lexbuf )
# 348 "frontend/lexer.ml"

  | 28 ->
# 86 "frontend/lexer.mll"
      ( TOK_EOF )
# 353 "frontend/lexer.ml"

  | __ocaml_lex_state -> lexbuf.Lexing.refill_buff lexbuf; 
      __ocaml_lex_token_rec lexbuf __ocaml_lex_state

and comment lexbuf =
    __ocaml_lex_comment_rec lexbuf 37
and __ocaml_lex_comment_rec lexbuf __ocaml_lex_state =
  match Lexing.engine __ocaml_lex_tables __ocaml_lex_state lexbuf with
      | 0 ->
# 90 "frontend/lexer.mll"
       ( () )
# 365 "frontend/lexer.ml"

  | 1 ->
# 91 "frontend/lexer.mll"
                ( comment lexbuf )
# 370 "frontend/lexer.ml"

  | 2 ->
# 92 "frontend/lexer.mll"
          ( new_line lexbuf; comment lexbuf )
# 375 "frontend/lexer.ml"

  | __ocaml_lex_state -> lexbuf.Lexing.refill_buff lexbuf; 
      __ocaml_lex_comment_rec lexbuf __ocaml_lex_state

;;
