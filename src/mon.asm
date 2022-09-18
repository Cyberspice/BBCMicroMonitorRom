

; The mon command starts the CLI

.mon
  lda #&8E
  ldx p0_rom_num
  jmp OSBYTE
