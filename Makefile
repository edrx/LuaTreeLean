
# (find-angg "bin/djvuize")
# (find-es "make" "variables")
# See: (find-node "(make)Text Functions")

STEMS    = LuaTree Test1
LEANS    = $(STEMS:=.lean)
PYGHTMLS = $(STEMS:=.lean.pyg.html)

%.pyg.html: %
	pygmentize -O full -o $@ $<

pyghtmls: $(PYGHTMLS)

stems:
	echo $(STEMS)
	echo $(LEANS)

clean:
	rm -fv $(PYGHTMLS) *~
	rm -Rfv .lake/
	rm -fv lake-manifest.json
	rm -fv lean-toolchain

# See: (find-eepitch-intro "3.3. `eepitch-preprocess-line'")
# (setq eepitch-preprocess-regexp "^")
# (setq eepitch-preprocess-regexp "^#T ?")
#
#T  (eepitch-shell)
#T  (eepitch-kill)
#T  (eepitch-shell)
#T make -f Makefile clean
#T make -f Makefile pyghtmls
#T make -f Makefile luatree.lua.pyg.html
#T laf
#T rm -Rv .lake/
#T lake build
#T find .lake * | sort
# (find-man "rm")
