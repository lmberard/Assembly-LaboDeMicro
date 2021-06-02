;****************************************************************************************************************
; Parcial 24-JUN-2020, Ejercicio 1
/*
Realizar un programa que permita controlar el contenido de un tanque de agua. El tanque 
cuenta con tres sensores, uno ubicado al tope del tanque (tanque lleno), el segundo ubicado a 
un cuarto de altura del tanque (25% de la capacidad) y el último indica la situación de tanque 
vacío. También cuenta con dos llaves de paso accionadas eléctricamente que permiten la 
circulación de agua hacia el tanque, una principal y una secundaria; y un LED de alarma. 

Se pide que en todo momento la altura del agua en el tanque sea superior al 25% del mismo 
utilizando solo la llave de paso principal, es decir, cuando se detecta que el sensor de tanque 
lleno se desactiva, se debe abrir la llave de paso principal hasta que dicho sensor vuelva a 
indicar que el tanque esta lleno. 

En la contingencia que el agua del tanque llegase al mínimo (tanque vacío), se prenderá el LED 
de alarma para indicar el problema (el LED quedará prendido hasta que se alcance 
nuevamente el 25% del nivel del tanque), y se accionará la llave secundaria hasta retomar el 
normal funcionamiento (agua por arriba del 25%, en ese momento se apagará la llave 
secundaria y el LED). 
 
Si en algún momento se activa el sensor de tanque lleno, se debe apagar la llave de paso 
principal.  

Se pide indicar claramente en el programa a qué puerto y pin del microcontrolador está 
conectado cada elemento del sistema (los sensores de tanque lleno, de 25% de capacidad; y 
de tanque vacio, y las dos llaves de paso de agua, primaria y secundaria y el LED de alarma) y 
como son las señales (que representa un “1” o un “0” en las entradas de sensor y si un “1” o un 
“0” indica que las llaves estan abiertas o cerradas y el LED de alarma encendido o apagado) 

El programa debe incluir la configuracion de los puertos. Asimismo se debe documentar cuales 
son los distintos estados en los que puede estar el tanque; que sensor genera un cambio de 
estado y a que estado pasa; y en cada estado la condición (abierta o cerrada) de las llaves de 
paso primaria y secundaria y del LED de alarma. 

*/
;****************************************************************************************************************

.INCLUDE "m328pdef.inc"

.DEF AUX=R16

;--------------------------------------------------------------
.CSEG
.ORG 0X0000
		RJMP	config

.ORG INT_VECTORS_SIZE

config:												;Inicializo el SP al final de la RAM
		LDI		AUX, HIGH(RAMEND)					;Cargo el SPH
		OUT		SPH, AUX			
		LDI		AUX, LOW(RAMEND)					;Cargo el SPL
		OUT		SPL, AUX

		LDI		AUX, 0X00							
 		OUT		DDRB, AUX							;Declaro al puerto B como entrada
		LDI		AUX, 0X00							
		OUT		PORTB, AUX							;Inicializo al puerto B en 0X00
													; PB0 CORRESPONDE AL SENSOR DE TANQUE LLENO
													; PB1 CORRESPONDE AL SENSOR DE TANQUE EN CUARTO
													; PB2 CORRESPONDE AL SENSOR DE TANQUE VACIO
													; UN ESTADO LOGICO ALTO INDICA QUE EL SENSOR SE ENCIENDE

		LDI		AUX, 0XFF							
 		OUT		DDRC, AUX							;Declaro al puerto C como salida
		LDI		AUX, 0X00							
		OUT		PORTB, AUX							;Inicializo al puerto C en 0X00
													; PC0 CORRESPONDE A LA LLAVE PRINCIPAL
													; PC1 CORRESPONDE A LA LLAVE SECUNDARIA
													; PC2 CORRESPONDE AL LED
													; UN ESTADO LOGICO ALTO INDICA QUE LAS LLAVES O EL LED SE ENCIENDEN

;--------------------------------------------------------------
main:													
		RCALL	revisar_tanque
		RJMP	main

;--------------------------------------------------------------
revisar_tanque:

revisar_vacio:
		SBIC	PINB, 2								;Si PB2=1, entonces el tanque esta vacio
		RJMP	activar_llaves_led						;Salto a activar llaves y LED

revisar_cuarto:
		SBIC	PINB, 1								;Si PB1=1, entonces el tanque tiene mas de 1/4 
		RJMP	activar_principal						;Salto a activar llave principal y apagar segundaria y LED

revisar_lleno:
		SBIC	PINB, 0								;Si PB0=1, entonces el tanque esta lleno
		RJMP	desactivar_principal					;Salto a desactivar la llave principal
		RJMP	retorno	

;--------------------------------------------------------------
activar_llaves_led:
		SBI		PORTC, 0								;Abro llave principal
		SBI		PORTC, 1								;Abro llave secundaria
		SBI		PORTC, 2								;Enciendo LED
		RJMP	revisar_cuarto
		;sbi = set bit in i/o register
		;sbic = Skip if Bit in I/O Register is Cleared
		;cbi = Clear Bit in I/O Register
activar_principal:
		SBI		PORTC, 0								;Activo llave principal
		CBI		PORTC, 1								;Cierro llave secundaria
		CBI		PORTC, 2								;Apago LED
		RJMP	revisar_lleno
		
desactivar_principal:
		CBI		PORTC, 0								;Cierro llave principal

retorno:
		RET

;--------------------------------------------------------------