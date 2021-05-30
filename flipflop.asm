//------------------------------------------//
//			Ejemplo FLIP FLIP D				//
//------------------------------------------//

/*------------------------------------------
	Pines de entrada 0 (clock) y 1(D)
	Pin de salida 2(Q)
-------------------------------------------*/
.equ	CK=1
.equ	D=1
.equ	Q=2
.equ	PUERTO_SALIDA=PORTB
.equ	PUERTO_ENTRADA=PINB
.equ	CONF_PUERTO=DDRB

;--------------------------------------------
.CSEG
	JMP MAIN

.ORG INT_VECTORS_SIZE
;--------------------------------------------
MAIN:
	
	;INICIALIZO PUNTEROS
	LDI		R22, (0<<CK|0<<D|1<<Q)
	OUT		CONF_PUERTO,R22

	;DETECTO FLACO DESCENDENTE
	BAJO:
		SBIS	PUERTO_ENTRADA,CK
		JMP		BAJO
	ALTO:
		SBIC	PUERTO_ENTRADA,CK
		JMP		ALTO
		;COPIO VALOR DE ENTRADA A LA SALIDA
		SBIC	PUERTO_ENTRADA,CK
		JMP		SET_HIGH
		CBI		PUERTO_SALIDA,Q
		;VUELVO A DETECTAR FLANCO
		JMP		BAJO
	SET_HIGH:
		SBI		PUERTO_SALIDA,Q
		JMP		BAJO

	ACA:JMP ACA
;--------------------------------------------
/*
si el bit esta en 0 me quedo loopeando, sino salto al prox

depsues si esta cleareado, salto 

En la parte de alto, voy a esperar un flaco descendente

si el puerto de entrada esta en clear (0),a setear un set high

lo del aca jpm aca esta medio al pedo, proque en realidad todo lo otro seria como un while(1)
*/
