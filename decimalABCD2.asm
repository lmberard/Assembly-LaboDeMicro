;
;Realizar una rutina que pase un numero decimal a BCD empaquetado de un byte.
;Si no es posible representar el número con un byte BCD, volver de la rutina
;indicando que hubo un error.

; unit -> unidad
; ten -> decena
; hundred -> centena (no voy a usar esta , igual)

.DEF R_NUMBER_DECIMAL = R16
.DEF R_UNIT = R17
.DEF R_TEN = R18
.DEF R_NUMBER_PACKED_BCD = R19

.EQU MAX_NUMBER = 0x64 ; 99d es el máximo valor que puedo hacer con 2 nibbles/1 byte
.EQU EXAMPLE = 0x4C ; pongo un numero cualquiera, 4Ch = 76d => el packedBCD debería ser 0111 0110b (7 en highnibble y 6 en lownibble) = 76h (esto pasa en todos los numero -> va con 0x00 a 0x99 )
.EQU TEN_FACTOR = 0x0A ; es lo que voy a usar para sacar las decenas
.EQU ZERO = 0x00

.cseg

.ORG 0x00

MAIN:

			LDI R_NUMBER_DECIMAL, EXAMPLE ; cargo el numero 
			LDI R_NUMBER_PACKED_BCD, ZERO ; inicializo en 0 el resultado final
			RCALL CONVERTER ; llamo a la rutina de conversión
ERROR:		RJMP ERROR ; el número es mayor a 99d, no es posible convertir. ERROR.
SUCC_END:	RJMP SUCC_END ; final exitoso, fin del programa.

;********************************************* FUNCIONES ********************************************************************

CONVERTER:

				CPI R_NUMBER_DECIMAL, MAX_NUMBER ; comparo a ver si el número no se va de cotas
				BRLO VALID_NUMBER ; si el número es menor a 100d (se ve en la CPI anterior), es posible convertirlo
				RJMP ERROR ; error, el numero es muy grande
VALID_NUMBER:	RCALL FACTORIZE ; voy a factorizarle para buscarle las decenas y las unidades (voy a usar división por 10 con restas)
				OR R_NUMBER_PACKED_BCD, R_TEN ; cargo las decenas
				SWAP R_NUMBER_PACKED_BCD ; como son las decenas, deben ir en el high nibble
				OR R_NUMBER_PACKED_BCD, R_UNIT ; cargo las unidades
				RJMP SUCC_END ; listooo

;****************************************************************************************************************************

FACTORIZE:

KEEP_GOING:		SUBI R_NUMBER_DECIMAL , TEN_FACTOR
				BRMI END_FACTORIZE ; si la resta da negativa no puedo restar mas
				INC R_TEN ; si pude hacer la resta es porque tiene una decena más
				RJMP KEEP_GOING
END_FACTORIZE:	SUBI R_NUMBER_DECIMAL, -TEN_FACTOR ; cosa rara que tengo que hacer porque no existe addi
				MOV R_UNIT, R_NUMBER_DECIMAL ; el resto de la division son las unidades
				RET 