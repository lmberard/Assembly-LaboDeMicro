.cseg
.org 0x00
	jmp  main


.org INT_VECTORS_SIZE

main:
	ldi	 r16, HIGH(RAMEND)
	out  sph, r16
	ldi  r16, LOW(RAMEND)
	out  spl, r16		; inicializo el stack pointer al final de la RAM

	ldi  r16, 0xF3  ;243
	ldi  r17, LOW(0x534D)
	ldi  r18, HIGH(0x534D)  ;r18:r17=21325

	jmp multiplicar

here: jmp here

multiplicar:		; r18:r17 * r16
	mul r16, r17
	mov r20, r0
	mov r21, r1
	mul r16, r18
	mov r2, r1
	mov r1, r0
	mov r0, r20
	add r1, r21
	brsh end		;branch if same or higher
	inc r2
end: jmp here