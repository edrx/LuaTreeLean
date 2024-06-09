-- This file:
--   http://anggtwu.net/LuaTreeLean/LT.lean.pyg.html
--   http://anggtwu.net/LuaTreeLean/LT.lean.html
--   http://anggtwu.net/LuaTreeLean/LT.lean
--          (find-angg "LuaTreeLean/LT.lean")
-- Author: Eduardo Ochs <eduardoochs@gmail.com>
--    See: https://github.com/edrx/LuaTreeLean
--
-- (defun e () (interactive) (find-angg "LuaTreeLean/LT.lean"))
--
-- Example:
--   #eval toLT      [2, 3]      --> LT.LT.t "[]" [LT.LT.s "2", LT.LT.s "3"]
--   #eval toLuaExpr [2, 3]      --> "{[0]=\"[]\", \"2\", \"3\"}"
--   #eval printTree [2, 3]      --> []__.
--                               --  |   |
--                               --  2   3

import Lean
open Lean Elab
namespace LT


/- Basic operations with strings
-/
open String

def q   s  :=     "\"" ++ s ++ "\""   -- quote
def zq  s  := "[0]=\"" ++ s ++ "\""   -- zero/quote
def br  s  :=      "{" ++ s ++ "}"    -- bracket
def ac  s  :=     ", " ++ s           -- add comma

def acs (strs : List String) : String := join (List.map ac strs)
def zacs (head : String) (strs : List String) : String :=
  br ((zq head) ++ (acs strs))
def zconcat := zacs

#eval zconcat "a" [  "b",   "c"]      --> "{[0]=\"a\", b, c}"
#eval zconcat "a" [q "b", q "c"]      --> "{[0]=\"a\", \"b\", \"c\"}"


/- IO
-- See: (find-angg "luatree/luatree.lua")
-/
def mkfilepath (fname : String) : System.FilePath :=
  System.mkFilePath [fname]
def readfile   (fname : String) : IO String :=
  IO.FS.readFile (mkfilepath fname)
def writefile  (fname content : String) : IO Unit :=
  IO.FS.writeFile (mkfilepath fname) content
def getoutput (cmd : String) (args : Array String) : IO String := do
  let out ← IO.Process.output { cmd := cmd, args := args }
  return out.stdout

def luatreescript  := "./luatree.lua"
def luatreetmpfile := "/tmp/o1.lua"

def luatreerun (luaexpr : String) : IO String := do
  writefile luatreetmpfile luaexpr
  return (← getoutput luatreescript #[luatreetmpfile])
def luatreeprint (luaexpr : String) : IO Unit := do
  IO.println (← luatreerun luaexpr)


/- LT: structure and class
-/
inductive LT where
  | s (s : String) : LT
  | t (h : String) (l : List LT) : LT
  deriving Repr

partial def toLuaExpr0 : LT → String
  | .s s   => q s
  | .t h l => zconcat h (List.map toLuaExpr0 l)

class ToLT (α : Type) where
  toLT      : α → LT
  toLuaExpr : α → String  := fun o => toLuaExpr0 (toLT o)
  printTree : α → IO Unit := fun o => do IO.print (← luatreerun (toLuaExpr o))

export ToLT (toLT toLuaExpr printTree)


/- LT: basic instances
-/
instance : ToLT String     where toLT str := LT.s str
instance : ToLT Int        where toLT n   := LT.s (toString n)
instance : ToLT Nat        where toLT n   := LT.s (toString n)

instance {α} [ToLT α] : ToLT (List α)  where toLT as :=
  (LT.t "[]"  (List.map  toLT as))
instance {α} [ToLT α] : ToLT (Array α) where toLT as :=
  (LT.t "#[]" (Array.map toLT as).toList)


/- High-level tests
-/
#eval toLT      [2, 3]
#eval toLuaExpr [2, 3]
#eval printTree [2, 3]



/- A DSL for tests
-/
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

declare_syntax_cat catA

syntax num                      : catA
syntax:50 catA:50 " - " catA:51 : catA
syntax:70 catA:71 " ^ " catA:70 : catA
syntax "[: " catA " :]"         : term

macro_rules | `([: $n:num :]) => `(A.n ($n))
macro_rules | `([: $b:catA - $c:catA :]) => `(A.minus ([: $b :]) ([: $c :]))
macro_rules | `([: $b:catA ^ $c:catA :]) => `(A.pow   ([: $b :]) ([: $c :]))

#check      [: 1 - 2 - 3 - 4 ^ 5 ^ 6 :]
#eval paren [: 1 - 2 - 3 - 4 ^ 5 ^ 6 :]   --> "(((1-2)-3)-(4^(5^6)))"

def toLT_A : A → LT
  | .n n       => LT.s (toString n)
  | .minus b c => LT.t "-" [toLT_A b, toLT_A c]
  | .pow   b c => LT.t "^" [toLT_A b, toLT_A c]

instance : ToLT A   where toLT := toLT_A

#eval toLT      [: 1 - 2 - 3 - 4 ^ 5 ^ 6 :]
#eval printTree [: 1 - 2 - 3 - 4 ^ 5 ^ 6 :]

-- -________.
-- |        |
-- -_____.  ^__.
-- |     |  |  |
-- -__.  3  4  ^__.
-- |  |        |  |
-- 1  2        5  6

end DSL
end LT



-- Local Variables:
-- coding:  utf-8-unix
-- End:
