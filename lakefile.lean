/-
-- This file:
--   http://anggtwu.net/LuaTreeLean/lakefile.lean.html
--   http://anggtwu.net/LuaTreeLean/lakefile.lean
--          (find-angg "LuaTreeLean/lakefile.lean")
--    See: https://github.com/edrx/LuaTreeLean
-- Author: Eduardo Ochs <eduardoochs@gmail.com>
-/

import Lake
open   Lake DSL

package «LuaTree» -- where
  -- add package configuration options here

@[default_target]
lean_lib «LuaTree» -- where
  -- add library configuration options here

/-
-- Test:

 (eepitch-shell)
 (eepitch-kill)
 (eepitch-shell)
make -f Makefile clean
# lake build
  lake build --verbose
  lake env lean --run Test1.lean
find .lake/ | sort

-/
