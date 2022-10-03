;===========================================
; MGO
;
; Command to run machine code at an address
;===========================================

; The shadow registers only exist when the Monitor shell
; or Language is being used.

; *MGO takes an argument, which is a start address.

.mgo
  lda (p0_cmd_ptr_low),y
  cmp #13
  bne mgo_not_cr
  jmp err_bad_command

.mgo_not_cr
  jsr read_hex_16bit  ; Read address
  bcc mgo_address_good
  jmp err_illegal_value

.mgo_address_good
  jsr mgo_value
  jmp done

.mgo_value
  jmp (value_low)

; The language version of MGO takes an optional argument
; which is the start address. If it is not supplied then
; the saved PC is used. The A, X, Y and flags are set
; from the save state (which can be updated with MREGS).
; An RTS will return from the code.

.mgo_lang
  lda (p0_cmd_ptr_low),y   ; If no args, use saved PC
  cmp #13
  beq mgo_use_shadow_pc

  jsr read_hex_16bit       ; Read address
  bcc mgo_lang_address_good
  jmp err_illegal_value

.mgo_lang_address_good
  jsr space_check          ; Check correctly ended line

  lda value_low            ; Update saved PC
  sta shadow_pc_low
  lda value_high
  sta shadow_pc_high

.mgo_use_shadow_pc
  jsr mgo_use_shadow_regs  ; Run the code (RTS returns)
  jmp done

.mgo_use_shadow_regs
  lda shadow_x
  tax
  lda shadow_y
  tay
  lda shadow_flags
  pha
  lda shadow_a
  plp
  jmp (shadow_pc_low)
