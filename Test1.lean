-- This file:
--   http://anggtwu.net/LuaTreeLean/Test1.lean.pyg.html
--   http://anggtwu.net/LuaTreeLean/Test1.lean.html
--   http://anggtwu.net/LuaTreeLean/Test1.lean
--          (find-angg "LuaTreeLean/Test1.lean")
-- Author: Eduardo Ochs <eduardoochs@gmail.com>
--    See: https://github.com/edrx/LuaTreeLean

import Lean
import LuaTree
open   LuaTree
namespace DSL

inductive A where
  | n     (n : Nat) : A
  | minus (b c : A) : A
  | pow   (b c : A) : A
  deriving Repr

def paren : A → String
  | .n n       => toString n
  | .minus b c => "(" ++ paren b ++ "-" ++ paren c ++ ")"
  | .pow   b c => "(" ++ paren b ++ "^" ++ paren c ++ ")"

def toLT_A : A → LT
  | .n n       => LT.s (toString n)
  | .minus b c => LT.t "-" [toLT_A b, toLT_A c]
  | .pow   b c => LT.t "^" [toLT_A b, toLT_A c]

instance : ToLT A where toLT := toLT_A

declare_syntax_cat catA

syntax num                      : catA
syntax:50 catA:50 " - " catA:51 : catA
syntax:70 catA:71 " ^ " catA:70 : catA
syntax "[: " catA " :]"         : term

macro_rules | `([: $n:num :]) => `(A.n ($n))
macro_rules | `([: $b:catA - $c:catA :]) => `(A.minus ([: $b :]) ([: $c :]))
macro_rules | `([: $b:catA ^ $c:catA :]) => `(A.pow   ([: $b :]) ([: $c :]))

#check          [: 1 - 2 - 3 - 4 ^ 5 ^ 6 :]
#eval paren     [: 1 - 2 - 3 - 4 ^ 5 ^ 6 :]   --> "(((1-2)-3)-(4^(5^6)))"
#eval toLT      [: 1 - 2 - 3 - 4 ^ 5 ^ 6 :]   --> LuaTree.LT.t "-" [...]
#eval printTree [: 1 - 2 - 3 - 4 ^ 5 ^ 6 :]   --> a 2D tree

end DSL

-- Local Variables:
-- coding:  utf-8-unix
-- End:
