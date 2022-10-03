
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
 	lda (cmd_ptr),y
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
