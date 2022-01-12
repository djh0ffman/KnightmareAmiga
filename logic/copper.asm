;----------------------------------------------------------------------------
;
; copper code
;
;----------------------------------------------------------------------------

    include            "common.asm"

;----------------------------------------------------------------------------
;
; fills the two copper buffers from the template and sets the pointers
;
;----------------------------------------------------------------------------

CopperInit:
    lea                cpCopper,a0
    lea                Copper1,a1
    lea                Copper2,a2

    move.l             a1,CopperBuffer(a5)
    move.l             a2,CopperBuffer+4(a5)

    move.w             #COPPER_SIZEOF-1,d7
.copy
    move.b             (a0)+,d0
    move.b             d0,(a1)+
    move.b             d0,(a2)+
    dbra               d7,.copy

    bsr                NullSprites
    rts


;----------------------------------------------------------------------------
;
; null sprites
;
;----------------------------------------------------------------------------

NullSprites:
    move.l             CopperBuffer(a5),a0
    move.l             CopperBuffer(a5),a1

    lea                COPPER_SPRITE(a0),a0
    lea                COPPER_SPRITE(a0),a1

    move.l             #NullSprite,d0
    REPT               8
    PLANE_TO_COPPER    d0,a0
    addq.l             #8,a0
    ENDR
    REPT               8
    PLANE_TO_COPPER    d0,a1
    addq.l             #8,a1
    ENDR

    lea                SpritePtrs(a5),a0
    REPT               8
    move.l             d0,(a0)+
    ENDR

    lea                cpSpriteFin,a0
    move.l             #NullSprite,d0
    REPT               8
    PLANE_TO_COPPER    d0,a0
    addq.l             #8,a0
    ENDR

    rts


LoadCopperMenu:
    lea                cpMenu,a0
    move.l             TitleCopperPtr(a5),a1
    move.l             TitleCopperPtr+4(a5),a2
    move.w             #COPPER_MENU_HEADER-1,d7
.copyloop
    move.b             (a0),(a1)+
    move.b             (a0)+,(a2)+
    dbra               d7,.copyloop

    bsr                HideTitleSprites
    
    lea                cpMenuCastle,a3
    move.l             TitleCastlePtr(a5),d0                  ; current screen  
    subq.l             #2,d0         
    move.l             #CASTLE_WIDTH_BYTE*CASTLE_HEIGHT,d1  
    LONGTOCOPPERADD    d0,a3,MENU_DEPTH,d1
    

    rts     

;----------------------------------------------------------------------------
;
; load up copper with pointers and palette
;
;----------------------------------------------------------------------------

LoadCopper:
    move.l             CopperBuffer(a5),a4
    lea                COPPER_PLANES1(a4),a3
                  
    move.l             ScreenBuffer(a5),d0                    ; current screen                
    move.l             #SCREEN_WIDTH_BYTE,d1  
    LONGTOCOPPERADD    d0,a3,SCREEN_DEPTH,d1

    lea                COPPER_PLANES_HUD(a4),a3
    move.l             #Hud,d0                                ; current screen
    move.l             #SCREEN_WIDTH_BYTE,d1  
    PLANE_TO_COPPER    d0,a3

    lea                COPPER_PALETTE(a4),a3
    lea                MainPalette(a5),a0
    addq.l             #2,a3
    REPT               SCREEN_COLORS
    move.w             (a0)+,(a3)
    addq.l             #4,a3
    ENDR

    rts     



;----------------------------------------------------------------------------
;
; load plane pointers with scroll offset
;
;----------------------------------------------------------------------------

LoadCopperScroll:
    move.l             CopperBuffer(a5),a4

    move.l             ScreenBuffer(a5),d0                    ; current screen    
    moveq              #0,d1
    move.w             MapScrollOffset(a5),d1                 ; constant for routine
    add.w              d1,d1
    add.w              d1,d1
    move.l             StrideLookUp(a5,d1.w),d1
    add.l              d1,d0                                  ; main pointer

    lea                COPPER_PLANES1(a4),a3
    move.l             #SCREEN_WIDTH_BYTE,d5  
    LONGTOCOPPERADD    d0,a3,SCREEN_DEPTH,d5

    tst.w              PaletteDirty(a5)
    beq                .skippalette
    subq.w             #1,PaletteDirty(a5)

    lea                COPPER_PALETTE(a4),a3
    lea                MainPalette(a5),a0
    addq.l             #2,a3
    REPT               SCREEN_COLORS
    move.w             (a0)+,(a3)
    addq.l             #4,a3
    ENDR
.skippalette
    
    tst.w              SpriteDirty(a5)
    beq                .skipsprite

    subq.w             #1,SpriteDirty(a5)
    lea                COPPER_SPRITE(a4),a3
    lea                SpritePtrs(a5),a2
    
    REPT               8
    move.l             (a2)+,d0
    PLANE_TO_COPPER    d0,a3
    addq.l             #8,a3
    ENDR

.skipsprite

    ;lea                COPPER_PLANES_HUD(a4),a3
    ;move.l             #Hud,d0                                ; current screen TODO: stop loading this!
    ;PLANE_TO_COPPER    d0,a3
    move.l             #HUD,d0
    lea                COPPER_PLANES_HUD(a4),a3
    move.l             #HUD_WIDTH_BYTE,d5  
    LONGTOCOPPERADD    d0,a3,SCREEN_DEPTH,d5

    WAITBLIT
    move.l             CopperBuffer(a5),COP1LC(a6)            ; load this copper list for next frame
    
    tst.b              DoubleBuffer(a5)
    beq                .skiprot

    lea                CopperBuffer(a5),a0
    ROTATE_LONG        a0,2
    lea                ScreenBuffer(a5),a0
    ROTATE_LONG        a0,2

.skiprot
    rts


;----------------------------------------------------------------------------
;
; rotates the plane pointers
;
;----------------------------------------------------------------------------

ScreenRotate:
    lea                ScreenBuffer(a5),a0
    ROTATE_LONG        a0,2
    rts

;----------------------------------------------------------------------------
;
; rotates the plane pointers
;
;----------------------------------------------------------------------------

CopperRotate:
    lea                CopperBuffer(a5),a0
    ROTATE_LONG        a0,2
    rts



;----------------------------------------------------------------------------
;
; Vert adjust
;
; DIWSTRT,$2ca1                      ; window start stop (256 * 212)  
; DIWSTOP,$00a1
;
; d0 = adjust
;
;----------------------------------------------------------------------------

SetVertScroll:
    moveq              #0,d0
    move.l             CopperBuffer(a5),a4
    move.l             CopperBuffer+4(a5),a3

    move.b             ScreenStart(a5),d1
    move.b             ScreenEnd(a5),d2
    add.b              d0,d1
    add.b              d0,d2
    lsl.w              #8,d1
    lsl.w              #8,d2
    move.b             #$a1,d1
    move.b             #$a1,d2
    move.w             d1,COPPER_VERT+2(a4)
    move.w             d2,COPPER_VERT+6(a4)
    move.w             d1,COPPER_VERT+2(a3)
    move.w             d2,COPPER_VERT+6(a3)

    sub.w              #$100,d2

    move.w             d1,cpVertMenu+2
    move.w             d2,cpVertMenu+6

    move.w             d1,cpVertFin+2
    move.w             d2,cpVertFin+6

    move.b             ScreenStart(a5),d1
    add.b              #SCREEN_HUD_WAIT,d1
    add.b              d0,d1
    lsl.w              #8,d1
    move.b             #$cf,d1

    move.w             d1,COPPER_VERT_HUD(a4)
    move.w             d1,COPPER_VERT_HUD(a3)

    add.w              #$100,d1
    move.w             d1,COPPER_VERT_HUD2(a4)
    move.w             d1,COPPER_VERT_HUD2(a3)

    rts



;----------------------------------------------------------------------------
;
; hides game playfield from view so it can be drawn
;
;----------------------------------------------------------------------------


HideGameScreen:
    bsr                wait_raster_HUD
    move.w             #$200,d0
    move.l             CopperBuffer(a5),a4
    move.w             d0,2(a4)
    move.l             CopperBuffer+4(a5),a4
    move.w             d0,2(a4)
    rts


ShowGameScreen:
    move.w             #(SCREEN_DEPTH<<12)+$200,d0
    move.l             CopperBuffer(a5),a4
    move.w             d0,2(a4)
    move.l             CopperBuffer+4(a5),a4
    move.w             d0,2(a4)
    rts



HideHudScreen:
    if                 DEBUG_STATS=1
    move.w             #$1200,d0
    else
    move.w             #$200,d0
    endif
    move.l             CopperBuffer(a5),a4
    move.w             d0,COPPER_HUD_ENABLE(a4)
    move.l             CopperBuffer+4(a5),a4
    move.w             d0,COPPER_HUD_ENABLE(a4)
    rts

ShowHudScreen:
    move.w             #$5200,d0
    move.l             CopperBuffer(a5),a4
    move.w             d0,COPPER_HUD_ENABLE(a4)
    move.l             CopperBuffer+4(a5),a4
    move.w             d0,COPPER_HUD_ENABLE(a4)
    rts
