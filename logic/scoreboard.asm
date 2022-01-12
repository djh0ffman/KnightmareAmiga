;----------------------------------------------------------------------------
;
;  score board
;
;----------------------------------------------------------------------------


    include     "common.asm"

ScoreBoardInit:
    bsr         LoadGameData
    rts

    lea         DefaultScores,a0
    lea         ScoreBoard(a5),a1
    moveq       #TOTAL_SCORES-1,d7
.loop
    move.l      (a0)+,(a1)+
    move.l      (a0)+,(a1)+
    dbra        d7,.loop
    rts

;----------------------------------------------------------------------------
;
;  tries to add the current score to the board
;
; d7 returns -1 if not found
; a0 = score board position
;
;----------------------------------------------------------------------------

ScoreBoardWhere:
    lea         ScoreBoard(a5),a0
    move.l      Score(a5),d0
    moveq       #TOTAL_SCORES-1,d7
.loop
    cmp.l       4(a0),d0
    bcc         .found
    addq.l      #8,a0
    dbra        d7,.loop
.found
    rts

SCORE_POS_Y  = 3
SCORE_VAL_X  = 8
SCORE_NAME_X = 19

;----------------------------------------------------------------------------
;
;  tries to add the current score to the board
;
; d7 returns -1 if not found
; a0 = score board position
;
;----------------------------------------------------------------------------

ScoreBoardAdd:
    addq.b      #1,GameSubStatus(a5)
    moveq       #0,d0
    moveq       #MOD_HISCORE,d1
    bsr         MusicSet

    clr.b       ScoreChar(a5)
    clr.b       ScorePos(a5)
    clr.b       ScorePosY(a5)
    move.b      #SCORE_NAME_X,ScorePosX(a5)

    bsr         ScoreBoardWhere
    tst.w       d7
    bmi         .exit  

    moveq       #TOTAL_SCORES-1,d0
    sub.b       d7,d0
    lsl.b       #1,d0
    add.b       #SCORE_POS_Y,d0    

    move.b      d0,ScorePosY(a5)

    subq.b      #1,d7
    bmi         .addscore

    lea         ScoreBoard+(9*8)(a5),a1
    lea         ScoreBoard+(10*8)(a5),a2

.moveloop
    move.l      -(a1),-(a2)
    move.l      -(a1),-(a2)
    dbra        d7,.moveloop

.addscore
    move.l      a0,ScorePtr(a5)
    clr.l       (a0)
    move.l      Score(a5),4(a0)

.exit
    rts

;----------------------------------------------------------------------------
;
; logic for enter a score
;
;----------------------------------------------------------------------------

ScoreBoardEnter:
    JMPINDEX    d1

ScoreBoardEnterLogic:
    dc.w        ScoreBoardAdd-ScoreBoardEnterLogic
    dc.w        ScoreBoardShow-ScoreBoardEnterLogic
    dc.w        ScoreBoardSelectChar-ScoreBoardEnterLogic
    dc.w        ScoreBoardDone-ScoreBoardEnterLogic

ScoreBoardDone:
    subq.b      #1,WaitCounter(a5)
    bne         .notdone

    moveq       #0,d0
    moveq       #MOD_GAMEOVER,d1
    bsr         MusicSet

    moveq       #7,d0
    bra         SetGameStatus

.notdone
    rts

;----------------------------------------------------------------------------
;
; draw the score board
;
;----------------------------------------------------------------------------

ScoreBoardDisplay:
    tst.b       d1
    beq         ScoreBoardDisplayInit

    subq.b      #1,d1
    beq         .checkexit

    ; fade
    bsr         FadeLogic
    bsr         LoadCopperScroll
        
    tst.b       ModFadeStatus(a5)
    bne         .exit

    jsr         _mt_end
    bra         ResetGameStatus
.exit
    rts

.checkexit
    btst        #4,ControlsTrigger(a5)
    beq         .noexit

    lea         BlackPal,a0
    move.w      #SCREEN_COLORS,d0
    bsr         FadeInit

    addq.b      #1,GameSubStatus(a5)

    addq.b      #1,ModFadeStatus(a5)
    move.b      #1,ModFadeWait(a5)
    move.b      #64,ModFadeVolume(a5)
.noexit
    rts




ScoreBoardDisplayInit:
    moveq       #0,d0
    moveq       #MOD_HISCORE,d1
    bsr         MusicSetHard

ScoreBoardShow:
    bsr         HideGameScreen
    bsr         wait_raster_HUD
    bsr         ScreenClear
    WAITBLIT
    sf          DoubleBuffer(a5)
    lea         TextScoreBoard,a0
    bsr         TextPlotMain

    ; -- draw names
    moveq       #SCORE_POS_Y,d0                              ; y
    moveq       #SCORE_NAME_X,d1                             ; x
    moveq       #TOTAL_SCORES-1,d7
    lea         ScoreBoard(a5),a0

.nameloop
    bsr         ScoreBoardDrawName
    dbra        d7,.nameloop

    ; -- draw scores
    moveq       #SCORE_POS_Y,d4                              ; y
    moveq       #SCORE_VAL_X,d5                              ; x
    moveq       #TOTAL_SCORES-1,d7
    lea         ScoreBoard(a5),a4

.scoreloop
    bsr         ScoreBoardDrawScore
    dbra        d7,.scoreloop

    bsr         ShowGameScreen
    addq.b      #1,GameSubStatus(a5)
    rts

ScoreBoardDrawScore:
    move.l      4(a4),d0

    bsr         Binary2Decimal

    moveq       #8,d2
    sub.b       d0,d2

    lea         TextStat,a1
    move.l      a1,a2
.spaceloop
    move.b      #" ",(a1)+
    subq.b      #1,d2
    bne         .spaceloop
.charloop
    move.b      (a0)+,(a1)+
    subq.b      #1,d0
    bne         .charloop

    clr.b       (a1)

    move.l      a2,a0

    move.w      d4,d0
    move.w      d5,d1

    bsr         TextPlotMain1
    
    addq.l      #8,a4
    addq.w      #2,d4

    rts

    ; a0 = name
ScoreBoardDrawName:
    PUSHM       d0/d1/a0
    bsr         TextPlotMain1
    POPM        d0/d1/a0
    addq.b      #2,d0
    addq.l      #8,a0
    rts



;----------------------------------------------------------------------------
;
; select char
;
;----------------------------------------------------------------------------

ScoreBoardSelectChar:
    addq.b      #1,ScoreTimer(a5)

    move.b      ControlsTrigger(a5),d0
    bne         .controlcheck

    move.b      ControlsHold(a5),d0
    beq         .nohold

    addq.b      #1,ScoreHold(a5)
    cmp.b       #10,ScoreHold(a5)
    bcs         .exit
    move.b      ScoreHold(a5),d1
    and.b       #3,d1
    beq         .controlcheck
.exit
    rts

.nohold
    clr.b       ScoreHold(a5)
    move.b      ControlsTrigger(a5),d0

.controlcheck
    btst        #2,d0
    bne         .left

    btst        #3,d0
    bne         .right

    btst        #4,d0
    bne         .select

    bra         ScoreBoardDoChar

.select
    lea         ScoreChars,a0
    moveq       #0,d2
    move.b      ScoreChar(a5),d2
    move.b      (a0,d2.w),d2

    move.l      ScorePtr(a5),a0
    moveq       #0,d0
    move.b      ScorePos(a5),d0
    add.l       d0,a0

    move.b      d2,(a0)
    clr.b       ScoreTimer(a5)
    bsr         ScoreBoardDoChar

    moveq       #$10,d0
    bsr         SfxPlay

    addq.b      #1,ScorePos(a5)
    cmp.b       #3,ScorePos(a5)
    bne         .notyet
    move.b      #40,WaitCounter(a5)
    addq.b      #1,GameSubStatus(a5)
    bsr         SaveGameData
.notyet
    rts
    

.right
    addq.b      #1,ScoreChar(a5)
    cmp.b       #SCORE_CHAR_COUNT,ScoreChar(a5)
    bcs         .plot
    clr.b       ScoreChar(a5)
    bra         .plot
.left
    subq.b      #1,ScoreChar(a5)
    bpl         .plot
    move.b      #SCORE_CHAR_COUNT-1,ScoreChar(a5)
.plot
    moveq       #$12,d0
    bsr         SfxPlay
    clr.b       ScoreTimer(a5)
    bra         ScoreBoardDoChar



ScoreBoardDoChar:
    btst        #4,ScoreTimer(a5)  
    beq         ScoreBoardDrawChar
    bra         ScoreBoardClearChar

ScoreBoardDrawChar:
    lea         ScoreChars,a0
    moveq       #0,d2
    move.b      ScoreChar(a5),d2
    move.b      (a0,d2.w),d2
    bra         ScoreBoardPlotChar

ScoreBoardClearChar:
    move.b      #" ",d2

ScoreBoardPlotChar:
    moveq       #SCORE_NAME_X,d1
    add.b       ScorePos(a5),d1
    moveq       #0,d0
    move.b      ScorePosY(a5),d0
    bsr         CharPlotMain
    rts


;----------------------------------------------------------------------------
;
; load / save score board
;
;----------------------------------------------------------------------------

LoadGameData:    
    PUSHM       d1-d6,-(sp)
    moveq       #0,d0                                        ; drive 0
    move.w      #SAVE_POS,d1                                 ; start sec
    move.w      #SAVE_SIZE_SECTOR,d2                         ; save size
    move.w      #$8000,d3                                    ; mode (read & motor off)
    moveq       #0,d4
    lea         ScoreTemp,a0
    lea         TrackBuffer,a1
LoadGameDataPtr:    
    jsr         diskio
    tst.b       d0
    bne         FailedLoad
    
    lea         ScoreBoard(a5),a1

    cmp.l       #SAVE_IDENTIFIER,(a0)+
    bne         FailedLoad

    move.w      #SCORE_SIZE-1,d7
    lea         ScoreBoard(a5),a1
.copyloop
    move.b      (a0)+,(a1)+
    dbra        d7,.copyloop
    moveq       #0,d0

.exit
    POPM        d1-d6,-(sp)
    rts


FailedLoad:
    lea         DefaultScores,a0
    move.w      #SCORE_SIZE-1,d7
    lea         ScoreBoard(a5),a1
.copyloop
    move.b      (a0)+,(a1)+
    dbra        d7,.copyloop
    moveq       #0,d0
    POPM        d1-d6,-(sp)
    rts


SaveGameData:    
    PUSHM       d1-d6,-(sp)

    lea         ScoreBoard(a5),a0
    lea         ScoreTemp,a1
    move.l      #SAVE_IDENTIFIER,(a1)+

    move.w      #SCORE_SIZE-1,d7
.copyloop
    move.b      (a0)+,(a1)+
    dbra        d7,.copyloop

    moveq       #0,d0                                        ; drive 0
    move.w      #SAVE_POS,d1                                 ; start sec
    move.w      #SAVE_SIZE_SECTOR,d2                         ; save size
    move.w      #$8001,d3                                    ; mode (write & motor off)
    moveq       #0,d4
    lea         ScoreTemp,a0
    lea         TrackBuffer,a1
SaveGameDataPtr:    
    jsr         diskio
    POPM        d1-d6,-(sp)
    rts
