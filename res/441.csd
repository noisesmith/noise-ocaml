<CsoundSynthesizer>
<CsOptions>
-o 441.wav
</CsOptions>
<CsInstruments>

sr	=	44100
ksmps	=	1
nchnls	=	2
0dbfs	=	1

	instr 1
aout	poscil 0.95, 441
	outs aout, aout
	endin

</CsInstruments>
<CsScore>

i 1 0 10

</CsScore>
</CsoundSynthesizer>

