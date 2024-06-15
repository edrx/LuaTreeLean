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

• (eepitch-shell)
• (eepitch-kill)
• (eepitch-shell)
make -f Makefile clean
  lake build --verbose
# lake build
find .lake/ | sort

-/
