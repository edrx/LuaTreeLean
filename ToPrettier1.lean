-- This file:
--   http://anggtwu.net/LuaTreeLean/ToPrettier1.lean.html
--   http://anggtwu.net/LuaTreeLean/ToPrettier1.lean
--          (find-angg "LuaTreeLean/ToPrettier1.lean")
-- Author: Eduardo Ochs <eduardoochs@gmail.com>
--    See: https://github.com/edrx/LuaTreeLean
--
-- This is a variant of LuaTree that uses Std.Format - that is based
-- on Phil Wadler's "A Prettier Printer" - to draw trees with branches
-- growing rightwards.
--
-- Here is a small example:
--
--   #eval zpile "aaa" ["b", "c", zpile "d" ["e", "f"]]
--   => aaa b
--          c
--          d e
--            f
--
-- The big "run_cmd" at the end prettierfies a big parse tree.

import Lean
import Init.Data.Format
open   Lean SourceInfo Parser
open   Std Format

def pile : (List Format) → Format
  | []           => ""
  | [item]       => item
  | item :: rest => item ++ line ++ pile rest

def zpile (head : String) (fmts : List Format) :=
  nest (1 + String.length head) <| head ++ align true ++ (pile fmts)

---- Small examples:
--#eval  pile       ["b", "c"]
--#eval zpile "a"   ["b", "c"]
--#eval zpile "aaa" ["b", "c"]
--#eval zpile "aaa" ["b", "c", zpile "d" ["e", "f"]]

class  ToPrettier (α : Type) where toPrettier : α → Format
export ToPrettier (toPrettier)

def    toPrettier_Nat (n : Nat) : Format := toString n
def    toPrettier_Int (n : Int) : Format := toString n
def    toPrettier_List  [ToPrettier α] (as : List α)  : Format :=
  zpile "[]"  (List.map  toPrettier as)
def    toPrettier_Array [ToPrettier α] (as : Array α) : Format :=
  zpile "#[]" (List.map toPrettier (as.toList))
def    toPrettier_SourceInfo (_ : Sourceinfo) : Format := ".sourceinfo"
def    toPrettier_Name : Name → Format
  | .anonymous .. => ".anonymous"
  | .num name i   => toPrettier_Name name ++ " " ++ toString i
  | .str _ str    => "name: " ++ str

instance : ToPrettier Nat        where toPrettier := toPrettier_Nat
instance : ToPrettier Int        where toPrettier := toPrettier_Int
instance : ToPrettier Name       where toPrettier := toPrettier_Name
instance : ToPrettier SourceInfo where toPrettier := toPrettier_SourceInfo
instance {α} [ToPrettier α] : ToPrettier (List α)  where toPrettier := toPrettier_List
instance {α} [ToPrettier α] : ToPrettier (Array α) where toPrettier := toPrettier_Array

def toPrettier_SyntaxNodeKind  : SyntaxNodeKind  → Format := toPrettier_Name
def toPrettier_SyntaxNodeKinds : SyntaxNodeKinds → Format := toPrettier_List
instance : ToPrettier SyntaxNodeKind  where toPrettier := toPrettier_SyntaxNodeKind
instance : ToPrettier SyntaxNodeKinds where toPrettier := toPrettier_SyntaxNodeKinds

partial def toPrettier_Syntax : Syntax → Format
  | .missing          => ".missing"
  | .atom _ str       => ".atom: " ++ str
  | .ident _ _ name _ => ".ident: " ++ toPrettier_Name name
  | .node _ kind args =>
       let k     := toPrettier_SyntaxNodeKind kind
       let sargs := List.map toPrettier_Syntax (args.toList)
       zpile ".node" (k :: sargs)

instance : ToPrettier Syntax where toPrettier := toPrettier_Syntax

partial def toPrettier_TSyntax {ks : SyntaxNodeKinds} (ts : TSyntax ks) : Format :=
  zpile "TSyntax" [toPrettier ks, toPrettier ts.raw]

instance : ToPrettier (TSyntax ks) where toPrettier := toPrettier_TSyntax

run_cmd do
  let stx <- `(fun {α β} [BEq α] (ab : α×β) => let (a,_) := ab; a==a)
  -- let stx <- `(fun (x : Nat) => x*x)
  -- process stx
  Lean.logInfo m!"{stx}"
  -- Lean.logInfo s!"{repr stx}"
  Lean.logInfo s!"{toPrettier stx}"
