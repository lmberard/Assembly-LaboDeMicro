; VECTOR DE NUMEROS ALEATORIOS
; VOY A ASUMIR QUE YA EXISTE EL VECTOR Y LE VOY A IR SOLAPANDO NUMEROS


; Registros <<<<<<<<<<<<<<<<<<<<<<<<<<<<

; reg rand8
.DEF R_INITIAL_VALUE = R16
.DEF R_CLOCK_CYCLES = R17
.DEF R_RESULT = R18
.DEF R_AUX_INITIAL_VALUE = R19

; otros reg
.DEF R_LOADER = R20
.DEF R_COUNTER = R21
.DEF R_MEAN = R22 ; el "R3"
.DEF R_AUX_MEAN = R23

; Valores constantes <<<<<<<<<<<<<<<<<<
.EQU VECT_SIZE = 8
.EQU FIRST_INITIAL_VALUE = 0x78
.EQU ZERO_VALUE = 0x00
.EQU CLOCK_CYCLES_IF_0 = 0x8F
.EQU BIT7 = 0x07

.DSEG 

.ORG SRAM_START
	VAR2:			.BYTE VECT_SIZE
	
.CSEG   
 
.ORG 0x00                   
	
	LDI ZL, LOW(VAR2) ; apunto al vector viejo
	LDI ZH, HIGH(VAR2)


LOAD_TABLE:  ; le voy a hardcodear 5 numeros porque es un vector viejo que estoy asumiendo que ya existe
	LDI R_LOADER, 0x1A
	ST Z+, R_LOADER
	LDI R_LOADER, 0x05
	ST Z+, R_LOADER
	LDI R_LOADER, 0x00
	ST Z+, R_LOADER
	LDI R_LOADER, 0x00
	ST Z+, R_LOADER
	LDI R_LOADER, 0x0A
	ST Z+, R_LOADER
	LDI R_LOADER, 0x00
	ST Z+, R_LOADER
	LDI R_LOADER, 0x02
	ST Z+, R_LOADER
	LDI R_LOADER, 0x01
	ST Z+, R_LOADER

;¨****************************************** MAIN *************************************************************************************

MAIN:
	; vuelvo a inicializar el vector para hacer el ejercicio
	LDI ZL, LOW(VAR2) ; apunto al vector viejo
	LDI ZH, HIGH(VAR2) ; Z ubicado en el primer valor del vector


	LDI R_LOADER, ZERO_VALUE ; voy a usar a R_LOADER como auxiliar para no hacer un reg solo para el 0 
	LDI R_INITIAL_VALUE, FIRST_INITIAL_VALUE ; hardcodeo el primer "R0" = 0x78
	LDI R_COUNTER, VECT_SIZE ; cargo un counter para hacer el fill
	RCALL FILL_VECTOR
	LDI R_COUNTER, VECT_SIZE ; ahora cargo para hacer la E[vec]
	RCALL VECTOR_MEAN ; calculo la esperanza del nuevo vector
FIN: JMP FIN ; end 


;********************************************* FUNCIONES *******************************************************************************

FILL_VECTOR:
	LD R_CLOCK_CYCLES, Z ; cargo el valor actual del vector en "R1"
	CPSE R_CLOCK_CYCLES, R_LOADER ; comparo a ver si el valor era nulo.Si lo es, skipeo la sig instruc
	JMP NOT_0_CLOCK ; el clock es un valor valido
	LDI R_CLOCK_CYCLES, CLOCK_CYCLES_IF_0 ; cargo el 0x8F que dice el ejercicio
NOT_0_CLOCK:
	RCALL RAND_8 
	ST Z, R_RESULT ; solapo el resultado "R2" con el random que me dio RAND_8
	LD R_INITIAL_VALUE, Z+ ; mi próximo "R0" va a ser el resultado de todo lo anterior, y ya dejo apuntando al proximo para la proxima iteracion
	DEC R_COUNTER
	BRNE FILL_VECTOR ; si el counter es distinto de 0 hay que seguir llenando
	RET ;retorno al main

;****************************************************************************************************************************************

RAND_8:			
	MOV R_AUX_INITIAL_VALUE , R_INITIAL_VALUE ; copio el valor inicial a un auxiliar así no pierdo la referencia
	LSL R_INITIAL_VALUE ; shifteo el valor (es lo que pide el ejercicio)
	EOR R_AUX_INITIAL_VALUE , R_INITIAL_VALUE ; como movi el con el shift, ahora estoy haciendo b7viejo xor b6viejo=b7nuevo
	SBRC R_AUX_INITIAL_VALUE , BIT7 ; si la xor me dio 0 (chequeo el b7 de AUX que es la xor anterior), dejo el 0 que me puso el shift. Si no, setteale el 0
	ORI R_INITIAL_VALUE , 0x01 ; seteo el 1 con 0b00000001
	DEC R_CLOCK_CYCLES ; hago una especia de counter con la cantidad de ciclos de clock
	BRNE RAND_8 ; mientras la cantidad de ciclos sea distinta de 0, hay que seguir
	MOV R_RESULT, R_INITIAL_VALUE ; pongo en el resultado el valor final
	RET 

;****************************************************************************************************************************************

VECTOR_MEAN:
	LDI ZL, LOW(VAR2)
	LDI ZH, HIGH(VAR2) ;vuelvo a apuntar
KEEP_GOING:
	LD R_AUX_MEAN, Z+
	DEC R_COUNTER
	LD R_MEAN, Z+
	ADD R_MEAN, R_AUX_MEAN 
	DEC R_COUNTER
	BRNE KEEP_GOING ; si el counter es =/= seguir sumando
;	LSR R_MEAN
;	LSR R_MEAN; me dio paja loopear xd
;	LSR R_MEAN; como 8 es 2^3 , es shiftear 3 veces a la derecha (en el ejemplo es 128 que es 2^7)
	RET