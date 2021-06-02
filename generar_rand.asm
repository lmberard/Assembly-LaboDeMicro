
; 10)Una forma de generar números pseudoaleatorios es mediante registros
; de desplazamiento realimentados. Uno de los más simples es el siguiente: 
;donde b0 a b7 son los 8 bits de un registro. En cada ciclo de reloj 
;se desplaza su contenido un bit hacia la izquierda, tal que 
;b6viejo pasa a ser b7nuevo, b5viejo pasa a ser b6nuevo, etc;
; además, el contenido de b7viejo se pierde, y el contenido de b0nuevo 
;es la or-exclusiva entre b7viejo y b6viejo.

;Se pide programar la subrutina RAND_8 que implemente este circuito, 
;la cual recibe en R0 el valor inicial del registro, en R1 la cantidad 
;de CICLOS de reloj a iterar, y devuelve en R2 el resultado. Si por ejemplo, 
;se recibe R0=0x80 y R1=0x0a; la subrutina pasa por los estados indicados
; en la tabla, devolviendo R2=0x06

;Valor inicial	0x80	0b10000000
;1°ciclo		0x01	0b00000001
;2°ciclo		0x02	0b00000010
;3°ciclo		0x04	0b00000100
;4°ciclo		0x08	0b00001000
;5°ciclo		0x10	0b00010000
;6°ciclo		0x20	0b00100000
;7°ciclo		0x40	0b01000000
;8°ciclo		0x81	0b10000001
;9°ciclo		0x03	0b00000011
;10°ciclo(final)0x06	0b00000110


.DEF VALINIC=R20
.DEF CICLOS=R21
.DEF RESULTADOS=R22
.DEF random=R16
.DEF aux1=R17
.DEF aux2=R18
.DEF contador=R19
.DEF viejo=R23
.EQU mascara7=0x80
.EQU mascara6=0X40



.CSEG

Seteo:
	LDI VALINIC,0x80
	LDI CICLOS, 0x0A
	MOV RESULTADOS, VALINIC

Ciclo:
	MOV viejo, RESULTADOS
	LSL RESULTADOS
	LDI contador,7
	MOV aux1, viejo
	ANDI aux1, mascara7
cor:LSR aux1
	DEC contador
	BRNE cor
	LDI contador,6
	MOV aux2, viejo
	ANDI aux2, mascara6
cor2:LSR aux2
	DEC contador
	BRNE cor2
	EOR aux1, aux2
	OR RESULTADOS, aux1
	DEC CICLOS
	BRNE ciclo

FIN:
	JMP FIN