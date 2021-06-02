;
; Ejercicio_parcial_10.asm
;
; programar la subrutina RAND_8, la cual recibe en r0 el valor
; inicial del registro, en r1 la catidad de ciclos de reloj a iterar y devuelve en r2,
; el resultado. 

.def VALOR = r0
.def CICLOS = r1
.def RESULTADO = r2
.def AUX1 = r16
.def AUX2 = r17
.dseg 

.cseg

.org  0x500

TABLA: .DB "HolaGil"

.org 0x00
	jmp  main

.org INT_VECTORS_SIZE

main:
	ldi	 r16, HIGH(RAMEND)
	out  sph, r16
	ldi  r16, LOW(RAMEND)
	out  spl, r16		; inicializo el stack pointer al final de la RAM
	
	ldi  r16, 0x80
	mov  r0,  r16
	ldi  r16, 0x0A
	mov  r1,  r16

	rjmp rand_8				

; SUBRUTINAS --------------------

rand_8:
	mov  RESULTADO, VALOR
	mov  r18, CICLOS		; guardo el valor de ciclos
	
loop:
	clr  AUX1
	clr  AUX2
	bst  RESULTADO, 7		; guardo b7 en T
	bld	 AUX1, 0			; lo pongo en el bit 0 de AUX1
	bst  RESULTADO, 6		; guardo b6 en T
	bld  AUX2, 0			; lo pongo en el bit 0 de AUX2
	eor  AUX1, AUX2			; exoreo los registros
	lsl  RESULTADO			; shifteo r0
	or   RESULTADO, AUX1	; guardo (b6 exor b7) en b0nuevo de r0
	dec  CICLOS
	brne loop
	mov  CICLOS, r18




