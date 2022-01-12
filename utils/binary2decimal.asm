        ; *********************************************
        ;
        ; $VER: Binary2Decimal.s 0.2b (22.12.15)
        ;
        ; Author:       Highpuff
        ; Orginal code: Ludis Langens
        ;
        ; In:   D0.L = Hex / Binary
        ;
        ; Out:  A0.L = Ptr to null-terminated String
        ;       D0.L = String Length (Zero if null on input)
        ;
        ; *********************************************
 
 
b2dNegative equ 0                                ; 0 = Only Positive numbers
                                ; 1 = Both Positive / Negative numbers
 
        ; *********************************************
 
 
Binary2Decimal:    movem.l    d1-d5/a1,-(sp)
 
                   moveq      #0,d1              ; Clear D1/2/3/4/5
                   moveq      #0,d2
                   moveq      #0,d3
                   moveq      #0,d4
                   moveq      #0,d5
 
                   lea.l      b2dString+12,a0
                   movem.l    d1-d3,-(a0)        ; Clear String buffer
 
                   neg.l      d0                 ; D0.L ! D0.L = 0?
                   bne        .notZero           ; If NOT True, Move on...
                   move.b     #$30,(a0)          ; Put a ASCII Zero in buffer
                   moveq      #1,d0              ; Set Length to 1
                   bra        .b2dExit           ; Exit  
                 
.notZero:          neg.l      d0                 ; Restore D0.L
 
                   IF         b2dNegative        ; Is b2dNegative True?
 
                   move.l     d0,d1              ; D1.L = D0.L
                   swap       d1                 ; Swap Upper Word with Lower Word
                   rol.w      #1,d1              ; MSB  = First byte
                   btst       #0,d1              ; Negative?
                   beq        .notNegative       ; If not, jump to .notNegative
                   move.b     #$2d,(a0)+         ; Add a '-' to the String
                   neg.l      d0                 ; Make D0.L positive
.notNegative:      moveq      #0,d1              ; Clear D1 after use
 
                   ENDC
 
.lftAlign:         addx.l     d0,d0              ; D0.L = D0.L << 1
                   bcc.s      .lftAlign          ; Until CC is set (all trailing zeros are gone)
 
.b2dLoop:          abcd.b     d1,d1              ; xy00000000
                   abcd.b     d2,d2              ; 00xy000000
                   abcd.b     d3,d3              ; 0000xy0000
                   abcd.b     d4,d4              ; 000000xy00
                   abcd.b     d5,d5              ; 00000000xy
                   add.l      d0,d0              ; D0.L = D0.L << 1
                   bne.s      .b2dLoop           ; Loop until D0.L = 0
         
                ; Line up the 5x Bytes
 
                   lea.l      b2dTemp,a1         ; A1.L = b2dTemp Ptr
                   move.b     d5,(a1)            ; b2dTemp = d5.xx.xx.xx.xx
                   move.b     d4,1(a1)           ; b2dTemp = d5.d4.xx.xx.xx
                   move.b     d3,2(a1)           ; b2dTemp = d5.d4.d3.xx.xx
                   move.b     d2,3(a1)           ; b2dTemp = d5.d4.d3.d2.xx
                   move.b     d1,4(a1)           ; b2dTemp = d5.d4.d3.d2.d1
 
 
                ; Convert Nibble to Byte
                 
                   moveq      #5-1,d5            ; 5 bytes (10 Bibbles) to check
.dec2ASCII:        move.b     (a1)+,d1           ; D1.W = 00xy
                   ror.w      #4,d1              ; D1.W = y00x
                   move.b     d1,(a0)+           ; Save ASCII
                   sub.b      d1,d1              ; D1.B = 00
                   rol.w      #4,d1              ; D1.W = 000y
                   move.b     d1,(a0)+           ; Save ASCII
                   dbf        d5,.dec2ASCII      ; Loop until done...
 
                   sub.l      #10,a0             ; Point to first byte (keep "-" if it exists)
                   move.l     a0,a1
 
                ; Find where the numbers start and trim it...
 
                   moveq      #10-1,d5           ; 10 Bytes total to check
.trimZeros:        move.b     (a0),d0            ; Move byte to D0.B
                   bne.s      .trimSkip          ; Not Zero? Exit loop
                   add.l      #1,a0              ; Next Character Byte
                   dbf        d5,.trimZeros      ; Loop
.trimSkip:         move.b     (a0)+,d0           ; Move Number to D0.B
                   add.b      #$30,d0            ; Add ASCII Offset to D0.B
                   move.b     d0,(a1)+           ; Move to buffer
                   dbf        d5,.trimSkip       ; Loop
 
                ; Get string length
 
                   move.l     a1,d0              ; D0.L = EOF b2dString
                   lea.l      b2dString,a0       ; A0.L = SOF b2dString
                   sub.l      a0,d0              ; D0.L = b2dString.Length
 
.b2dExit:          movem.l    (sp)+,d1-d5/a1
                   rts
 
        ; *********************************************
 
b2dTemp:           dc.l       0,0
b2dString:         dc.l       0,0,0
                   dc.l       0,0
        ; *********************************************