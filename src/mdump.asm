;=========================================
; MDUMP
;
; Command to display memory contents
;=========================================

; Print the bytes space separated

.mdump_prt_bytes
  lda p0_rom_ptr_low
  pha
  lda p0_rom_ptr_high
  pha
.mdump_prt_bytes_loop
	lda #' '
	jsr OSWRCH
  ldy rom_num
  jsr get_byte
	jsr print_hex
	dex
	bne mdump_prt_bytes_loop
  pla
  sta p0_rom_ptr_high
  pla
  sta p0_rom_ptr_low
	rts

; Print the padding out to align the text chars

.mdump_prt_padding
	lda #' '
	jsr OSWRCH
  lda #'?'
	jsr OSWRCH
	jsr OSWRCH
	dex
	bne mdump_prt_padding
	rts

; Print the printable characters represented by the bytes

.mdump_prt_chars
  lda p0_rom_ptr_low
  pha
  lda p0_rom_ptr_high
  pha
.mdump_prt_chars_loop
  ldy rom_num
  jsr get_byte
  jsr print_byte_as_char
	dex
	bne mdump_prt_chars_loop
  pla
  sta p0_rom_ptr_high
  pla
  sta p0_rom_ptr_low
	rts

; Print a line of bytes, their character representations

.mdump_prt_line
  jsr print_address

  ldx line_count
  jsr mdump_prt_bytes

  lda #MAX_BYTE_COUNT  ; Print padding if line_count != MAX_BYTE_COUNT
  sec
  sbc line_count
  beq mdump_prt_line_2
  tax
  jsr mdump_prt_padding
.mdump_prt_line_2

  lda #' '
  jsr OSWRCH

  ldx line_count
  jsr mdump_prt_chars

  lda #13
  jmp OSASCI

; Do the mdump command. This takes an address. It will either print
; 8 bytes of data or, if a count or end address is specified, that
; number of bytes. A rom number may be specified using single hex
; digit, ie. 0-9, A-F.
;
; *MDUMP ADDR [+COUNT|END_ADDR] [ROM]
;
; Command address:
;    (p0_cmd),y
;
; Errors:
;    Illegal Value - If bad hex
;    Bad Command - If not correctly formed command

.mdump
  jsr get_parameters

; Print all the bytes asked for. p0_rom_ptr contains the address and
; value contains the number of bytes.

.mdump_prt_all
  lda value_high       ; > 256 bytes to dump?
  bne mdump_prt_all_2

  lda value_low        ; < MAX_BYTE_COUNT bytes to dump?
  cmp #MAX_BYTE_COUNT
  bcc mdump_prt_all_3

.mdump_prt_all_2
  lda #MAX_BYTE_COUNT  ; MAX_BYTE_COUNT on the line

.mdump_prt_all_3
  sta line_count       ; Save it

  jsr mdump_prt_line   ; Print the line of bytes

  lda p0_escape_flag   ; ESCAPE processing
  bpl mdump_no_esc

  lda #ob_clear_vdu_q
  jsr OSBYTE
  lda #ob_esc_eff_clear
  jsr OSBYTE
  jsr OSNEWL
  jmp done

.mdump_no_esc
  sec                  ; Decrement byte counter
  lda value_low
  sbc line_count
  sta value_low
  lda value_high
  sbc #0
  sta value_high

  bne mdump_prt_next   ; Is the count zero?
  lda value_low
  bne mdump_prt_next

  jmp done

.mdump_prt_next
  clc                  ; Next row of bytes
  lda line_count
  adc p0_rom_ptr_low
  sta p0_rom_ptr_low
  lda #0
  adc p0_rom_ptr_high
  sta p0_rom_ptr_high

  jmp mdump_prt_all