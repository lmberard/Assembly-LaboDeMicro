; Definicion de Macros
; esta macro decrementa el registro que se pasa como argumento 1 y si llega a cero, 
; salta a la etiqueta que se pasa como argumento 2
; uso:		djnz	<Rd>,<Etiqueta>
.macro	djnz
			dec		@0
			tst		@0
			brne	@1
.endmacro

; esta macro inicializa el puntero X a una posicion en RAM
; uso:		initX	<Etiqueta>
.macro	initX
			ldi		Xh,HIGH(@0) 
			ldi		Xl,LOW(@0)	
.endmacro

; esta macro inicializa el puntero Z a una posicion en ROM
; uso:		initZ	<Etiqueta>
.macro	initZ
			ldi		Zh,HIGH(@0<<1) 
			ldi		Zl,LOW(@0<<1)
.endmacro

; esta macro inicializa el stack pointer
; uso:		initSP	
.macro	initSP
			ldi dummyreg,low(RAMEND)
			out spl,dummyreg
			ldi dummyreg,high(RAMEND)
			out sph,dummyreg
.endmacro
