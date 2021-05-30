
; EjemploMacro.asm

.include "m328pdef.inc"

; Definiciones de registros
.def dummyreg = r16			;aca voy a guardar cosas
.def RegRetA = r17			;estos tres registros los voy a usar para el retardo de los "fors anidados" para el parpadeo de un led
.def RegRetB = r18
.def RegRetC = r19

; Asignacion de Pines
.equ pinLed = 5

;-------------------------------------------------------------------------------------
; Definicion de Macros
; esta macro decrementa el registro que se pasa como argumento 1 y si llega a cero, 
; salta a la etiqueta que se pasa como argumento 2
; uso:		djnz	<Rd>,<Etiqueta>
.macro	djnz
			dec		@0
			tst		@0			;para ver si es cero
			brne	@1			;si no es cero, salto a la etiqueta
.endmacro
;-------------------------------------------------------------------------------------

.cseg 
.org 0x0000
			jmp		configuracion

.org INT_VECTORS_SIZE
configuracion:
; Inicializacion stack pointer
			ldi dummyreg,low(RAMEND)
			out spl,dummyreg
			ldi dummyreg,high(RAMEND)
			out sph,dummyreg
; Led en PB5 (arduino uno) 
; Configuro puerto B
			ldi		dummyreg,0xff	;(PORTB como salida)
			out		DDRB,dummyreg

;-------------------------------------------------------------------------------------
; Ciclo principal
main:
			sbi		PORTB,pinLed 		; encendido del led
			call	retardo
			cbi		PORTB,pinLed		; apagado del led
			call	retardomacro
			jmp		main

;-------------------------------------------------------------------------------------
retardo:
			ldi 	RegRetA,0x00
			ldi 	RegRetB,0x00
			ldi		RegRetC,0x00
ciclo1:		inc		RegRetA
			cpi		RegRetA,0xff
			brlo	ciclo1
			ldi		RegRetA,0x00
			inc		RegRetB
			cpi		RegRetB,0xff
			brlo	ciclo1
			ldi		RegRetB,0x00
			inc		RegRetC
			cpi		RegRetC,0x20
			brlo	ciclo1
			ret
;-------------------------------------------------------------------------------------	
;es lo mismo y tarda lo mismo pero con las macros es muchisimo mas legible:	
retardoMacro:
			ldi 	RegRetA,0xff
			ldi 	RegRetB,0xff
			ldi		RegRetC,0x20
ciclo2:		djnz	RegRetA,ciclo2
			ldi		RegRetA,0xff
			djnz	RegRetB,ciclo2
			ldi 	RegRetB,0xff
			djnz	RegRetC,ciclo2
			ret
