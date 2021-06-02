; Ejercicio_parcial_8.asm
; 
; Escribir una rutina que divda dos numeros de dos bytes
; numero1 y numero2 que estan en la RAM  y devolver el resultadp
; en una tercer variable de la RAM, resultado 

.def COCIENTE_LOW = r24
.def COCIENTE_HIGH = r25

.def NUM_LOW = r22
.def NUM_HIGH = r23

.def DEN_LOW = r20
.def DEN_HIGH = r21

.dseg 

numero1: .byte 2
numero2: .byte 2

resultado: .byte 2

.cseg
.org 0x00
	jmp main

.org INT_VECTORS_SIZE

main:
	ldi r16, HIGH(RAMEND)
	out sph, r16
	ldi r16, LOW(RAMEND)
	out spl, r16			; inicializo el stack pointer al final de la RAM

	rcall cargar_datos
	
	rjmp division

here: rjmp here

; SUBRUTINAS -----------------------------------------


cargar_datos:				; cargo las variables numero1 y numero2
	ldi r16, LOW(0xFFCD)			
	sts numero1, r16
	ldi r16, HIGH(0xFFCD)
	sts numero1+1, r16		; guardo el numero FFCD=65485 en numero1

	ldi r16, LOW(0x0135)			
	sts numero2, r16
	ldi r16, HIGH(0x0135)
	sts numero2+1, r16		; guardo el numero 0135=309 en numero2
	ret

division:
	lds NUM_LOW, numero1	; paso numero1 y numero2 a registros
	lds NUM_HIGH, numero1+1
	lds DEN_LOW, numero2
	lds DEN_HIGH, numero2+1

	clr COCIENTE_LOW
	clr COCIENTE_HIGH

loop:
	adiw COCIENTE_HIGH:COCIENTE_LOW, 1
	sub  NUM_LOW, DEN_LOW
	sbc  NUM_HIGH, DEN_HIGH
	brsh loop				; resto hasta que NUM_HIGH me de negativo
	sbiw COCIENTE_HIGH:COCIENTE_LOW, 1 	
	add  NUM_LOW, DEN_LOW	; dejo en el NUMERADOR el resto de la division
	adc  NUM_HIGH, DEN_HIGH
	
	sts resultado, COCIENTE_LOW		; lo cargo en la RAM el cociente
	sts resultado+1, COCIENTE_HIGH

	rjmp here









