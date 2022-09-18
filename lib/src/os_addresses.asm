
; OS routines
OSWRSC            = &FFB6
OSRDRM            = &FFB9
OSRDSC            = &FFB9
OSEVEN            = &FFBF
OSARGS            = &FFDA
OSRDCH            = &FFE0
OSASCI            = &FFE3
OSNEWL            = &FFE7
OSWRCH            = &FFEE
OSWORD            = &FFF1
OSBYTE            = &FFF4
OSCLI             = &FFF7

; Stack
stack_start       = &0100

; OS vectors
BRKV              = &0202
FILEV             = &0212
INSV              = &022a
REMV              = &022c
CNPV              = &022e

; OS workspace
uart_evt_flg      = &02c6
adc_conv_last     = &02f7
adc_conv_lsb      = &02f8
adc_conv_msb      = &02fc

; Event numbers
evt_adc_conv    = 3
evt_uart_err    = 7

; File system numbers
fs_number_none  = 0
fs_number_rom   = 3

; OSARGS operations (Value for A)
oa_get_fs_number   = 0
