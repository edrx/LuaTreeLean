-- This file:
--   http://anggtwu.net/LuaTreeLean/Test3.lean.html
--   http://anggtwu.net/LuaTreeLean/Test3.lean
--          (find-angg "LuaTreeLean/Test3.lean")
-- Author: Eduardo Ochs <eduardoochs@gmail.com>
--    See: https://github.com/edrx/LuaTreeLean
--
-- (defun e () (interactive) (find-angg "LuaTreeLean/Test3.lean"))

import Lean
import LuaTree
open   Lean LuaTree Syntax

/- Name
-/

def toLTree_Name : Name → LTree      -- full tree
  | .anonymous                       => .s ".anonymous"
  | .str (pre : Name) (str : String) => .t ".str" [toLTree_Name pre, .s str]
  | .num (pre : Name) (i : Nat)      => .t ".num" [toLTree_Name pre, toLTree i]

def toLTree_Name1 : Name → LTree     -- only the last name
  | .anonymous .. => .s ".anonymous"
  | .str _ str    => .s str
  | .num ..       => .s ".num"

instance : ToLTree Name where toLTree := toLTree_Name   -- full tree

#eval printTree  `Parser.Command.instance
#eval printTree ``Parser.Command.instance
#eval printTree (Name.mkNum `Parser.Command 42)
#eval printTree (Name.mkNum "foo" 42)

instance : ToLTree Name where toLTree := toLTree_Name1  -- only the last name

#eval printTree  `Parser.Command.instance
#eval printTree ``Parser.Command.instance
#eval printTree (Name.mkNum `Parser.Command 42)
#eval printTree (Name.mkNum "foo" 42)

/- SyntaxNodeKind and SyntaxNodeKinds
-/
instance : ToLTree SyntaxNodeKind  where toLTree := toLTree_Name1
instance : ToLTree SyntaxNodeKinds where toLTree := toLTree_List

/- Syntax and TSyntax
-/
partial def toLTree_Syntax : Syntax → LTree
  | .missing          => .s ".missing"
  | .node _ kind args =>
       let k     := toLTree kind
       let sargs := List.map toLTree_Syntax (args.toList)
       .t ".node" (k :: sargs)
  | .atom _ str        => .t ".atom" [.s str]
  | .ident _ _ name _  => .t ".ident" [toLTree name]

instance : ToLTree Syntax          where toLTree := toLTree_Syntax

partial def toLTree_TSyntax {ks : SyntaxNodeKinds} (ts : TSyntax ks) : LTree :=
  .t "TSyntax" [toLTree ks, toLTree ts.raw]

instance : ToLTree (TSyntax ks) where toLTree := toLTree_TSyntax

/- Tests
-/ 
#check TSyntax
#check TSyntax `term
#check TSyntax `foo
#check TSyntax []
#check show TSyntax `term from { raw := mkNumLit "1" }

def syntax1 := Syntax.atom (SourceInfo.none) "1"
def syntax2 := Syntax.node (SourceInfo.none) `num #[Syntax.atom (SourceInfo.none) "1"]
def syntax3 := mkNumLit "1"
def syntax4 := mkNode `«term_+_» #[mkNumLit "1", mkAtom "+", mkNumLit "1"]
def syntax5 := mkApp (mkIdent `Nat.add) #[mkNumLit "1", mkNumLit "1"]

#eval           syntax1
#eval           syntax2
#eval           syntax3
#eval           syntax4
#eval           syntax5
#eval printTree syntax1
#eval printTree syntax2
#eval printTree syntax3
#eval printTree syntax4
#eval printTree syntax5

#check printTree
#eval  printTree [2,3]

elab "#minihelp " x:term : command => printTree x.raw
elab "#minihelp " x:term : command => logInfo (repr x.raw)
elab "#minihelp " x:term : command => IO.println "foo"
#minihelp "bla"



-- Local Variables:
-- coding:  utf-8-unix
-- End:
