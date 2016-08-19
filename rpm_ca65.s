; ASC
; DFB
.include "ca65_fixes.inc"

ZERO_LEAD   EQU $00

KEY_CR      EQU $8D
KEY_ESC     EQU $9B
KEY_0       EQU $B0 ; '0' = $30
KEY_9       EQU $B9 ; '9' = $39

pDigits     EQU $FA
Carry       EQU $FC
Div         EQU $FD

KEYBOARD    EQU $C000
KEYSTROBE   EQU $C010

TEXT        EQU $FB2F ; Init text mode and window
HOME        EQU $FC58
RDKEY       EQU $FD0C
COUT        EQU $FDED

__main = $2000

; Header for DOS 3.3 binary file; remove 2 lines for ProDOS
        DW __main
        DW __end - __main

; main()
        ORG __main

        LDA #7          ; Version
        JSR TEXT        ; Just in case we are in graphics mode
        JSR HOME
        JSR InitABS     ; Init A,B,S
        JSR IntroH
        JSR InputA      ; Input
        JSR InputB
        JSR IntroS

MulDigit                ; Calc
        JSR IsZeroB
        BCS OutS

        JSR IsOddB
        BCC EvenS
        JSR AddAToS
EvenS
        JSR ShlA
        JSR ShrB
        CLC
        BCC MulDigit    ; ^ (always)
OutS
        JSR PrintS      ; output
        ;RTS             ; NOTE: DOS3.3 BRUN bug doesn't exit, should JMP $3D0
        JMP $0000

InputA
        JSR IntroA
        JSR GetPtrA
        BNE GetString
InputB
        JSR IntroB
        JSR GetPtrB
                        ; intentional fall int GetString
GetString               ; common entry point
        STX pDigits
        STY pDigits+1

        LDX #0          ; digits length
_linechar
        JSR GetDigit    ; C=1 enter, C=0 digit
        BCS _linedone
        JSR COUT        ; preserves A,Y
        AND #$F         ; C=0 digit
        STA Buffer,X
        INX
        BPL _linechar   ; or BNE for 255 digits
        BMI IntroE      ; error if > 127 digits
_linedone               ; Now move digits from $200 -> DigitsA, DigitsB, etc.

        LDY #0          ; X = src, Y = dst offset
        CPX #0          ; any digits?
        BEQ _movedone   ; No digits!
_moveline
        DEX
        LDA Buffer,X
        STA (pDigits),Y ; digit[y] = char & 0xF
        INY
       CPX #0
        BNE _moveline   ; ^ max 256 digits
_movedone
        BEQ PrintCR     ; v (always)

GetDigit
;        LDA KEYBOARD
;        BPL GetDigit
;        STA KEYSTROBE
        JSR RDKEY
        CMP #KEY_CR
        BEQ _eol
        CMP #KEY_ESC
        BEQ _esc
        CMP #KEY_0
        BCC GetDigit
        CMP #KEY_9+1
        BCS GetDigit
        RTS
_eol    SEC             ; C=1 enter
        RTS
_esc                    ; Unwind stack of InputA/B
        PLA
        PLA
        RTS             ; Return to who originally called main()

GetPtrA
        LDX #<DigitsA   ; lo byte
        LDY #>DigitsA   ; hi byte
        RTS
GetPtrB
        LDX #<DigitsB
        LDY #>DigitsB
        RTS
GetPtrS
        LDX #<DigitsS
        LDY #>DigitsS
        RTS

InitABS
        LDA #$00
        TAX
_zero
        STA DigitsA,X
        STA DigitsB,X
        STA DigitsS,X
        INX
        BNE _zero       ; zero digits[0..$FF]
        RTS


IntroA  LDY #OffsetA
        BNE _intro
IntroB  LDY #OffsetB
        BNE _intro
IntroS  LDY #OffsetS
        BNE _intro
IntroE  LDY #OffsetE
        BNE _intro
IntroH
        LDY #OffsetH
_intro
        LDA _text,Y
        BEQ _outro      ; asciiz
        JSR COUT
        INY
        BNE _intro
_outro
        RTS
PrintCR
        LDA #KEY_CR
        JMP COUT

; ________________________________________________________________________
; Pseudo BCD - one byte per digit
; ________________________________________________________________________

; ========================================
PrintA
        JSR GetPtrA
        BNE _print
PrintB
        JSR GetPtrB
        BNE _print
PrintS
        JSR GetPtrS
_print
        STX _bcd+1
        STY _bcd+2
        LDX #ZERO_LEAD  ; Default to leading zero ($0)
        LDY #$FF        ; start at digits[255]
_bcd
        LDA $FFFF,Y     ; NOTE: Self-Modified by _print
        BNE _digit      ; digits[i] == 0 && leadingzero
        CPX #ZERO_LEAD  ; X != 0
        BEQ _skip
_digit
        CLC
        ADC #KEY_0      ; 0 -> $B0 .. 9 -> $B9
        TAX             ; If digit printed stop checking for leading zero
        JSR COUT
_skip
        DEY             ;
        CPY #$FF        ; digits[255] ?
        BNE _bcd        ; ^

; Bug fix: If no digits were printed then number must be zero
        LDA #0          ; print '0'
        TAY             ; no length
        CPX #ZERO_LEAD
        BEQ _digit
        BNE PrintCR     ; ^ (always) move to next line when done

; ========================================
AddAToS
        LDY #0
        CLC
_add
        LDA DigitsS,Y
        ADC DigitsA,Y
        CMP #$A         ; Base=10, C = (a+s+carry) >= 10
        BCC _overflow
        SBC #$A         ; C=1, A = A - 9 - C
_overflow
        STA DigitsS,Y
        INY
        BNE _add
        RTS

; ========================================
IsOddB
        LDY #0
        LDA DigitsB,Y
        AND #1
        BEQ _not_zero   ; Even -> C=0
        BNE _is_zero    ; Odd  _> C=1

; ========================================
IsZeroB
        LDY #0
_is_0
        LDA DigitsB,Y
        BNE _not_zero
        INY
        BNE _is_0
_is_zero
        SEC
        RTS
_not_zero
        CLC
        RTS

; ========================================
ShlA
        LDY #0
        CLC
_shl
        LDA DigitsA,Y
        TAX
        LDA Mul2Digit,X
        ADC #0
        STA DigitsA,Y
        LDA Mul2Carry,X
        ROR
        INY
        BNE _shl
        RTS

; ========================================
ShrB
        LDY #$FF        ; start at digits[255]
        LDX #0          ; digits processed
        STX Carry       ; $00 .. 9*2 = $18
_shr
        CLC             ;
        LDA DigitsB,Y   ; sum      = digit[i] + carry
        ADC Carry       ;         A=0000_00xy  C=0/1
        ROR             ;         A=c000_000x, C=y
        AND #$F         ;         A=0000_000x
        STA DigitsB,Y   ; digit[i] = (sum / 2)
        LDA #0          ;
        BCC _shr_next   ;         C=0 -> Carry = 0
        LDA #10         ;         C=1 -> Carry = 10 (base)
_shr_next
        STA Carry       ; carry    = (sum & 1) ? BASE : 0
        DEY
        INX             ; we need to compare y=$FF without disturbing carry
        BNE _shr        ; max 256 digits -- solution, use X reg :-)
        RTS

Mul2Digit       ;         Digit
        DFB 0   ; 0*2 = 0 0
        DFB 2   ; 1*2 = 0 2
        DFB 4   ; 2*2 = 0 4
        DFB 6   ; 3*2 = 0 6
        DFB 8   ; 4*2 = 0 8
        DFB 0   ; 5*2 = 1 0
        DFB 2   ; 6*2 = 1 2
        DFB 4   ; 7*2 = 1 4
        DFB 6   ; 8*2 = 1 6
        DFB 8   ; 9*2 = 1 8
Mul2Carry       ;       Carry
        DFB 0   ; 0*2 = 0 0
        DFB 0   ; 1*2 = 0 2
        DFB 0   ; 2*2 = 0 4
        DFB 0   ; 3*2 = 0 6
        DFB 0   ; 4*2 = 0 8
        DFB 1   ; 5*2 = 1 0
        DFB 1   ; 6*2 = 1 2
        DFB 1   ; 7*2 = 1 4
        DFB 1   ; 8*2 = 1 6
        DFB 1   ; 9*2 = 1 8

_text
TextH   ; Header
        ASC "RUSSIAN PEASANT MULTIPLICATION"
        DFB KEY_CR
        DFB KEY_CR
        DFB 0
TextA
        ASC "INPUT A"
        DFB KEY_CR
        ASC "?"
        DFB 0
TextB
        ASC "INPUT B"
        DFB KEY_CR
        ASC "?"
        DFB 0
TextE
        DFB KEY_CR
        ASC "WARNING"
        ASC ": MORE THAN 127 CHARS"
        DFB KEY_CR
        DFB 0
TextS
        ASC "= "
        DFB 0

OffsetH EQU TextH - _text
OffsetA EQU TextA - _text
OffsetB EQU TextB - _text
OffsetE EQU TextE - _text
OffsetS EQU TextS - _text

__end

; Pad until end of page, these globals are not stored on disk
pad     EQU 256 - <*
page    EQU *+pad

DigitsA EQU page        ; stupid assembler can't use variable 'a'
DigitsB EQU page+256
DigitsS EQU page+512
Buffer  EQU page+768

