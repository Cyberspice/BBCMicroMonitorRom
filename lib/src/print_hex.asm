
; Print a single byte as two hex digits
;
; Inputs:
;    A - The value
;
; Returns:
;    X - Unchanged
;    Y - Unchanged

.print_hex
	pha
	lsr a
	lsr a
	lsr a
	lsr a
	jsr print_hex_digit
	pla
; Drop through

; Prints a single hex digit
;
; Inputs:
;    A - The value (0 - 15)
;
; Returns:
;    X - Unchanged
;    Y - Unchanged

.print_hex_digit
  pha
	and #&0f
	cmp #10
	bcc print_hex_digit_2
	adc #6
.print_hex_digit_2
	adc #&30
	jsr OSASCI
  pla
  rts
