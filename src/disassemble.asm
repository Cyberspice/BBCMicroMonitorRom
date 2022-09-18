
; Addressing modes.
;
; This table has the number of bytes per instruction type
; and an offset to the routine to handle that instruction
; type

.opcode_modes
.opcode_mode_acc
  EQUB 1 ; Accumulator
  EQUW opcode_acc
.opcode_mode_imm
  EQUB 1 ; Immediate
  EQUW opcode_imm
.opcode_mode_zpg
  EQUB 2 ; Direct (Zero) page
  EQUW opcode_zpg
.opcode_mode_abs
  EQUB 3 ; Absolute
  EQUW opcode_abs
.opcode_mode_zpgx
  EQUB 2 ; Direct (Zero) page X indexed
  EQUW opcode_zpgx
.opcode_mode_absx
  EQUB 3 ; Absolute X indexed
  EQUW opcode_absx
.opcode_mode_absy
  EQUB 3 ; Absolute Y indexed
  EQUW opcode_absy
.opcode_mode_xind
  EQUB 2 ; Direct (Zero) page indirect pre indexed X
  EQUW opcode_xind
.opcode_mode_indy
  EQUB 2 ; Direct (Zero) page indirect post indexed Y
  EQUW opcode_indy
.opcode_mode_bra
  EQUB 2 ; Branch instruction
  EQUW opcode_bra


; The 65xx processors have groups of instructions where some bits
; describe the opcode and the other bits the addressing mode. The
; following tables have instruction patterns, addressing mode
; patterns and indexes of addressing mode types.

; Group 1 opcodes

.opcode_grp1_mask
  EQUB &E0

.opcode_grp1
  EQUB 8   ; Count
  EQUB &60 ; ADC
  EQUS "ADC"
  EQUB &20 ; AND
  EQUS "AND"
  EQUB &C0 ; CMP
  EQUS "CMP"
  EQUB &40 ; EOR
  EQUS "EOR"
  EQUB &A0 ; LDA
  EQUS "LDA"
  EQUB &00 ; ORA
  EQUS "ORA"
  EQUB &E0 ; SBC
  EQUS "SBC"
  EQUB &80 ; STA
  EQUS "STA"

.opcode_grp1_addr_mask
  EQUB &1F

.opcode_grp1_addr
  EQUB 8   ; Count
  EQUB &09 ; Immediate
  EQUB opcode_mode_imm - opcode_mode
  EQUB &05 ; Direct (Zero) page
  EQUB opcode_mode_zpg - opcode_mode
  EQUB &0D ; Absolute
  EQUB opcode_mode_abs - opcode_mode
  EQUB &15 ; Direct (Zero) page X indexed
  EQUB opcode_mode_zpgx - opcode_mode
  EQUB &1D ; Absolute X indexed
  EQUB opcode_mode_absx - opcode_mode
  EQUB &19 ; Absolute Y indexed
  EQUB opcode_mode_absy - opcode_mode
  EQUB &01 ; Direct (Zero) page indirect pre indexed X
  EQUB opcode_mode_xind - opcode_mode
  EQUB &11 ; Direct (Zero) page indirect post indexed Y
  EQUB opcode_mode_indy - opcode_mode

.opcode_grp1_addr_65C02
  EQUB &12 ; Direct (Zero) page indirect
  EQUW opcode_ind

; .opcode_grp1_addr_16bit  - TODO

; Group 2 opcodes. These are in two sub-groups indicated by the top bit.

.opcode_grp2a_mask
  EQUB &E3

; Top bit clear
.opcode_grp2a
  EQUB 4   ; Count
  EQUB &02 ; ASL
  EQUS "ASL"
  EQUB &42 ; LSR
  EQUS "LSR"
  EQUB &22 ; ROL
  EQUS "ROL"
  EQUB &62 ; ROR
  EQUS "ROR"

.opcode_grp2b_mask
  EQUB &E7

; Top bit set
.opcode_grp2b
  EQUB 4   ; Count
  EQUB &C6 ; DEC
  EQUS "DEC"
  EQUB &E6 ; INC
  EQUS "INC"
  EQUB &86 ; STX
  EQUS "STX"
  EQUB &84 ; STY
  EQUS "STY"

.opcode_grp2_addr_mask
  EQUB &1C

.opcode_grp2_addr
  EQUB 5   ; Count
  EQUB &08 ; Accumulator
  EQUB opcode_mode_acc - opcode_mode
  EQUB &04 ; Direct (Zero) page
  EQUB opcode_mode_zpg - opcode_mode
  EQUB &0C ; Absolute
  EQUB opcode_mode_abs - opcode_mode
  EQUB &14 ; Direct (Zero) page X indexed
  EQUB opcode_mode_zpgx - opcode_mode
  EQUB &1C ; Absolute X indexed
  EQUB opcode_mode_absx - opcode_mode

; LDX and LDY opcodes

.opcode_ldxy_mask
  EQUB &E3

.opcode_ldxy
  EQUB 2   ; Count
  EQUB &A2 ; LDX
  EQUS "LDX"
  EQUB &A0 ; LDY
  EQUS "LDY"

.opcode_ldxy_addr
  EQUB 5   ; Count
  EQUB &00 ; Immediate
  EQUB opcode_mode_imm - opcode_mode
  EQUB &04 ; Direct (Zero) page
  EQUB opcodev_zpg - opcode_mode
  EQUB &0C ; Absolute
  EQUB opcode_mode_abs - opcode_mode
  EQUB &14 ; Direct (Zero) page X indexed
  EQUB opcode_mode_zpgx - opcode_mode
  EQUB &1C ; Absolute X indexed
  EQUB opcode_mode_absx - opcode_mode

; CPX and CPY opcodes

.opcode_cpxy_mask
  EQUB &F3

.opcode_cpxy
  EQUB 2   ; Count
  EQUB &E0 ; CPX
  EQUS "CPX"
  EQUB &C0 ; CPY
  EQUS "CPY"

.opcode_cpxy_addr
  EQUB 3   ; Count
  EQUB &00 ; Immediate
  EQUB opcode_mode_imm - opcode_mode
  EQUB &04 ; Direct (Zero) page
  EQUB opcode_mode_zpg - opcode_mode
  EQUB &0C ; Absolute
  EQUB opcode_mode_abs - opcode_mode

; Two additional addressing modes
; EQUB &14 ; Direct page indexed (X uses Y, and Y uses X)
; EQUB &1C ; Absolute indexed (X uses Y, and Y uses X)

; TRB and TSB opcodes

.opcode_tsrb_mask
  EQUB &F7

.opcode_tsrb
  EQUB 2   ; Count
  EQUB &14 ; TRB
  EQUS "TRB"
  EQUB &04 ; TSB
  EQUS "TSB"

.opcode_tsrb_addr
  EQUB 2   ; Count
  EQUB &00 ; Direct (Zero) page
  EQUB opcode_mode_zpg - opcode_mode
  EQUB &08 ; Absolute
  EQUB opcode_mode_abs - opcode_mode

; Immediate opcodes. These are always 1 byte

.opcode_immeds
  EQUB &18 ; CLC
  EQUS "CLC"
  EQUB &D8 ; CLD
  EQUS "CLD"
  EQUB &58 ; CLI
  EQUS "CLI"
  EQUB &B8 ; CLV
  EQUS "CLV"
  EQUB &EA ; NOP
  EQUS "NOP"
  EQUB &48 ; PHA
  EQUS "PHA"
  EQUB &08 ; PHP
  EQUS "PHP"
  EQUB &68 ; PLA
  EQUS "PLA"
  EQUB &28 ; PLP
  EQUS "PLP"
  EQUB &40 ; RTI
  EQUS "RTI"
  EQUB &60 ; RTS
  EQUS "RTS"
  EQUB &38 ; SEC
  EQUS "SEC"
  EQUB &F8 ; SED
  EQUS "SED"
  EQUB &78 ; SEI
  EQUS "SEI"
  EQUB &AA ; TAX
  EQUS "TAX"
  EQUB &A8 ; TAY
  EQUS "TAY"
  EQUB &BA ; TSX
  EQUS "TSX"
  EQUB &8A ; TXA
  EQUS "TXA"
  EQUB &9A ; TXS
  EQUS "TXS"
  EQUB &98 ; TYA
  EQUS "TYA"

; Banch instructions. These are always 2 bytes

.opcode_branch
  ; BCC
  ; BCS
  ; BEQ
  ; BIT
  ; BMI
  ; BNE
  ; BPL
  ; BVC

; Jump instructions. These are always 3 bytes

.opcode_jmpjsr
  ; JMP
  ; JSR

; BRK instruction is 2 bytes

.opcode_others
  ; BRK


.diss_prt_inst
  clc
  sta temp_ws_low
  asl a
  adc temp_ws_low
  tax
  lda opcode_inst,x
  jsr OSWRCH
  inx
  lda opcode_inst,x
  jsr OSWRCH
  inx
  lda opcode_inst,x
  jmp OSWRCH

.diss_prt_amp
  lda #&26
  jmp OSWRCH

.diss_prt_next_byte
  jsr diss_next_byte
  jmp print_hex

.diss_prt_next_ind
  pha
  jsr diss_prt_next_byte
  lda #&2C
  jsr OSWRCH
  pla
  jsr OSRWRCH
  jmp opcode_imm

.opcode_abs
.opcode_absx
.opcode_absy
.opcode_ind
.opcode_xind
.opcode_indy
.opcode_rel
.opcode_zpg
  jsr diss_prt_amp
  jsr diss_prt_next_byte
  jmp opcode_imp

.opcode_zpgx
  jsr diss_prt_amp
  jsr diss_prt_next_byte
  lda #&2C
  jsr OSWRCH
  lda #&58
  jsr OSRWRCH
  jmp opcode_imm

.opcode_zpgy

.opcode_imm
  lda #&23
  jsr OSWRCH
  jsr diss_prt_amp
  jsr diss_prt_next_byte
  jsr print_hex
  jmp opcode_imm

.opcode_acc
  lda #&65
  jsr OSWRCH

.opcode_imp
  lda #13
  jmp OSASCI




  ldx opcode_grp1
  ldy #1
  lda inst
  and opcode_grp1_mask
.grp1_loop
  cmp opcode_grp1,x
  beq grp1_loop_2
  iny
  iny
  iny
  iny
  dex
  bne grp1_loop
  sec
  rts
.grp1_loop_2
  clc
  tya
  adc opcode_grp1
  sta nmenomic
  lda opcode_grp1 + 1
  adc #0
  sta nmenomic + 1









.disassemble

.disloop
  jsr mdump_prt_addr
  lda (p0_rom_ptr_low),y
  pha
  tax
  lda opcode_tbl,x
  cmp #&ff
  beq disloop2
  jsr diss_prt_inst



.disloop2
  ;jsr diss_prt_byte
.disloop3

  rts
