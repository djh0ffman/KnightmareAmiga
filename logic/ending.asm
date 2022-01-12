

;----------------------------------------------------------------------------
;
; ending
;
;----------------------------------------------------------------------------

    include            "common.asm"

Ending:
    lea                PlayerStatus(a5),a0
    JMPINDEX           d1

.id
    dc.w               EndingInit-.id
    dc.w               EndingLogic0-.id
    dc.w               EndingLogic1-.id
    dc.w               EndingLogic2-.id
    dc.w               EndingLogic3-.id
    dc.w               EndingLogic4-.id
    dc.w               EndingLogic5-.id
    dc.w               EndingLogic6-.id
    dc.w               EndingLogic7-.id
    dc.w               EndingLogicWait-.id
    dc.w               EndingLogic8-.id
    dc.w               EndingLogic9-.id
    dc.w               EndingLogic10-.id
    dc.w               EndingLogic11-.id
    dc.w               EndingLogicExit-.id

; ---------------------------------------------------------------------------

EndingInit:  
    bsr                HideGameScreen
    bsr                BobClear
    bsr                HideHudScreen
    bsr                ScreenClear
    WAITBLIT
    bsr                ShowGameScreen
    lea                MenuPal,a0
    move.w             #SCREEN_COLORS,d0
    bsr                LoadPalette
    sf                 DoubleBuffer(a5)

    lea                TextEnding1,a0
    bsr                TextPlotMain

    move.b             #$b4,WaitCounter(a5)                    ; wait for for that this screen

    addq.b             #1,GameSubStatus(a5)

    moveq              #0,d0
    moveq              #MOD_ENDING,d1
    bra                MusicSetHard

; ---------------------------------------------------------------------------

EndingLogic0:
    subq.b             #1,WaitCounter(a5)
    bne                .exit

    move.w             #$9700,PLAYER_PosY(a0)
    move.w             #$7800,PLAYER_PosX(a0)
    clr.w              PLAYER_SpeedX(a0)
    clr.w              PLAYER_SpeedY(a0)
    clr.b              PLAYER_PowerUp(a0)

    bsr                BobAllocate
    sf                 Bob_Hide(a4)
    move.w             d0,PLAYER_BobSlot(a0)

    bsr                PlayerAutoWalk

    lea                PrincessStatus(a5),a1
    move.b             #POWERUP_PRINCESS,PLAYER_PowerUp(a1)
    move.w             #0,PLAYER_PosY(a1)
    move.w             #$7800,PLAYER_PosX(a1)
    clr.w              PLAYER_SpeedX(a1)
    move.w             #$0070,PLAYER_SpeedY(a1)

    bsr                BobAllocate
    sf                 Bob_Hide(a4)
    move.w             #$16,Bob_TopMargin(a4)

    move.w             d0,PLAYER_BobSlot(a1)

    move.l             a1,a0
    bsr                PlayerAutoWalk

    bsr                HideGameScreen
    bsr                ScreenClear
    bsr                MapInit

    moveq              #7,d0                                   ; enfore level 7 palette because reasons
    bsr                LoadLevelPal1
    
    st                 DoubleBuffer(a5)
    bsr                ShowGameScreen

    addq.b             #1,GameSubStatus(a5)
.exit
    rts

; ---------------------------------------------------------------------------

EndingLogic1:
    lea                PrincessStatus(a5),a0
    bsr                PlayerAutoWalk                          ; move the princess into the screen


    PUSHMOST
    bsr                BobClean
    bsr                BobDraw
    POPMOST

    cmp.b              #$48,PLAYER_PosY(a0)                    ; below $48, not ready yet
    bcs                .exit

    lea                PlayerStatus(a5),a0
    move.w             #-$a0,PLAYER_SpeedY(a0)                 ; set player move speed

    addq.b             #1,GameSubStatus(a5)
.exit
    rts

; ---------------------------------------------------------------------------

EndingLogic2:
    bsr                PlayerAutoWalk                          ; walk the player to the princess
 
    PUSHMOST
    bsr                BobClean
    bsr                BobDraw
    POPMOST

    cmp.b              #$64,PLAYER_PosY(a0)                    ; not arrived yet
    bcc                .exit

    move.b             #$78,EndingTimer(a5)                    ; set enegmatic pause

    addq.b             #1,GameSubStatus(a5)
.exit
    rts

; ---------------------------------------------------------------------------

EndingLogic3:
    PUSHMOST
    bsr                BobClean
    bsr                BobDraw
    POPMOST

    subq.b             #1,EndingTimer(a5)                      ; enegmatic pause not complete
    beq                .exit

    sf                 DoubleBuffer(a5)
    clr.b              Shrink(a5)                              ; prep...
    addq.b             #1,GameSubStatus(a5)
.exit
    rts

; ---------------------------------------------------------------------------

EndingLogic4:
    PUSHMOST
    bsr                BobClean
    bsr                BobDraw
    POPMOST

    moveq              #0,d0
    move.b             Shrink(a5),d0
    cmp.b              #$40,d0
    bcc                .hori

    ; clear hoizontal lines
    moveq              #0,d0
    move.b             Shrink(a5),d0
    bsr                LineClearHori

    move.w             #SCREEN_HEIGHT_DISPLAY-1,d0
    sub.b              Shrink(a5),d0
    bsr                LineClearHori
.hori
    ; clear veritcal lines
    moveq              #0,d0
    move.b             Shrink(a5),d0
    cmp.b              #$60,d0
    bcc                .next

    moveq              #0,d0
    move.b             Shrink(a5),d0
    bsr                LineClearVert

    move.w             #SCREEN_DISPLAY_WIDTH-1,d0
    sub.b              Shrink(a5),d0
    bsr                LineClearVert

    addq.b             #1,Shrink(a5)
    rts

.next
    lea                TextEnding2,a0                          ; love is forever....
    bsr                TextPlotMain

    addq.b             #1,GameSubStatus(a5)
    rts
; ---------------------------------------------------------------------------

EndingLogic5:
    PUSHMOST
    bsr                BobClean
    bsr                BobDraw
    POPMOST

    subq.b             #1,EndingTimer(a5)
    bne                .exit

    lea                BlackPal,a0
    move.w             #SCREEN_COLORS,d0
    bsr                FadeInit

    addq.b             #1,GameSubStatus(a5)
.exit
    rts

; ---------------------------------------------------------------------------

EndingLogic6:
    PUSHMOST
    bsr                BobClean
    bsr                BobDraw
    POPMOST

    move.b             TickCounter(a5),d0
    and.b              #3,d0
    bne                .exit

    bsr                FadeLogic
    tst.w              PaletteStatus(a5)
    bne                .exit

    ; setup fin screen
    moveq              #0,d0
    moveq              #MOD_HISCORE,d1
    bsr                MusicSetHard

    move.b             #1,DisableCopper(a5)

    bsr                ScreenClear
    WAITBLIT
    
    lea                BlackPal,a0
    move.w             #SCREEN_COLORS,d0
    bsr                LoadPalette
    
    lea                cpPaletteFin,a0
    bsr                PaletteToCopper

    lea                FinPal,a0
    move.w             #SCREEN_COLORS,d0
    bsr                FadeInit

    move.l             #WorkArea,d0
    lea                cpPlanesFin,a0
    move.l             #FIN_SCREEN_WIDTH_BYTE,d5  
    LONGTOCOPPERADD    d0,a0,FIN_SCREEN_DEPTH,d5

    move.l             #cpCopperFin,COP1LC(a6)

    bsr                BobClear

    lea                FinPic,a0
    lea                WorkArea,a1
    bsr                Unpack
    ;sub.l              a2,a2
    ;bsr                ShrinklerDecompress

    addq.b             #1,GameSubStatus(a5)
.exit
    rts

; ---------------------------------------------------------------------------
; setup FIN screen

EndingLogic7:
    btst.b             #1,TickCounter(a5)
    beq                .exit

    bsr                FadeLogic
    lea                cpPaletteFin,a0
    bsr                PaletteToCopper

    tst.w              PaletteStatus(a5)
    bne                .exit

    addq.b             #1,GameSubStatus(a5)
    move.b             #$f0,WaitCounter(a5)
    lea                BlackPal,a0
    move.w             #SCREEN_COLORS,d0
    bsr                FadeInit

.exit
    rts

; ---------------------------------------------------------------------------
; fade etc.

EndingLogic8:
    btst.b             #1,TickCounter(a5)
    beq                .exit

    bsr                FadeLogic
    lea                cpPaletteFin,a0
    bsr                PaletteToCopper

    tst.w              PaletteStatus(a5)
    bne                .exit
    addq.b             #1,GameSubStatus(a5)
.exit
    rts

; ---------------------------------------------------------------------------
; fade etc.

EndingLogicWait:
    subq.b             #1,WaitCounter(a5)
    bne                .exit
    addq.b             #1,GameSubStatus(a5)
.exit
    rts

; ---------------------------------------------------------------------------
; fade etc.

EndingLogic9:
    bsr                ScreenClear
    WAITBLIT
    lea                MenuPal,a0
    move.w             #SCREEN_COLORS,d0
    bsr                LoadPalette

    clr.w              MapScrollOffset(a5)
    clr.b              DisableCopper(a5)
    st                 DoubleBuffer(a5)
    ;lea                TextTest,a0
    ;bsr                TextPlotMain

    bsr                CreditsInit

    addq.b             #1,GameSubStatus(a5)
    rts

; ---------------------------------------------------------------------------
; scroller

EndingLogic10:
    bsr                CreditsRun
    btst               #4,ControlsTrigger(a5)
    beq                .noskip

    lea                BlackPal,a0
    move.w             #SCREEN_COLORS,d0
    bsr                FadeInit

    move.b             #1,ModFadeStatus(a5)
    move.b             #2,ModFadeWait(a5)

    addq.b             #1,GameSubStatus(a5)

.noskip
    rts

; ---------------------------------------------------------------------------
; scroller fade

EndingLogic11:
    bsr                CreditsRun
    btst               #1,TickCounter(a5)
    beq                .skipfade
    bsr                FadeLogic
.skipfade

    tst.b              _mt_Enable
    bne                .exit

    addq.b             #1,GameSubStatus(a5)
.exit
    rts


EndingLogicExit:
    bsr                BobClear
    bsr                BlitQueueReset

    clr.b              DisableCopper(a5)
    move.b             #$d0,WaitCounter(a5)
    clr.b              GameSubStatus(a5)
    clr.b              LevelInitFlag(a5)
    bsr                ShowHudScreen
    bra                SetStatusInGame                         ; jump back into the game
    

