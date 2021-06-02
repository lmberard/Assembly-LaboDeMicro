
;Codificar en assembler para AVR una subrutina que, dados dos numeros de 8bits con signo
;en convencion complemento a 2 en los registros R16(dividendo) y R17 (divisor), devuelva
;el resultado de su division en R18 el cociente  y en R19 el resto y el bit T(SREG,6) en
;uno si el divisor es 0

; Replace with your application code

.DEF DIVIDENDO = R16
.DEF DIVISOR = R17
.DEF COCIENTE = R18
.DEF RESTO = R19
.DEF AUX1 = R20
.DEF AUX2 = R21

.EQU MASCARA_SIGNO = 0b10000000

.CSEG
SETEO:
	CLR AUX1
	CLR AUX2
	LDI DIVIDENDO, -17
	LDI DIVISOR, -4
MAIN:
	SBRC DIVIDENDO, 7
	RCALL NEGAR_DIVIDENDO
	SBRC DIVISOR, 7
	RCALL NEGAR_DIVISOR
	RJMP RESTAS_SUCESIVAS

NEGAR_DIVIDENDO:
	NEG DIVIDENDO
	INC AUX1
	RET

NEGAR_DIVISOR:
	NEG DIVISOR
	INC AUX2
	RET

RESTAS_SUCESIVAS:
	CP DIVIDENDO, DIVISOR
	BRLO TERMINAR_DIVISION
	SUB DIVIDENDO, DIVISOR
	INC COCIENTE
	RJMP RESTAS_SUCESIVAS

TERMINAR_DIVISION:
	MOV RESTO, DIVIDENDO
	EOR AUX1, AUX2
	SBRC AUX1, 0
	NEG COCIENTE
	RJMP FIN

FIN:
	RJMP FIN

;OTRA OPCION:
;Codoficar una subrutina quye dados dos numeros de 8 biuts
;con signo en convencion complemento a 2 en r16 y r17 devuelva
; el resultado de su divison en r18 y en r19 el resto. 
;El bit T en 1 si el divisor es cero.


.def NUMERADOR   = r16
.def DENOMINADOR = r17
.def QUOTIENT    = r18
.def RESTO       = r19


.org 0x00
	rjmp main

.org INT_VECTORS_SIZE
	

main:	

	ldi NUMERADOR, 54
	neg NUMERADOR
	ldi DENOMINADOR, 4
	neg DENOMINADOR

division:

	clt						; limpia el T
	clr  r20
	clr  QUOTIENT

	sbrs NUMERADOR, 7
	rjmp next
	neg  NUMERADOR
	inc  r20

next:

	sbrs DENOMINADOR, 7
	rjmp next1
	neg  DENOMINADOR
	inc  r20
	
next1:

	inc  QUOTIENT
	sub  NUMERADOR, DENOMINADOR
	brpl next1
	
	dec  QUOTIENT
	add  NUMERADOR, DENOMINADOR
	
	sbrc r20,0
	neg  QUOTIENT
	
	mov  RESTO, NUMERADOR	
	rjmp main		
