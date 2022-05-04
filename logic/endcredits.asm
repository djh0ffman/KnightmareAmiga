    include      "common.asm"

;----------------------------------------------------------------------------
;
; end credits
;
;----------------------------------------------------------------------------

CreditsInit:
    move.l       #Credits,CreditsPtr(a5)
    clr.w        CreditsCounter(a5)
    clr.w        MapScrollOffset(a5)
    sf           DoubleBuffer(a5)
    move.w       #8,MapScrollOffset(a5)
    move.l       ScreenBuffer(a5),d0
    move.l       ScreenBuffer+4(a5),d1
    cmp.l        d0,d1
    bcc          .noswitch
    exg          d0,d1
.noswitch
    move.l       d0,ScreenBuffer(a5)
    move.l       d1,ScreenBuffer+4(a5)
    rts


CreditsRun:
    btst         #0,TickCounter(a5)
    beq          .exit

    bsr          CreditPlot

    addq.w       #1,MapScrollOffset(a5)

    cmp.w        #(CREDITS_ROLL+2)*8,MapScrollOffset(a5)
    bne          .exit
    move.w       #8,MapScrollOffset(a5)
.exit
    rts


CreditPlot:
    move.w       MapScrollOffset(a5),d0
    and.w        #7,d0
    bne          .exit

    bsr          TextScrollClear

    move.l       CreditsPtr(a5),a0

    cmp.b        #-1,(a0)
    beq          .wraptext

    moveq        #0,d0
    move.l       a0,a1
.next
    tst.b        (a1)+
    beq          .found
    addq.w       #1,d0
    bra          .next
.found
    ; d0 = char count
    move.w       d0,CreditsCharCount(a5)
    beq          .emptyline
    moveq        #32,d1
    sub.w        d0,d1
    lsr.w        #1,d1                                      ; start X

    moveq        #0,d0
    move.w       MapScrollOffset(a5),d0
    subq.w       #8,d0                                      ; y first line

    bsr          CreditPlotText

    moveq        #0,d0
    move.w       MapScrollOffset(a5),d0
    add.w        #CREDITS_ROLL*8,d0                         ; y second line

    bsr          CreditPlotText

    move.w       CreditsCharCount(a5),d0
    and.b        #1,d0
    beq          .emptyline
    
    bsr          TextScrollShift


.emptyline
    move.l       a1,CreditsPtr(a5)
    rts

.wraptext
    move.l       #Credits,CreditsPtr(a5)
.exit
    rts


CreditPlotText:
    PUSHMOST
    mulu         #SCREEN_STRIDE,d0

    add.l        d0,d1  

    move.l       ScreenBuffer(a5),a1
    add.l        d1,a1

    lea          GfxFont2,a2
.loop
    moveq        #0,d0
    move.b       (a0)+,d0
    beq          .done
    cmp.b        #-1,d0
    beq          TextPlotMain

    sub.b        #$20,d0                                    ; font start
    mulu         #40,d0                                     ; * 40

    move.l       a2,a3
    add.l        d0,a3

    CHARPLOT5    a3,a1,SCREEN_WIDTH_BYTE

    addq.l       #1,a1
    bra          .loop
.done
    POPMOST
    rts