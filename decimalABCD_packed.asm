; Ejercicio_parcial_1.asm
;

; realziar una rutina quepase un numero decimal a BCD empaquetado de un byte.
; Si no es posible volver de la rutina indicando que hubno un error

.def UNIDAD = r16
.def DECENA = r17
.def NUMERO = r18	; numero a convertir a BCD packed
.def NUMERADOR = r19
.def DENOMINADOR = r20
.def COCIENTE = r21
.def RESULTADO = r22
.def AUX = r23

.dseg 

.cseg

.org 0x00
	jmp main

.org INT_VECTORS_SIZE

main:
	ldi r16, HIGH(RAMEND)
	out sph, r16
	ldi r16, LOW(RAMEND)
	out spl, r16			; inicializo el stack pointer al final de la RAM
	
	ldi NUMERO, 78    

	rjmp convert_BCD_packed

    rjmp main

; SUBRUTINAS -------------------------------------

convert_BCD_packed:
	; convierte un numero decimal a BCD pack en un byte
	ldi DENOMINADOR, 10

	clr COCIENTE
	
l1:
	inc		COCIENTE
	sub		NUMERO, DENOMINADOR
	brpl	l1
	dec		COCIENTE 
	add		NUMERO, DENOMINADOR 
	;en NUMERO quedo el resto de la division (UNIDAD) Y el COCIENTE es la DECENA 

	mov	UNIDAD, NUMERO
	mov DECENA, COCIENTE

	; ahora lo tengo que guardar como BCD packed

	ldi RESULTADO, 0b00001111
	and RESULTADO, DECENA
	swap RESULTADO
	or RESULTADO, UNIDAD
	rjmp main






