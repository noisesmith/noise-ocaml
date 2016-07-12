PACKAGES=sdl,ocaml_portmidi,str
OPT=ocamlfind ocamlopt
BYTE=ocamlfind ocamlc

app.byte: vidstuff.cmo midistuff.cmo app.cmo ui.cmo
	${BYTE} -o app.byte -linkpkg -package ${PACKAGES} vidstuff.cmo midistuff.cmo ui.cmo app.cmo

vidstuff.cmo: vidstuff.ml
	${BYTE} -c -package ${PACKAGES} vidstuff.ml

midistuff.cmo: midistuff.ml
	${BYTE} -c -package ${PACKAGES} midistuff.ml

ui.cmo: ui.ml vidstuff.cmo
	${BYTE} -c -package ${PACKAGES} ui.ml

app.cmo: vidstuff.cmo midistuff.cmo ui.cmo app.ml
	${BYTE} -c -package ${PACKAGES} app.ml

app: vidstuff.cmx midistuff.cmx ui.cmx app.cmx
	${OPT} -o app -linkpkg -package ${PACKAGES} vidstuff.cmx midistuff.cmx ui.cmx app.cmx

vidstuff.cmx: vidstuff.ml
	${OPT} -c -package ${PACKAGES} vidstuff.ml

midistuff.cmx: midistuff.ml
	${OPT} -c -package ${PACKAGES} midistuff.ml

ui.cmx: ui.ml vidstuff.cmx
	${OPT} -c -package ${PACKAGES} ui.ml

app.cmx: vidstuff.cmx midistuff.cmx ui.cmx app.ml
	${OPT} -c -package ${PACKAGES} app.ml

clean:
	rm -f app.byte app *.cmi *.cmo *.cmx *.o
