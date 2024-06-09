-- This file:
--   http://anggtwu.net/LuaTreeLean/Example.lean.pyg.html
--   http://anggtwu.net/LuaTreeLean/Example.lean.html
--   http://anggtwu.net/LuaTreeLean/Example.lean
--          (find-angg "LuaTreeLean/Example.lean")
-- Author: Eduardo Ochs <eduardoochs@gmail.com>
--    See: https://github.com/edrx/LuaTreeLean
--
-- Note: THIS IS BROKEN!
-- I don't know how to set up the lakefile.lean to make the
-- "import LT" below load the LT.lean that is in this directory...
-- Please help! =(

import LT
open   LT

#eval toLT      [2, 3]
#eval toLuaExpr [2, 3]
#eval printTree [2, 3]


/-
• (eepitch-shell)
• (eepitch-kill)
• (eepitch-shell)
lake setup-file /home/edrx/LuaTreeLean/Example.lean Init LT

-/

-- Local Variables:
-- coding:  utf-8-unix
-- End:
