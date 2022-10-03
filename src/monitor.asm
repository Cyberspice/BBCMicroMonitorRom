;===========================================
; Monitor
;
; The main monitor ROM file
;===========================================

_ELECTRON_=FALSE

; Include common defines

INCLUDE "../lib/src/hw_addresses.asm"
INCLUDE "../lib/src/os_addresses.asm"
INCLUDE "../lib/src/osbytes_ops.asm"
INCLUDE "../lib/src/page0_addresses.asm"

; Workspace

line_count = &a8
rom_num    = &a9
value_low  = &aa
value_high = &ab
byte_count_low = &ac
byte_count_high = &ad
opcode_str_low = &ae
opcode_str_high = &af

ORG &8000

; Start of ROM

.start
	jmp lang
	jmp service

	EQUB &c2
	EQUB (copystr - start)
.version
	EQUB 0
.titlestr
	EQUS "Monitor"
	EQUB 0
	EQUS "1.00"
.copystr
	EQUB 0
	EQUS "(C) 2022 Cyberspice"
	EQUB 0

; Utilities

INCLUDE "errors.asm"
INCLUDE "common.asm"

; Language entry

INCLUDE "lang.asm"

; Service entry

INCLUDE "service.asm"

; Library routines

INCLUDE "../lib/src/print_hex.asm"

cmd_ptr = p0_cmd_ptr_low ; For read hex

INCLUDE "../lib/src/char_to_hex.asm"
INCLUDE "../lib/src/read_hex_8bit.asm"
INCLUDE "../lib/src/read_hex_16bit.asm"

; Commands

INCLUDE "mdump.asm"
INCLUDE "mgo.asm"
INCLUDE "mon.asm"
INCLUDE "mregs.asm"
INCLUDE "mset.asm"
INCLUDE "mdiss.asm"

; Star help and star command handling

INCLUDE "help.asm"
INCLUDE "command.asm"

.end

SAVE "monrom", start, end