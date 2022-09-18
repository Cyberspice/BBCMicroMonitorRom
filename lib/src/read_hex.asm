;===========================================
; Read 8 bit and 16 bit hex values from the
; command line
;===========================================

; Reads a hex value from the command line as an 8 bit value
;
; Command address:
;    (p0_cmd),y
;
; Returns:
;    value_low - the value
;    (p0_cmd),y - next character
;    Carry set on error

MAX_CHARS_8BIT=2

.read_hex_8bit
	lda #0                ; Zero the value
	sta value_low

  ldx #MAX_CHARS_8BIT   ; Max 2 hex chars
.read_hex_8bit_next
 	lda (p0_cmd_low),y
  cmp #13
  bne read_hex_8bit_next_2
  cpx #MAX_CHARS_8BIT   ; Any digits at all? Sets carry if >=!
  beq read_hex_8bit_err
  bne read_hex_8bit_done

.read_hex_8bit_next_2
  cmp #' '
  bne read_hex_8bit_next_3
  cpx #MAX_CHARS_8BIT   ; Any digits at all? Sets carry if >=!
  beq read_hex_8bit_err
  bne read_hex_8bit_done

.read_hex_8bit_next_3
	jsr char_to_hex
  bcs read_hex_8bit_err ; Valid hex digit?

  asl value_low
  bcs read_hex_8bit_err ; Value overflow?
  asl value_low
  bcs read_hex_8bit_err ; Value overflow?
  asl value_low
  bcs read_hex_8bit_err ; Value overflow?
  asl value_low
  bcs read_hex_8bit_err ; Value overflow?

  ora value_low
  sta value_low
  iny
  dex
  bne read_hex_8bit_next

.read_hex_8bit_done
  clc
  rts
.read_hex_8bit_err
  sec
  rts

MAX_CHARS_16BIT=4

; Reads a hex value from the command line as a 16 bit value
;
; Command address:
;    (p0_cmd),y
;
; Returns:
;    value_low/high - the value
;    (p0_cmd),y - next character
;    Carry set on error

.read_hex_16bit
	lda #0                ; Zero the value
	sta value_low
	sta value_high

  ldx #MAX_CHARS_16BIT  ; Max 4 hex chars

.read_hex_16bit_next
 	lda (p0_cmd_low),y
  cmp #13
  bne read_hex_16bit_next_2
  cpx #MAX_CHARS_16BIT  ; Any digits at all? Sets carry if >=!
  beq read_hex_16bit_err
  bne read_hex_16bit_done

.read_hex_16bit_next_2
  cmp #' '
  bne read_hex_16bit_next_3
  cpx #MAX_CHARS_16BIT  ; Any digits at all? Sets carry if >=!
  beq read_hex_16bit_err
  bne read_hex_16bit_done

.read_hex_16bit_next_3
	jsr char_to_hex
  bcs read_hex_16bit_err ; Valid hex digit?

  asl value_low
  rol value_high
  bcs read_hex_16bit_err ; Value overflow?
  asl value_low
  rol value_high
  bcs read_hex_16bit_err ; Value overflow?
  asl value_low
  rol value_high
  bcs read_hex_16bit_err ; Value overflow?
  asl value_low
  rol value_high
  bcs read_hex_16bit_err ; Value overflow?

  ora value_low
  sta value_low
  iny
  dex
  bne read_hex_16bit_next

.read_hex_16bit_done
  clc
  rts
.read_hex_16bit_err
  sec
  rts

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

