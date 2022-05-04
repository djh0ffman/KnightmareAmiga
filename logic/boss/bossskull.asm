;----------------------------------------------------------------------------
;
; boss 2 (skull)
;
;----------------------------------------------------------------------------

    include     "common.asm"


SkullBossLogic:                                
    moveq       #0,d0
    move.b      BossStatus(a5),d0
    bne         .run
    rts
.run
    subq.b      #1,d0
    JMPINDEX    d0

SkullBossIndex:
    dc.w        BossLoad-SkullBossIndex
    dc.w        BossSkullSetup-SkullBossIndex
    dc.w        SkullBossInit-SkullBossIndex
    dc.w        SkullBossMoveShoot-SkullBossIndex
    dc.w        BossDeathFlash-SkullBossIndex               ; start of default
    dc.w        BossFireDeath1-SkullBossIndex             
    dc.w        BossFireDeath2-SkullBossIndex            
    dc.w        Boss1Dummy-SkullBossIndex                


BossSkullSetup:                              
    bsr         SetHealthBar

    bsr         SkullBossShadow
    subq.b      #1,BossTimer(a5)
    bne         .skip

    addq.b      #1,BossStatus(a5)
.skip
    rts

SkullBossShadow:
    move.l      BossBobShadowSlotPtr(a5),a4
 
    moveq       #0,d0
    move.b      BossPosX(a5),d0
    move.w      d0,Bob_X(a4)

    sf          Bob_Hide(a4)
    move.l      BossBobShadowPtrs(a5),a0
    btst        #0,TickCounter(a5)
    beq         .ok
    move.l      BossBobShadowPtrs+4(a5),a0
.ok
    BOBSET      a0,a4

    lea         BossShadowOffsets,a0
    moveq       #0,d0
    move.b      BossId(a5),d0
    add.w       d0,d0
    add.w       d0,d0
    move.w      (a0,d0.w),Bob_OffsetY(a4)
    move.w      2(a0,d0.w),Bob_OffsetX(a4)
    rts

SkullBossInit:                                 
    move.b      #$40,BossWaveSpeedY(a5)
    move.b      #$1,BossWaveSpeedX(a5)

    move.w      #$180,BossSpeedX(a5)

    move.w      #$100,BossSpeedY(a5)
    move.b      #$20,BossWaveOffsetY(a5)
    move.b      #$78,BossWaveOffsetX(a5)
    clr.b       BossIsSafe(a5)

    addq.b      #1,BossStatus(a5)
    rts

SkullBossMoveShoot:
    bsr         SkullBossShadow
    
    bsr         BossWaveMove
    bsr         SkullBossAnimate
    bsr         SkullBossShootLogic

    bsr         PlayerShotBossLogic
    tst.b       BossDeathFlag(a5)
    bne         KillBoss
    bsr         SkullBossShotCollision
    move.b      TickCounter(a5),d0
    and.b       #$1f,d0
    bne         .exit
    bsr         SkullBossAddShots
.exit
    rts


SkullBossShotCollision:
    cmp.b       #2,PlayerStatus(a5)
    beq         .exit
    lea         EnemyShotList(a5),a1
    moveq       #SKULL_SHOT_COUNT-1,d7

.loop
    tst.b       ENEMYSHOT_Status(a1)                        ; TODO: decide if shots will catch fire!
    beq         .next

    bsr         CheckEnemyShotCollision
    bsr         BonesShotCollisionCheck

.next
    lea         ENEMYSHOT_Sizeof(a1),a1
    dbra        d7,.loop
    rts
.exit
    rts


; moves the boss in a wave like motion in y and x position

BossWaveMove:
    ; wave Y
    moveq       #0,d0
    move.b      BossPosY(a5),d0
    sub.b       BossWaveOffsetY(a5),d0
    ext         d0
    neg         d0

    moveq       #0,d1
    move.b      BossWaveSpeedY(a5),d1
    muls        d1,d0
    asr.w       #3,d0

    add.w       BossSpeedY(a5),d0
    move.w      d0,BossSpeedY(a5)

    add.w       BossPosY(a5),d0
    move.w      d0,BossPosY(a5)

    ; wave x
    moveq       #0,d0
    move.b      BossPosX(a5),d0
    sub.b       BossWaveOffsetX(a5),d0
    ext         d0
    neg         d0

    moveq       #0,d1
    move.b      BossWaveSpeedX(a5),d1
    muls        d1,d0
    asr.w       #3,d0

    add.w       BossSpeedX(a5),d0
    move.w      d0,BossSpeedX(a5)

    add.w       BossPosX(a5),d0
    move.w      d0,BossPosX(a5)

    rts

SkullBossAnimate:
    ; update bob
    move.l      BossBobSlotPtr(a5),a4

    moveq       #0,d0
    move.b      BossPosY(a5),d0
    move.w      d0,Bob_Y(a4)
    move.b      BossPosX(a5),d0
    move.w      d0,Bob_X(a4)

    moveq       #0,d0 
    btst        #7,BossSpeedY(a5)
    beq         .otherframe
    addq.b      #1,d0
.otherframe
    lea         BossBobPtrs(a5),a0
    add.w       d0,d0
    add.w       d0,d0
    move.l      (a0,d0.w),a0
    BOBSET      a0,a4
    rts


SKULL_SHOT_COUNT = 5

SkullBossAddShots:                                      
    lea         EnemyShotList(a5),a1
    moveq       #SKULL_SHOT_COUNT-1,d7

.loop
    tst.b       ENEMYSHOT_Status(a1)
    beq         .addshot

    lea         ENEMYSHOT_Sizeof(a1),a1
    dbra        d7,.loop
    rts

.addshot
    move.b      #1,ENEMYSHOT_Status(a1)                     ; activate shot

    move.b      #6,ENEMYSHOT_Type(a1)                       ; pickaxe fakes shot type 6 so to have same collision size as the bone shot

    move.w      BossPosY(a5),d0
    add.w       #$1000,d0
    move.w      d0,ENEMYSHOT_PosY(a1)

    move.w      BossPosX(a5),d0
    add.w       #$400,d0
    move.w      d0,ENEMYSHOT_PosX(a1)

    clr.w       ENEMYSHOT_SpeedY(a1)

    move.w      #$180,d1
    move.b      BossPickAxeCount(a5),d2
    and.b       #2,d2
    beq         .noinvert
    neg.w       d1
.noinvert
    move.w      d1,ENEMYSHOT_SpeedX(a1)

    move.b      #$7c,ENEMYSHOT_WaveX(a1)
    move.b      #$f,ENEMYSHOT_OffsetY(a1)
    move.b      #$74,ENEMYSHOT_WaveY(a1)
    move.b      ENEMYSHOT_PosX(a1),ENEMYSHOT_OffsetX(a1)
    clr.b       ENEMYSHOT_Counter(a1)
    addq.b      #1,BossPickAxeCount(a5)

    clr.b       ENEMYSHOT_BobId(a1)
    clr.b       ENEMYSHOT_BobIdPrev(a1)

    moveq       #$10*4,d0
    lea         EnemyShotBobLookup(a5),a0
    move.l      (a0,d0.w),a0
    move.l      a0,ENEMYSHOT_BobPtr(a1)
    rts

SkullBossShootLogic:                           
    lea         BobMatrix(a5),a4
    bsr         SkullBossMoveShots
    moveq       #SKULL_SHOT_COUNT-1,d7
    bsr         BossMoveEnemyShot
    bsr         SkullBossRemoveShots
    rts




SkullBossMoveShots:                             
    lea         EnemyShotList(a5),a1
    moveq       #SKULL_SHOT_COUNT-1,d7

.loop
    tst.b       ENEMYSHOT_Status(a1)
    beq         .next

    moveq       #0,d0       
    move.b      ENEMYSHOT_WaveY(a1),d0
    sub.b       ENEMYSHOT_PosY(a1),d0
    bne         .skipcount
    addq.b      #1,ENEMYSHOT_Counter(a1)

.skipcount
    ext         d0
    asr.w       #2,d0
    add.w       d0,ENEMYSHOT_SpeedY(a1)

    moveq       #0,d0

    btst        #7,ENEMYSHOT_Counter(a1)
    bne         .skipx

    move.b      ENEMYSHOT_OffsetX(a1),d0
    sub.b       ENEMYSHOT_PosX(a1),d0
    bne         .skipx

    cmp.b       #2,ENEMYSHOT_Counter(a1)
    bcs         .skipx
    bset        #7,ENEMYSHOT_Counter(a1)
    moveq       #0,d0

.skipx
    ext         d0
    asr.w       #2,d0
    add.w       d0,ENEMYSHOT_SpeedX(a1)

.next
    lea         ENEMYSHOT_Sizeof(a1),a1
    dbra        d7,.loop
    rts



; pass d7 = number of shots!

BossMoveEnemyShot:                             
    lea         EnemyShotList(a5),a1

.loop
    move.b      ENEMYSHOT_Status(a1),d0
    subq.b      #1,d0
    bne         .next

    move.w      ENEMYSHOT_SpeedY(a1),d0
    add.w       d0,ENEMYSHOT_PosY(a1)
    move.w      ENEMYSHOT_SpeedX(a1),d0
    add.w       d0,ENEMYSHOT_PosX(a1)

    move.b      ENEMYSHOT_PosX(a1),d0
    sub.b       #$f0,d0
    cmp.b       #8,d0

    move.b      ENEMYSHOT_PosX(a1),d0
    
    sub.b       #8,d0
    cmp.b       #$f0,d0                                     ; TODO: maybe wider edges??
    bcc         .removeshot

    cmp.b       #1,BossId(a5)                               ; special code / sfx for skull boss pick axe
    bne         .normal
    
    bsr         AnimatePickAxe
    bra         .next

.normal
    bsr         EnemyShotAnim

.next
    lea         ENEMYSHOT_Sizeof(a1),a1
    dbra        d7,.loop
    rts

.removeshot
    clr.b       ENEMYSHOT_Status(a1)                        ; disable shot
    bra         .next


SkullBossRemoveShots:
    lea         EnemyShotList(a5),a1
    moveq       #SKULL_SHOT_COUNT-1,d7

.loop
    tst.b       ENEMYSHOT_Status(a1)
    beq         .next

    btst        #7,ENEMYSHOT_SpeedY(a1)
    beq         .next

    move.b      BossPosY(a5),d0
    add.b       #$18,d0
    sub.b       ENEMYSHOT_PosY(a1),d0
    cmp.b       #$38,d0
    bcc         .next

    move.b      BossPosX(a5),d0
    sub.b       ENEMYSHOT_PosX(a1),d0
    add.b       #$30,d0
    cmp.b       #$50,d0
    bcc         .next

    clr.b       ENEMYSHOT_Status(a1)

.next
    lea         ENEMYSHOT_Sizeof(a1),a1
    dbra        d7,.loop
    rts
