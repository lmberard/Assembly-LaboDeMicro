; Ejercicio tipo aprcial 9

; Usando la subrutina RAND_8 del ejercicio 10 escribir el 
; codigo para inicializar un vector VAR2 en memoria RAM, con 
; nros aleatorios de la siguiente forma: tomar para r0 el 
; utimo valor calculador en r2 o 0x78 si es el primero.
; Para r1, tomar el valor actual del elemento del vector
; si es no nulo o 0x8f en caso contrario. Tiene 128 elementos  



.def VALOR = r0
.def CICLOS = r1
.def RESULTADO = r2
.def AUX1 = r16
.def AUX2 = r17
.def CONT = r20
.equ VECTOR_SIZE = 128

.dseg

var2: .byte VECTOR_SIZE

.cseg
.org 0x00
	jmp  main

.org INT_VECTORS_SIZE

main:
	ldi	 r16, HIGH(RAMEND)
	out  sph, r16
	ldi  r16, LOW(RAMEND)
	out  spl, r16			; inicializo el stack pointer al final de la RAM

	rjmp initialize_vector

here: rjmp here



; SUBRUTINAS --------------------

initialize_vector:
	ldi  zl, LOW(var2)
	ldi  zh, HIGH(var2)		; que z apunte al inicio del vector

	ldi  r18, 0x78
	mov  r0, r18			; pongo 0x78 en r0, primer valor inicial
	
	ldi  r18, 0x8F			
	mov  r1, r18			; pongo 0x8F en r1, cantidad de ciclos

	ldi  CONT, VECTOR_SIZE  ; contador que voy a usar
	clr  r21				; lo voy a usar para ver si el elemento del vector es 0 o no

l1:	
	rcall rand_8			; en r2 tengo un nro aleatorio
	ldi  CICLOS, 0x78
	st	 z+, RESULTADO		; lo guardo en el vector
	mov  VALOR, RESULTADO		; lo guardo en r0 (valor inicial para el proximo nro aleatorio)
	
	ld   r19, z				; chequeo si el siguiente elemento del vector es nulo 
	cp   r19, r21           ; comparo con r21 = 0         				
	breq next
	mov  CICLOS, r19		; si el elemento del vector no es 0, lo cargo en r1 (ciclos)
next:
	dec  CONT
	brne l1
	nop
	rjmp here


;--------------------------------

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

	ret

