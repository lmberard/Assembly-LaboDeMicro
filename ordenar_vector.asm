; Ejercicio_parcial_1.asm
;

; Dado un vector de 25 numeros en memoria RAM
; externa ubicado a partir de la direccion Vec1
; reescribiro de mayor a menor a partir de la direccion 
; Vec2. Los numeros son entero sin signo y los vectores no se solapan 
; en ninguna posiscion

.equ VECTOR_SIZE=25			; cantidad de elementos que tiene mis vectores	
.def MAYOR_P = r20				; registro para guardar maximos parciales	
.def AUX2 = r21

.dseg 

vec1: .byte VECTOR_SIZE

vec2: .byte VECTOR_SIZE+5

.cseg
.org 0x00
	jmp main

.org INT_VECTORS_SIZE

main:
	ldi r16, HIGH(RAMEND)
	out sph, r16
	ldi r16, LOW(RAMEND)
	out spl, r16			; inicializo el stack pointer al final de la RAM
	
    ldi zl, LOW(vec1)       ; cargo Z con el primer elemento de vec1
	ldi zh, HIGH(vec1)

	ldi yl, LOW(vec2)		; cargo Y con el primer elemento de vec2
	ldi yh, HIGH(vec2)

	ldi r17, VECTOR_SIZE    ; registro con el largo del vector

	rcall inicializar_vec1  ; inicializo vec1 con numeros de menor a mayor

	ldi r18, VECTOR_SIZE    ; lo voy a necesitar de vuelta 
	
	rcall ordenar_vec1

here: rjmp main				; termine
	
; SUBRUTINAS ---------------------------------------------------

inicializar_vec1:   ; cargo el vector con numeros de menor a mayor para probar				
	ldi r16, 4     ; desde el 3 
loop1:
	st z+, r16
	inc r16
	dec r17
	brne loop1
    
	ldi r16, 15
	sts 0x0100, r16
	ret

; ---------------------------------------------------------------
	
ordenar_vec1:

; se busca el mayor de vec1, se guarda en el primer elemento de vec2, 
; se elimina ese valor de vec1 y se vuelve a buscar el mayor de vec1, 
; y asi por VECTOR_SIZE veces.

    ldi zl, LOW(vec1)       ; cargo Z y X con el primer elemento de vec1
	ldi zh, HIGH(vec1)
	mov xl, zl				
	mov xh, zh
	ld MAYOR_P, z+          ; defino al primer elemento como maximo temporal
	ldi r17, VECTOR_SIZE	; contador
	 
	loop:					; busca el mayor del vector, queda en MAYOR_P, y guarda su posicion
							; en X para borrarlo de vec1
    dec r17
	breq copy_to_vec2
    ld AUX2, z+	
	cp MAYOR_P, AUX2
	brge loop
	ld MAYOR_P, -z
	mov xl, zl
	mov xh, zh
	inc zl
	rjmp loop
	
	copy_to_vec2:
	st y+, MAYOR_P
	ldi r16, 0				; pongo en 0 el elemento de vec1 luego de ponerlo en vec2
	st x, r16
	dec r18
	brne ordenar_vec1
	ldi r16, 0
	st -x, r16
	ret
 	 
