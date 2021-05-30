;
; EntradaPorPolling.asm
;
; Created: 30/5/2020 16:28:51
; Author : Ignacio
;
;----------------------------------
#define monolitico

;#define tareas
;#define varios_ret
;#define un_ret
;----------------------------------
.include "m328pdef.inc"

.def dummyreg = r16			
.equ pinEntrada = 7
.equ pinLed = 5

;----------------------------------
.cseg 
.org 0x0000
			jmp		configuracion

.org INT_VECTORS_SIZE	;es una posicion de memoria de codigo (entre 0 y ese valor se guarda para los vectores de interrupcion!!)

;----------------------------------
configuracion:
; Inicializacion stack pointer al finhak de la memoria
			ldi dummyreg,low(RAMEND)
			out spl,dummyreg
			ldi dummyreg,high(RAMEND)
			out sph,dummyreg			
; Led en PB5 (arduino uno) 
; entrada en PD7 (DIO 7)
; Configuro puerto B
			ldi		dummyreg,0xff	;(PORTB como salida)
			out		DDRB,dummyreg
; configuro puerto D
			ldi		dummyreg,0x00	;(PORTD como entrada)
			out		DDRD,dummyreg
			ldi		dummyreg,0xFF	;(PORTD pull-ups activados)
			out		PORTD,dummyreg

;***********************************************************
; Variante 1: Leo y ejecuto o salto la instruccion correspondiente
;si ese label "monolitico" esta definido, ejecuto todas esas cosas:
#ifdef monolitico
main:
;sbis se fija un registro de I/0 y si esta el bit esta seteado en 1, salta a la prox instruccion
			sbis	PIND,pinEntrada		; leo el pin, si esta en uno (entrada sin activar, el uno lo pone el pull-up), salto la instruccion de prender el led
;si esta pulsado se pone en cero, por eso digo si esta en 1 segui y PRENDELO
			sbi		PORTB,pinLed 		; encendido del led
			sbic	PIND,pinEntrada		; leo el pin, si esta en cero (entrada activada), salto la instruccion de apagar led
			cbi		PORTB,pinLed		; apagado del led
			jmp		main				; reinicio el ciclo
#endif
;esta forma no es muy legible

;************************************************************
; Variante 2: Llamo a distintas tareas en el ciclo principal (esta forma es + legible)
#ifdef tareas
main:		
			call	leer_entrada
			call	escribir_salida
			jmp		main	

; lee el estado de la entrada y deja el bit T en 1 si la entrada es 0; deja el bit T en 0 si la entrada es 1
leer_entrada:
			in		dummyreg,PIND	; como no puedo leer un pin directamente al bit T, leo el puerto
			com		dummyreg			; invierto la entrada para que T sea 1 con entrada 0
			bst		dummyreg,pinEntrada		; muevo el bit de entrada del puerto al bit T
			ret	
			;bst agarra un bit del registro y lo pone en el bit (flag) T del sreg
#endif
;----------------------------------
; Variante 2.1: varios RET
#ifdef varios_ret
escribir_salida:
; pongo la salida en 1 o 0 de acuerdo al valor del bit T
			brtc	apagar_led	; si T esta en cero, paso a apagar el led		
			sbi		PORTB,pinLed 	; enciendo el led y salgo
			ret
apagar_led:	cbi		PORTB,pinLed		; apago el led y salgo
salir:		ret					
#endif
;esta opcion es de varios ret y es medio dificil de leer. no esta buena

;-----------------------------------
#ifdef un_ret
; Variante 2.2: un solo RET => mejor esta opcion
escribir_salida:
; pongo la salida en 1 o 0 de acuerdo al valor del bit T
			brtc	apagar_led	; si T esta en cero, paso a apagar el led		
			sbi		PORTB,pinLed 	; encendido del led
			brts	salir 		; si T esta en uno, ya prendi el led, salgo (tambien podria ser "jmp salir")
apagar_led:	cbi		PORTB,pinLed		; apagado del led
salir:		ret					
#endif


;----------------------------------
