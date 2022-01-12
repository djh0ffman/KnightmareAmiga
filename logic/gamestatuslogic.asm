

;----------------------------------------------------------------------------
;
; game status logic
;
;----------------------------------------------------------------------------

    include     "common.asm"

GameStatusLogic:    
    addq.b      #1,TickCounter(a5)

    moveq       #0,d0
    move.b      GameStatus(a5),d0
    cmp.b       #3,d0
    bcc         GameStatusRunning

    bsr         GameStatusRunning
    bra         CheckMenuJump

GameStatusRunning:  
    moveq       #0,d1
    move.b      GameSubStatus(a5),d1
    JMPINDEX    d0

GameStatusJumpIndex:
    dc.w        KonamiLogoLogic-GameStatusJumpIndex      ; 0 -- KonamiLogoLogic
    dc.w        WaitMenu-GameStatusJumpIndex             ; 1 -- WaitMenu
    dc.w        AttractMode-GameStatusJumpIndex          ; 2 -- AttractMode
    dc.w        InitGame-GameStatusJumpIndex             ; 3 -- InitGame
    dc.w        PrepLevel-GameStatusJumpIndex            ; 4 -- PrepLevel                ; sub status not set, setup screen and hud
    dc.w        GameLogic-GameStatusJumpIndex            ; 5 -- GameLogic
    dc.w        CheckLives-GameStatusJumpIndex           ; 6 -- CheckLives
    dc.w        GameOverLogic-GameStatusJumpIndex        ; 7 -- GameOverLogic
    dc.w        AdvanceStageLogic-GameStatusJumpIndex    ; 8 -- AdvanceStageLogic
    dc.w        Ending-GameStatusJumpIndex               ; 9 -- Ending
    dc.w        SoundMenuLogic-GameStatusJumpIndex       ; 10 -- my lovely sound menu
    dc.w        ShopLogic-GameStatusJumpIndex            ; 11 -- penguin shop
    dc.w        ScoreBoardEnter-GameStatusJumpIndex      ; 12 -- enter a score
    dc.w        ScoreBoardDisplay-GameStatusJumpIndex    ; 13 -- show the score board

GameStatusNextDummy:
    addq.b      #1,GameStatus(a5)
    rts

; ---------------------------------------------------------------------------
;
; wait in menu
;
; ---------------------------------------------------------------------------

CheckMenuJump:      
    bsr         ReadPads                                 ; read joystick / pads
    bsr         ReadControls
    lea         Controls2Hold(a5),a3
    bsr         StoreControls
    move.b      (a3),d0                                  ; controls trigger
    beq         .exit

    cmp.b       #1,GameStatus(a5)
    bne         DrawMenuNow

.exit
    rts


DrawMenuNow:
    lea         BlackPal,a0
    move.w      #SCREEN_COLORS,d0
    bsr         LoadPalette
    bsr         LoadCopperScroll
    bsr         LoadCopperScroll
    bsr         MenuInit
    move.b      #1,GameStatus(a5)
    clr.b       GameSubStatus(a5)
    clr.b       WaitCounter(a5)
    rts

; ---------------------------------------------------------------------------
;
; wait in menu
;
; ---------------------------------------------------------------------------

WaitMenu:                                        
    bra         TitleRenderTest


; ---------------------------------------------------------------------------
;
; konami logo logic
;
; ---------------------------------------------------------------------------

KonamiLogoInit:
    clr.w       MapScrollOffset(a5)
    bsr         ScreenClear
    bsr         HideHudScreen
    sf          DoubleBuffer(a5)
    move.w      #210,LogoPos(a5)
    lea         KonamiLogoPal,a0
    move.w      #SCREEN_COLORS,d0
    bsr         LoadPalette
    rts

KonamiLogoLogic:      
    DJNZ        d1,KonamiLogoWait

    bsr         KonamiClear
    cmp.w       #80,LogoPos(a5)
    bcs         .done
    sub.w       #4,LogoPos(a5)
    bsr         KonamiBlit
    rts

.done
    bsr         KonamiBlitFinal
    moveq       #0,d0
    bra         NextGameSubStatusWait

KonamiLogoWait:     
    DJNZ        d1,KonamiLogoFade

    subq.b      #1,WaitCounter(a5)
    bne         .exit

    lea         BlackPal,a0
    move.w      #SCREEN_COLORS,d0
    bsr         FadeInit

    moveq       #0,d0
    bra         NextGameSubStatusWait
.exit
    rts


KonamiLogoFade:
    DJNZ        d1,RebootGame
    bsr         FadeLogic
    tst.w       PaletteStatus(a5)
    bne         .exit

    bsr         MenuInit

    moveq       #0,d0
    bra         NextGameStatusWait
.exit
    rts

; ---------------------------------------------------------------------------

RebootGame:  
    bsr         KonamiLogoInit
    bra         NextGameSubStatus

; ---------------------------------------------------------------------------
AttractModeExit:
    rts

AttractMode:     
    DJNZ        d1,AttractModeInit
    bsr         DemoPlayLogic                            ; process controls from the demo play data
    bsr         MainGameLogic

    tst.b       GameRunning(a5)
    bne         AttractModeExit

    move.b      Level(a5),d0                             ; move to next level for the demo
    addq.b      #1,d0
    and.b       #7,d0
    move.b      d0,Level(a5)


ResetGameStatus:    
    moveq       #0,d0

SetGameStatus:      
    move.b      d0,GameStatus(a5)
    move.b      #0,WaitCounter(a5)
    clr.b       GameSubStatus(a5)
    rts

; ---------------------------------------------------------------------------

AttractModeInit:    
    bsr         HideGameScreen
    bsr         ScreenClear
    bsr         UnpackTiles

    clr.l       Score(a5)
    clr.b       Lives(a5)
    clr.b       CheckPoint(a5)
    clr.b       AttackWavePos(a5)
    bsr         StartDemo

    moveq       #$40,d0                                  ; wait for $40 frames

NextGameSubStatusWait: 
    move.b      d0,WaitCounter(a5)

NextGameSubStatus:  
    addq.b      #1,GameSubStatus(a5)
    rts

;----------------------------------------------------------------------------
;
; init game
;
;----------------------------------------------------------------------------

InitGame:                                       
    DJNZ        d1,InitPlayStart
                           
    bsr         ShowHudScreen

    bsr         InitGameVars                             ; clear all game stats? 

NextGameStatusWait20:
    moveq       #$20,d0

NextGameStatusWait: 
    move.b      d0,WaitCounter(a5)

NextGameStatus:     
    addq.b      #1,GameStatus(a5)

ResetSubStatus:     
    clr.b       GameSubStatus(a5)
    rts

;----------------------------------------------------------------------------
;
; init play start
;
;----------------------------------------------------------------------------

InitPlayStart:      
    moveq       #0,d0
    moveq       #MOD_START,d1
    bsr         MusicSet

    move.b      #$40,WaitCounter(a5)
    addq.b      #1,GameSubStatus(a5)
    rts

;----------------------------------------------------------------------------
;
; init game
;
;----------------------------------------------------------------------------

InitGameVars:
    lea         Score(a5),a0
    move.w      #Variables_SizeOf-Score-1,d7
.clear
    clr.b       (a0)+
    dbra        d7,.clear

    bsr         DirtyHud

    move.b      #DEBUG_STARTLIVES,Lives(a5)
    move.b      #DEBUG_LEVEL+1,Stage(a5)
    move.b      #DEBUG_LEVEL,Level(a5)
    move.b      #$10,ExtraLifeScore(a5)

    bsr         KillEnemyShots

    rts

;----------------------------------------------------------------------------
;
; init main menu
;
;----------------------------------------------------------------------------


MenuInit:    
    bra         MainMenuInit

; ---------------------------------------------------------------------------
;
; prep level, screen etc.
;
; ---------------------------------------------------------------------------

PrepLevel:   
    DJNZ        d1,PrepLevelScreenHud                    ; sub status not set, setup screen and hud

    tst.b       LevelInitFlag(a5)
    bne         PrepLevelWaitCounter                     ; level has already been started, just do a wait

    tst.b       Level(a5)
    bne         .waitmusic

    cmp.b       #4,Stage(a5)
    bcc         PrepLevelWaitCounter

.waitmusic
    tst.b       _mt_Enable
    bne         .exit

    bsr         HideGameScreen
    bsr         PrepLevelRun
.exit
    rts

; ---------------------------------------------------------------------------

PrepLevelWaitCounter:
    subq.b      #1,WaitCounter(a5)
    bne         .exit
    bra         PrepLevelRun
.exit
    rts

PrepLevelRun:
    bsr         InitLevel

    bsr         ShowGameScreen
    move.b      #1,GameRunning(a5)

    bra         NextGameStatus

; ---------------------------------------------------------------------------

PrepLevelScreenHud: 
    bsr         BobClear
    bsr         ScreenClear

    WAITBLIT
    clr.w       MapScrollOffset(a5)
    sf          DoubleBuffer(a5)

    bsr         DrawStageText

    lea         MenuPal,a0                               ; load a palette
    move.w      #SCREEN_COLORS,d0
    bsr         LoadPalette

    move.b      #$40,WaitCounter(a5)

    bra         NextGameSubStatus

CheckLives:  
    tst.b       Lives(a5)
    beq         CheckLivesGameOver

SetStatusInGame:    
    moveq       #4,d0
    bra         SetGameStatus                            ; alive.. keep going!

CheckLivesGameOver:    
    bsr         ScoreBoardWhere
    tst.w       d7
    bpl         .addscoresetup

    moveq       #0,d0
    moveq       #MOD_GAMEOVER,d1
    bsr         MusicSet

    bra         NextGameStatusWait20

.addscoresetup
    moveq       #12,d0
    bra         SetGameStatus


; ---------------------------------------------------------------------------
;
; advance clear - clears the screen
;
; ---------------------------------------------------------------------------

AdvanceStageClearInit:
    clr.b       Shrink(a5)
    sf          DoubleBuffer(a5)
    addq.b      #1,GameSubStatus(a5)
    rts

AdvanceStageClear:
    bsr         ClearHorizontal
    bne         .notyet
    addq.b      #1,GameSubStatus(a5)
.notyet
    rts



; ---------------------------------------------------------------------------
;
; advance stage
;
; ---------------------------------------------------------------------------

AdvanceStageLogic:  
    tst.b       d1
    beq         AdvanceStageClearInit
    subq.b      #1,d1
    beq         AdvanceStageClear

    clr.b       AdvanceStageFlag(a5)
    clr.b       LevelInitFlag(a5)
    clr.b       ShopEntered(a5)

    cmp.b       #4,LevelId2(a5)                          ; weird flag for warps to become active
    bcc         AdvanceStageExtraLife
    move.b      Stage(a5),d0
    cmp.b       LevelId2(a5),d0
    bcs         AdvanceStageExtraLife
    move.b      d0,LevelId2(a5)

AdvanceStageExtraLife:
    addq.b      #1,Stage(a5)

    move.b      Level(a5),d0
    addq.b      #1,d0
    and.b       #7,d0
    move.b      d0,Level(a5)
    bne         SetStatusInGame

    move.b      #1,EnemyShotsActive(a5)
    bra         NextGameStatusWait20



GameOverLogic:      
    DJNZ        d1,GameOverInit

    tst.b       ContinueState(a5)
    beq         .checkstate

    tst.b       _mt_Enable
    bne         .wait

    tst.b       ContinuePos(a5)
    bne         .exitmenu
    
    move.b      #DEBUG_STARTLIVES,Lives(a5)
    clr.l       Score(a5)
    moveq       #4,d0
    bra         SetGameStatus


.checkstate
    move.b      ControlsTrigger(a5),d0
    btst        #4,d0
    beq         .checkupdown

    move.b      #1,ContinueState(a5)    
    bsr         ClearContinueArrow

    lea         TextContinueClear,a0
    tst.b       ContinuePos(a5)
    bne         .nocontinue
    lea         TextGiveUpClear,a0
.nocontinue
    bsr         TextPlotMain
    bra         .wait    

.checkupdown
    and.b       #3,d0
    beq         .wait

    bsr         ClearContinueArrow
    eor.b       #1,ContinuePos(a5)
    bsr         PlotContinueArrow
    bra         .wait

.exitmenu
    and.b       #$bf,ControlConfig(a5)                   ; set control to out of game

    bsr         InitGameVars
    bsr         DirtyHud
    bra         ResetGameStatus
.wait
    rts

GameOverInit:
    bsr         ScreenClear
    bsr         BobClear

    sf          DoubleBuffer(a5)

    clr.w       MapScrollOffset(a5)

    lea         MenuPal,a0                               ; load a palette
    move.w      #SCREEN_COLORS,d0
    bsr         LoadPalette
        
    WAITBLIT
    lea         TextGameOver,a0
    bsr         TextPlotMain

    lea         TextContinue,a0
    bsr         TextPlotMain

    lea         TextGiveUp,a0
    bsr         TextPlotMain
    
    clr.b       ContinuePos(a5)
    clr.b       ContinueState(a5)

    bsr         PlotContinueArrow

    move.b      #$f0,WaitCounter(a5)
    bra         NextGameSubStatus


ClearContinueArrow:
    move.w      #11,d0
    move.w      #8,d1
    move.b      #" ",d2

    tst.b       ContinuePos(a5)
    beq         .top

    addq.w      #2,d0
.top
    bsr         CharPlotMain
    rts


PlotContinueArrow:
    move.w      #11,d0
    move.w      #8,d1
    move.b      #"%",d2

    tst.b       ContinuePos(a5)
    beq         .top

    addq.w      #2,d0
.top
    bsr         CharPlotMain
    rts