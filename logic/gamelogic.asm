

;----------------------------------------------------------------------------
;
; main game loop logic
;
;----------------------------------------------------------------------------

    include    "common.asm"

GameLogic:
    bsr        MainGameLogic

    moveq      #8,d0
    tst.b      AdvanceStageFlag(a5)
    bne        SetGameStatus

    tst.b      GameRunning(a5)
    bne        .running
    bra        NextGameStatusWait20

.running
    rts

;----------------------------------------------------------------------------
;
; main game logic
;
;----------------------------------------------------------------------------


MainGameLogic:
    btst       #6,ControlConfig(a5)
    beq        MainGameLogic2


    btst       #0,FKeysTrigger(a5)
    beq        MainGameLogic2


    move.b     #1,PauseFlag(a5)                     ; -- activate pause
    bsr        MusicPause

    moveq      #$3a,d0
    bsr        SfxPlay

MainGameLogic2:
    cmp.b      #PLAYERMODE_DEAD,PlayerStatus(a5)    ; player alive?
    bcc        MainGameLogic3 

    tst.b      FreezeFlag(a5)
    beq        MainGameLogic3

    clr.b      FreezeFlag(a5)

MainGameLogic3:
    addq.b     #1,GameFrame(a5)

    tst.b      FreezeStatus(a5)
    bne        FreezeLogic

    cmp.b      #PLAYERMODE_DEAD,PlayerStatus(a5)
    bcc        .skipscroll
    bsr        ScrollLogic                          ; move the map on by one line
.skipscroll

MainGameLogic4:                                   ; ...
    tst.b      BossStatus(a5)
    beq        .skipboss
    bsr        BossLogic
.skipboss
    bsr        PlayerModeLogic
    bsr        BossInitLogic
    bsr        ProcessQBlocks
    bsr        EnemyLogic

    bsr        BobClean                     
    bsr        BobSort                              ; sort sprites in Y order         
    bsr        BobDraw

    bsr        EnemyShotMove
    bsr        UpdatePlayerShots
    bsr        PowerUpLogic
    rts

; ---------------------------------------------------------------------------
;
; freeze logic
;
; ---------------------------------------------------------------------------

FreezeLogic:
    move.b     FreezeStatus(a5),d0
    cmp.b      #1,d0
    bne        .skipphase1
    bsr        ScrollOneOff
    bsr        MusicPause
    addq.b     #1,FreezeStatus(a5)

.skipphase1

    bsr        FreezeTimerRender

    subq.b     #1,FreezeTimerLo(a5)
    bcc        .continue
    move.b     #59,FreezeTimerLo(a5)               
    subq.b     #1,FreezeTimerHi(a5) 
    bcc        .continue

    clr.b      FreezeStatus(a5)
    bsr        FreezeTimerRemove
    bsr        MusicPlay
.exit
    rts

.continue
    tst.b      FreezeTimerHi(a5)
    beq        .emergencysfx

    moveq      #$30,d0
    cmp.b      #59,FreezeTimerLo(a5)
    beq        .playsfx
    addq.b     #1,d0
    cmp.b      #30,FreezeTimerLo(a5)
    beq        .playsfx
    bra        MainGameLogic4

.emergencysfx
    moveq      #$32,d0
    moveq      #0,d1
    move.b     FreezeTimerLo(a5),d1
    addq.b     #1,d1
    divu       #20,d1
    swap       d1
    tst.w      d1
    bne        .skipalarm

.playsfx
    bsr        SfxPlay
.skipalarm
    bra        MainGameLogic4
