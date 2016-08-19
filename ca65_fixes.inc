; Version 2
; DB -> DFB

; ca65
.feature c_comments
.linecont +
.feature labels_without_colons
.feature leading_dot_in_identifiers
.PC02 ; 65C02

; Fix ca65's crappy out-of-the-box support for old assembler directives -- which are completely missing!

; Force APPLE 'text' to have high bit on
; Will display as NORMAL characters
.macro ASC text
    .repeat .strlen(text), I
        .byte   .strat(text, I) | $80
    .endrep
.endmacro


; Define Double Byte -- Big Endian, high-byte first, low-byte second
.macro DDB words
.endmacro


; Define Byte
.macro DFB byte1,byte2,byte3,byte4,byte5,byte6,byte7,byte8,byte9,byte10
    .ifnblank byte1
        .byte byte1
    .endif
    .ifnblank byte2
        .byte byte2
    .endif
    .ifnblank byte3
        .byte byte3
    .endif
    .ifnblank byte4
        .byte byte4
    .endif
    .ifnblank byte5
        .byte byte5
    .endif
    .ifnblank byte6
        .byte byte6
    .endif
    .ifnblank byte7
        .byte byte7
    .endif
    .ifnblank byte8
        .byte byte8
    .endif
    .ifnblank byte9
        .byte byte9
    .endif
    .ifnblank byte10
        .byte byte10
    .endif
.endmacro


.macro DW words
    .word words
.endmacro


; DS 1
; DS 30, $A0
.macro DS length, fillval
    .ifblank fillval
        .res length
    .else
        .res length, fillval
    .endif
.endmacro


; MAIN EQU *
.define	equ	=
.define EQU =


; ORG *+256
;
; DATA EQU *
;   ORG DATA+256
.macro ORG address
    ; work around that 
    ;   .res address-*
    ; doesn't work due to bogus "Error: Constant expression expected"
    .local _pc_
_pc_:
.if .const(_pc_)
    .out .sprintf( "Current * = %04X, Reserving $%04X Bytes, New * = $%04X", _pc_, (address-_pc_), address )
    .res (address - _pc_),$EA
.else
    .org address
.endif
.endmacro

