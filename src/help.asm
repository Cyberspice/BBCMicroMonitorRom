
; Print help
;
; This prints help about this ROM on the screen. It skips
; any white space and if it is the end of the line it prints
; the brief help, otherwise it checks the commands on the
; line and displays the appropriate help if they match.
;
; Command address:
;    (cmdline),Y
; Returns:
;    Y - Unchanged

.help
  tya
  pha

; Test if there's a help word

  lda (p0_cmd_low),y
  cmp #13
  bne help_word

; No word, print the help summary

  ldx #0
.help_summ_loop
  lda help_str,x
  beq help_return
  jsr OSASCI
  inx
  bne help_summ_loop   ; Save a byte (as x is never 0) and stop infinite looping

; Return from service call with registers intact

.help_return
  pla
  tya
  jmp return

; Check the help word

.help_word
  ldx #0

; Loop through the characters in the help word
; up to the CR or space or dot

.help_word_loop
  lda (p0_cmd_low),y
  cmp #13               ; End of line?
  bne help_word_next
  cmp help_command,x
  beq help_print
  jmp help_return

; Not a CR (ends help word on command line)

.help_word_next
  cmp #' '              ; Space (end of word)
  bne help_word_next_2
  lda #13
  cmp help_command,x
  beq help_print
  jmp help_return

; Not a space (ends help word on command line)

.help_word_next_2
  cmp #'.'              ; Dot character abbreviation?
  beq help_print
  and #&DF              ; To upper case
  cmp help_command,x
  bne help_return       ; Not this word
  iny
  inx
  jmp help_word_loop    ; Check next char

; This word so print the help

.help_print
  ldx #0
.help_print_loop
  lda help_monitor,x
  beq help_done
  jsr OSASCI
  inx
  bne help_print_loop   ; Save a byte (as x is never 0) and stop infinite looping

; Help done

.help_done
  pla
  jmp return

.help_str
	EQUB 13
	EQUS "Monitor 1.00"
	EQUB 13
	EQUS "  MON"
	EQUB 13
	EQUB 0

.help_monitor
	EQUB 13
	EQUS "Monitor commands"
  EQUB 13
  EQUS "  MDISS <mem start> <mem end>"
	EQUB 13
	EQUS "  MDUMP <mem start> <mem end>"
  EQUB 13
  EQUS "  MGO   <addr>"
  EQUB 13
  EQUS "  MSET  <mem start> <byte> (<byte>)..."
	EQUB 13
	EQUS "End addresses may be replaced by +<length>"
	EQUB 13
	EQUB 0

.help_command
  EQUS "MON"
  EQUB 13
