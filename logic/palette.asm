    include    "common.asm"

;--------------------------------
;
; Init Palette Fade
;
; a0 new palette
; a2 current palette
;
;--------------------------------

FadeInit:
    move.w     d0,PaletteColorCount(a5)
    lea        MainPalette(a5),a2
    move.l     a2,PalettePointer(a5)
              
    lea        WorkPalette(a5),a1

    move.w     d0,d7
    subq.w     #1,d7
.copy
    move.w     (a0)+,(a1)+
    dbra       d7,.copy

    move.w     #-1,PaletteStatus(a5)
    move.w     #2,PaletteDirty(a5)
    rts



;--------------------------------
;
; Just load the palette straight in
;
; a0 new palette
;
;--------------------------------


LoadPalette:  
    move.w     d0,PaletteColorCount(a5)
    lea        MainPalette(a5),a1
    move.w     d0,d7
    subq.w     #1,d7
.copy
    move.w     (a0)+,(a1)+
    dbra       d7,.copy

    move.w     #-1,PaletteStatus(a5)
    move.w     #2,PaletteDirty(a5)
    rts


;--------------------------------
;
; Just load the palette straight in
;
; a0 copper pointer
;
;--------------------------------

PaletteToCopper:
    lea        MainPalette(a5),a1
    move.w     PaletteColorCount(a5),d7
    subq.w     #1,d7
.loop
    move.w     (a1)+,2(a0)
    addq.l     #4,a0
    dbra       d7,.loop    
    rts

;--------------------------------
;
; Init Palette Fade
;
; a0 new palette
;
;--------------------------------

FadeLogic: 
    tst.w      PaletteStatus(a5)
    beq        .fadedone

    move.w     PaletteColorCount(a5),d7    ; total colors
    subq.w     #1,d7
 
    move.w     #2,PaletteDirty(a5)
    sub.l      a4,a4                       ; flag if change occured
    move.l     PalettePointer(a5),a0       ; current
    lea        WorkPalette(a5),a1          ; destination
.nextcolor
    moveq      #0,d5                       ; resulting color value

    moveq      #3-1,d6                     ; loop components

    move.w     (a0),d0                     ; current
    move.w     (a1)+,d1                    ; required
.nextcomp
    move.w     d0,d2                       ; copy RGB
    move.w     d1,d3

    and.w      #$f,d2                      ; mask to component
    and.w      #$f,d3

    moveq      #1,d4                       ; add
    cmp.b      d3,d2
    beq        .nochange
    addq.l     #1,a4                       ; flag a change occured
    bcs        .moveval
    neg        d4                          ; flip value
.moveval
    add.b      d4,d2                       ; add / subtract
.nochange
    move.b     d2,d5                       ; store this component
    ror.l      #4,d5                       ; shift it to the top half of register

    lsr.w      #4,d0                       ; shift components down
    lsr.w      #4,d1

    dbra       d6,.nextcomp                ; next component

    swap       d5                          ; swap the resulting color
    lsr.w      #4,d5                       ; shift into correct place

    move.w     d5,(a0)+                    ; store in palette

    dbra       d7,.nextcolor

    move.l     a4,d0
    tst.w      d0
    bne        .fadedone

    clr.w      PaletteStatus(a5)
.fadedone
    rts


