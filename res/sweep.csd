<CsoundSynthesizer>
<CsOptions>
-o sweep.wav
</CsOptions>
<CsInstruments>

sr	=	44100
ksmps	=	1
nchnls	=	2
0dbfs	=	1

	instr 1
afq	line 0, 10, 20000
aout	poscil3 0.95, afq
	outs aout, aout
	endin

</CsInstruments>
<CsScore>

i 1 0 10

</CsScore>
</CsoundSynthesizer>

