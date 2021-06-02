/*----------------------------------------------------------------------------
				Parcial 2do cuatrim 2014 - Ejercicio 1

 Programar en Assembly un bucle infinito que:
	-lea los 8 bits de los terminales del puerto B => puerto B entrada
	-se lo pasa a un rutina FILTRO a través de una variable ENTRADA en RAM
	-Luego recibe en la variable SALIDA el resultado
	-saca el resultado por el puerto C. ]=> portC como salida

	Antes de invocar a FILTRO por primera vez:
	-Definir las variables en memoria RAM
	-inicializar SALIDA en 0 y la pila .
------------------------------------------------------------------------------*/ 
.INCLUDE "m328pdef.inc"

.DSEG
.ORG 0x100
	;ej1
	ENTRADA:	.byte 1
	SALIDA:		.byte 1
	;ej2
	E:			.byte 1
	S:			.byte 1

;--------------------------------------------------------------------------------
;Inicio del segmento de codigo y configuracion
.CSEG
.ORG 0X0000
	RJMP	CONFIG

.ORG INT_VECTORS_SIZE

CONFIG:
	;Inicializacion Stack Pointer
	LDI		R16, LOW(RAMEND)	
	OUT		SPL, R16			
	LDI		R16, HIGH(RAMEND)
	OUT		SPH, R16			

	;Configuracion puertos
	LDI		R17, 0x00			;variable aux para inicializar SALIDA
	STS		SALIDA, R17			;inicialice salida
	OUT		DDRB, R17			;seteo puerto B como entrada
	LDI		R18, 0xFF			;para setear portC como salida
	OUT		DDRC, R18			;seteo portC como salida
	
;--------------------------------------------------------------------------------
;Ciclo principal
LOOP:
	IN		R19, PINB
	STS		ENTRADA, R19		;guardo la variable en ENTRADA, que se ubica en la SRAM
	RCALL	FILTRO
	LDS		R20, SALIDA			;cargo lo de SALIDA, lo q deviuelve filtro
	OUT		PORTC, R20
	RJMP	LOOP

;--------------------------------------------------------------------------------
;					Ejercicio 2 - Rutina para el filtro
/*
Programar en Assembly una rutina (FILTRO) que calcula la respuesta del siguiente filtro 
de 1er orden: 
				S(k+1) = (1/4)*E(k) + (3/4)*S(k)  

donde E(k), S(k) y S(k+1) son variables de 8 bits alojadas en RAM. 
Sugerencia: Se supone que la rutina lee los valores E y S (en el tiempo k) calcula la 
nueva salida S(k+1) y pisa el viejo valor en RAM de S(k). 

------------------------------------------------------------------------------*/ 
FILTRO:
;tengo que usar E y S o esta bien si uso el ENTRADA Y SALIDA que defini antes??
	;cargo valores
	LDS		R19, E				;cargo E en R19
	LDS		R20, S				;cargo S

	;divido por 4
	LSR		R19					;shifteo para dividir por 2
	LSR		R19					;idem 
	;hasta aca tengo E/4

	LDI		R21, 3
	MUL		R20, R21			;3*S

	;divido por 4
	LSR		R20					;divido por 2
	LSR		R20					;divido por 2

	ADD		R20, R19			;salida = E/4 + 3*S/4
	STS		S, R20			;guardo en la memoria SRAM, SALIDA, el resultado
	RET

