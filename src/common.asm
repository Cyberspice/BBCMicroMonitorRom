;=========================================
; Common routines
;=========================================

MAX_BYTE_COUNT=8

; Skip white space. (which is all control characters except carriage
; return). Returns the last character in the accumulator.

.skip_space
  lda (p0_cmd_low),y
  cmp #13
  beq skip_space_done
  cmp #33
  bcs skip_space_done
  iny
  jmp skip_space
.skip_space_done
  rts

; Tests for white space, line end or illegal characters following
; a parameter. If its NOT followed by white space or end of line
; then an error is raised. Returns the last character in the accumulator.

.space_check
  lda (p0_cmd_low),y     ; Test for line end or white space
  cmp #13
  beq space_check_done
  cmp #' '
  beq space_check_skip_space
  jmp err_illegal_value
.space_check_skip_space
  jsr skip_space
.space_check_done
  rts

; Reads an address from the command line. If the address is not
; there it raises a bad command error. If it is invalid hex then
; an illegal value error is raised. The address is stored in
; value_low and value_high and the accumlator returns the last
; character read

.read_address
  lda (p0_cmd_low),y
  cmp #13
  bne read_address_not_cr
  jmp err_bad_command

.read_address_not_cr
  jsr read_hex_16bit  ; Read address
  bcc read_address_good
  jmp err_illegal_value

.read_address_good
  lda value_low
  sta p0_rom_ptr_low
  lda value_high
  sta p0_rom_ptr_high  ; Save address

  jmp space_check

; Print a space to the output

.print_space
  pha
  lda #' '
  jsr OSWRCH
  pla
  rts

; Prints X spaces to the output

.print_x_spaces
  pha
  lda #' '
.print_x_spaces_loop
  jsr OSWRCH
  dex
  bne print_x_spaces_loop
  pla
  rts

; Print an equals character '=' to the output

.print_equals
  pha
  lda #'='
  jsr OSWRCH
  pla
  rts

; Print the address of ROM pointer

.print_address
	lda p0_rom_ptr_high
	jsr print_hex
	lda p0_rom_ptr_low
	jmp print_hex


.print_byte_as_char
	cmp #' '
	bmi print_byte_as_char_dot
	cmp #&7F
	bcc print_byte_as_char_ascii
.print_byte_as_char_dot
	lda #'.'
.print_byte_as_char_ascii
	jmp OSWRCH


; Get a byte from the the current ROM pointer
; paging in the ROM specified by Y. X and Y are
; preserved. The address is incremented.

.get_byte
  pha                   ; Place holder on the stack
	txa                   ; Save X
  pha
  tya                   ; Save Y
  pha
  jsr OSRDRM
  inc p0_rom_ptr_low    ; Increment the address
  bne get_byte_next
  inc p0_rom_ptr_high
.get_byte_next
  tsx
  sta &103,x            ; Stack is Y, X, A and S points
                        ; to the next empty space
  pla
  tay
  pla
  tax
  pla                   ; We're pulling the value we read
  rts

; Read parameters from the command line.
;
; This reads a start address, and optionally either a number
; of bytes (preceeded with a +) or the end addresss exclusive.
; The third parameter is optionally a ROM number for dumping
; memory from a sideways ROM.

.get_parameters
  jsr read_address
  cmp #13
  bne get_param_next
  lda #MAX_BYTE_COUNT   ; No end of count so set it to MAX_BYTE_COUNT
  sta value_low
  lda #0
  sta value_high
  rts

; Next param is count or end address

.get_param_next
  cmp #'+'
  beq get_param_count   ; Provided a count rather than end address

  jsr read_hex_16bit
  bcc get_param_good_end_addr
  jmp err_illegal_value

; Get the end address and calulate the count

.get_param_good_end_addr
  sec
  lda value_low
  sbc p0_rom_ptr_low
  sta value_low
  lda value_high
  sbc p0_rom_ptr_high
  sta value_high         ; Calculate count
  jmp get_param_good_count

; Get the count

.get_param_count
  iny
  jsr read_hex_16bit
  bcc get_param_good_count
  jmp err_illegal_value

; We have a count now see if there's a ROM number

.get_param_good_count
  jsr space_check
  cmp #13
  bne get_param_rom_num_next
  lda p0_rom_num
  sta rom_num
  rts

; Get the ROM number

.get_param_rom_num_next
  jsr char_to_hex
  bcc get_param_good_rom_num
  jmp err_illegal_value

; If its good check there's no garbage on the end of
; the line and then return

.get_param_good_rom_num
  sta rom_num
  iny
  jsr space_check
  cmp #13
  bne mdump_bad_command
  rts

.mdump_bad_command
  jmp err_bad_command
