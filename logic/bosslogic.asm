;----------------------------------------------------------------------------
;
; boss logic
;
;----------------------------------------------------------------------------

    include     "common.asm"

BossInitLogic:
    cmp.b       #PLAYERMODE_DEAD,PlayerStatus(a5)
    bcc         .exit

    tst.b       BossDeadFlag(a5)
    beq         .notdead


    move.b      #PLAYERMODE_BOSSBEAT,PlayerStatus(a5)
    clr.b       PlayerStatus+PLAYER_Timer(a5)

.notdead
    cmp.b       #$d8,LevelPosition(a5)                 
    bne         .exit

    tst.b       BossStatus(a5)
    bne         .exit
    move.b      #1,BossStatus(a5)
    clr.b       BossBarLoad(a5)                          ; clear health bar
    
    bsr         KillEnemyShots
    bra         SetBossMusic
.exit
    rts

;----------------------------------------------------------------------------
;
; boss logic jump
;
;----------------------------------------------------------------------------

BossLogic:   
    move.b      BossId(a5),d0
    and.w       #$7,d0
    JMPINDEX    d0

BossLogicList:
    dc.w        Boss1Logic-BossLogicList                 ; TileBossLogic
    dc.w        SkullBossLogic-BossLogicList             ; SkullBossLogic
    dc.w        BatBossLogic-BossLogicList               ; BatBossLogic
    dc.w        CloakBossLogic-BossLogicList             ; CloakBossLogic
    dc.w        BigKnightLogic-BossLogicList             ; TileBossLogic
    dc.w        SumoLogic-BossLogicList                  ; TileBossLogic
    dc.w        BossKnightsLogic-BossLogicList           ; BlueKnightBoss
    dc.w        EyesBossLogic-BossLogicList              ; EyesBossLogic

BossClearParams:
    clr.b       BossHitCount(a5)

    lea         BossHitCountList,a0
    moveq       #0,d0
    move.b      BossId(a5),d0
    move.b      (a0,d0.w),BossHitMax(a5)

    clr.b       BossDeathFlag(a5)
    rts

BossAnimate2:
    moveq       #0,d0 
    btst        #4,GameFrame(a5)
    beq         .otherframe
    addq.b      #1,d0
.otherframe
    move.l      BossBobSlotPtr(a5),a4

    lea         BossBobPtrs(a5),a0
    add.w       d0,d0
    add.w       d0,d0
    move.l      (a0,d0.w),a0
    BOBSET      a0,a4

    cmp.b       #4,BossId(a5)
    bne         .notknight

    move.l      BossBobSlotPtr2(a5),a4
    lea         BossBobPtrs(a5),a0
    move.l      8(a0),a0
    BOBSET      a0,a4
.notknight
    rts


BossAnimateQuick:
    moveq       #0,d0 
    btst        #2,GameFrame(a5)
    beq         .otherframe
    addq.b      #1,d0
.otherframe
    move.l      BossBobSlotPtr(a5),a4

    lea         BossBobPtrs(a5),a0
    add.w       d0,d0
    add.w       d0,d0
    move.l      (a0,d0.w),a0
    BOBSET      a0,a4

    cmp.b       #4,BossId(a5)
    bne         .notknight

    move.l      BossBobSlotPtr2(a5),a4
    lea         BossBobPtrs(a5),a0
    move.l      8(a0),a0
    BOBSET      a0,a4
.notknight
    rts

DecBossTimerSetSpeed:                      
    subq.b      #1,BossTimer(a5)
    bne         .quit
    bra         BossSetMoveSpeed
.quit 
    rts                                                 
;----------------------------------------------------------------------------
;
; sets the tile boss move speed
; there are three different speeds depending on
; distance to the player
;
;----------------------------------------------------------------------------

BossSetMoveSpeed:
    move.b      PlayerStatus+PLAYER_PosX(a5),d1
    and.w       #$fc,d1


    move.b      BossPosX(a5),d0
    and.w       #$fc,d0
    add.b       #$c,d0
    
    move.b      d1,BossDestX(a5)

    moveq       #0,d2                                    ; speed x
    cmp.b       d1,d0
    beq         .setspeed
    move.w      #$100,d2                                 ; right
    cmp.b       d0,d1
    bcc         .setspeed
    move.w      #-$100,d2                                ; left 

.setspeed
    moveq       #0,d0
    move.b      BossId(a5),d0
    beq         .setspeed2
    
    tst.w       d2
    bne         .setspeed2
    move.w      #$100,d2

.setspeed2
    move.w      d2,BossSpeedX(a5)

    mulu        #3,d0
    asr.w       #8,d2
    add.w       d2,d0

    lea         BossOffsets+1(pc),a0
    move.b      (a0,d0.w),d0
    add.b       d1,d0
    move.b      d0,BossDestXOffset(a5)
    rts

BossOffsets:
    dc.b        0, 0, 0                           
    dc.b        0, 0, 0                           
    dc.b        0, 0, 0                           
    dc.b        0, 0, 0                           
    dc.b        -$20, $10, $20
    dc.b        -$30, $10, $30
    dc.b        0, 0, 0                           
    dc.b        0, 0, 0                           
    even


    incdir      "logic/boss"
    include     "bosswitch.asm" 
    include     "bossskull.asm"
    include     "bossbat.asm"
    include     "bosscloak.asm"
    include     "bossbigknight.asm"
    include     "bosssumo.asm"
    include     "bossblueknight.asm"
    include     "bosseyes.asm"
    
    include     "bossclouds.asm"