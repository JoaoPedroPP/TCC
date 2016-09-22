TEMP EQU (65535 - 37933)	; Abscissa (X)
TEMP2 EQU (65535 - 30274 )	; Ordenada (Y)
TEMP3 EQU (65535 - 14801)	; Z
TEMP4 EQU (65535 - 20183)	;X DAS CORES
TEMP5 EQU (65535- 12110)	;Y DAS CORES
DRIVE1 EQU P2.0			; Definição de sentido X
DRIVE2 EQU P2.1			; Definição de sentido Y
DRIVE3 EQU P2.2			; Definição de sentido Z
M1 EQU  P3.5                    ;OSCILADOR DE X
M2 EQU P3.6 			;OSCILADOR DE Y
M3 EQU P3.7			;OSCILADOR DE Z
GARRA EQU P3.3                  ;CONTROLE DA GARRA
FC1 EQU P0.0			; Origem X
FC2 EQU P0.1			; Final X
FC3 EQU P0.2			; Origem Y
FC4 EQU P0.3			; Final Y
FC5 EQU P0.4			; Origem Z
FC6 EQU P0.5			; Final Z
SINX EQU P1.0                   ;SINALIZADOR DE SENTIDO X
SINY EQU P1.1			;SINALIZADOR DE SENTIDO Y
SINZ EQU P1.2			;SINALIZADOR DE SENTIDO Z
BRANCO EQU P2.3			;SELEÇÃO DE COR
VERMELHO EQU P2.4		;SELEÇÃO DE COR
VERDE EQU P2.5			;SELEÇÃO DE COR
AZUL EQU P2.6			;SELEÇÃO DE COR

ORG 0000H

	LJMP INICIA

ORG 0030H

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;VERIFICA SE O BOTAO DE INCIO FOI APERTADO E MOVE O BRAÇO PARA A POSIÇÃO INICIAL;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

INICIA:

	JB BRANCO, $-1

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;POSICIONAMENTO DA ORIGEM;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

INICIO1:		
			SETB DRIVE1		; Faz alguma coisa com o sentido do eixo X
			SETB DRIVE2		; Faz alguma coisa com o sentido do eixo Y
			SETB DRIVE3		; Faz alguma coisa com o sentido do eixo Z
INICIO10:

ORIGEMX:
			JNB FC1, PARAX		; Verifica estado do fim de curso origem X
			LJMP CHAMA1
			
PARAX:
			SETB M1
			LJMP ORIGEMY
ORIGEMY:		
			JNB FC3, PARAY		; Verifica estado do fim de curso origem Y
			LJMP CHAMA2
PARAY:
			SETB M2
			LJMP ORIGEMZ
ORIGEMZ:			
			;CLR GARRA 		; Porte do servo-motor
			LCALL ANTI		;ABRE A GARRA
			JNB FC6, PARAZ		; Verifica estado do fim de curso origem Z
			LJMP CHAMA3
PARAZ:
			SETB M3

			LJMP INICIO2	
				
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;CONTROLE DO POSICIONAMENTO;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
			
CHAMA1:			
			CLR M1
  			;MOV R3, #9
			CALL LOOP3
			LJMP ORIGEMX	
			
CHAMA2:			
			CLR M2		
			;MOV R3, #15
			CALL LOOP3
			LJMP ORIGEMY

CHAMA3:			
			CLR M3
			;MOV R3, #11
			CALL LOOP3
			LJMP ORIGEMZ
			
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;			
;;;;;;CONFIGURAÇÃO DA SERIAL;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

INICIO2:		
			MOV SCON,#01010000B    	;OU 50H
			MOV PCON,#00000000B    	;OU 00H
			MOV TMOD,#00100000B    	;OU 20H
			MOV TH1,#0FDH           ;11101000B OU 232D
			MOV TL1,#0FDH           ;11101000B OU 232D
			SETB TR1
			LJMP SELECAODACOR
			
			
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;			
;;;;RECEBIMENTO DA SERIAL E TRATAMENTO DA INFORMAÇÃO;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

SELECAODACOR:
			JNB RI,$
			MOV A, SBUF
			MOV R6, A
			CLR RI
			CJNE R6,#'B', BRANCO1
			LJMP CORES
			
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;RORINA DA COR BRANCA;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
			
BRANCO1:		
			MOV R6, #00H	

SERIALRECEBENDO:	
			JNB RI,$
			MOV A, SBUF
			CLR RI
			CJNE R6,#1, COORDENADAX	; Verifica recebimento do bluetooth
			LJMP COORDENADAY

COORDENADAX:		;CLR DRIVE1		; Faz o inverso do comando executado na linha 18 
			MOV R1, A		; 
			MOV R6, #1			
			LJMP SERIALRECEBENDO	; Retorna para checagem da coordenada Y

COORDENADAY:		;CLR DRIVE2
			MOV R2, A		; Grava em R2 a posição Y da cor
			MOV R6, #00H		; Limpa R6 para criar a possibilidade de recebimento do próximo dado da serial (Posição X)
			LJMP MOVEX

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;			
;;;;;;ROTINA DAS OUTRAS CORES;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
			
CORES:			
			MOV R6, #00H

SERIALRECEBENDO1:	
			JNB RI,$
			MOV A, SBUF
			CLR RI
			CJNE R6,#1, COORDENADAX1	; Verifica recebimento do bluetooth
			LJMP COORDENADAY1

COORDENADAX1:		
			;CLR DRIVE1		; Faz o inverso do comando executado na linha 18 
			MOV R1, A		; 
			MOV R6, #1			
			LJMP SERIALRECEBENDO1	; Retorna para checagem da coordenada Y

COORDENADAY1:		
			;CLR DRIVE2
			MOV R2, A		; Grava em R2 a posição Y da cor
			MOV R6, #00H		; Limpa R6 para criar a possibilidade de recebimento do próximo dado da serial (Posição X)
			LJMP MOVEX1
			
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;			
;;;;;MOVIMENTAÇÃO DO BRANCO;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
			
MOVEX:			
			CLR DRIVE1
			LCALL DELAY1M
			MOV R4, A		; Move valor serial para R0
			MOV A, R1		; Move valor serial para R0
			MOV R0, A		; Move valor serial para R0
			MOV A, R4		; Move valor serial para R0
			;MOV R3, #9		; Quantidade de pulsos necessária para que o servo ande 1mm
			CLR M1
			CLR SINX
			CALL LOOP1
			SETB SINX
			SETB M1
			LJMP MOVEY		

MOVEY:			
			CLR DRIVE2
			LCALL DELAY1M
			MOV R4, A
			MOV A, R2
			MOV R0, A
			MOV A, R4
			;MOV R3, #15
			CLR M2
			CLR SINY
			CALL LOOP2
			SETB SINY
			SETB M2
			LJMP COORDENADAZ
			

COORDENADAZ:		
			CLR DRIVE3
			LCALL DELAY1M
			;MOV R3, #11
			CLR M3
			CLR SINZ
			CALL LOOP3
			JNB FC5, PARAZ2
			LJMP COORDENADAZ
			
PARAZ2:
			SETB SINZ
			SETB M3
			;CLR GARRA 		; Porte do servo-motor
			LCALL HORARIO    	;FECHA A GARRA
			LJMP INICIO1
			
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;			
;;;;MOVIMENTAÇÃO DAS CORES;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

MOVCORES:

MOVEX1:			
			CLR DRIVE1
			LCALL DELAY1M
			MOV R4, A		; Move valor serial para R0
			MOV A, R1		; Move valor serial para R0
			MOV R0, A		; Move valor serial para R0
			MOV A, R4		; Move valor serial para R0
			;MOV R3, #9		; Quantidade de pulsos necessária para que o servo ande 1mm
			CLR M1
			CLR SINX
			CALL LOOP4
			SETB SINX
			SETB M1
			LJMP MOVEY1		

MOVEY1:			
			CLR DRIVE2
			LCALL DELAY1M
			MOV R4, A
			MOV A, R2
			MOV R0, A
			MOV A, R4
			;MOV R3, #15
			CLR M2
			CLR SINY
			CALL LOOP5
			SETB SINY
			SETB M2
			LJMP COORDENADAZ
			

COORDENADAZ1:		
			CLR DRIVE3
			LCALL DELAY1M
			;MOV R3, #11
			CLR M3
			CLR SINZ
			CALL LOOP3
			JNB FC5, PARAZ3
			LJMP COORDENADAZ1

PARAZ3:
			SETB SINZ
			SETB M3
			;CLR GARRA 			; Porte do servo-motor
			LCALL HORARIO     		;FECHA A GARRA
			LJMP INICIO1
			
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;; ROTINAS DE CONTAGEM DE TEMPO;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

LOOP1:			
			MOV TMOD,#00000001B
			MOV TL0,#LOW(TEMP)		;Abscissa (X)
			MOV TH0,#HIGH(TEMP)		;Abscissa (X)
			SETB TR0
			JNB TF0,$
			CLR TR0
			CLR TF0
			;DJNZ R3, LOOP1
			DJNZ R0,LOOP1
			RET

LOOP2:			
			MOV TMOD,#00000001B
			MOV TL0,#LOW(TEMP2)		;Ordenada (Y)
			MOV TH0,#HIGH(TEMP2)		;Ordenada (Y)
			SETB TR0
			JNB TF0,$
			CLR TR0
			CLR TF0
			;DJNZ R3, LOOP2
			DJNZ R0,LOOP2
			RET
			
LOOP3:			
			MOV TMOD,#00000001B
			MOV TL0,#LOW(TEMP3)		; Z
			MOV TH0,#HIGH(TEMP3)		; Z
			SETB TR0
			JNB TF0,$
			CLR TR0
			CLR TF0
			;DJNZ R3, LOOP3
			RET

LOOP4:			
			MOV TMOD,#00000001B
			MOV TL0,#LOW(TEMP4)		;Abscissa (X) CORES
			MOV TH0,#HIGH(TEMP4)		;Abscissa (X) CORES
			SETB TR0
			JNB TF0,$
			CLR TR0
			CLR TF0
			;DJNZ R3, LOOP1
			DJNZ R0,LOOP1
			RET

LOOP5:			
			MOV TMOD,#00000001B
			MOV TL0,#LOW(TEMP5)		;ORDENADA (Y) CORES
			MOV TH0,#HIGH(TEMP5)		;ORDENADA (Y) CORES
			SETB TR0
			JNB TF0,$
			CLR TR0
			CLR TF0
			;DJNZ R3, LOOP1
			DJNZ R0,LOOP1
			RET
			

DELAY1M: 		MOV R4,#10
LOOP12:			MOV R5,#200
LOOP02:			DJNZ R5,LOOP02
			DJNZ R4,LOOP12
			RET		
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;ROTINA DE ABERTURA E FECHAMENTO DA GARRA;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

HORARIO:
MOV A,#00010000B
MOV P1,A
LOOP20:
LCALL TEMPO
ROTACIONARLEDs:
RL A
MOV P1,A
CJNE A,#1,LOOP20
SJMP HORARIO

ANTI:
MOV A,#10000000B
MOV P1,A
LOOP21:
LCALL TEMPO
ROTACIONARLEDs2:
RR A
MOV P1,A
CJNE A,#8,LOOP21
LCALL TEMPO
SJMP ANTI

TEMPO:		;rotina de tempo(20x50.000)
MOV R0,#12

LOOP10:
MOV TMOD,#00000001B
MOV TL0,#LOW(TEMP)
MOV TH0,#HIGH(TEMP)
SETB TR0
JNB TF0,$
CLR TR0
CLR TF0
DJNZ R0,LOOP10
RET


END
