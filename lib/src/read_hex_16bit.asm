
; Reads a hex value from the command line as a 16 bit value
;
; Command address:
;    (p0_cmd),y
;
; Returns:
;    value_low/high - the value
;    (p0_cmd),y - next character
;    Carry set on error

MAX_CHARS_16BIT=4

.read_hex_16bit
	lda #0                ; Zero the value
	sta value_low
	sta value_high

  ldx #MAX_CHARS_16BIT  ; Max 4 hex chars

.read_hex_16bit_next
 	lda (cmd_ptr),y
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
