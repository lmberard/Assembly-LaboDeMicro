

;Programar una rutina que lea una tabla alojada en SRAM 
;a partir de la direccion TABLA_RAM, y que finaliza con el valor 0xFF.
; El byte leido se pasa en R20 como parametro de entrada de la rutina 
;CALCULA_PARIDAD. Cuando no hay mas datos se regresa con RET.

.EQU TABLA_SIZE=10
.EQU TABLA_RAM=SRAM_START 
.EQU MASCARA_DECIMAL=1
.EQU MASCARA_BIT=0x80


.DSEG

.ORG TABLA_RAM 
	var1:		.BYTE 1
	Tabla:		.BYTE TABLA_SIZE ;Esta tabla contiene los valores alojados en la direccion tabla_ram 
	Paridad:	.BYTE TABLA_SIZE ;Aca guardo los valores de paridad

.CSEG
;Cargo la tabla con numeros del 1 al 9 y al final pongo un 0xff
.ORG 0x00
	LDI ZL, LOW(Tabla)
	LDI ZH, HIGH(Tabla)
	LDI R20, TABLA_SIZE-1
	LDI R19, 0x1

CARGAR_TABLA:
	ST Z+, R19
	INC R19
	DEC R20
	BRNE CARGAR_TABLA
	LDI R19, 0xFF
	ST Z, R19
;aca empieza el ejercicio


MAIN:
	LDI ZL, LOW(Tabla)
	LDI ZH, HIGH(Tabla)
	LDI XL, LOW(Paridad)
	LDI XH, HIGH(Paridad)
	LDI R19, TABLA_SIZE ;esto lo uso para terminar el loop de los valores 
	CALL PARIDAD_BIT

FIN:
	JMP FIN
; Esta funcion cuenta la cantidad de unos en el numero que me pasan
;Primero le aplico una mascara al numero para ver el ultimo bit, veo si el resultado da 1 entonces sumo un al contador, igualmente despues 
;cambio la mascara para ver el anteultimo bit, y asi sucecivamente. Despues me fijo si el contador es par o impar: si es
;par entoces pongo un 0 en la nueva tabla, sino pongo un 1
PARIDAD_BIT:
	LDI R18, MASCARA_BIT ; Cargo en el registro la mascara
	CLR R23; este lo uso para contar la cantidad de 1s
	CLR R24; Este registro lo uso para comparar para ver si tengo que sumar un uno o no
BIT:
	LD R20,Z ;Cargo siempre el numero para aplicarle la mascara
	AND R20,R18 ;Le aplico la mascara al numero de la tabla  
	CPSE R20, R24 ; Compara con 0, sino incrementa 1 al contador
	INC R23
	LSR R18; shifteo la mascara
	BRCC BIT; voy a cortar cuando la mascara sea 0 y me ponga un uno en el carrie 
	CALL CALCULA_PARIDAD_EN_DECIMAL
	LD R20,Z+
	DEC R19
	BRNE PARIDAD_BIT
	RET
;calculo si el contador es par o impar y lo cargo en la tabla paridad
CALCULA_PARIDAD_EN_DECIMAL:
	ANDI R23, MASCARA_DECIMAL;me fijo si el ultimo bit es 1 o 0
	ST X+, R23
	RET
