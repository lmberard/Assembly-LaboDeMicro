;-----------------------------------------------------------------------------
.include "m328pdef.inc"
.include "Macros.inc"

; Definiciones de registros
.def dummyreg = r16
; Registros que uso en la subrutina de ordenamiento
.def RegN = r17
.def RegN1 = r18			;registro n+1
.def Regi = r19				;registro para el i que tengo que ordenar
.def ordenado = r20

.equ N = 64

;-----------------------------------------------------------------------------
.cseg 
.org 0x0000
			jmp		configuracion

.org INT_VECTORS_SIZE

configuracion:
; Inicializacion stack pointer
			initSP	;macro definida en Macros.inc

;-----------------------------------------------------------------------------
; Ciclo principal
main:
			call	copiarARam  ;copio el listado a RAM
			initX	listadoRAM	;macro definida en Macros.inc: tengo que cargar en X el inicio de l atabla antes de llamar a la subrutina
			call	ordenar
			jmp		main

;-----------------------------------------------------------------------------
;ORDENAMIENTO-----------------------------------------------------------------
ordenar:
			; ordenado = falso
			ldi		ordenado,0x00 ; 0x00=falso; otro valor=verdadero
			; Mientras (ordenado==falso)
cicloMientras:
			tst		ordenado
			brne	salir
			; ordenado = verdadero
			ldi		ordenado,0x01
			; Reinicio el vector 
			initX	listadoRAM
			; Para i=0 hasta n-1 
			ldi		Regi,N-1	;esto lo puedo hacer porque N es una cte ya definida antes, no es variable
cicloFor:
			; Si (elemento(i) < elemento (i+1) 
			ld		RegN,x+		;cargo en RegN lo de x e incremento el puntero(ahora apunta a i+1)
			ld		RegN1,x		;cargo en RegN1 lo que esta apuntando el puntero (i+1)
			cp		RegN,RegN1	
			brsh	noCambio
			; Intercambiar (elemento(i), (elemento(i+1)))
			st		-x,RegN1	;como x habia quedado apuntando a i+1, lo tengo que decrementar para que apunte a i y guardo el regn1(guardo n+1 en n)
			ld		dummyreg,x+ ; lectura dummy para incrementar el registro x
			st		x,RegN
			; Ordenado = falso;
			ldi		ordenado,0x00

noCambio:	djnz	Regi,cicloFor
			jmp		cicloMientras
salir:		ret

;-----------------------------------------------------------------------------
;-----------------------------------------------------------------------------
copiarARam:
			initZ	listadoROM
			initX	listadoRAM
			ldi		Regi,N			;inicializa el indice de la cantidad que tiene que copiar
copy:		lpm		dummyreg,z+		;lo saco de la rom, lo guardo en dummy, incremento el puntero
			st		x+,dummyreg		;guardo dummy en la RAM, incremento
			djnz	Regi,copy		;si no llegue a cero vuelvo a copiar
			ret


;-----------------------------------------------------------------------------
; Tabla de Constantes en ROM
listadoROM:
.db	0x06,0x4E,0x9D,0xF6,0xEB,0xD8,0xF8,0x17,0x24,0x9D,0x80,0x4D,0x09,0x82,0x88,0x65
.db 0x8A,0x58,0xFA,0x2C,0x40,0xAE,0xE1,0x73,0x3E,0xBF,0x65,0x8D,0x0C,0x0C,0x47,0xA2
.db 0x3F,0x68,0xFD,0x2E,0x19,0x3F,0x0F,0x94,0x3A,0x56,0x93,0xBB,0x9F,0xCC,0xAF,0x7F
.db 0x4C,0xED,0x2A,0x92,0x6C,0xF1,0xB3,0xF5,0x4C,0x53,0x4F,0x65,0x0D,0x24,0x0A,0x2B

;-----------------------------------------------------------------------------
; Reserva de espacio en RAM
.dseg
.org SRAM_START
listadoRAM: .byte	N
