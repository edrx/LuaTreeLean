-- This file:
--   http://anggtwu.net/LuaTreeLean/LuaTree.lean.pyg.html
--   http://anggtwu.net/LuaTreeLean/LuaTree.lean.html
--   http://anggtwu.net/LuaTreeLean/LuaTree.lean
--          (find-angg "LuaTreeLean/LuaTree.lean")
-- Author: Eduardo Ochs <eduardoochs@gmail.com>
--    See: https://github.com/edrx/LuaTreeLean
--
-- Example:
--   #eval toLTree   [2, 3]      --> LTree.LTree.t "[]" [LTree.LTree.s "2", LTree.LTree.s "3"]
--   #eval toLuaExpr [2, 3]      --> "{[0]=\"[]\", \"2\", \"3\"}"
--   #eval printTree [2, 3]      --> []__.
--                               --  |   |
--                               --  2   3

import Lean
open Lean Elab
namespace LuaTree


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
-- See: (find-angg "LuaTreeLean/luatree.lua")
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


/- LTree: structure and class
-/
inductive LTree where
  | s (s : String) : LTree
  | t (h : String) (l : List LTree) : LTree
  deriving Repr

instance : Inhabited LTree where
  default := .s ""

partial def toLuaExpr0 : LTree → String
  | .s s   => q s
  | .t h l => zconcat h (List.map toLuaExpr0 l)

class ToLTree (α : Type) where
  toLTree   : α → LTree
  toLuaExpr : α → String  := fun o => toLuaExpr0 (toLTree o)
  printTree : α → IO Unit := fun o => do IO.print (← luatreerun (toLuaExpr o))

export ToLTree (toLTree toLuaExpr printTree)


/- LTree: basic instances
-/

def toLTree_LTree  (o : LTree)    : LTree := o
def toLTree_Int    (n : Int)      : LTree := LTree.s (toString n)
def toLTree_Nat    (n : Nat)      : LTree := LTree.s (toString n)
def toLTree_String (str : String) : LTree := LTree.s str
def toLTree_List   [ToLTree α] (as : List α)  : LTree :=
  (LTree.t "[]"  (List.map  toLTree as))
def toLTree_Array  [ToLTree α] (as : Array α) : LTree :=
  (LTree.t "#[]" (Array.map toLTree as).toList)

instance                 : ToLTree LTree     where toLTree := toLTree_LTree
instance                 : ToLTree Int       where toLTree := toLTree_Int
instance                 : ToLTree Nat       where toLTree := toLTree_Nat
instance                 : ToLTree String    where toLTree := toLTree_String
instance {α} [ToLTree α] : ToLTree (List α)  where toLTree := toLTree_List
instance {α} [ToLTree α] : ToLTree (Array α) where toLTree := toLTree_Array

/- High-level tests
-/
#eval toLTree   [2, 3]
#eval toLuaExpr [2, 3]
#eval printTree [2, 3]


end LuaTree



-- Local Variables:
-- coding:  utf-8-unix
-- End:
