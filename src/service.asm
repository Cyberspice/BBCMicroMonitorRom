


.service
  php
  pha
  cmp #9
  bne service_not_help
  jmp help
.service_not_help
  cmp #4
  bne service_not_cmd
  jmp command
.service_not_cmd

; Service call is not handled

.return
	ldx &f4
	pla
	plp
	rts

; Service call has been handled.

.done
	pla
	lda #0
	plp
	rts
