;=========================================
; MSET
;
; Command to set bytes in memory
;=========================================

; The monitor language command entry point

; When running as a language, you can enter bytes
; one at a time using a UI which displays the current
; memory location, the existing value, and a place
; to enter the byte. ESC ends input. To enter this
; mode just supply the starting address with no other
; arguments. If you specify arguments then the regular
; * command mode is used (see below)

.mset_lang
  jsr read_address
  cmp #13
  bne mset_read_data
.mset_lang_loop

; Print the current address and current byte

  jsr print_address
  jsr print_space
  ldy #0
  lda (p0_rom_ptr_low),y
  jsr print_hex           ; Current byte value
  jsr print_space

; Read a byte

  jsr byte_input
  bcs mset_lang_err       ; Read error
  jsr OSNEWL

; Parse the input

  lda #<COMMAND_BUF
  sta p0_cmd_ptr_low
  lda #>COMMAND_BUF
  sta p0_cmd_ptr_high
  jsr read_hex_8bit       ; Read the data
  bcc mset_lang_data_good
  jmp err_illegal_value   ; Should never be called as validated on input

; Save the parsed value

.mset_lang_data_good
  ldy #0
  lda value_low
  sta (p0_rom_ptr_low),y  ; Store byte
  inc p0_rom_ptr_low      ; Increment address
  bne mset_lang_next
  inc p0_rom_ptr_high     ; Increment address high if page boundary
.mset_lang_next
  jmp mset_lang_loop      ; Next bytes

.mset_lang_err
  cmp #27
  lda #ob_clear_vdu_q
  jsr OSBYTE
  lda #ob_esc_eff_clear
  jsr OSBYTE
.mset_lang_done
  jsr OSNEWL
  jmp done

; The * command entry point

; The mset command takes an address and one or more byte values.
; It sets the address to the value of the first byte, the next
; address to the value of the next byte, and so on. It then
; displays the memory updated in MDUMP format.

.mset
  jsr read_address
  cmp #13
  bne mset_read_data
  jmp err_bad_command

; Parse the data twice, once for syntax checking

.mset_read_data
  tya
  pha                     ; Save Y to rewind later

.mset_read_data_loop
  jsr read_hex_8bit       ; Read the data
  bcc mset_read_data_good ; Carry clear means valid hex
  jmp err_illegal_value

.mset_read_data_good
  jsr space_check
  cmp #13
  bne mset_read_data_loop

.mset_read_data_done
  pla
  tay                     ; Restore Y

  lda #0                  ; Set the count to zero
  sta line_count

.mset_set_data_loop
  jsr read_hex_8bit       ; Read the data
  tya                     ; Save the position in the command line
  pha
  ldy line_count          ; Get the position in memory
  lda value_low           ; The value
  sta (p0_rom_ptr_low),y  ; Store it
  pla
  tay                     ; Restore position in command line
  inc line_count          ; Next position in memory
  jsr space_check         ; Next value
  cmp #13
  bne mset_set_data_loop

; Print the data set

  lda line_count
  sta value_low
  lda #0
  sta value_high
  jmp mdump_prt_all

; Reads a nybble from the input, displaying it Valid characters
; are 0-9 and A-F, CR and DEL. Carry is set on error and clear
; otherwise. Sounds a bell for an invalid character. A contains
; the character read.

.byte_char_input
  jsr OSRDCH
  bcs byte_char_input_err
  cmp #127
  beq byte_valid_char
  cmp #'0'
  bcc byte_invalid_char
  cmp #('9' + 1)
  bcc byte_valid_char
  cmp #'A'
  bcc byte_invalid_char
  cmp #('F' + 1)
  bcc byte_valid_char
.byte_invalid_char
  lda #7
  jsr OSWRCH
  jmp byte_char_input
.byte_valid_char
  clc
.byte_char_input_err
  rts

; Read a byte from the input. CR terminates input as does entering
; two valid characters. DEL deletes. Carry is set on error and
; clear otherwise. The characters are stored in the input buffer.
; A contains the last character read, X contains the number of
; characters read.

.byte_input
  ldx #0                   ; Number of characters in the buffer
.byte_input_loop
  jsr byte_char_input      ; Read a valid char
  bcs byte_input_err       ; Error (eg escape)
  cmp #127                 ; Backspace/Delete
  bne byte_input_next      ; Valid char
  cpx #0                   ; If not at the start of the line...
  bne byte_input_del       ; ...delete the character
  jmp byte_input_loop      ; Next char
.byte_input_next
  jsr OSWRCH               ; Print it
  sta COMMAND_BUF,x        ; Save it
  inx
  cpx #2                   ; Got two chars?
  bcc byte_input_loop
.byte_input_loop2
  jsr OSRDCH               ; Read another (may want to delete last one)
  bcs byte_input_err       ; Error (eg escape)
  cmp #13                  ; CR so we're done
  beq byte_input_valid
  cmp #127                 ; DEL so delete
  beq byte_input_del
  lda #7                   ; Anything else, just BEL
  jsr OSWRCH
  jmp byte_input_loop2
.byte_input_valid
  sta COMMAND_BUF,x        ; Save the char (CR)
  clc
.byte_input_err
  rts
.byte_input_del
  jsr OSWRCH               ; Output DEL char
  dex                      ; One less char
  jmp byte_input_loop
