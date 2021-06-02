; Leer una tabla en la rom y pasar a una tabla en la RAM solo los numero en asci
.dseg
	TABLA_RAM: .byte 1000

.cseg

.org 0x00
	rjmp main

.org 0x0500									; defino una tabla en la ROM
	TABLA_ROM: .DB 'a' , 'x' , '4' , 'c' , '7' , 'v' , 'z' , '0' , '5' , 't', '9', 0XFF


.org INT_VECTORS_SIZE


main:

	ldi  r16, HIGH(RAMEND)						; inicializacion stack pointer
	out  sph, r16
	ldi  r16, HIGH(RAMEND)
	out  spl, r16

incializacion_puntero:

	ldi  zh, HIGH(TABLA_ROM<<1)					; inicilizo el puntero Z en el primer elemento de la tabla guardada en memoria ROM
	ldi  zL, LOW(TABLA_ROM<<1)

	ldi  yh, HIGH(TABLA_RAM)					; inicilizo el puntero Y en el primer elemento de la tabla guardada en memoria ROM
	ldi  yL, LOW(TABLA_RAM) 
	
	ldi  r18, 0x30
	ldi  r19, 0x3A


procesar_tabla:
	ldi  r17, 0xFF

loop:
	lpm  r16, Z+								; leo de la TABLA_ROM				

	cp   r16, r17			
	breq fin									; branchea a main si el registro leido es 0XFF

	cp	 r16, r18								; compara si el numero es mayor a 30H, si no lo es toma otro elemento
	brlo loop

	cp   r16, r19								; si el nro fue mayor a 30H, se fija si es menor a 39H, si no lo es toma otro elemento
	brsh loop

	st   Y+,r16									; si el valor estaba entre 30H y 39H lo guarda en la RAM 
	nop
	rjmp loop


fin: rjmp fin