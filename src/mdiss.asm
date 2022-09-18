;=========================================
; MDISS
;
; Command to disassembler memory contents
;=========================================

opcode_size=&100
opcode_pad=&101
opcode_addr_sub_low=&102
opcode_addr_sub_high=&103
opcode_bytes=&104 ; Three bytes

; 6502 opcodes are a single byte followed by zero or more
; operand bytes up to 2. The single byte can be separated
; as follows:
;
; aaabbbcc - pattern
; 7      0 - bits
;
; cc  - defines the group. There's group 0, group 1 and group 2.
;       Group 3 comprises 'illegal' instructions
; aaa - the opcode (Not always consistent except for group 1)
; bbb - the addressing mode (Group 0 and 2 are mostly consistent
;       with one another. Group 1 is consistent in the group)

; The basic algorithm is, check the group for the opcode (not
; all instructions support all variants). Once found, mask off
; bits to find the 'base' opcode which is used to find the
; mnenomic string. Mask off the inverse bits to find the
; addressing mode. Jump to the mode handler.

; Typical output
;
; 1234 01 02 03 MEN #&1234,X ...

; Find an immediate opcode.
; If found carry is clear and value_low and value_high
; are set to the address of the mnemonic string. If
; not found carry is set.

.mdiss_imm_check
  ldx #0
.mdiss_imm_loop
  lda opcode_bytes
  cmp opcodes_immeds,x
  beq mdiss_imm_found
  lda #&FF
  cmp opcodes_immeds,x
  beq mdiss_imm_not_found
  inx
  inx
  inx
  inx
  jmp mdiss_imm_loop
.mdiss_imm_not_found
  sec
  rts
.mdiss_imm_found
  inx
  txa
  clc
  adc #<opcodes_immeds
  sta opcode_str_low
  lda #0
  adc #>opcodes_immeds
  sta opcode_str_high
  lda opcodes_imm_sub
  sta opcode_addr_sub_low
  lda opcodes_imm_sub + 1
  sta opcode_addr_sub_high
  lda opcodes_imm_size
  sta opcode_size
  lda opcodes_imm_pad
  sta opcode_pad
  rts

; Opcodes for immediates. Handle these separately for
; speed an ease

.opcodes_immeds
  EQUB &00 ; BRK
  EQUS "BRK"
  EQUB &18 ; CLC
  EQUS "CLC"
  EQUB &D8 ; CLD
  EQUS "CLD"
  EQUB &58 ; CLI
  EQUS "CLI"
  EQUB &B8 ; CLV
  EQUS "CLV"
  EQUB &CA ; DEX
  EQUS "DEX"
  EQUB &88 ; DEY
  EQUS "DEY"
  EQUB &E8 ; INX
  EQUS "INX"
  EQUB &C8 ; INY
  EQUS "INY"
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
  EQUB &FF ; END

.opcodes_imm_sub
  EQUW mdiss_imm

.opcodes_imm_size
  EQUB 1

.opcodes_imm_pad
  EQUB 10

; Opcodes for branch instructions. These clash
; with some group two alternate instructions so
; test for them next.

.mdiss_bra_check
  ldx #0
.mdiss_bra_loop
  lda opcode_bytes
  cmp opcodes_branch,x
  beq mdiss_bra_found
  lda #&FF
  cmp opcodes_branch,x
  beq mdiss_bra_not_found
  inx
  inx
  inx
  inx
  jmp mdiss_bra_loop
.mdiss_bra_not_found
  sec
  rts
.mdiss_bra_found
  inx
  txa
  clc
  adc #<opcodes_branch
  sta opcode_str_low
  lda #0
  adc #>opcodes_branch
  sta opcode_str_high
  lda opcodes_branch_sub
  sta opcode_addr_sub_low
  lda opcodes_branch_sub + 1
  sta opcode_addr_sub_high
  lda opcodes_branch_size
  sta opcode_size
  lda opcodes_branch_pad
  sta opcode_pad
  rts

.opcodes_branch
  EQUB &90 ; BCC
  EQUS "BCC"
  EQUB &B0 ; BCS
  EQUS "BCS"
  EQUB &F0 ; BEQ
  EQUS "BEQ"
  EQUB &30 ; BMI
  EQUS "BMI"
  EQUB &D0 ; BNE
  EQUS "BNE"
  EQUB &10 ; BPL
  EQUS "BPL"
  EQUB &50 ; BVC
  EQUS "BVC"
  EQUB &70 ; BVS
  EQUB "BVS"
  EQUB &FF ; END

.opcodes_branch_sub
  EQUW mdiss_bra

.opcodes_branch_size
  EQUB 2

.opcodes_branch_pad
  EQUB 5

; Opcodes for jump and jump subroutine

.mdiss_jump_check
  ldx #0
.mdiss_jump_loop
  lda opcode_bytes
  cmp opcodes_jump,x
  beq mdiss_jump_found
  lda #&FF
  cmp opcodes_jump,x
  beq mdiss_jump_not_found
  inx
  inx
  inx
  inx
  jmp mdiss_jump_loop
.mdiss_jump_not_found
  sec
  rts
.mdiss_jump_found
  inx
  txa
  clc
  adc #<opcodes_jump
  sta opcode_str_low
  lda #0
  adc #>opcodes_jump
  sta opcode_str_high

  txa
  lsr a
  tax

  lda opcodes_jump_addr_sub,x
  sta opcode_addr_sub_low
  lda opcodes_jump_addr_sub + 1,x
  sta opcode_addr_sub_high

  txa
  lsr a
  tax

  lda opcodes_jump_size,x
  sta opcode_size
  lda opcodes_jump_pad,x
  sta opcode_pad
  rts


.opcodes_jump
  EQUB &4C
  EQUS "JMP"
  EQUB &6C
  EQUS "JMP"
  EQUB &20
  EQUS "JSR"
  EQUB &FF ; END

.opcodes_jump_addr_sub
  EQUW mdiss_abs
  EQUW mdiss_jmpind
  EQUW mdiss_abs

.opcodes_jump_size
  EQUB 3
  EQUB 3
  EQUB 3

.opcodes_jump_pad
  EQUB 5
  EQUB 3
  EQUB 5

; Opcodes for Group 1

.mdiss_grp1_check

; Check the instruction is in group 1

  ldx #0
.mdiss_grp1_loop
  lda opcode_bytes
  cmp opcodes_grp1,x
  beq mdiss_grp1_found
  lda #&FF
  cmp opcodes_grp1,x
  beq mdiss_grp1_done
  inx
  jmp mdiss_grp1_loop
.mdiss_grp1_done
  sec
  rts

; Now find the string using the mask
; A contains the instruction

.mdiss_grp1_found
  pha
  and #&E3
  ldx #0
.mdiss_grp1_found_loop
  cmp opcodes_grp1_mask,x
  beq mdiss_grp1_mask_found
  inx
  inx
  inx
  inx
  jmp mdiss_grp1_found_loop

; Found the mask, the mnemonic starts in the next byte

.mdiss_grp1_mask_found
  inx
  txa
  txa
  clc
  adc #<opcodes_grp1_mask
  sta opcode_str_low
  lda #0
  adc #>opcodes_grp1_mask
  sta opcode_str_high

; Turn addressing mode in to an offset

  pla
  and #&1C
  lsr a
  pha
  tax

; Get address of the mode handler and the size of the opcode

  lda opcodes_grp1_addr_sub,x
  sta opcode_addr_sub_low
  lda opcodes_grp1_addr_sub + 1,x
  sta opcode_addr_sub_high
  pla
  lsr a
  tax
  lda opcodes_grp1_size,x
  sta opcode_size
  lda opcodes_grp1_pad,x
  sta opcode_pad
  rts

; Group 1 opcodes have the bottom two bits of the opcode as 01
; I.e. they are always odd. They also support all of the addressing
; modes: immediate, zero page, zero page plus X, absolute, absolute
; plus X, absolute plus Y, zero page plus X indirected, zero page
; indirected plust Y.

.opcodes_grp1
; ADC
  EQUB &69
  EQUB &65
  EQUB &75
  EQUB &6D
  EQUB &7D
  EQUB &79
  EQUB &61
  EQUB &71
; AND
  EQUB &29
  EQUB &25
  EQUB &35
  EQUB &2D
  EQUB &3D
  EQUB &39
  EQUB &21
  EQUB &31
; CMP
  EQUB &C9
  EQUB &C5
  EQUB &D5
  EQUB &CD
  EQUB &DD
  EQUB &D9
  EQUB &C1
  EQUB &D1
; EOR
  EQUB &49
  EQUB &45
  EQUB &55
  EQUB &4D
  EQUB &5D
  EQUB &59
  EQUB &41
  EQUB &51
; LDA
  EQUB &A9
  EQUB &A5
  EQUB &B5
  EQUB &AD
  EQUB &BD
  EQUB &B9
  EQUB &A1
  EQUB &B1
; ORA
  EQUB &09
  EQUB &05
  EQUB &15
  EQUB &0D
  EQUB &1D
  EQUB &19
  EQUB &01
  EQUB &11
; SBC
  EQUB &E9
  EQUB &E5
  EQUB &F5
  EQUB &ED
  EQUB &FD
  EQUB &F9
  EQUB &E1
  EQUB &F1
; STA
  EQUB &85
  EQUB &95
  EQUB &8D
  EQUB &9D
  EQUB &99
  EQUB &81
  EQUB &91

  EQUB &FF ; END

.opcodes_grp1_mask
  EQUB &61 ; ADC
  EQUS "ADC"
  EQUB &21 ; AND
  EQUS "AND"
  EQUB &C1 ; CMP
  EQUS "CMP"
  EQUB &41 ; EOR
  EQUS "EOR"
  EQUB &A1 ; LDA
  EQUS "LDA"
  EQUB &01 ; ORA
  EQUS "ORA"
  EQUB &E1 ; SBC
  EQUS "SBC"
  EQUB &81 ; STA
  EQUS "STA"
  EQUB &FF ; END

.opcodes_grp1_addr_sub
  EQUW mdiss_Xind
  EQUW mdiss_zpg
  EQUW mdiss_val
  EQUW mdiss_abs
  EQUW mdiss_indY
  EQUW mdiss_zpgX
  EQUW mdiss_absY
  EQUW mdiss_absX

.opcodes_grp1_size
  EQUB 2
  EQUB 2
  EQUB 2
  EQUB 3
  EQUB 2
  EQUB 2
  EQUB 3
  EQUB 3

.opcodes_grp1_pad
  EQUB 3
  EQUB 7
  EQUB 6
  EQUB 5
  EQUB 3
  EQUB 3
  EQUB 3
  EQUB 3

; Opcodes for group 2 and some group 0

; Group 0 and Group 2 have the bottom two bis with values
; 00 and 10. Group 3 is entirely 'illegal' instructions on
; the original 65xx processors.
;
; Group 0 and 2 support a subset of the addressing modes
; and/or alternate usage (for example branch instructions)

.mdiss_grp2_check

; Check the instruction is in group 2

  ldx #0
.mdiss_grp2_loop
  lda opcode_bytes
  cmp opcodes_grp2,x
  beq mdiss_grp2_found
  lda #&FF
  cmp opcodes_grp2,x
  beq mdiss_grp2_done
  inx
  jmp mdiss_grp2_loop
.mdiss_grp2_done
  sec
  rts

; Now find the string using the mask
; A contains the instruction

.mdiss_grp2_found
  pha
  and #&E3
  ldx #0
.mdiss_grp2_found_loop
  cmp opcodes_grp2_mask,x
  beq mdiss_grp2_mask_found
  inx
  inx
  inx
  inx
  jmp mdiss_grp2_found_loop

; Found the mask, the mnemonic starts in the next byte

.mdiss_grp2_mask_found
  inx
  txa
  txa
  clc
  adc #<opcodes_grp2_mask
  sta opcode_str_low
  lda #0
  adc #>opcodes_grp2_mask
  sta opcode_str_high

; Turn addressing mode in to an offset

  pla
  and #&1C
  lsr a
  pha
  tax

; Get address of the mode handler and the size of the opcode

  lda opcodes_grp2_addr_sub,x
  sta opcode_addr_sub_low
  lda opcodes_grp2_addr_sub + 1,x
  sta opcode_addr_sub_high
  pla
  lsr a
  tax
  lda opcodes_grp2_size,x
  sta opcode_size
  lda opcodes_grp2_pad,x
  sta opcode_pad
  rts


.opcodes_grp2
; ASL
  EQUB &0A
  EQUB &06
  EQUB &16
  EQUB &0E
  EQUB &1E
; LSR
  EQUB &4A
  EQUB &46
  EQUB &56
  EQUB &4E
  EQUB &5E
; ROL
  EQUB &2A
  EQUB &26
  EQUB &36
  EQUB &2E
  EQUB &3E
; ROR
  EQUB &6A
  EQUB &66
  EQUB &76
  EQUB &6E
  EQUB &7E
; DEC
  EQUB &C6
  EQUB &D6
  EQUB &CE
  EQUB &DE
; INC
  EQUB &E6
  EQUB &F6
  EQUB &EE
  EQUB &FE
; LDX
  EQUB &A2
  EQUB &A6
  EQUB &B6
  EQUB &AE
  EQUB &BE
; LDY
  EQUB &A0
  EQUB &A4
  EQUB &B4
  EQUB &AC
  EQUB &BC
; CPX
  EQUB &E0
  EQUB &E4
  EQUB &EC
; CPY
  EQUB &C0
  EQUB &C4
  EQUB &CC
; STX
  EQUB &86
  EQUB &96
  EQUB &8E
; STY
  EQUB &84
  EQUB &94
  EQUB &8C
; BIT
  EQUB &24
  EQUB &2C
; BCC
  EQUB &90

  EQUB &FF ; END

.opcodes_grp2_mask
  EQUB &02 ; ASL
  EQUS "ASL"
  EQUB &42 ; LSR
  EQUS "LSR"
  EQUB &22 ; ROL
  EQUS "ROL"
  EQUB &62 ; ROR
  EQUS "ROR"
  EQUB &C2 ; DEC
  EQUS "DEC"
  EQUB &E2 ; INC
  EQUS "INC"
  EQUB &A2 ; LDX
  EQUS "LDX"
  EQUB &A0 ; LDY
  EQUS "LDY"
  EQUB &E0 ; CPX
  EQUS "CPX"
  EQUB &C0 ; CPY
  EQUS "CPY"
  EQUB &82 ; STX
  EQUS "STX"
  EQUB &80 ; STY
  EQUS "STY"
  EQUB &20 ; BIT
  EQUS "BIT"
  EQUB &FF ; END

.opcodes_grp2_addr_sub
  EQUW mdiss_val
  EQUW mdiss_zpg
  EQUW mdiss_acc
  EQUW mdiss_abs
  EQUW mdiss_bra
  EQUW mdiss_zpgX
  EQUW mdiss_imm
  EQUW mdiss_absX

.opcodes_grp2_size
  EQUB 2
  EQUB 2
  EQUB 1
  EQUB 3
  EQUB 2
  EQUB 2
  EQUB 2
  EQUB 3

.opcodes_grp2_pad
  EQUB 6
  EQUB 7
  EQUB 9
  EQUB 5
  EQUB 5
  EQUB 5
  EQUB 3

; TODO LDX and STX use zpgY instead of zpgX

.mdiss_val
  lda #'#'
  jsr OSWRCH ; Drop through

.mdiss_zpg
  lda #'&'
  jsr OSWRCH
  lda opcode_bytes + 1
  jmp print_hex

.mdiss_abs
  lda #'&'
  jsr OSWRCH
  lda opcode_bytes + 2
  jsr print_hex
  lda opcode_bytes + 1
  jmp print_hex

.mdiss_acc
  lda #'A'
  jmp OSWRCH

.mdiss_imm
  rts

.mdiss_Xind
  lda #'('
  jsr OSWRCH
  jsr mdiss_zpg
  lda #','
  jsr OSWRCH
  lda #'X'
  jsr OSWRCH
  lda #')'
  jmp OSWRCH

.mdiss_indY
  lda #'('
  jsr OSWRCH
  jsr mdiss_zpg
  lda #')'
  jsr OSWRCH
  lda #','
  jsr OSWRCH
  lda #'Y'
  jmp OSWRCH

.mdiss_zpgX
  jsr mdiss_zpg
  lda #','
  jsr OSWRCH
  lda #'X'
  jmp OSWRCH

.mdiss_absY
  jsr mdiss_abs
  lda #','
  jsr OSWRCH
  lda #'Y'
  jmp OSWRCH

.mdiss_absX
  jsr mdiss_abs
  lda #','
  jsr OSWRCH
  lda #'X'
  jmp OSWRCH

; Branch is relative to the PC. The address of the next
; instruction will be in p0_rom_ptr_low and p0_rom_ptr_high.
; Twos complement is used for backwards jumps so just
; add them but with &FF as the upper byte and let the value
; wrap

.mdiss_bra
  lda opcode_bytes + 1
  bpl mdiss_bra_forward
  clc
  adc p0_rom_ptr_low
  sta opcode_bytes + 1
  lda #&FF
  jmp mdiss_bra_out
.mdiss_bra_forward
  clc
  adc p0_rom_ptr_low
  sta opcode_bytes + 1
  lda #0
.mdiss_bra_out
  adc p0_rom_ptr_high
  sta opcode_bytes + 2
  jmp mdiss_abs

.mdiss_jmpind
  lda #'('
  jsr OSWRCH
  jsr mdiss_abs
  lda #')'
  jmp OSWRCH

; Call the address handler

.mdiss_addr_handler
  jmp (opcode_addr_sub_low)
  rts

; Prints the 3 character mnenomic as found during the opcode
; search

.mdiss_prt_mnenomic
  ldy #0
.mdiss_prt_mnenomic_lp
  lda (opcode_str_low),y
  jsr OSWRCH
  iny
  cpy #3
  bcc mdiss_prt_mnenomic_lp
  rts

; Print a line of assembler on the screen, comprising the address,
; the opcode values, the mnenomic, the addressing data, and the
; opcode values as characters.

.mdiss_prt_line
  jsr print_address
  jsr print_space

; Get the instruction byte, save it and print it

  ldy rom_num
  jsr get_byte
  sta opcode_bytes
  jsr print_hex

; Test for &FF (used as end of table marker) explicitly as a short
; cut.

  cmp #&FF
  beq mdiss_prt_unknown

; Try and find the instruction and its meta data

  jsr mdiss_imm_check
  bcc mdiss_prt_line_found
  jsr mdiss_bra_check
  bcc mdiss_prt_line_found
  jsr mdiss_jump_check
  bcc mdiss_prt_line_found
  jsr mdiss_grp1_check
  bcc mdiss_prt_line_found
  jsr mdiss_grp2_check
  bcc mdiss_prt_line_found

; Not found so just display the byte

.mdiss_prt_unknown
  ldx #8
  jsr print_x_spaces
  lda #'?'
  jsr OSWRCH
  jsr OSWRCH
  jsr OSWRCH
  ldx #11
  jsr print_x_spaces
  lda opcode_bytes
  jsr print_byte_as_char
  jmp OSNEWL

; Found it so print the instruction

.mdiss_prt_line_found
  ldx #1

; Get any additional bytes

.mdiss_prt_line_byte_lp
  cpx opcode_size
  bcs mdiss_prt_line_next
  jsr print_space
  ldy rom_num
  jsr get_byte
  sta opcode_bytes,x
  jsr print_hex
  inx
  jmp mdiss_prt_line_byte_lp

; Pad out

.mdiss_prt_line_next
  cpx #3
  beq mdiss_prt_line_next_2
  lda #' '
  jsr OSWRCH
  jsr OSWRCH
  jsr OSWRCH
  inx
  jmp mdiss_prt_line_next

; Print space then mnenomic

.mdiss_prt_line_next_2
  jsr print_space
  jsr print_space

; Print the mnenomic and the addressing mode

  jsr mdiss_prt_mnenomic
  jsr print_space
  jsr mdiss_addr_handler

; Print the padding before the bytes as chars

  ldx opcode_pad
  jsr print_x_spaces

; Print the bytes as chars

  ldy opcode_size
  ldx #0
.mdiss_prt_line_char_lp
  lda opcode_bytes,x
  jsr print_byte_as_char
  inx
  dey
  bne mdiss_prt_line_char_lp
  jmp OSNEWL

; DO the mdiss command. This takes an address. It will either print
; 8 bytes of data or, if a count or end address is specified, that
; number of bytes. A rom number may be specified using single hex
; digit, ie. 0-9, A-F.
;
; *MDISS ADDR [+COUNT|END_ADDR] [ROM]
;
; Command address:
;    (p0_cmd),y
;
; Errors:
;    Illegal Value - If bad hex
;    Bad Command - If not correctly formed command

.mdiss
  jsr get_parameters

; Ironically convert count back to end address
  clc
  lda value_low
  adc p0_rom_ptr_low
  sta value_low
  lda value_high
  adc p0_rom_ptr_high
  sta value_high

.mdiss_loop
  jsr mdiss_prt_line

  lda p0_escape_flag   ; ESCAPE processing
  BPL mdiss_no_escape

  lda #ob_clear_vdu_q
  jsr OSBYTE
  lda #ob_esc_eff_clear
  jsr OSBYTE
  jsr OSNEWL
  jmp done

.mdiss_no_escape
  lda p0_rom_ptr_high
  cmp value_high
  bcc mdiss_loop
  lda p0_rom_ptr_low
  cmp value_low
  bcc mdiss_loop
  jmp done
