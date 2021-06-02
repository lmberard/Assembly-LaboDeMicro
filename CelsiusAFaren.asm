; Ejercicio_parcial_6.asm

; codificar una rutina que recibe en R0 un valor de temp
; y devuelve en R1 el equivalente en grado farenheit.
; la conversion es C(9/5) + 32 = F
; sugerencia: 9/5 = 1,8 = 0001,11001101b


.def CELCIUS = r0
.def FAREN = r1
.def AUX_HIGH = r20
.def AUX_LOW = r19

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


	ldi r16, 32             ; grados celcius que voy a conertir
	mov CELCIUS, r16

	rjmp convert_faren		; convierte r0 a farenheith y lo guarda en r1

; SUBRUTINA ---------------------

convert_faren:
	; voy a aproximar a 9/5 por 461/2^8
	; entonces F = C*461/2^8+32
	
	mov AUX_LOW, CELCIUS
	
	ldi r25, 0x01 
	ldi r24, 0xCD ; cargo el 461 en r18:r17
		
	dec r24

multiplicacion:     ; hago 461*CELCIUS
	add AUX_LOW, CELCIUS
	brsh next
	inc AUX_HIGH
next:
	sbiw r25:r24, 1
	brne multiplicacion
	
	; tengo que dividir por 2^8 o lo que es lo mismo, quedarmo con el aux_high

	ldi r22, 32
	add AUX_HIGH, r22
	mov FAREN , AUX_HIGH
	nop






