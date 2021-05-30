
;----------------------------------
.include "m328pdef.inc"

.def dummyreg = r16
.equ pinInPinChange = 0
.equ pinLed = 5

;----------------------------------
.cseg 
.org 0x0000
			jmp		configuracion

;interrupciones, cuando pasa eso quiero que salte a esos labels
.org INT0addr				;pin externo
			jmp		isr_int0
.org PCI0addr				;pin de I/O cambia su valor
			jmp		isr_pci0

.org INT_VECTORS_SIZE

;----------------------------------------------------------------------------------------------------
;----------------------------------------------------------------------------------------------------
configuracion:
; Inicializacion stack pointer
			ldi dummyreg,low(RAMEND)
			out spl,dummyreg
			ldi dummyreg,high(RAMEND)
			out sph,dummyreg		
; Entrada de interrupcion externa en PD2 (DIO 2)
; Led en PB5 (arduino uno) 
; Pin change PCINT0 en PB0 (DIO 8)
; Configuro low nible como entrada, high nible como salida
; Configuro puerto B
			ldi		dummyreg,0xf0	; Parte alta del PORTB como salida, parte baja como entrada
			out		DDRB,dummyreg
			ldi		dummyreg,0x0f	; pullups de la parte baja del PORTB activados
			out		PORTB,dummyreg
; configuro puerto D
			ldi		dummyreg,0x00	;(PORTD como entrada)
			out		DDRD,dummyreg
			ldi		dummyreg,0xFF	;(PORTD pull-ups activados)
			out		PORTD,dummyreg
; pongo al cero el bit T del SREG
			clt
; configuro interrupcion externa 0
;isc01, int0 y todos esos vienen en cero pero deberia forzar en cero 
;tb deberia poner un clr dummyreg para ponerlo en cero por las dudas(aunque en teoria ya viene en cero)
			ldi		dummyreg,(1 << ISC01) ;0x02	; IE0 por flanco descendente (ISC01=1;ISC00=0)
			sts		EICRA,dummyreg		 ;observaddd que uso STS y no out!!!
			ldi		dummyreg,(1 << INT0) ;0x01	; habilito IE0 
			out		EIMSK,dummyreg
; configuro pin change 0	
			ldi		dummyreg,(1 << PCIE0) ;0x01	; habilito interrupciones pin change para el grupo 0 (PC0-PC7)
			sts		PCICR,dummyreg
			ldi		dummyreg,( 1 << PCINT0) ;0x01	; habilito interrupcion pin change del pin PC0
			sts		PCMSK0,dummyreg
; habilito interrupciones globales
			sei					
			;=> tengo 3 configuraciones para las interrupciones:
				;sei que es la global
				;PCICR que es nivel de habilitacion por un grupo de 8 bits
				;PCMSK que es nivel de habilitacion a nivel individual

;termina las configuraciones
;----------------------------------------------------------------------------------------------------
;----------------------------------------------------------------------------------------------------


;----------------------------------------------------------------------------------------------------
; bucle principal
; como la lectura de la entrada es por interrupcion, la unica tarea en el bucle principal es 
; fijar la salida de acuerdo al valor del bit T
main:		
			call	escribir_salida			;solo llamo a esto porque lo otro se va a hacer por una interrupcion externa
			jmp		main	

escribir_salida: ;idem caso de polling
; pongo la salida en 1 o 0 de acuerdo al valor del bit T
			brtc	apagar_led	; si T esta en cero, paso a apagar el led		
			sbi		PORTB,pinLed 	; encendido del led
			brts	salir 		; si T esta en uno, ya prendi el led, salgo (tambien podria ser "jmp salir")
apagar_led:	cbi		PORTB,pinLed		; apagado del led
salir:		ret					


;----------------------------------------------------------------------------------------------------
; rutina de interrupcion externa 0
; invierte el valor del bit T cada vez que se ejecuta
isr_int0:
			brbc	SREG_T,t_es_ceroA ; si T esta en cero, salto para ponerlo en uno
			;brbc ve si el bit T esta en cero 
			clt					; no salte, T esta en uno, lo pongo en cero
			reti				; salgo de la rutina
t_es_ceroA:	set					; como T esta en cero, lo pongo en 1			
			reti
			
; rutina de interrupcion pin change 0
; invierte el valor del bit T cada vez que se ejecuta
isr_PCI0:
			brbc	SREG_T,t_es_ceroB ; si T esta en cero, salto para ponerlo en uno
			clt					; no salte, T esta en uno, lo pongo en cero
			reti				; salgo de la rutina
t_es_ceroB:	set					; como T esta en cero, lo pongo en 1			
			reti				;analogo al ret pero aca me pone en 0 el bit q indica q hubo una interrupcion y leer del stack pointer donde estaba ejecutando
				