

;Programar en Assembly un bucle infinito que lee los 8 bits de los terminales del puerto B y 
;se lo pasa a un rutina FILTRO a través de una variable ENTRADA en RAM. Luego recibe en la variable SALIDA 
;el resultado y lo saca por el puerto C. Definir las variables en memoria RAM, inicializar SALIDA en 0 y 
;la pila antes de invocar a FILTRO por primera vez.

.DSEG
	.DEF ENTRADA = R16
	.DEF SALIDA = R17
.CSEG

SETEO:
	
	LDI R18, 0x10
	CLR SALIDA
stack:
	LDI	R19,	HIGH(RAMEND)
	OUT	SPH,	R19
	LDI	R19,	LOW(RAMEND)
	OUT	SPL,	R19

;Por default portb viene como input
LECTURA:
	INC R18 ;Debug
	OUT PORTB, R18 ;Debug	
	IN ENTRADA, PORTB
	CALL FILTRO
	OUT PORTC, SALIDA
	JMP LECTURA


;Programar en assembly una rutina (FILTRO) que calcula la respuesta del siguiente filtro de 1er orden:
;S(k+1)= (1/4)*E(k) + (3/4) * S(k),
;donde E(k), S(k) y S(k+1) son variables de 8 bits alojadas en RAM.
;Sugerencia: Se supone que la rutina lee los valores E y 
;S (en el tiempo k) calcula la nueva salida S(k+1) y pisa el viejo valor en RAM de S(k).

FILTRO:
	MOV R20, ENTRADA;Muevo la entrada a un registro auxiliar para no cambiar la entrada
	LSR R20;
	LSR R20 ;Divido por dos dos veces
	LDI R21, 0xC0 ;Aca tengo que multiplicar la salida por 3/4 entonces lo pense como primero multiplico por 192(que
	;es 3 por 2^6) y despues dividirlo por 256(que es 4 por 2^6), para despues cuando hago la multiplicacion solo tengo que
	;la parte high de la multiplicacion
	MUL SALIDA, R21
	MOV SALIDA, R1; R1 es la parte high de la multiplicacion
	ADD SALIDA, R20; sumo las dos partes
	RET