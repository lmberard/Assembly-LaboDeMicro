;****************************************************************************************************************

; Lucia Berard - 101213
; Parcial 24-JUN-2020, Ejercicio 2

/*
Ejercicio 2 
Dado un vector de bytes en la memoria RAM a partir de la posicion VECTOR, y cuyo largo se 
encuentra en el registro R16, hacer una subrutina que entregue en R17 un “1” si el vector es 
simétrico, o un “0” si no lo es.  
Mostrar la llamada a la rutina desde el programa principal. 
El vector de bytes puede tener un numero par o impar de valores; contemplar ambos casos 

Ejemplos: 
	a)	R16=5 
		VECTOR= 5,13,123,13,5 
		Es simétrico, R17 = 1 
	b)	R16=6 
		VECTOR=5,13,123,123,13,5  
		Es simétrico, R17 = 1 
	c)	R16=5 
		VECTOR= 5,13,123,123,31,5 
		No es simétrico, R17 = 0 
*/
;****************************************************************************************************************

.INCLUDE "m328pdef.inc"

.DEF INICIO = R22
.DEF LARGO=R16
.DEF SIMETRIA=R17

.DEF AUX1=R18
.DEF AUX2=R19
.DEF CONTADOR=R20
.DEF CARRY=R21



;--------------------------------------------------------------
.CSEG
.ORG 0X0000
		RJMP	config

.ORG INT_VECTORS_SIZE

config:		
		;Inicializacion Stack Pointer
		LDI		AUX1, HIGH(RAMEND)					
		OUT		SPH, AUX1			
		LDI		AUX1, LOW(RAMEND)					
		OUT		SPL, AUX1

;--------------------------------------------------------------
main:
		LDI		LARGO, 4			;R16			;Cargo un LARGO para probar la rutina y cargo los valores en RAM con el Debug			
		LDI		INICIO,0
		RCALL	obtener_simetria

end:
		RJMP	end
;--------------------------------------------------------------

obtener_simetria:
		
		;PONE EL CONTADOR EN EL MEDIO
		MOV		CONTADOR, LARGO						
		LSR		CONTADOR							;Divido el contador por 2 desplazandolo a derecha

	loop:
			;APUNTO AL PRIMERO y cargo el valor en el registro aux1
			LDI		ZL, LOW(VECTOR_ROM<<1)			;Apunto X al primer elemento del vector
			LDI		ZH, HIGH(VECTOR_ROM<<1)	
			CLR		CARRY
			ADD		ZL, INICIO						;Le sumo a Y el largo del vector asi lo dejo apuntando al elemento 
			ADC		ZH, CARRY

			LPM		AUX1, Z							;Copio en AUX1 el valor apuntado por X y paso a apuntar el proximo elemento
			;-------------------------
			;APUNTO AL FINAL y cargo el valor en el registro aux2
			LDI		ZL, LOW(VECTOR_ROM<<1)			;Apunto X al primer elemento del vector
			LDI		ZH, HIGH(VECTOR_ROM<<1)	
			CLR		CARRY
			ADD		ZL, LARGO						;Le sumo a Y el largo del vector asi lo dejo apuntando al elemento 
			ADC		ZH, CARRY						;siguiente al ultimo del vector
		
			LPM		AUX2, Z							;Apunto con Y al anterior elemento y copio su valor en AUX2
			;-------------------------
			;COMPARO VALORES
			CP		AUX1, AUX2			
			BRNE	no_simetrico					;En caso de que AUX1 sea diferente de AUX2 indico que el vector no es simetrico

			DEC		LARGO
			INC		INICIO

			DEC		CONTADOR						;R20				
			BREQ	es_simetrico					;Si al decrementar el contador este da 0, significa que el vector es simetrico
	
			RJMP	loop							;Como no entre en ninguno de los anteriores casos, salto a repetir el ciclo 

;--------------------------------------------------------------
es_simetrico:
		LDI		SIMETRIA, 1							;Cargo en R17 un 1 para indicar que el vector es simetrico
		RET
				
no_simetrico:
		LDI		SIMETRIA, 0							;Cargo en R17 un 0 para indicar que el vector no es simetrico
		RET	

;--------------------------------------------------------------
.ORG 0X0100
VECTOR_ROM: .DB 0x02,0x07,0x04,0x03,0x02
