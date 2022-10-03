

command_addr_off = &a8
command_addr_low = &aa
command_addr_high = &ab

.command
  ldx #0
  stx command_addr_off

; Loop through the commands. End of command
; list is indicated by a zero byte.

.command_loop
  tya
  pha                    ; Save Y

; Loop through the characters in the command
; up to the CR or space or dot.

.command_cmp_loop
  lda command_table,x
  beq command_not_found   ; End of table

  lda (p0_cmd_ptr_low),y
  cmp #13                 ; End of line?
  bne command_next
  cmp command_table,x
  beq command_found
  jmp command_not_this

; Not a CR (ends command on command line)

.command_next
  cmp #' '                ; Space (end of word)
  bne command_next_2
  lda #13
  cmp command_table,x
  beq command_found
  jmp command_not_this

; Not a space (ends command on command line)

.command_next_2
  cmp #'.'                ; Dot character abbreviation?
  beq command_abrev
  and #&DF                ; To upper case
  cmp command_table,x
  bne command_not_this
  inx
  iny
  jmp command_cmp_loop    ; Check next char

; Match failed, move on to the next command

.command_not_this
  inx
  lda command_table,x
  cmp #13
  bne command_not_this
  inx
  inc command_addr_off
  inc command_addr_off
  pla
  tay
  jmp command_loop
.command_not_found
  pla
  jmp return

; Command matched

.command_abrev
  iny                      ; skip dot

.command_found
  pla
  jsr skip_space

; Get the address of the command routine and call it

  ldx command_addr_off
  lda command_addr_table,x
  sta command_addr_low
  lda command_addr_table + 1,x
  sta command_addr_high
  jmp (command_addr_low)

.command_table
  EQUS "MDISS"
  EQUB 13
  EQUS "MDUMP"
  EQUB 13
  EQUS "MGO"
  EQUB 13
  EQUS "MON"
  EQUB 13
  EQUS "MSET"
  EQUB 13
  EQUB 0

.command_addr_table
  EQUW mdiss
  EQUW mdump
  EQUW mgo
  EQUW mon
  EQUW mset
