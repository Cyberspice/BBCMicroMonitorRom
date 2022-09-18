;===========================================
; MGO
;
; Command to run machine code at an address
;===========================================

; MGO takes an optional argument, which is a start address.
; If it is not supplied then the saved PC is used. The A,
; X, Y and flags are set from the save state (which can be
; updated with MREGS). An RTS will return from the code.

.mgo
  lda (p0_cmd_low),y       ; If no args, use saved PC
  cmp #13
  beq mgo_shadow_pc

  jsr read_hex_16bit       ; Read address
  bcc mgo_address_good
  jmp err_illegal_value

.mgo_address_good
  jsr space_check          ; Check before we update the saved
                           ; PC

  lda value_low            ; Update saved PC
  sta shadow_pc_low
  lda value_high
  sta shadow_pc_high

.mgo_shadow_pc
  jsr mgo_go               ; Run the code (RTS returns)
  jmp done

.mgo_go
  lda shadow_x
  tax
  lda shadow_y
  tay
  lda shadow_flags
  pha
  lda shadow_a
  plp
  jmp (shadow_pc_low)
