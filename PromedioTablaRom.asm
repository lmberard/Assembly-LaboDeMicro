//////////////////////////////////////////////////////////////////////////////////
; Promedio.asm

; Levanta 16 valores de la tabla rom, los suma  y hace el promedio y el resultado lo copia en la memoria RAM 
; clave para ver como declarar cosas en la ram 
 .EQU TAMANIO = 16
 .EQU ROTAR_N = 4				; (LOG(2) TAMANIO) => cantidad de veces que tengo que rotar
 .DEF DUMMY = R20				; lo voy a usar para hacer la suma de los carrys
 .DEF TEMP_LOW = R22			; para poner los resultados de manera temporal
 .DEF TEMP_HIGH = R23		
 .DEF ITEM = R24
 .DEF CONTADOR = R25			; como una suerte de loop

 ;---- memoria RAM--------------------------------------------
.DSEG

	.ORG 0X100					;me "reserva" ese espacio de memoria para la label 0x100
	;.byte es como un malloc de bytes para el espacio de la memoria ram
RESULT: .byte 1					;aca voy a guardar el resultado total de la cuenta
VECTOR: .byte TAMANIO			;vector va a estar en 0x101
;-----end memoria ram----------------------------------------

;-----------segmento de codigo-------------------------------
.CSEG
	RJMP MAIN

.ORG INT_VECTORS_SIZE

MAIN:
	; inicializacion stack pointer=> GOOD PRACTICE
		LDI R16, LOW(RAMEND)
		OUT SPL, R16			;SPL=STACK POINTER LOW
		LDI R16, HIGH(RAMEND)
		OUT SPH, R16			;SPL=STACK POINTER HIGH

	; INICIALIZO PUNTEROS para ubicar los valores de la tabla rom:
		LDI ZL, LOW(TABLA_ROM<<1)			;registros 30 y 31
		LDI ZH, HIGH(TABLA_ROM<<1)
		LDI XL, LOW(RESULT)					;registros 26 y 27
		LDI XH, HIGH(RESULT)

	; INICIALIZO CONTADOR
		LDI CONTADOR, TAMANIO				;lo inicializo con la cantidad de cosas en la tabla, para despues ir decrementando y chequeando
 		CALL LEER_VALOR						; aca estoy usando una rutina!!!!

	; DIVIDO POR 16
		/*
		rotar a la derecha es dividir por 2, rotar a la izq es multiplicar por 2
		si yo hice 16 sumas, y quiero dividir por 16, tengo que rotarlo 4 VECES
		*/
		LDI CONTADOR, ROTAR_N
	
	ROTAR:
		LSR TEMP_HIGH		;logical shift me rota a la derecha y me pone un cero en la primer posicion, lo que "tira"(bit menos signifcicativo) pasa al carry
		ROR TEMP_LOW		;lo que estaba en el carry lo voy a poner en el bit mas significativo del carry, y lo que esta en el bit menos significativo lo manda al carry
		;ROR R25
		DEC CONTADOR
		CPI CONTADOR, 0x00
		BRNE ROTAR			;para que lo haga 4 veces
	; CARGO RESULTADO
		ST X, TEMP_LOW

	FIN: RJMP FIN

;------------------------------------------------------------
;la rutina tiene que estar despues del fin
LEER_VALOR:
		PUSH R0							;guardo en el stack lo que haya en R0
		PUSH R1
	; LEO UN VALOR DE LA TABLA ROM
	LOOP:	
		INC R0
		LPM ITEM, Z+					;lee lo del principio de la tabla rom (osea el numero 10), lo guarda en ITEM y despues incrementa el puntero Z
	; LO SUMO A AL ACUMULADO
		CLR DUMMY						;lo borro porque aca voy a ir guardando el carry que se me haga en las sumas
		ADD TEMP_LOW, ITEM				;sumas sin carry
		ADC TEMP_HIGH, DUMMY			;agrego el carry 
	; CHEQUEO SI ES EL ULTIMO VALOR, SI NO VUELVO A LEER
		DEC CONTADOR
		CPI CONTADOR, 0x00				;decremento el contador y lo comparo con cerp
		BRNE LOOP						;si ese valor NO ES CERO, vuelvo al loop!! ojo vuelve al loop, no al leer valor porque sino pushearia mil veces y ROMPE	
		POP R1							;saco lo que tenia en el stack ( r1 va a salir con lo que entro)
		POP R0							;chequar el orden!!!! 
		;TODO LO QUE PUSHEO, LO TENGO QUE POPEAR PORQUE SINO CUANDO TERMINE ME VA A DEVOLVER 
		;A CUALQUIER DIRECCION
	RET ;IDEM SI NO PONGO RET PORQUE YO QUIERO QUE RETORNE A LA INSTRUCCION Q LE SIGUE AL CALL

;------------------------------------------------------------
;yo quiero valores fijos asignados y para eso tienen que estar en la ROM
;cuando yo inicializo arriba (abajo de cseg) el PC va a querer ver los dos primeros (lee 2 bytes) y va a pensar que es una instruccion
;ACA NO SON INSTRUCCIONES entonces las va a querer ejecutar y pierde tiempo o puede tener problemas
;siempre hay que declararlas despues de poner el codigo

;la rom guarda de a 2 bytes a la vez pero cuando yo la quiero leer la tengo que leer de a posiciones de a bytes no de a words por eso despues yo lo hago como low y high 
;cuando armo los punteros
TABLA_ROM: .DB 10,20,30,40,50,60,70,80,90,100,110,120,130,140,150,160
