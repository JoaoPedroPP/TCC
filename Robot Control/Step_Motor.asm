TEMP EQU (65535-15000)

ORG 0000H
sjmp anti

HORARIO:
MOV A,#00010000B
MOV P1,A
LOOP:
LCALL TEMPO
ROTACIONARLEDs:
RL A
MOV P1,A
CJNE A,#1,LOOP
SJMP HORARIO

ANTI:
MOV A,#10000000B
MOV P1,A
LOOP2:
LCALL TEMPO
ROTACIONARLEDs2:
RR A
MOV P1,A
CJNE A,#8,LOOP2
LCALL TEMPO
SJMP ANTI

TEMPO:		;rotina de tempo(20x50.000)
MOV R0,#12

LOOP1:
MOV TMOD,#00000001B
MOV TL0,#LOW(TEMP)
MOV TH0,#HIGH(TEMP)
SETB TR0
JNB TF0,$
CLR TR0
CLR TF0
DJNZ R0,LOOP1
RET

END