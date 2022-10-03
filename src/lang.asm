;=========================================
; Language entry point
 ;=========================================

shadow_pc_low  = &00
shadow_pc_high = &01
shadow_flags   = &02
shadow_s       = &03
shadow_a       = &04
shadow_x       = &05
shadow_y       = &06

cmd_buf_low    = &08
cmd_buf_high   = &09
cmd_max_chars  = &0a
cmd_min_char   = &0b
cmd_max_char   = &0c

cmd_vec_low    = &0e
cmd_vec_high   = &0f

COMMAND_BUF    = &700

.lang
  cmp #1                 ; Language entry?
  beq mon_lang_setup
  rts

; Main language entry. Since this is simple
; Just set the break vector for error handling

.mon_lang_setup
  sei
  lda #<mon_brk          ; Set BRKV
  sta BRKV
  lda #>mon_brk
  sta BRKV + 1
  ldx #&FF               ; Reset stack
  txs
  cli

.mon_lang_loop

; Prompt

  lda #'?'
  jsr OSWRCH

; OSWORD 0 (Read line) parameter block

  lda #<COMMAND_BUF
  sta cmd_buf_low
  lda #>COMMAND_BUF
  sta cmd_buf_high
  lda #&FF
  sta cmd_max_chars
  sta cmd_max_char
  lda #0
  sta cmd_min_char

  ldx #cmd_buf_low
  ldy #0
  jsr OSWORD
  bcs mon_escape

; If an empty line was entered just loop. Skip all white
; space characters to find the start of the command proper.
; Can't use skip space as looking at the buffer directly.

  ldx #0
.mon_lang_skip_loop
  lda COMMAND_BUF,x
  cmp #13
  beq mon_lang_loop
  cmp #(' ' + 1)
  bcs mon_lang_next
  inx
  jmp mon_lang_skip_loop

.mon_lang_next
  cmp #'*'
  bne mon_command

; Is it a star command, if so pass the command line to OSCLI.
; The command buffer on a page boundary so the X offset will
; be the low byte

  ldy #>COMMAND_BUF
  jsr OSCLI
  jmp mon_lang_loop

; The handler when someone presses escape at the command line.

.mon_escape
  lda #ob_clear_vdu_q
  jsr OSBYTE
  lda #ob_esc_eff_clear
  jsr OSBYTE

.mon_escape_err
  jmp err_escape

; Parse the command line for a command. Save the command buffer
; address in to the MOS command pointer. (&F2),Y is the pointer
; to the first non whites space character after the command
; keeps compatibility with handling * commands

.mon_command
  lda #<COMMAND_BUF
  sta p0_cmd_ptr_low
  lda #>COMMAND_BUF
  sta p0_cmd_ptr_high

; X contains the offset to the first non white space char ie the
; command
  txa
  tay

; Load the first character and save it
  lda (p0_cmd_ptr_low),y
  pha

; Now check its followed by a space
  iny
  lda (p0_cmd_ptr_low),y
  cmp #(' ' + 1)
  bcs mon_bad_command
  jsr skip_space

; Now look up the command in the command table

  ldx #0
.mon_cmd_lookup_loop
  pla
  cmp mon_cmd_table,x
  beq mon_cmd_found
  pha
  lda mon_cmd_table,x
  beq mon_bad_command
  inx
  inx
  inx
  jmp mon_cmd_lookup_loop

; Stack will be reset on error

.mon_bad_command
  jmp err_bad_command

.mon_cmd_found
  inx
  lda mon_cmd_table,x
  sta cmd_vec_low
  inx
  lda mon_cmd_table,x
  sta cmd_vec_high
  jsr mon_cmd_jump
  jmp mon_lang_loop

; When calling a command as a star command, returning will
; pop the accumulator and flags. So we push then here for
; stack balance even if it is not necessary.

.mon_cmd_jump
  php
  pha
  jmp (cmd_vec_low)

; Command table when in language

.mon_cmd_table
  EQUB 'D'
  EQUW mdiss
  EQUB 'G'
  EQUW mgo_lang
  EQUB 'M'
  EQUW mdump
  EQUB 'Q'
  EQUW quit
  EQUB 'R'
  EQUW mregs
  EQUB 'S'
  EQUW mset_lang
  EQUB 0

; On entry &FD and &FE point at the address of the byte
; the brk instruction. The stack includes the status
; register and the address of the next instruction (brk
; is a two byte instruction although the second one is
; not used). Push the rest of the registers on the stack

.mon_brk
  pha
  txa
  pha
  tya
  pha

; BRK followed by a zero byte is handled as a traditional
; breakpoint rather than an error. Error code 0 is "Silly"
; in BASIC which is not supported in this code. Non zero
; values are still considered to be error codes and so the
; regular error code message handling takes place.

  ldy #0
  lda (p0_brk_addr_low),y
  beq mon_breakpoint

; The byte after the brk is non zero so treat is as an Acorn
; MOS style error where this byte is the error number. It is
; followed by a zero byte terminated string describing the
; error.

.mon_error
  pha
  iny

; Print the error message

  jsr OSNEWL
.mon_error_loop
  lda (p0_brk_addr_low),y
  beq mon_error_next
  jsr OSWRCH
  iny
  jmp mon_error_loop

; Followed by the error code (in hex)

.mon_error_next
  lda #' '
  jsr OSWRCH
  lda #'('
  jsr OSWRCH
  pla
  jsr print_hex
  lda #')'
  jsr OSWRCH
  jsr OSNEWL

; Reset the stack then go back to the main loop

.mon_error_cleanup
  ldx #&FF
  txs
  jmp mon_lang_loop

; The byte after the brk IS zero so its a real breakpoint
; so save all the registers in to the shadow register
; storage

.mon_breakpoint
  pla
  sta shadow_y
  pla
  sta shadow_x
  pla
  sta shadow_a
  tsx
  stx shadow_s

; Leave the status and return address on the stack for
; the rti.

  lda &101,x
  sta shadow_flags
  lda &102,x
  sta shadow_pc_low
  lda &103,x
  sta shadow_pc_high

; Print the shadow register values out

  jsr print_regs

; Print the continue message

  ldx #0
.mon_prt_cont_next
  lda mon_cont_msg,x
  beq mon_read_key
  jsr OSWRCH
  inx
  jmp mon_prt_cont_next

; Wait for the user to press a key

.mon_read_key
  jsr OSNEWL

; Wait for Y/N (case insensitive)

.mon_read_key_next
  jsr OSRDCH
  bcs mon_read_key_err
  cmp #'y'
  beq mon_continue
  cmp #'Y'
  beq mon_continue
  cmp #'n'
  beq mon_error_cleanup
  cmp #'N'
  beq mon_error_cleanup

.mon_read_key_err
  lda p0_escape_flag
  bpl mon_read_key_next

; Handle escape - Can't just do an escape message
; as we're still in the brk handler. So need to duplicate
; behaviour

  lda #ob_clear_vdu_q
  jsr OSBYTE
  lda #ob_esc_clear
  jsr OSBYTE

  ldx #0
.mon_prt_esc
  lda err_escape_str,x
  beq mon_prt_esc_done
  jsr OSWRCH
  inx
  jmp mon_prt_esc
.mon_prt_esc_done
  jsr OSNEWL
  jmp mon_error_cleanup

; Return to the address on the stack and continue

.mon_continue
  lda shadow_a
  ldx shadow_x
  ldy shadow_y
  rti

.mon_cont_msg
  EQUS "BRK! Continue? (y/n)"
  EQUB 0

; Return to BASIC command. Basically just calls
; *BASIC.

.quit
  ldx #<basic_str
  ldy #>basic_str
  jmp OSCLI

.basic_str
  EQUS "BASIC"
  EQUB 13
