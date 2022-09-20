;===========================================
; MREGS
;
; Command to display or set register values
;===========================================

mregs_jump_low=&100
mregs_jump_high=&101

.print_regs
  lda #'P'               ; Program counter value
  jsr OSWRCH
  lda #'C'
  jsr OSWRCH
  jsr print_equals
  lda shadow_pc_high
  jsr print_hex
  lda shadow_pc_low
  jsr print_hex
  jsr print_space

  lda #'A'               ; Accumulator value
  jsr OSWRCH
  jsr print_equals
  lda shadow_a
  jsr print_hex
  jsr print_space

  lda #'X'               ; X value
  jsr OSWRCH
  jsr print_equals
  lda shadow_x
  jsr print_hex
  jsr print_space

  lda #'Y'               ; Y value
  jsr OSWRCH
  jsr print_equals
  lda shadow_y
  jsr print_hex
  jsr print_space

  lda #'S'               ; Stack pointer value
  jsr OSWRCH
  jsr print_equals
  lda shadow_s
  jsr print_hex
  jsr print_space

  lda #'P'
  jsr OSWRCH
  jsr print_equals

  ldx #0
.print_flags_loop
  lda mregs_flag_table,x
  beq print_flags_done
  and shadow_flags
  beq print_flags_reset
  inx
  lda mregs_flag_table,x
  jsr OSWRCH
  inx
  jmp print_flags_loop
.print_flags_reset
  inx
  lda #'-'
  jsr OSWRCH
  inx
  jmp print_flags_loop
.print_flags_done

  jmp OSNEWL

; Check for = and then read the 8 bit value that follows
; it.

.mregs_set_read_val
  lda (p0_cmd_low),y
  cmp #'='               ; Test there's an equals
  beq mregs_set_read_val_2
  sec
  rts
.mregs_set_read_val_2
  iny
  jsr read_hex_8bit
  bcs mregs_set_read_val_3
  lda value_low
.mregs_set_read_val_3
  rts

; Set the accumulator shadow

.mregs_set_a
  jsr mregs_set_read_val
  bcs mregs_illegal_value
  sta shadow_a
  jmp mregs_set_next

; Set the X shadow

.mregs_set_x
  jsr mregs_set_read_val
  bcs mregs_illegal_value
  sta shadow_x
  jmp mregs_set_next

; Set the Y shadow

.mregs_set_y
  jsr mregs_set_read_val
  bcs mregs_illegal_value
  sta shadow_y
  jmp mregs_set_next

; Set the stack point shadow

.mregs_set_s
  jsr mregs_set_read_val
  bcs mregs_illegal_value
  sta shadow_s
  jmp mregs_set_next

; Illegal Value Error, placed within relative branch range.

.mregs_illegal_value
  jmp err_illegal_value

; Set the flags register

.mregs_set_flags
  lda (p0_cmd_low),y
  cmp #'='               ; Test there's an equals
  bne mregs_illegal_value
  iny                    ; Next char should be a flag or - for all clear

; Save the current shadow flags value and
; then zero them.

  lda shadow_flags
  pha
  lda #0
  sta shadow_flags

  lda (p0_cmd_low),y
  cmp #'-'               ; Clear flags character
  bne mregs_set_a_flag   ; May be a flag bit
  iny                    ; Next char
  pla                    ; Throw away saved flags
  jmp mregs_set_next

; Set a flag bit

.mregs_set_a_flag
  ldx #0
.mregs_set_a_flag_loop
  lda mregs_flag_table,x
  beq mregs_set_flag_err ; Test for end of flags table

  pha                    ; Save the flag bit
  inx                    ; Skip to the flag character
  lda (p0_cmd_low),y
  cmp mregs_flag_table,x
  beq mregs_flag_found   ; Is this flag?

  pla                    ; Nope, try next one
  inx
  jmp mregs_set_a_flag_loop

; Invalid flag character

.mregs_set_flag_err
  pla                    ; Restore the original flags
  sta shadow_flags
  jmp err_illegal_value  ; Can jump directly

; Found a valid flag bit, so set it.

.mregs_flag_found
  pla
  ora shadow_flags       ; Set the bit
  sta shadow_flags
  iny                    ; Next char
  lda (p0_cmd_low),y
  cmp #(' ' + 1)
  bcs mregs_set_a_flag
  pla                    ; Throw away saved flags
  jmp mregs_set_next

; Set all the shadow registers. This iterates through
; the command line looking for ?=XX where ? is a valid
; register identifier and XX is a valid hex value,
; except for the flags which is one or more flag characters.

.mregs_set_regs
  lda (p0_cmd_low),y
  cmp #13                ; End of params?
  bne mregs_set_a_reg
  rts

; Loop through arguments on command line

.mregs_set_a_reg
  ldx #0
.mregs_set_loop
  lda mregs_set_reg_table,x
  beq mregs_illegal_value

; Look up register name

  lda (p0_cmd_low),y
  cmp mregs_set_reg_table,x
  beq mregs_set_found
  inx
  inx
  inx
  jmp mregs_set_loop

; Next argument

.mregs_set_next
  jsr skip_space
  jmp mregs_set_regs

; Found a register, so set it by calling the setter routine.

.mregs_set_found
  inx
  lda mregs_set_reg_table,x
  sta mregs_jump_low
  inx
  lda mregs_set_reg_table,x
  sta mregs_jump_high
  iny
  jmp (mregs_jump_low)

; With no arguments the command displays the last saved
; state of the registers. The saved state is set when a
; BRK instruction is handled.

.mregs
  lda (p0_cmd_low),y
  cmp #13
  bne mregs_set
  jsr print_regs
  jmp done

; Command with arguments sets those registers

.mregs_set
  jsr mregs_set_regs
  jsr print_regs
  jmp done

.mregs_flag_table
  EQUB &80
  EQUB 'N'
  EQUB &40
  EQUB 'V'
  EQUB &08
  EQUB 'D'
  EQUB &04
  EQUB 'I'
  EQUB &02
  EQUB 'Z'
  EQUB &01
  EQUB 'C'
  EQUB 0

.mregs_set_reg_table
  EQUB 'A'
  EQUW mregs_set_a
  EQUB 'P'
  EQUW mregs_set_flags
  EQUB 'S'
  EQUW mregs_set_s
  EQUB 'X'
  EQUW mregs_set_x
  EQUB 'Y'
  EQUW mregs_set_y
  EQUB 0