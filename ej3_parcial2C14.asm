/*----------------------------------------------------------------------------
				Parcial 2do cuatrim 2014 - Ejercicio 3

Programar una rutina que levante una tabla ubicada en ROM (TABLA_ROM) y copie a 
una tabla ubicada en SRAM (TABLA_RAM) solamente los ASCII de números 
(ASCII(‘0’)=30h … ASCII(‘9’)=39h).
La Tabla en ROM termina con 0xFF y no tiene más de 1000 posiciones.  

------------------------------------------------------------------------------*/ 
.INCLUDE "m328pdef.inc"

.EQU	VAL_MAX = ?????	
.EQU	VAL_min = ?????
.EQU	END_ROM = 0xFF

.DEF	REG_ROM	= R16
.DEF	REG_MIN = R17
.DEF	REG_MAX = R18
.DEF	REG_ENDROM = R19

;--------------------------------------------------------------------------------
.DSEG
.ORG	0X100
	TABLA_RAM: .byte 1000

;--------------------------------------------------------------------------------
.CSEG
.ORG 0X0000
	RJMP	CONFIG

.ORG INT_VECTORS_SIZE

CONFIG:
	;Inicializacion del stack pointer
	LDI		R20, LOW(RAMEND) 
	OUT		SPL, R20 
	LDI		R20, HIGH(RAMEND)
	OUT		SPH, R20 

	;apunto a la tabla de la ROM
	LDI		ZL, LOW(2*TABLA_ROM) ;es lo mismo que hacer (tabla_Rom << 1)
	LDI		ZH, HIGH(2*TABLA_ROM)
	;apunto a la tabla de la RAM
	LDI		XL, LOW(TABLA_RAM)
	LDI		XH, HIGH(TABLA_RAM)

;--------------------------------------------------------------------------------
LOOP:
	;cargo el comienzo de la tabla rom en reg_rom e incremento el puntero
	LPM		REG_ROM, Z+				
	;cargo los valores en los registros
	LDI		REG_MIN, VAL_MIN
	LDI		REG_MAX, VAL_MAX
	LDI		REG_ENDROM, END_ROM
			
	;comparo si llego al final de la tabla rom:
	CP		REG_ROM, REG_ENDROM	
	BREQ	TERMINAR				;si son iguales(llego al final) => terminar

	;verifico si es un ascii de numero asi?
	CP		REG_MAX, REG_ROM
	BRLO	LOOP					;si reg_max < reg_rom => loop
	CP		REG_ROM, REG_MIN
	BRLO	LOOP					;si reg_rom < reg_min => loop

	;si todo va bien, copio y vuelvo a loop
	RCALL	COPIAR
	RJMP	LOOP

;--------------------------------------------------------------------------------
TERMINAR:
	RJMP	TERMINAR

COPIAR:
	ST		X+, REG_ROM	;copio el reg_rom en la ram(x) e incremento el puntero
	RET

;--------------------------------------------------------------------------------
TABLA_ROM:	.DB "1234",6,"HOL1",0XFF 