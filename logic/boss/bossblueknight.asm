;----------------------------------------------------------------------------
;
; boss 7 (blue knight)
;
;----------------------------------------------------------------------------

    include     "common.asm"

BossKnightsLogic:                                 
    moveq       #0,d0
    move.b      BossStatus(a5),d0
    bne         .run
    rts
.run
    subq.b      #1,d0
    JMPINDEX    d0

BossKnightsIndex:   
    dc.w        BossKnightsLoad-BossKnightsIndex           
    dc.w        BossKnightsSetup-BossKnightsIndex     
    dc.w        BossKnightsAttack-BossKnightsIndex    
    dc.w        BossDeathFlash-BossKnightsIndex     
    dc.w        BossDeathFlash-BossKnightsIndex     
    dc.w        BossFireDeath1-BossKnightsIndex     
    dc.w        BossFireDeath2-BossKnightsIndex     
    dc.w        Boss1Dummy-BossKnightsIndex   


BossKnightsLoad:
    bsr         BossClearParams

    moveq       #0,d0
    move.b      BossId(a5),d0
    add.w       d0,d0
    add.w       d0,d0
    lea         BossStartPos,a0
    add.l       d0,a0
    move.w      (a0)+,BossPosY(a5)
    move.w      (a0)+,BossPosX(a5)

    bsr         BobAllocate
    move.l      a4,BossBobSlotPtr(a5)

    moveq       #0,d0
    move.b      BossPosY(a5),d0
    move.w      d0,Bob_Y(a4)
    move.b      BossPosX(a5),d0
    move.w      d0,Bob_X(a4)

    move.l      BossBobPtrs(a5),a0
    BOBSET      a0,a4

    ; 2nd bob for big knight and sumo attack (leave it hidden)
    bsr         BobAllocate
    move.l      a4,BossBobSlotPtr2(a5)

    BOBSET      a0,a4
    moveq       #0,d0
    move.b      BossPosY(a5),d0
    add.b       #$8,d0
    move.w      d0,Bob_Y(a4)
    move.b      BossPosX(a5),d0
    add.b       #$8,d0
    move.w      d0,Bob_X(a4)


    ; shadow bob slot
    bsr         BobAllocate
    move.l      a4,BossBobShadowSlotPtr(a5)

    moveq       #0,d0
    move.b      BossPosY(a5),d0
    move.w      d0,Bob_Y(a4)
    move.b      BossPosX(a5),d0
    move.w      d0,Bob_X(a4)

    bsr         LoadBossHealth

    move.b      #120,BossTimer(a5)

    addq.b      #1,BossStatus(a5)
    move.b      #1,BossIsSafe(a5)

    lea         BossEnemy1(a5),a2
    bsr         EnemyClear

    rts

BossKnightsSetup:                              
    bsr         SetHealthBar

    move.l      BossBobSlotPtr(a5),a4
    st          Bob_Hide(a4)
    move.l      BossBobShadowSlotPtr(a5),a4
    st          Bob_Hide(a4)
    
    subq.b      #1,BossTimer(a5)
    bne         .skip

    bsr         BossSetMoveSpeed

    clr.b       BossIsSafe(a5)
    addq.b      #1,BossStatus(a5)
.skip
    rts



BossKnightsAttack:
    lea         BobMatrix(a5),a4
    lea         BossEnemy1(a5),a2

    cmp.b       #$e,GameFrame(a5)
    bne         .skipboss

    tst.b       ENEMY_Status(a2)
    beq         BossKnightsBossSetActive
                                    
.skipboss
    bsr         WhiteKnightLogic

    lea         EnemyList(a5),a2
    moveq       #5-1,d7
                                     
.loop
    lea         KnightSpawnTimers,a0
    move.b      (a0,d7.w),d0

    btst        #0,TickCounter(a5)
    beq         .skipadd

    add.b       #1,ENEMY_FrameCount(a2)
    move.b      ENEMY_FrameCount(a2),d2
    cmp.b       ENEMY_FrameCount(a2),d0
    bne         .skipadd

    tst.b       ENEMY_Status(a2)
    bne         .skipadd

    bsr         BlueKnightSetActive
    move.b      #9,ENEMY_Id(a2)
                                    
.skipadd
    tst.b       ENEMY_Status(a2)
    beq         .skiprun
    bsr         BlueKnightLogicBoss
    bsr         EnemyPlayerShotLogic
    bsr         EnemyCollisionLogic
.skiprun
    lea         ENEMY_Sizeof(a2),a2
    dbra        d7,.loop

    lea         BossEnemy1(a5),a2
    move.b      ENEMY_PosY(a2),BossPosY(a5)
    move.b      ENEMY_PosX(a2),BossPosX(a5)
    bsr         PlayerShotBossLogic
    tst.b       BossDeathFlag(a5)
    bne         .killboss

    lea         BossEnemy1(a5),a2
    cmp.b       #2,ENEMY_Status(a2)
    bne         .skipshot
    move.b      GameFrame(a5),d0
    and.b       #$1f,d0
    bne         .skipshot
    moveq       #1,d0                                    ; arrow
    bsr         AddEnemyShot
.skipshot
    rts

; ---------------------------------------------------------------------------


.killboss
    lea         BossEnemy1(a5),a2
    moveq       #0,d0
    moveq       #0,d1
    move.b      ENEMY_PosY(a2),d0
    move.b      ENEMY_PosX(a2),d1
    sub.b       #$10,d0                                  ; adjust position for flames
    sub.b       #$10,d1
    move.l      BossBobSlotPtr(a5),a4
    move.b      d0,Bob_Y(a4)
    move.b      d1,Bob_X(a4)

    PUSHMOST
    bsr         KillAllEnemy
    POPMOST
    
    bra         KillBoss

BossKnightsBossSetActive:
    lea         BossBobPtrs(a5),a1
    move.l      a1,ENEMY_BobPtr(a2)
    bra         BossKnightCreate

BlueKnightSetActive:
    move.l      EnemyBobLookup+(9*4)(a5),a1
    move.l      a1,ENEMY_BobPtr(a2)
    bsr         EnemyClear

BossKnightCreate:
    move.b      #3,ENEMY_HitPoints(a2)
    move.b      #1,ENEMY_Status(a2)
    clr.w       ENEMY_PosY(a2)
    move.w      #$7e00,ENEMY_PosX(a2)
    move.w      #$100,ENEMY_SpeedY(a2)
    clr.w       ENEMY_SpeedX(a2)
    move.w      #-1,ENEMY_ShadowSlot(a2)
    move.w      #-1,ENEMY_BobSlot2(a2)

    RANDOM
    move.b      d0,ENEMY_Random(a2)

    PUSH        a4
    bsr         BobAllocate
    move.w      d0,ENEMY_BobSlot(a2)



    moveq       #0,d0
    move.b      ENEMY_PosY(a2),d0
    move.w      d0,Bob_Y(a4)
    move.b      ENEMY_PosX(a2),d0
    move.w      d0,Bob_X(a4)
    move.w      #$16,Bob_TopMargin(a4)

    sf          Bob_Hide(a4)
    POP         a4
    rts

; ---------------------------------------------------------------------------
;
; white knight boss logic
;
; ---------------------------------------------------------------------------

BlueKnightLogicBoss:
    lea         BobMatrix(a5),a4
    moveq       #0,d0
    move.b      ENEMY_Status(a2),d0
    subq.b      #1,d0
    bpl         .doit
    rts
.doit
    JMPINDEX    d0

BlueKnightIndex2:
    dc.w        BlueKnightApproach-BlueKnightIndex2
    dc.w        BlueKnightRun-BlueKnightIndex2
    dc.w        BlueKnightRun-BlueKnightIndex2
    dc.w        EnemyFireDeath-BlueKnightIndex2          ;EnemyFireDeath1-BlueKnightLogicList
    dc.w        EnemyBonusWait-BlueKnightIndex2          ;EnemyBonusWait-BlueKnightLogicList
BlueKnightApproach:                           
    ANIMATE2
    bsr         MoveEnemy

    cmp.b       #$20,ENEMY_PosY(a2)
    bcs         .exit

    bsr         BlueKnightAttack

    addq.b      #1,ENEMY_Status(a2)
.exit  
    rts

BlueKnightRun:                          
    ANIMATE2
    bsr         MoveEnemy
    move.b      GameFrame(a5),d0
    add.b       ENEMY_Random(a2),d0
    and.b       #$3f,d0
    bne         .skipshot
    bsr         ShootAtPlayer
.skipshot
    rts

BlueKnightAttack:                              
    bsr         CalcAngleToPlayer
    bsr         CalcSpeed

    asl.w       #1,d1
    asl.w       #1,d2

    move.w      d1,ENEMY_SpeedY(a2)
    move.w      d2,ENEMY_SpeedX(a2)  
    rts


; ---------------------------------------------------------------------------
;
; white knight boss logic
;
; ---------------------------------------------------------------------------

WhiteKnightLogic:
    lea         BobMatrix(a5),a4
    moveq       #0,d0
    move.b      ENEMY_Status(a2),d0
    subq.b      #1,d0
    bpl         .doit
    rts
.doit
    JMPINDEX    d0

WhiteKnightIndex:
    dc.w        WhiteKnightApproach-WhiteKnightIndex
    dc.w        WhiteKnightWaitShoot-WhiteKnightIndex


WhiteKnightApproach:                           
    ANIMATE2
    bsr         MoveEnemy

    cmp.b       #$20,ENEMY_PosY(a2)
    bcs         .exit

    move.b      #1,ENEMY_WaitCounter(a2)
    addq.b      #1,ENEMY_Status(a2)
.exit  
    rts
; ---------------------------------------------------------------------------

WhiteKnightWaitShoot:                          
    ANIMATE2
    bsr         MoveEnemy

    cmp.b       #$38,ENEMY_PosY(a2)
    bcs         WhiteKnightShoot

    subq.b      #1,ENEMY_WaitCounter(a2)
    bne         WhiteKnightExit
    
WhiteKnightShoot:                              
    bsr         CalcAngleToPlayer
    bsr         CalcSpeed

    move.b      BossHitCount(a5),d3
    moveq       #1,d0                                    ; multiplier
    cmp.b       #$14,d3
    bcs         .setspeed
    addq.b      #1,d0
    cmp.b       #$28,d3
    bcs         .setspeed
    addq.b      #1,d0

.setspeed
    muls        d0,d1
    muls        d0,d2
    move.w      d1,ENEMY_SpeedY(a2)
    move.w      d2,ENEMY_SpeedX(a2)  
    move.b      #$60,ENEMY_WaitCounter(a2)
WhiteKnightExit:
    rts
    
