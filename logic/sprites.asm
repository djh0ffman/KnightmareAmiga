;----------------------------------------------------------------------------
;
; sprite bits
;
;----------------------------------------------------------------------------

    include            "common.asm"





;----------------------------------------------------------------------------
;
; backup
;
;----------------------------------------------------------------------------


SpriteBackup:
    PUSHM              a0/a1
    lea                SpritePtrs(a5),a0
    lea                SpritePtrsBackup(a5),a1
    REPT               8
    move.l             (a0)+,(a1)+
    ENDR

    bsr                ClearAllSprites

    POPM               a0/a1
    rts



SpriteRestore:
    PUSHM              a0/a1
    lea                SpritePtrsBackup(a5),a0
    lea                SpritePtrs(a5),a1
    REPT               8
    move.l             (a0)+,(a1)+
    ENDR

    move.w             #2,SpriteDirty(a5)

    POPM               a0/a1
    rts

;----------------------------------------------------------------------------
;
; clear all
;
;----------------------------------------------------------------------------


ClearAllSprites:
    PUSH               a0
    move.l             #NullSprite,d0
    lea                SpritePtrs(a5),a0
    REPT               8
    move.l             d0,(a0)+
    ENDR
    move.w             #2,SpriteDirty(a5)
    POP                a0
    rts
;----------------------------------------------------------------------------
;
; freeze timer
;
;----------------------------------------------------------------------------


FreezeTimerDisplay:
    PUSHMOST
    lea                TimerSprite1A,a0
    move.l             #$d0,d1
    moveq              #$8,d2
    moveq              #0,d5
    bsr                SpriteCoord

    lea                TimerSprite1B,a0
    move.l             #$d0,d1
    moveq              #$8,d2
    move.b             #$80,d5
    bsr                SpriteCoord


    lea                TimerSprite2A,a0
    move.l             #$e8,d1
    moveq              #$8,d2
    moveq              #0,d5
    bsr                SpriteCoord

    lea                TimerSprite2B,a0
    move.l             #$e8,d1
    moveq              #$8,d2
    move.b             #$80,d5
    bsr                SpriteCoord


    lea                TimerSpriteColonA,a0
    move.l             #$e0,d1
    moveq              #$8,d2
    moveq              #0,d5
    bsr                SpriteCoord

    lea                TimerSpriteColonB,a0
    move.l             #$e0,d1
    moveq              #$8,d2
    move.b             #$80,d5
    bsr                SpriteCoord

    lea                SpritePtrs(a5),a0

    move.l             #TimerSprite1A,(a0)+
    move.l             #TimerSprite1B,(a0)+
    move.l             #TimerSprite2A,(a0)+
    move.l             #TimerSprite2B,(a0)+
    move.l             #TimerSpriteColonA,(a0)+
    move.l             #TimerSpriteColonB,(a0)+

    move.w             #2,SpriteDirty(a5)
    POPMOST
    rts

FreezeTimerRender:
    PUSHMOST

    lea                TimerSprite2A+4,a2
    lea                TimerSprite2B+4,a3
    moveq              #0,d0
    move.b             FreezeTimerLo(a5),d0
    DECIMAL2           d0,d1
    bsr                Render2SpriteMulti

    lea                TimerSprite1A+4,a2
    lea                TimerSprite1B+4,a3
    moveq              #0,d0
    move.b             FreezeTimerHi(a5),d0
    DECIMAL2           d0,d1
    bsr                Render2SpriteMulti

    POPMOST
    rts


FreezeTimerColonRender:
    PUSHMOST

    lea                TimerSpriteColonA+4,a2
    lea                TimerSpriteColonB+4,a3
    moveq              #0,d1
    move.b             #":",d1
    bsr                Render1SpriteMulti

    POPMOST
    rts


FreezeTimerRemove:
    lea                SpritePtrs(a5),a0
    move.l             #NullSprite,d0
    move.l             d0,(a0)+
    move.l             d0,(a0)+
    move.l             d0,(a0)+
    move.l             d0,(a0)+
    move.l             d0,(a0)+
    move.l             d0,(a0)+
    move.w             #2,SpriteDirty(a5)
    rts


;----------------------------------------------------------------------------
;
; render 2 digit number to sprite
;
; a2 - sprite 1
; a3 - sprite 2
;
;----------------------------------------------------------------------------

SPRCHR MACRO
    move.b             (a1)+,(\1*4)+0(a2)
    move.b             (a1)+,(\1*4)+2(a2)
    move.b             (a1)+,(\1*4)+0(a3)
    move.b             (a1)+,(\1*4)+2(a3) 
    addq.l             #1,a1
    ENDM

Render1SpriteMulti:
    sub.b              #$20,d1
    mulu               #40,d1

    lea                GfxFont2,a0                              

    lea                (a0,d1.w),a1

    SPRCHR             0
    SPRCHR             1
    SPRCHR             2
    SPRCHR             3
    SPRCHR             4
    SPRCHR             5
    SPRCHR             6
    SPRCHR             7
    rts

Render2SpriteMulti:
    add.l              #$00100010,d1
    move.l             d1,d2
    swap               d2
    mulu               #40,d1
    mulu               #40,d2

    lea                GfxFont2,a0                              

CharsToSprite:
    lea                (a0,d1.w),a1

    SPRCHR             0
    SPRCHR             1
    SPRCHR             2
    SPRCHR             3
    SPRCHR             4
    SPRCHR             5
    SPRCHR             6
    SPRCHR             7

    addq.l             #1,a2
    addq.l             #1,a3

    lea                (a0,d2.w),a1

    SPRCHR             0
    SPRCHR             1
    SPRCHR             2
    SPRCHR             3
    SPRCHR             4
    SPRCHR             5
    SPRCHR             6
    SPRCHR             7

    rts

;----------------------------------------------------------------------------
;
; power up timer
;
;----------------------------------------------------------------------------

PowerTimerDisplay:
    PUSHMOST
    lea                TimerSpritePower1,a0
    move.l             #$10,d1
    moveq              #$8,d2
    moveq              #0,d5
    bsr                SpriteCoord

    lea                TimerSpritePower2,a0
    move.l             #$10,d1
    moveq              #$8,d2
    move.w             #$80,d5
    bsr                SpriteCoord

    move.l             #TimerSpritePower1,SpritePtrs+24(a5)
    move.l             #TimerSpritePower2,SpritePtrs+28(a5)
    move.w             #2,SpriteDirty(a5)
    POPMOST
    rts

PowerTimerRender:
    PUSHMOST

    lea                TimerSpritePower1+4,a2
    lea                TimerSpritePower2+4,a3
    moveq              #0,d0
    move.b             PowerUpTimerHi(a5),d0
    DECIMAL2           d0,d1
    bsr                Render2SpriteMulti

    POPMOST
    rts


PowerTimerRemove:
    move.l             #NullSprite,SpritePtrs+24(a5)
    move.l             #NullSprite,SpritePtrs+28(a5)
    move.w             #2,SpriteDirty(a5)
    rts

;----------------------------------------------------------------------------
;
; sprite coord
;
; d1 = x
; d2 = y
; a0 = sprite strucutre
;
; d5 = $80 attach bit
;
;----------------------------------------------------------------------------


SpriteCoord:
    PUSHM              d1/d2
    add.w              #SCREEN_HSTART,d1
    moveq              #0,d4
    move.b             ScreenStart(a5),d4
    add.w              d4,d2

    move.l             d1,d4
    swap               d4
    lsr.l              #1,d4
    rol.w              #1,d4                                    ; H START

    move.l             d2,d3
    lsl.l              #8,d3
    swap               d3
    lsl.w              #2,d3
    or.l               d3,d4                                    ; V START ( lower bits )

    move.l             d2,d3
    add.w              #8,d3                                    ; Height
    rol.w              #8,d3
    lsl.b              #1,d3
    or.l               d3,d4                                    ; V STOP ( lower bits )

    or.b               d5,d4                                    ; attach bit
    
    move.l             d4,(a0)+
    POPM               d1/d2

    rts



SpriteCoord10:
    PUSHM              d1/d2
    add.w              #SCREEN_HSTART,d1
    moveq              #0,d4
    move.b             ScreenStart(a5),d4
    add.w              d4,d2

    move.l             d1,d4
    swap               d4
    lsr.l              #1,d4
    rol.w              #1,d4                                    ; H START

    move.l             d2,d3
    lsl.l              #8,d3
    swap               d3
    lsl.w              #2,d3
    or.l               d3,d4                                    ; V START ( lower bits )

    move.l             d2,d3
    add.w              #10,d3                                   ; Height
    rol.w              #8,d3
    lsl.b              #1,d3
    or.l               d3,d4                                    ; V STOP ( lower bits )

    or.b               d5,d4                                    ; attach bit
    
    move.l             d4,(a0)+
    POPM               d1/d2

    rts

;----------------------------------------------------------------------------
;
; boss health
;
;----------------------------------------------------------------------------

LoadBossHealth:
    PUSHMOST
    lea                BossBarList,a4
    
    moveq              #96,d1                                   ; x pos
    moveq              #11,d2                                   ; y pos

    moveq              #4-1,d7

.loop
    move.l             (a4)+,a0
    moveq              #0,d5
    bsr                SpriteCoord10
    move.l             (a4)+,a0
    move.b             #$80,d5
    bsr                SpriteCoord10
    add.w              #16,d1
    dbra               d7,.loop

    lea                GfxFont2,a0                              
    lea                BossBarDisplayList,a6
    lea                TextBoss,a4
    moveq              #4,d6
    moveq              #2-1,d7
    bsr                TextToSprite1
    lea                CUSTOM,a6

    lea                BossBarDisplayList,a4
    moveq              #96,d1                                   ; x pos
    moveq              #2,d2                                    ; y pos
    moveq              #2-1,d7
.looptext
    move.l             (a4)+,a0
    moveq              #0,d5
    bsr                SpriteCoord
    move.l             (a4)+,a0
    move.b             #$80,d5
    bsr                SpriteCoord
    add.w              #16,d1
    dbra               d7,.looptext


    bsr                LoadBarSprites

    POPMOST
    rts

CalcEyeBossHealth:
    PUSHMOST
    moveq              #0,d0
    moveq              #EYE_COUNT-1,d7
    lea                EyeList(a5),a2
.loop
    add.b              EYE_HitCount(a2),d0
    lea                EYE_Sizeof(a2),a2
    dbra               d7,.loop

    move.w             #$14*6,d1                                ; hit max
    moveq              #0,d2
    move.w             d1,d2
    sub.w              d0,d2
    mulu               #BOSS_BAR_MAX,d2
    divu               d1,d2

    bsr                RenderBar

    bsr                LoadBarSprites

    POPMOST
    rts

CalcBossHealth:
    PUSHMOST
    moveq              #0,d0
    moveq              #0,d1
    moveq              #0,d2
    move.b             BossHitCount(a5),d0
    move.b             BossHitMax(a5),d1
    move.b             d1,d2
    sub.b              d0,d2
    mulu               #BOSS_BAR_MAX,d2
    divu               d1,d2

    bsr                RenderBar

    bsr                LoadBarSprites

    POPMOST
    rts

SetHealthBar:
    PUSHMOST
    moveq              #0,d2
    move.b             BossBarLoad(a5),d2
    cmp.b              #BOSS_BAR_MAX+1,d2
    beq                .done
    bsr                RenderBar
    addq.b             #1,BossBarLoad(a5)
    move.l             BossBobSlotPtr(a5),a4
    eor.b              #1,Bob_Hide(a4)
    move.b             Bob_Hide(a4),d0
    move.l             BossBobShadowSlotPtr(a5),a4
    move.b             d0,Bob_Hide(a4)
    POPMOST
    rts

.done
    move.l             BossBobSlotPtr(a5),a4
    sf                 Bob_Hide(a4)
    move.l             BossBobShadowSlotPtr(a5),a4
    sf                 Bob_Hide(a4)
    POPMOST
    rts



InitHealthBar:
    PUSHMOST
    lea                BossBarList,a0
    moveq              #8-1,d7
    lea                BossBarSpr,a1
.loop
    move.l             (a0)+,a2
    addq.l             #4,a2
    moveq              #40-1,d6
.copy
    move.b             (a1)+,(a2)+
    dbra               d6,.copy
    dbra               d7,.loop

    POPMOST
    rts

; d2 = total bar size ( max 59? )

BARSPRITE_BLIT_SIZE = (6<<6)+2

RenderBar:
    lea                BarMaskList,a0
    lea                BossBarList,a4
    lea                BarSizes,a3
    move.l             #BossBarSpr+8,d5
    moveq              #4-1,d7
.loop
    move.l             (a0)+,a2                                 ; next mask

    moveq              #16,d1                                   ; mask full
    tst.w              d2
    bpl                .flipmask
    moveq              #0,d1
.flipmask
    move.w             (a3)+,d0                                 ; current size
    cmp.w              d0,d2
    bcc                .skipmask

    move.w             d2,d1
.skipmask
    add.w              d1,d1
    move.w             (a2,d1.w),d3
    swap               d3
    move.w             (a2,d1.w),d3

    ; blit 2 sprites
    
    move.l             (a4)+,d4                                 ; sprite dest
    add.l              #12,d4                                   ; 2 control words and 2 lines
    ; 0bc0

    ; first blit
    WAITBLIT
    move.w             #$0be2,BLTCON0(a6)
    move.w             #0,BLTCON1(a6)
    move.l             #-1,BLTAFWM(a6)
    move.w             #0,BLTAMOD(a6)
    move.w             #0,BLTBMOD(a6)
    move.w             #-4,BLTCMOD(a6)                          ; repeat same two words from empty
    move.w             #0,BLTDMOD(a6)
    move.l             d5,BLTAPT(a6)                            ; source sprite
    move.l             #BossBarSpr+$54,BLTCPT(a6)               ; empty area
    move.l             d4,BLTDPT(a6)                            ; destination
    move.w             d3,BLTBDAT(a6)
    move.w             #BARSPRITE_BLIT_SIZE,BLTSIZE(a6)

    move.l             (a4)+,d4                                 ; sprite dest
    add.l              #12,d4                                   ; 2 control words and 2 lines
    add.l              #40,d5                                   ; sprite source

    ; second blit
    WAITBLIT
    move.w             #$0be2,BLTCON0(a6)
    move.w             #0,BLTCON1(a6)
    move.l             #-1,BLTAFWM(a6)
    move.w             #0,BLTAMOD(a6)
    move.w             #0,BLTBMOD(a6)
    move.w             #-4,BLTCMOD(a6)                          ; repeat same two words from empty
    move.w             #0,BLTDMOD(a6)
    move.l             d5,BLTAPT(a6)                            ; source sprite
    move.l             #BossBarSpr+$7c,BLTCPT(a6)               ; empty area
    move.l             d4,BLTDPT(a6)                            ; destination
    move.w             d3,BLTBDAT(a6)
    move.w             #BARSPRITE_BLIT_SIZE,BLTSIZE(a6)

    add.l              #40,d5                                   ; sprite source

    ; next sprite pair
    sub.w              d0,d2
    dbra               d7,.loop

    rts


BarMaskList:
    dc.l               BarMaskFirst
    dc.l               BarMasksFull
    dc.l               BarMasksFull
    dc.l               BarMasksLast

BarSizes:
    dc.w               14,16,16,14

BarMasksFull:          
    dc.w               %0000000000000000
    dc.w               %1000000000000000
BarMaskFirst:
    dc.w               %1100000000000000
    dc.w               %1110000000000000
    dc.w               %1111000000000000
    dc.w               %1111100000000000
    dc.w               %1111110000000000
    dc.w               %1111111000000000
    dc.w               %1111111100000000
    dc.w               %1111111110000000
    dc.w               %1111111111000000
    dc.w               %1111111111100000
    dc.w               %1111111111110000
    dc.w               %1111111111111000
    dc.w               %1111111111111100
    dc.w               %1111111111111110
    dc.w               %1111111111111111
    dc.w               %1111111111111111
    dc.w               %1111111111111111


BarMasksLast:          
    dc.w               %0000000000000001
    dc.w               %1000000000000001
    dc.w               %1100000000000001
    dc.w               %1110000000000001
    dc.w               %1111000000000001
    dc.w               %1111100000000001
    dc.w               %1111110000000001
    dc.w               %1111111000000001
    dc.w               %1111111100000001
    dc.w               %1111111110000001
    dc.w               %1111111111000001
    dc.w               %1111111111100001
    dc.w               %1111111111110001
    dc.w               %1111111111111001
    dc.w               %1111111111111101
    dc.w               %1111111111111111
    dc.w               %1111111111111111

LoadBarSprites:
    lea                BossBarDisplayList,a3
    lea                SpritePtrs(a5),a4
    moveq              #8-1,d7
.loadptr
    move.l             (a3)+,(a4)+
    dbra               d7,.loadptr

    move.w             #2,SpriteDirty(a5)
    rts


TitleSpritesInit:
    clr.w              TitleSelectPos(a5)
    move.l             #TextTitle1,TitleSpriteTextPtrs(a5)
    move.l             #TextTitle2,TitleSpriteTextPtrs+4(a5)
    move.l             #TextTitle3,TitleSpriteTextPtrs+8(a5)
    move.b             #" ",d0
    move.b             d0,TextTitle1
    move.b             d0,TextTitle2
    move.b             d0,TextTitle3
    rts

ClearMenuArrow:
    move.w             TitleSelectPos(a5),d0
    lea                TitleSpriteTextPtrs(a5),a0
    add.w              d0,d0
    add.w              d0,d0
    move.l             (a0,d0.w),a0
    move.b             #" ",(a0)
    rts

SetMenuArrow:
    move.w             TitleSelectPos(a5),d0
    lea                TitleSpriteTextPtrs(a5),a0
    add.w              d0,d0
    add.w              d0,d0
    move.l             (a0,d0.w),a0
    move.b             #"%",(a0)
    rts


;----------------------------------------------------------------------------
;
; render title sprites
;
;----------------------------------------------------------------------------

RenderTitleSprites:
    ;move.l             TitleSpriteTextPtrs(a5),a0
    ;move.l             TitleSpriteTextPtrs+4(a5),a1

    ;tst.w              TitleSelectPos(a5)
    ;beq                .skipswitch
    ;exg                a0,a1
;.skipswitch
    ;move.b             #"%",(a0)
    ;move.b             #" ",(a1)


    move.l             TitleSpriteTextPtrs(a5),a4
    lea                TitleSpritePtrs(a5),a6
    lea                GfxFont2,a0                              
    moveq              #4,d6                                    ; sprite ptr offset
    bsr                TextToSprite

    move.l             TitleSpriteTextPtrs+4(a5),a4
    lea                TitleSpritePtrs(a5),a6
    lea                GfxFont2,a0                              
    move.l             #TITLE_SPRITE_OFFSET2+4,d6               ; sprite ptr offset
    bsr                TextToSprite

    move.l             TitleSpriteTextPtrs+8(a5),a4
    lea                TitleSpritePtrs(a5),a6
    lea                GfxFont2,a0                              
    move.l             #TITLE_SPRITE_OFFSET3+4,d6               ; sprite ptr offset
    bsr                TextToSprite



    move.l             #TITLE_SPRITE_X,d1                       ; x
    move.l             #TITLE_SPRITE_Y1,d2                      ; y
    move.l             #0,a3                                    ; offset
    bsr                TitleCoords

    move.l             #TITLE_SPRITE_X,d1                       ; x
    move.l             #TITLE_SPRITE_Y2,d2                      ; y
    move.l             #TITLE_SPRITE_OFFSET2,a3                 ; offset
    bsr                TitleCoords

    move.l             #TITLE_SPRITE_X,d1                       ; x
    move.l             #TITLE_SPRITE_Y3,d2                      ; y
    move.l             #TITLE_SPRITE_OFFSET3,a3                 ; offset
    bsr                TitleCoords

    lea                CUSTOM,a6
    rts


TitleCoords:
    lea                TitleSpritePtrs(a5),a6
    moveq              #4-1,d6
.coordloop
    move.l             (a6)+,a0
    add.l              a3,a0
    moveq              #0,d5
    bsr                SpriteCoord
    move.l             (a6)+,a0
    add.l              a3,a0
    move.w             #$80,d5
    bsr                SpriteCoord

    add.w              #16,d1  
    dbra               d6,.coordloop
    rts

;----------------------------------------------------------------------------
;
; show / hide title sprites
;
;----------------------------------------------------------------------------


ShowTitleSprites:
    lea                TitleSpritePtrs(a5),a0
    move.l             TitleCopperPtr(a5),a1
    move.l             TitleCopperPtr+4(a5),a2
    add.l              #COPPER_MENU_SPRITES,a1
    add.l              #COPPER_MENU_SPRITES,a2
    ;lea                cpMenuSprites,a1
    moveq              #8-1,d7
.loop
    move.l             (a0)+,d0
    PLANE_TO_COPPER    d0,a1
    PLANE_TO_COPPER    d0,a2
    addq.l             #8,a1
    addq.l             #8,a2
    dbra               d7,.loop
    rts


HideTitleSprites:
    move.l             #NullSprite,d0
    move.l             TitleCopperPtr(a5),a3
    move.l             TitleCopperPtr+4(a5),a4
    add.l              #COPPER_MENU_SPRITES,a3
    add.l              #COPPER_MENU_SPRITES,a4
    ;lea                cpMenuSprites,a3
    moveq              #8-1,d7
.loop
    PLANE_TO_COPPER    d0,a3
    PLANE_TO_COPPER    d0,a4
    addq.l             #8,a3
    addq.l             #8,a4
    dbra               d7,.loop
    rts


RenderTitleSelect:
    lea                TitleSpriteTextPtrs(a5),a0
    lea                TextTitleClear,a1

    moveq              #0,d0
    moveq              #3-1,d7
.loop
    cmp.w              TitleSelectPos(a5),d0
    beq                .skip
    move.l             a1,(a0)
.skip
    addq.l             #4,a0
    addq.w             #1,d0
    dbra               d7,.loop

    bra                RenderTitleSprites

;----------------------------------------------------------------------------
;
; text to sprite
;
;----------------------------------------------------------------------------

TextToSprite:
    moveq              #4-1,d7                                  ; 4 sprites / 8 characters
TextToSprite1:
.loop
    move.l             (a6)+,a2
    move.l             (a6)+,a3

    add.l              d6,a2
    add.l              d6,a3

    moveq              #0,d1
    moveq              #0,d2
    move.b             (a4)+,d1
    move.b             (a4)+,d2

    sub.b              #$20,d1
    sub.b              #$20,d2                     
    mulu               #40,d1
    mulu               #40,d2

    bsr                CharsToSprite
    dbra               d7,.loop
    rts

TextBoss:
    dc.b               "BOSS"

TextTitle1:
    dc.b               "  START "    
TextTitle2:
    dc.b               "  OPTION"
TextTitle3:
    dc.b               "  SCORES"
TextTitleClear:
    dc.b               "        "
    even
