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

