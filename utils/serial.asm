; -------------------------------------------------
;
; 9600 baud serial output for debugging
;
; -------------------------------------------------




; -------------------------------------------------
; send line feed
; -------------------------------------------------

SpitLf:
    move.w     #368,$dff032     
.wait
    move.w     $dff018,d0
    and.w      #1<<12,d0
    beq        .wait
    move.w     #$010a,$dff030           ; Set stopbit
    rts

; -------------------------------------------------
; send hex number as ascii
; d1 = data
; -------------------------------------------------

SpitHex:    
    PUSHALL
    moveq      #8-1,d2
    move.w     #368,$dff032             ; set baud 9600
.next
.wait
    move.w     $dff018,d0               ; wait
    and.w      #1<<12,d0
    beq        .wait

    rol.l      #4,d1
    moveq      #0,d0
    move.b     d1,d0
    and.b      #$f,d0
    add.b      #$30,d0
    cmp.b      #$3a,d0
    bcs        .digit
    add.b      #7,d0
.digit
    or.w       #%0000000100000000,d0    ; Set stopbit
    move.w     d0,$dff030               ; Put data in serial output buffer
    dbra       d2,.next
    POPALL
    rts

; -------------------------------------------------
; send chars long word
; d1 = data
; -------------------------------------------------

SpitChar:    
    moveq      #4-1,d2
    move.w     #368,$dff032             ; set baud 9600
.next
.wait
    move.w     $dff018,d0               ; wait
    and.w      #1<<12,d0
    beq        .wait

    rol.l      #8,d1
    moveq      #0,d0
    move.b     d1,d0
    or.w       #%0000000100000000,d0    ; Set stopbit
    move.w     d0,$dff030               ; Put data in serial output buffer
    dbra       d2,.next
    rts
