PACKAGES=sdl,ocaml_portmidi,str
OPT=ocamlfind ocamlopt
BYTE=ocamlfind ocamlc

app.byte: mp3 process.cmo vidstuff.cmo midistuff.cmo app.cmo ui.cmo data.cmo
	${BYTE} -o app.byte -linkpkg -package ${PACKAGES} vidstuff.cmo midistuff.cmo ui.cmo app.cmo

%.cmo: %.ml
	${BYTE} -c -package ${PACKAGES} $<

ui.cmo: ui.ml vidstuff.cmo

app.cmo: app.ml ui.cmo

app: mp3 process.cmx vidstuff.cmx midistuff.cmx ui.cmx app.cmx data.cmx
	${OPT} -o app -linkpkg -package ${PACKAGES} vidstuff.cmx midistuff.cmx ui.cmx app.cmx

%.cmx: %.ml
	${OPT} -c -package ${PACKAGES} $<

ui.cmx: ui.ml vidstuff.cmx

app.cmx: vidstuff.cmx midistuff.cmx ui.cmx app.ml

mp3:	res/sweep.mp3 res/441.mp3

%.mp3:	%.wav
	lame $< -o $@

%.wav:	%.csd
	csound $< -o $@

clean:
	rm -f app.byte app *.cmi *.cmo *.cmx *.o res/*.wav res/*.mp3
