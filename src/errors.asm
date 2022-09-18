

STACK_BASE=&100

.err_escape
  jsr err_relocate
  EQUB 17
.err_escape_str
  EQUS "Escape"
  EQUB 0

.err_bad_command
  jsr err_relocate
  EQUB &FE
  EQUS "Bad command"
  EQUB 0

.err_illegal_value
  jsr err_relocate
  EQUB &C0
  EQUS "Illegal value"
  EQUB 0

.err_relocate
  pla
  sta value_low
  pla
  sta value_high
  ldy #1               ; PC pushed to stack points to last byte of the JSR instruction
  ldx #0

  stx STACK_BASE       ; Store a BRK instruction (zero)
  inx
  lda (value_low),y    ; The error code may be zero so do it explicitly
  sta STACK_BASE,x
  inx
  iny

; The message and terminator byte

.err_relocate_loop
  lda (value_low),y
  sta STACK_BASE,x
  beq err_relocate_done
  inx
  iny
  jmp err_relocate_loop

; Do the BRK

.err_relocate_done
  jmp STACK_BASE
