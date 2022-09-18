
; Prints a NUL terminated string
;
; String:
;    (gen_ptr_low),y
;
; Returns
;    (gen_ptr_low),y - the NUL char

.print_str_loop
	lda (p0_spare_low),y
	beq print_str_loop_2
	jsr OSASCI
	iny
	bne print_str_loop   ; If Y loops increment the MSB
	inc p0_spare_high
	jmp print_str_loop
.print_str_loop_2
	rts

; Prints a NUL byte terminated string
;
; X - low byte of address
; Y - high byte of address
;
; A - unchanged

.print_str
	pha
	lda p0_spare_low
	pha
	lda p0_spare_high
	pha
	stx p0_spare_low
	sty p0_spare_high
	ldy #0
	jsr print_str_loop
	pla
	sta p0_spare_high
	pla
	sta p0_spare_low
	pla
	rts
