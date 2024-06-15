-- This file:
--   http://anggtwu.net/LuaTreeLean/Test2.lean.pyg.html
--   http://anggtwu.net/LuaTreeLean/Test2.lean.html
--   http://anggtwu.net/LuaTreeLean/Test2.lean
--          (find-angg "LuaTreeLean/Test2.lean")
-- Author: Eduardo Ochs <eduardoochs@gmail.com>
--    See: https://github.com/edrx/LuaTreeLean

import Lean
import LuaTree
open   LuaTree
namespace DSL

declare_syntax_cat catB

syntax num                      : catB
syntax "x"                      : catB
syntax "sin" "(" catB ")"       : catB
syntax "cos" "(" catB ")"       : catB
syntax "log" "(" catB ")"       : catB
syntax:65 catB:65 " + " catB:66 : catB
syntax:65 catB:65 " - " catB:66 : catB
syntax:70 catB:70 " * " catB:71 : catB
syntax:70 catB:70 " / " catB:71 : catB
syntax:80 catB:81 " ^ " catB:80 : catB
syntax "(" catB ")"             : catB
syntax "(" catB ")'"            : catB
syntax "[: " catB " :]"         : term

macro_rules | `([: $n:num :])            => `(LTree.t "n" [LTree.s (toString $n)])
macro_rules | `([: x :])                 => `(LTree.t "var" [LTree.s "x"])
macro_rules | `([: sin($b:catB) :])      => `(LTree.t "sin" [[: $b :]])
macro_rules | `([: cos($b:catB) :])      => `(LTree.t "cos" [[: $b :]])
macro_rules | `([: log($b:catB) :])      => `(LTree.t "log" [[: $b :]])
macro_rules | `([: $b:catB + $c:catB :]) => `(LTree.t "+" [[: $b :], [: $c :]])
macro_rules | `([: $b:catB - $c:catB :]) => `(LTree.t "-" [[: $b :], [: $c :]])
macro_rules | `([: $b:catB * $c:catB :]) => `(LTree.t "*" [[: $b :], [: $c :]])
macro_rules | `([: $b:catB / $c:catB :]) => `(LTree.t "/" [[: $b :], [: $c :]])
macro_rules | `([: $b:catB ^ $c:catB :]) => `(LTree.t "^" [[: $b :], [: $c :]])
macro_rules | `([: ($b:catB)' :])        => `(LTree.t "'" [[: $b :]])
macro_rules | `([: ($b:catB)  :])        => `([: $b :])

partial def foo (a : LTree) : LTree := match a with
  | .t "n"   [.s s] => .s s
  | .t "var" [.s s] => .s s
  | .t h ts         => .t h (List.map foo ts)
  | .s _            => a

-- def t1 := [: 1 - 2 - 3 - 4 ^ 5 ^ 6 :]
-- def t1 := [: x^2 - 3/x :]
-- def t1 := [: x^2 - 3/(x+1) :]
def t1 := [: ((x)'^2 - 3/(x+1))' :]
def t2 := foo t1
#eval printTree t1
#eval printTree t2




end DSL



/-
| (lsp-describe-session)
| (find-eppp (lsp-session-folders (lsp-session)))
| (find-fline "~/.emacs.d/" ".lsp-session-v1")
| (find-fline "~/.emacs.d/.lsp-session-v1")

 (eepitch-shell)
 (eepitch-kill)
 (eepitch-shell)
lean --run Test2.lean
lake env lean Test2.lean

-/




-- Local Variables:
-- coding:  utf-8-unix
-- End:
