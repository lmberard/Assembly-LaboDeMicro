
;  Hacer una rutina para generar un numero pseudo random
; con un algoritmo en particular (ver el pdf de ejercicios
; tipo parcial)


.DEF R_VALOR_INICIAL = R16
.DEF R_CANTIDAD_DE_CICLOS = R17
.DEF R_RESULTADO = R18
.DEF R_AUX_VALOR_INICIAL = R19

.EQU PRIMER_VALOR = 0x80
.EQU CICLOS_DE_CLOCK = 0x0A ; ejemplo de la hoja
.EQU BIT7 = 0x07



.cseg

				LDI R_VALOR_INICIAL, PRIMER_VALOR ; cargo el valor inicial en un registro
				LDI R_CANTIDAD_DE_CICLOS, CICLOS_DE_CLOCK ; cargo cuantos ciclos de clock quiero

RAND_8:			MOV R_AUX_VALOR_INICIAL , R_VALOR_INICIAL ; copio el valor inicial a un auxiliar así no pierdo la referencia
				LSL R_VALOR_INICIAL ; shifteo el valor (es lo que pide el ejercicio)
				EOR R_AUX_VALOR_INICIAL , R_VALOR_INICIAL ; como movi el con el shift, ahora estoy haciendo b7viejo xor b6viejo=b7nuevo
				SBRC R_AUX_VALOR_INICIAL , BIT7 ; si la xor me dio 0 (chequeo el b7 de AUX que es la xor anterior), dejo el 0 que me puso el shift. Si no, setteale el 0
				ORI R_VALOR_INICIAL , 0x01 ; seteo el 1 con 0b00000001
				DEC R_CANTIDAD_DE_CICLOS ; hago una especia de counter con la cantidad de ciclos de clock
				BRNE RAND_8 ; mientras la cantidad de ciclos sea distinta de 0, hay que seguir
				MOV R_RESULTADO, R_VALOR_INICIAL ; pongo en el resultado el valor final
FIN:			JMP FIN ; en realidad va un RET al main porque RAND_8 es una función, bla bla





