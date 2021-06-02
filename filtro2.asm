;Programar en Assembly una rutina (FILTRO) que calcula la respuesta del siguiente filtro de 1er orden:
;S(k+1) = (1/4)*E(k) + (3/4)*S(k),
;donde E(k), S(k) y S(k+1) son variables de 8 bits alojadas en RAM.
;Sugerencia: Se supone que la rutina lee los valores E y S (en el tiempo k) calcula la
;nueva salida S(k+1) y pisa el viejo valor en RAM de S(k).

.DEF R_E = R16
.DEF R_S = R17
.DEF R_AUX_E = R18
.DEF R_AUX_S = R19
.DEF R_AUX_COEFICIENTE = R20 ; coeficiente del filtro

.EQU ENTRADA_INICIAL = 0x03
.EQU SALIDA_INICIAL = 0x04
.EQU COEFICIENTE_FILTRO = 0xC0 ; cargo 2.2^6 = 192

.cseg

.ORG 0x00

		LDI R_E, ENTRADA_INICIAL ; cargo la seed del valor entrada ( E(0) )
		LDI R_S, SALIDA_INICIAL ; cargo la seed del valor salida ( S(0) )
LOOP:	CALL FILTRO
		CALL CAMBIO_ENTRADA ; hago un cambio cualquiera para E(K) para =/= K
		JMP LOOP


FILTRO:
		MOV R_AUX_E, R_E ; copio los valores en auxiliares para no perder el valor de R_E
		MOV R_AUX_S, R_S ; idem

		LSR R_AUX_E ; dividir por 4 es como dividir por 2^k con k=2
		LSR R_AUX_E ; entonces es hacer un shift 2 veces a la derecha ... Hay una mejor forma seguro..

		LDI R_AUX_COEFICIENTE, COEFICIENTE_FILTRO ; cargo 192 al registro para hacer la multiplicación
		MUL R_AUX_S, R_AUX_COEFICIENTE ; multiplico 3. S(K) y se guarda en R1 high R0 low (ver datasheet)
		MOV R_AUX_S, R1 ; si agarro el R1 agarro la parte high de la multiplicacion (que es como dividir por 4.2^6)

		ADD R_AUX_S , R_AUX_E ; sumo los términos
		MOV R_S, R_AUX_S ; con esto obtengo " S(K+1) "
		RET

CAMBIO_ENTRADA:

		INC R_E ; le sumo uno a medida que aumenta K (me lo inventé para probarlo)
		RET


; En este ejercicio lo que hice fue multipliclar y dividir 3/4 por 2^6 . Esto hacía que abajo
; tenga un 2^8 lo que significaba shiftear 8 veces el numero que salía en R0 Y R1 de MUL
; peeero esto significaría agarrar el high (R1) de MUL. Entonces para mantener la igualdad
; me queda el 3.2^6 arriba. Esto sirve solo si abajo tengo potencias de 2. Si tenía un 3/5 me re cabio
; Arriba no me interesa lo que haya porque es por lo que voy a multiplicar y para eso MUL me da 2bytes/16bits
; ej) si tenia 3/8 , como 8 = 2^3 , era lo mismo pero con 2^5 para que abajo me quede 2^8