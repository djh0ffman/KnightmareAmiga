;----------------------------------------------------------------------------
;
; text
;
;----------------------------------------------------------------------------

    include      "common.asm"

;----------------------------------------------------------------------------
;
; textchar plot macro
;
; \1 font address 
; \2 screen address
; \3 stride
;----------------------------------------------------------------------------

CHARPLOT MACRO
    move.b       (\1)+,\3*0(\2)
    move.b       (\1)+,\3*1(\2)
    move.b       (\1)+,\3*2(\2)
    move.b       (\1)+,\3*3(\2)
    move.b       (\1)+,\3*4(\2)
    move.b       (\1)+,\3*5(\2)
    move.b       (\1)+,\3*6(\2)
    move.b       (\1)+,\3*7(\2)
    ENDM

CHARPLOT5 MACRO
    move.b       (\1)+,\3*0(\2)
    move.b       (\1)+,\3*1(\2)
    move.b       (\1)+,\3*2(\2)
    move.b       (\1)+,\3*3(\2)
    move.b       (\1)+,\3*4(\2)

    move.b       (\1)+,\3*5(\2)
    move.b       (\1)+,\3*6(\2)
    move.b       (\1)+,\3*7(\2)
    move.b       (\1)+,\3*8(\2)
    move.b       (\1)+,\3*9(\2)

    move.b       (\1)+,\3*10(\2)
    move.b       (\1)+,\3*11(\2)
    move.b       (\1)+,\3*12(\2)
    move.b       (\1)+,\3*13(\2)
    move.b       (\1)+,\3*14(\2)

    move.b       (\1)+,\3*15(\2)
    move.b       (\1)+,\3*16(\2)
    move.b       (\1)+,\3*17(\2)
    move.b       (\1)+,\3*18(\2)
    move.b       (\1)+,\3*19(\2)

    move.b       (\1)+,\3*20(\2)
    move.b       (\1)+,\3*21(\2)
    move.b       (\1)+,\3*22(\2)
    move.b       (\1)+,\3*23(\2)
    move.b       (\1)+,\3*24(\2)

    move.b       (\1)+,\3*25(\2)
    move.b       (\1)+,\3*26(\2)
    move.b       (\1)+,\3*27(\2)
    move.b       (\1)+,\3*28(\2)
    move.b       (\1)+,\3*29(\2)

    move.b       (\1)+,\3*30(\2)
    move.b       (\1)+,\3*31(\2)
    move.b       (\1)+,\3*32(\2)
    move.b       (\1)+,\3*33(\2)
    move.b       (\1)+,\3*34(\2)

    move.b       (\1)+,\3*35(\2)
    move.b       (\1)+,\3*36(\2)
    move.b       (\1)+,\3*37(\2)
    move.b       (\1)+,\3*38(\2)
    move.b       (\1)+,\3*39(\2)

    ENDM

;----------------------------------------------------------------------------
;
; dirty hud
;
;----------------------------------------------------------------------------

DirtyHud:
    move.l       #-1,ScorePrev(a5)
    move.b       #-1,LivesPrev(a5)
    move.b       #-1,StagePrev(a5)
    move.b       #-1,ShieldPrev(a5)
    move.b       #-1,SpeedPrev(a5)
    rts

;----------------------------------------------------------------------------
;
; text plot numbers
;
;----------------------------------------------------------------------------

SCORE_POS   = 8-8
HISCORE_POS = 17-8
REST_POS    = 23
STAGE_POS   = 30


TextHudStats:
    lea          Score(a5),a0
    lea          ScorePrev(a5),a1
    moveq        #2,d4                                     ; y pos (lines)
    moveq        #2,d5                                     ; x pos (chars)
    bsr          TextStatLongHUD

    lea          Lives(a5),a0
    lea          LivesPrev(a5),a1
    moveq        #6,d4                                     ; y pos (lines)
    moveq        #12,d5                                    ; x pos (chars)
    bsr          TextStatByteHUD

    lea          Stage(a5),a0
    lea          StagePrev(a5),a1
    moveq        #7,d4                                     ; y pos (lines)
    moveq        #29,d5                                    ; x pos (chars)
    bsr          TextStatByteHUD

    moveq        #0,d0
    lea          PlayerStatus+PLAYER_Speed(a5),a0
    lea          SpeedPrev(a5),a1
    move.b       (a0),d0
    cmp.b        (a1),d0
    beq          .skipspeed
    move.b       d0,(a1)
    bsr          DrawHUDSpeed

.skipspeed
    moveq        #0,d0
    lea          PlayerStatus+PLAYER_SheildPower(a5),a0
    lea          ShieldPrev(a5),a1
    move.b       (a0),d0
    cmp.b        (a1),d0
    beq          .skipshield
    move.b       d0,(a1)
    bsr          DrawHUDShield

.skipshield
    rts

;----------------------------------------------------------------------------
;
; Stat Byte
;
; a0 = stat
; a1 = stat previous
;
;----------------------------------------------------------------------------

TextStatByte:
    moveq        #0,d0
    move.b       (a0),d0
    cmp.b        (a1),d0
    beq          .skip

    move.b       d0,(a1)
    bsr          Binary2Decimal
    lea          Hud+HUD_LINE2,a1
    sub.w        d0,d1
    add.l        d1,a1
    bra          TextPlot
.skip
    rts



;----------------------------------------------------------------------------
;
; Stat Byte
;
; a0 = stat
; a1 = stat previous
;
;----------------------------------------------------------------------------

TextStatByteHUD:
    moveq        #0,d0
    move.b       (a0),d0
    cmp.b        (a1),d0
    beq          .skip

    move.b       d0,(a1)
    
    bsr          Binary2Decimal

    moveq        #8,d2
    sub.b        d0,d2

    lea          TextStat,a1
    move.l       a1,a2
.spaceloop
    move.b       #" ",(a1)+
    subq.b       #1,d2
    bne          .spaceloop
.charloop
    move.b       (a0)+,(a1)+
    subq.b       #1,d0
    bne          .charloop

    clr.b        (a1)

    move.l       a2,a0
    addq.l       #6,a0
    bra          TextPlotHUD
.skip
    rts

;----------------------------------------------------------------------------
;
; Stat Long
;
; a0 = stat
; a1 = stat previous
;
;----------------------------------------------------------------------------

TextStatLong:
    move.l       (a0),d0
    cmp.l        (a1),d0
    beq          .skip

    move.l       d0,(a1)
    
    bsr          Binary2Decimal

    moveq        #8,d2
    sub.b        d0,d2

    lea          TextStat,a1
    move.l       a1,a2
.spaceloop
    move.b       #" ",(a1)+
    subq.b       #1,d2
    bne          .spaceloop
.charloop
    move.b       (a0)+,(a1)+
    subq.b       #1,d0
    bne          .charloop

    clr.b        (a1)

    move.l       a2,a0
    lea          Hud+HUD_LINE2,a1
    add.l        d1,a1
    bra          TextPlot
.skip
    rts


;----------------------------------------------------------------------------
;
; Stat Long
;
; a0 = stat
; a1 = stat previous
; d4 = y lines
; d5 = x chars
;
;----------------------------------------------------------------------------

TextStatLongHUD:
    move.l       (a0),d0
    cmp.l        (a1),d0
    beq          .skip

    move.l       d0,(a1)
    
    bsr          Binary2Decimal

    moveq        #8,d2
    sub.b        d0,d2

    lea          TextStat,a1
    move.l       a1,a2
.spaceloop
    move.b       #" ",(a1)+
    subq.b       #1,d2
    bne          .spaceloop
.charloop
    move.b       (a0)+,(a1)+
    subq.b       #1,d0
    bne          .charloop

    clr.b        (a1)

    move.l       a2,a0
    addq.l       #1,a0
    bra          TextPlotHUD
.skip
    rts

;----------------------------------------------------------------------------
;
; Stat Long
;
; a0 = stat
; a1 = stat previous
;
;----------------------------------------------------------------------------

TextHUDStatLong:
    move.l       (a0),d0
    cmp.l        (a1),d0
    beq          .skip

    move.l       d0,(a1)
    
    bsr          Binary2Decimal

    moveq        #8,d2
    sub.b        d0,d2

    lea          TextStat,a1
    move.l       a1,a2
.spaceloop
    move.b       #" ",(a1)+
    subq.b       #1,d2
    bne          .spaceloop
.charloop
    move.b       (a0)+,(a1)+
    subq.b       #1,d0
    bne          .charloop

    clr.b        (a1)

    move.l       a2,a0
    lea          Hud+HUD_LINE2,a1
    add.l        d1,a1
    bra          TextPlot
.skip
    rts



;----------------------------------------------------------------------------
;
; char plot
;
; d0 = y
; d1 = x
; d2 = char
;
;----------------------------------------------------------------------------

CharPlotMain:
    and.l        #$ff,d0
    and.l        #$ff,d1
    and.l        #$ff,d2
    
    lsl.w        #3,d0                                     ; y * 8
    add.w        MapScrollOffset(a5),d0
    add.w        d0,d0
    add.w        d0,d0 
    move.l       StrideLookUp(a5,d0.w),d0                  ; y screen position
    add.l        d1,d0                                     ; screen position

    move.l       ScreenBuffer(a5),a1
    add.l        d0,a1

    lea          GfxFont2,a2

    sub.b        #$20,d2                                   ; font start
    mulu         #40,d2                                    ; * 40
    lea          (a2,d2.w),a2

    CHARPLOT5    a2,a1,SCREEN_WIDTH_BYTE
    rts

;----------------------------------------------------------------------------
;
; text plot game screen
;
; a0 = text
;
;----------------------------------------------------------------------------

TextPlotMain:
    moveq        #0,d0
    moveq        #0,d1
    move.b       (a0)+,d0                                  ; y
    move.b       (a0)+,d1                                  ; x
TextPlotMain1:
    lsl.w        #3,d0                                     ; y * 8
    add.w        MapScrollOffset(a5),d0
    ;add.w        d0,d0
    ;add.w        d0,d0 
    ;move.l       StrideLookUp(a5,d0.w),d0                  ; y screen position
    mulu         #SCREEN_STRIDE,d0

    add.l        d1,d0                                     ; screen position

    move.l       ScreenBuffer(a5),a1
    add.l        d0,a1

    lea          GfxFont2,a2
.loop
    moveq        #0,d0
    move.b       (a0)+,d0
    beq          .done
    cmp.b        #-1,d0
    beq          TextPlotMain

    sub.b        #$20,d0                                   ; font start
    mulu         #40,d0                                    ; * 40

    move.l       a2,a3
    add.l        d0,a3

    CHARPLOT5    a3,a1,SCREEN_WIDTH_BYTE

    addq.l       #1,a1
    bra          .loop
.done
    rts


DrawStageText:
    moveq        #0,d0
    move.b       Stage(a5),d0
    bsr          Binary2Decimal

    lea          TextStageNum,a1
    move.b       d0,d1                                     ; store length
.loop
    move.b       (a0)+,(a1)+
    subq.b       #1,d0
    bne          .loop
    clr.b        (a1)+                                     ; just to be safe

    addq.b       #6,d1                                     ; total

    moveq        #32,d0
    sub.b        d1,d0
    lsr.b        #1,d0
    
    lea          TextStage,a0
    move.b       d0,1(a0)                                  ; x position based on string length, but why!!
    bsr          TextPlotMain

    bsr          UnpackTiles
    rts

;----------------------------------------------------------------------------
;
; text plot hud
;
; a0 = text
; a1 = screen pos
;----------------------------------------------------------------------------

TextPlot:
    lea          GfxFont,a2
.loop
    moveq        #0,d0
    move.b       (a0)+,d0
    beq          .done

    sub.b        #$20,d0                                   ; font start
    lsl.w        #3,d0                                     ; * 8
    move.l       a2,a3
    add.l        d0,a3

    CHARPLOT     a3,a1,HUD_WIDTH_BYTE
    addq.l       #1,a1
    bra          .loop

.done
    rts



;----------------------------------------------------------------------------
;
; text plot hud
;
; a0 = text
; d4 = y pos (line)
; d5 = x pos (char)
;
;----------------------------------------------------------------------------

TextPlotHUD:
    mulu         #HUD_STRIDE,d4                            ; y screen position

    add.l        d5,d4                                     ; screen position

    lea          HUD,a1
    add.l        d4,a1

    lea          GfxFont2,a2
.loop
    moveq        #0,d0
    move.b       (a0)+,d0
    beq          .done

    sub.b        #$20,d0                                   ; font start
    mulu         #40,d0                                    ; * 40

    move.l       a2,a3
    add.l        d0,a3

    CHARPLOT5    a3,a1,HUD_WIDTH_BYTE

    addq.l       #1,a1
    bra          .loop
.done
    rts


