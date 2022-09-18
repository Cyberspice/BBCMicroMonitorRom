; Jumping off points as further than 128 bytes

.raise_bad_command_j
	jmp raise_bad_command

.raise_illegal_param_j
	jmp raise_illegal_param

; Reads a start and end address from the command line
;
; Command address:
;    (cmdline),Y
;
; Returns:
;    Last char - (cmdline),Y
;    rom_ptr - start
;    gen_count - length

.parse_start_and_len
	jsr skip_whitespace     ; Skip whitespace
	bcc raise_bad_command_j ; Premature end of line
	jsr read_hex            ; Read the start address
	bcs raise_illegal_param_j  ; Overflow - jump to error
	lda (p0_cmd_low),y     ; Test following char is whitespace
	beq raise_bad_command_j
	cmp #&20
	beq parse_start_and_len_2
	jmp raise_bad_command_j ; Not whitespace so error
.parse_start_and_len_2
	lda parse_hex_low       ; Store the value in the ROM ptr
	sta p0_rom_ptr_low
	lda parse_hex_high
	sta p0_rom_ptr_high
	jsr skip_whitespace     ; Skip whitespace
	bcc raise_bad_command_j ; Premature end of line
	lda (p0_cmd_low),y     ; + means the following value is a length
	cmp #'+'
	pha
	bne parse_start_and_len_3
	iny                     ; Next char
.parse_start_and_len_3
	jsr read_hex            ; Read the end address / length
	bcs raise_illegal_param_j  ; Overflow - jump to error
	pla
	cmp #'+'                ; Is it a length?
	beq parse_start_and_len_4
	sec                     ; Length is end address - start address
	lda parse_hex_low
	sbc p0_rom_ptr_low
	sta parse_hex_low
	lda parse_hex_high
	sbc p0_rom_ptr_high
	sta parse_hex_high
.parse_start_and_len_4
	lda parse_hex_low       ; Store the length
	sta gen_count_low
	lda parse_hex_high
	sta gen_count_high
	rts

; Do the MDUMP command
;
; Rest of command address:
;    (cmdline),Y

.do_mdump
	tya                     ; Save Y
	pha
	lda #ob_current_mode    ; Read current character and mode
	jsr OSBYTE
	tya
	tax                     ; Move the mode, Y, to X
	pla
	tay                     ; Restore Y
	jsr parse_start_and_len
	lda (p0_cmd_low),y	    ; Test following char is whitespace
	beq do_mdump_3          ; End of line
	cmp #&0d
	beq do_mdump_3          ; End of line
	cmp #&20
	beq do_mdump_2
	jmp raise_bad_command   ; Not a space so error
.do_mdump_2
	jsr skip_whitespace     ; Skip whitespace
	jmp raise_bad_command   ; More characters is an error
.do_mdump_3
	cpx #0
  beq mdump_80_col
  cpx #3
  beq mdump_80_col
	ldx #8
	jmp mdump_prt_lines
.mdump_80_col
	ldx #16
	jmp mdump_prt_lines

.mdump_prt_addr
	lda p0_rom_ptr_high
	jsr print_hex
	lda p0_rom_ptr_low
	jmp print_hex

.mdump_prt_bytes
	lda #&20
	jsr OSASCI
	lda (p0_rom_ptr_low),y
	jsr print_hex
	iny
	dex
	bne mdump_prt_bytes
	rts

.mdump_prt_pad_bytes
	lda #&20
	jsr OSASCI
	jsr OSASCI
	jsr OSASCI
	dex
	bne mdump_prt_pad_bytes
	rts

.mdump_prt_chars
	lda (p0_rom_ptr_low),y
	cmp #&20
	bmi mdump_prt_chars_2
	cmp #&7F
	bcc mdump_prt_chars_3
.mdump_prt_chars_2
	lda #'.'
.mdump_prt_chars_3
	jsr OSASCI
	iny
	dex
	bne mdump_prt_chars
	rts

.mdump_prt_lines
	stx temp_ws_high        ; Bytes per line

; Print a line of the memory dump
.mdump_prt_line
	lda p0_escape_flag
	beq mdump_ptr_line_1    ; No escape
	jmp command_done
.mdump_ptr_line_1
	jsr mdump_prt_addr      ; Print the address
	lda gen_count_high      ; Is there a whole line to print?
	bne mdump_prt_line_2
	ldx gen_count_low       ; Number of bytes remaining
	cpx temp_ws_high        ; Number of bytes per line
	bcs mdump_prt_line_2    ; More than a line, print a whole line

; Print the remainder of the bytes and chars
.mdump_prt_pad_bytes_and_chars
	ldy #0
	jsr mdump_prt_bytes     ; Print the remaining bytes
	sec
	lda temp_ws_high
	sbc gen_count_low       ; How much padding?
	jsr mdump_prt_pad_bytes ; Print the padding bytes to complete the bytes
	lda #&20
	jsr OSASCI
	ldx gen_count_low       ; Number of bytes remaining
	ldy #0
	txa
	jsr mdump_prt_chars     ; Print the remaining chars
	lda #13
	jsr OSASCI
	jmp command_done

; Print a line of bytes and chars
.mdump_prt_line_2
	ldx temp_ws_high
	ldy #0
	jsr mdump_prt_bytes     ; Print the bytes
	lda #&20
	jsr OSASCI
	ldx temp_ws_high
	ldy #0
	jsr mdump_prt_chars     ; Print the chars
	lda #13
	jsr OSASCI

; Update and move to the next line
	clc
	lda p0_rom_ptr_low         ; Address = Address + Bytes per line
	adc temp_ws_high
	sta p0_rom_ptr_low
	lda p0_rom_ptr_high
	adc #0
	sta p0_rom_ptr_high
	sec
	lda gen_count_low       ; Count = Count - Bytes per line
	sbc temp_ws_high
	sta gen_count_low
	lda gen_count_high
	sbc #0
	sta gen_count_high

; Still check as range may be (more than likely) a multiple of bytes per line
	beq mdump_prt_line_3    ; High count is zero
	bpl mdump_prt_line      ; High count is positive
.mdump_prt_line_3
	lda gen_count_low
	bne mdump_prt_line      ; Low count is not zero
	jmp command_done


