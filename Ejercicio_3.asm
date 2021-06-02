;****************************************************************************************************************
; Parcial 24-JUN-2020, Ejercicio 3
/* 
Se tiene un microcontrolador con dos interruptores, S0 y S1, conectados entre GND y las 
entradas de interrupción externas INT0 e INT1. 

Escribir un programa con las interrupciones externas configuradas por FLANCO DESCENDENTE y con sus resistencias de PULL-UP ACTIVADAS 
-cuando se presiona S0 se decrementa el contenido del PORTB 
-cuando se presiona S1 se incrementa el contenido de dicho puerto.

-Indicar con PC0 si el valor de PORTB desciende hasta 0x10
-Indicar con PC1 si el valor de PORTB asciende hasta 0xF0. 

-Si el valor de PORTB llega a 0x10; 
	-no seguir decrementando
	-dejarlo fijo-
	poner a ‘1’ PC0  (sino PC0 debe valer ‘0’). 

-Si el valor de PORTB llega a 0xF0;
	-no seguir incrementando
	-dejarlo fijo
	-poner a ‘1’ PC1 (sino PC1 debe valer ‘0’). 

Configurar inicialmente PORTB en 0x7F, PC0 y PC1 en ‘0’.
*/
;****************************************************************************************************************

.INCLUDE "m328pdef.inc"

.DEF AUX=R16

;--------------------------------------------------------------
.CSEG
.ORG 0X0000
		RJMP	config

/*Se tiene un microcontrolador con dos interruptores, S0 y S1, conectados entre GND y las 
entradas de interrupción externas INT0 e INT1. */
;INTERRUPTOR S0
.org INT0addr
		RJMP	isr_int0
;INTERRUPTOR S1
.org INT1addr
		RJMP	isr_int1

.ORG INT_VECTORS_SIZE

;--------------------------------------------------------------
/*
Escribir un programa con las interrupciones externas configuradas por FLANCO DESCENDENTE y con sus resistencias de PULL-UP ACTIVADAS
Configurar inicialmente PORTB en 0x7F, PC0 y PC1 en ‘0’. */
config:	
		;inicializacion del stack pointer
		LDI		AUX, HIGH(RAMEND)		
		OUT		SPH, AUX			
		LDI		AUX, LOW(RAMEND)		
		OUT		SPL, AUX

		;Config puerto B como salida e inicializado en 0x7F
		LDI		AUX, 0XFF						
		OUT		DDRB, AUX				;Declaro al puerto B como salida
		LDI		AUX, 0X7F							
		OUT		PORTB, AUX				;Inicializo al puerto B en 0X7F(enunciado)

		;Config PC0 y PC1 como salida e inicializados en ‘0’.
		LDI		AUX, 0XFF						
		OUT		DDRC, AUX				;Declaro al puerto C como salida
		LDI		AUX, 0X00						
		OUT		PORTC, AUX				;Inicializo al puerto C en estado logico bajo

		;Confif puerto D como entrada, con R pull up
		LDI		AUX, 0X00						
		OUT		DDRD, AUX				;Declaro al puerto D como entrada
		LDI		AUX, 0b00001100					
		OUT		PORTD, AUX				;Activo resistencias Pull-up en los pines PD2 Y PD3
		
		;Config IE0 y IE1 por flanco descendente
		LDI		AUX, 0b00001010			
		STS		EICRA, AUX				
		LDI		AUX, 0b00000011					
		OUT		EIMSK, AUX				

		SEI	
;--------------------------------------------------------------		
main:
		RJMP	main

;--------------------------------------------------------------
/*
cuando se presiona S0 se decrementa el contenido del PORTB
-Indicar con PC0 si el valor de PORTB desciende hasta 0x10
-Si el valor de PORTB llega a 0x10; 
	-no seguir decrementando
	-dejarlo fijo-
	poner a ‘1’ PC0  (sino PC0 debe valer ‘0’). 
*/
isr_int0:
		IN		AUX, PORTB				;Leo el valor que tengo en el puerto B y lo guardo en AUX
		CPI		AUX, 0X10							
		BREQ	retorno					;Si AUX=0X10 salto a retornar sin alterar nada
		
		DEC		AUX								
		OUT		PORTB, AUX				;Decremento AUX y lo cargo en el puerto B
		CPI		AUX, 0X10							
		BREQ	encender_PC0			;Si AUX=0X10 salto a poner en 1 a PC0

		CBI		PORTC, 0				;Como AUX es diferende de 0X10 pongo en 0 PC0
		CBI		PORTC, 1				;Pongo en 0 a PC1 porque tambien AUX es diferente de 0XF0
		RETI	
/*
-cuando se presiona S1 se incrementa el contenido de dicho puerto.
-Indicar con PC1 si el valor de PORTB asciende hasta 0xF0. . 
-Si el valor de PORTB llega a 0xF0;
	-no seguir incrementando
	-dejarlo fijo
	-poner a ‘1’ PC1 (sino PC1 debe valer ‘0’). 
*/
isr_int1:
		IN		AUX, PORTB				;Leo el valor que tengo en el puerto B y lo guardo en AUX
		CPI		AUX, 0XF0							
		BREQ	retorno					;Si AUX=0XF0 salto a retornar sin alterar nada

		INC		AUX    
		OUT		PORTB, AUX				;Incremento AUX y lo cargo en el puerto B
		CPI		AUX, 0XF0
		BREQ	encender_PC1			;Si AUX=0xF0 salto a poner en 1 a PC1 

		CBI		PORTC, 1				;Como AUX es diferente de 0XF0 pongo en 0 a PC0
		CBI		PORTC, 0				;Pongo en 0 a PC0 porque tambien AUX es diferente de 0X10
		RETI

;--------------------------------------------------------------
encender_PC0:
		SBI		PORTC,0					;Pongo en 1 a PC0
		RETI

encender_PC1:
		SBI		PORTC,1					;Pongo en 1 a PC1
		RETI

m;???
retorno: RETI ;???
		