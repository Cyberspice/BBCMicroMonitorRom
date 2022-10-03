
; Convert an ASCII hex digit to its value
;
; ASCII hex digit:
;    A - digit
;
; Returns:
;    A - value
;    X - Unchanged
;    Y - Unchanged
;    Carry set on error

.char_to_hex
	sec
	sbc #'0'                ; Carry will be clear if A < '0'
	bcc char_to_hex_err
  cmp #10
  bcc char_to_hex_done
  sbc #7
  cmp #16
  bcs char_to_hex_err
.char_to_hex_done
	rts
.char_to_hex_err
	sec
	rts

