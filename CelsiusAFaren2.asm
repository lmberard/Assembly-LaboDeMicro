
; Pasar de Celsius a Fahrenheit
; c*(9/5) + 32 = F
; 9/5 =~ 14/2^3 ya que e= 9/5 - 14/2^3 = 0.05
; IGUAL voy a hacer lo de multiplicar para dejar todo en high de mul
; 9/5 = n/2^8 => n = 460.8 entonces uso 461. => mul con 461 (porque y agarro el HIGH me da el resultado)
; pero como 461>255, hago A * (206 + 255) 

.DEF R_CELSIUS_VALUE = R16 ; valor en celsius
.DEF R_FAHRENHEIT_VALUE = R17 ; valor en fahrenheit
.DEF R_AUX1_VALUE = R18  ; voy a usar estos auxiliares
.DEF R_AUX2_VALUE = R19	; para distributiva
.DEF R_AUX_LOW = R20 ; aux para mul
.DEF R_AUX_HIGH = R21

.EQU AUX_255 = 0xFF
.EQU AUX_206 = 0xCE
.EQU AUX_32 = 0x20 

.SET TEST_VALUE = 0x05

.cseg

.ORG 0x00

MAIN:
		LDI R_CELSIUS_VALUE, TEST_VALUE ; cargo un valor cualquiera de temperatura en celsius
		LDI R_AUX1_VALUE , AUX_255 ; cargo el 255 en un auxiliar
		LDI R_AUX2_VALUE, AUX_206 ; cargo el 206 en otro auxiliar
		MUL R_CELSIUS_VALUE, R_AUX1_VALUE ; 
		MOV R_AUX_HIGH, R1 ; guardo los valores de MUL en auxiliares
		MOV R_AUX_LOW, R0 ; 
		MUL R_CELSIUS_VALUE, R_AUX2_VALUE ; 2da parte de la distrib
		ADD R_AUX_HIGH, R1 ; sumo el high anterior con el 2do
		ADD R_AUX_LOW, R0 ; idem
		MOV R_FAHRENHEIT_VALUE , R_AUX_HIGH ; hacer esto es dividir por 2^8 (la parte de la division)
		SUBI R_FAHRENHEIT_VALUE, -AUX_32 ;  sumo los 32 finales
END:	RJMP END ; end

			