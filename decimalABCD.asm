; Ejercicio_parcial_5.asm
;

; se mide una tension analoggica con un conversor AD de 8 bits,
; y una tension de referencia de 1 Volt. Programar una rutina 
; que reciba en R0 el valor del AD y devuelva en R4, R3, R2 las centenas
; decenas y unidades del valor de tension en milivoltios en bormato BCD
; desepaquetado. 0 Vlt representan el valor 00000000 y 1 Volt 11111111

.def UNIDAD = r16
.def DECENA = r17
.def CENTENA = r18

.def COCIENTE = r21
.def RESULTADO = r22
.def AUX = r23

.def NUMERADOR_LOW = r24
.def NUMERADOR_HIGH = r25


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

config_puerto:
	ldi r16, 0x00
	out DDRB, r16			; PUERTO B de entrada

codificacion:
	in r0, PINB
	
	; en r0 tengo un valor que va de 0 a 255, y cada salto equivale
	; a 4 mV del conversor

	
	ldi r16, 4
	mul r16, r0

	; para hacer la prueba de que funciona
    ldi r19, 23
	mul r16, r19

bcd_conversion:
	ldi zl, LOW(0x0010)
	ldi zh, HIGH(0x0010)  ; direccion de DECENA
	ldi AUX, 2            ; variable auxiliar

	mov NUMERADOR_LOW, r0	;traigo de r1:r0 el valor de tension en bits
	mov NUMERADOR_HIGH, r1

loop1:	
	clr COCIENTE
l1:
	inc		COCIENTE
	sbiw	NUMERADOR_HIGH:NUMERADOR_LOW, 10
	brpl	l1									; resto hasta que me de negativo
	dec		COCIENTE 
	adiw	NUMERADOR_HIGH:NUMERADOR_LOW, 10	; en NUMERADOR_LOW me queda el resto, valor de la derecha del numero
	st		z+, NUMERADOR_LOW
	mov     NUMERADOR_LOW, COCIENTE				; la primera vez, en cociente me queda un numero de dos cifras, ese es mi nuevo numero
	dec     AUX
	brne    loop1
	st      z, NUMERADOR_LOW		

	; Y EN R18, R17, R16 ME QUEDA CADA CIFRA
	



