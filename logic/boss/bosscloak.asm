;----------------------------------------------------------------------------
;
; boss 3 (cloak)
;
;----------------------------------------------------------------------------
    
    include     "common.asm"

CloakBossLogic:
    moveq       #0,d0
    move.b      BossStatus(a5),d0
    bne         .run
    rts
.run
    subq.b      #1,d0
    JMPINDEX    d0

CloakBossIndex:
    dc.w        BossLoad-CloakBossIndex
    dc.w        CloakBossSetup-CloakBossIndex
    dc.w        CloakBossInit-CloakBossIndex
    dc.w        CloakBossMoveShoot-CloakBossIndex
    dc.w        BossDeathFlash-CloakBossIndex         
    dc.w        BossFireDeath1-CloakBossIndex             
    dc.w        BossFireDeath2-CloakBossIndex            
    dc.w        Boss1Dummy-CloakBossIndex   

CloakBossSetup:
    bsr         SetHealthBar
    bsr         SkullBossShadow
    subq.b      #1,BossTimer(a5)
    bne         .skip
    addq.b      #1,BossStatus(a5)
.skip
    rts

CloakBossInit:
    move.b      #$8,BossWaveSpeedY(a5)
    move.b      #$2,BossWaveSpeedX(a5)

    move.w      #$280,BossSpeedX(a5)

    move.w      #$100,BossSpeedY(a5)
    move.b      #$20,BossWaveOffsetY(a5)
    move.b      #$78,BossWaveOffsetX(a5)
    clr.b       BossIsSafe(a5)

    addq.b      #1,BossStatus(a5)

    rts


CloakBossMoveShoot:   
    bsr         SkullBossShadow

    bsr         BossWaveMove
    bsr         SkullBossAnimate

    bsr         CloakBossMoveShootLogic

    bsr         PlayerShotBossLogic
    tst.b       BossDeathFlag(a5)
    bne         KillBoss
    
    move.b      TickCounter(a5),d0
    and.b       #$1f,d0
    bne         .skipshot

    lea         BossFakeEnemy(a5),a2                 ; fake enemy structure for shot coords
    move.b      BossPosY(a5),d0
    move.b      d0,ENEMY_PosY(a2)
    move.b      BossPosX(a5),d0
    move.b      d0,ENEMY_PosX(a2)

    moveq       #0,d0
    move.b      BossId(a5),d0
    lea         BossShotType,a0
    move.b      (a0,d0.w),d0
    bsr         AddEnemyShot    
    
.skipshot


    rts

CloakBossMoveShootLogic:                       
    lea         BobMatrix(a5),a4
    moveq       #ENEMYSHOT_COUNT-1,d7
    bsr         BossMoveEnemyShot
    bsr         CloakShotsMoveToPlayer
    bsr         CloakBossShotFireLogic
    bsr         CloakShotsTouchPlayer
    rts



CloakShotsMoveToPlayer:                        
    moveq       #0,d1
    moveq       #0,d2
    move.b      PlayerStatus+PLAYER_PosY(a5),d1
    move.b      PlayerStatus+PLAYER_PosX(a5),d2

    lea         EnemyShotList(a5),a1
    moveq       #ENEMYSHOT_COUNT-1,d7
                  
.loop
    move.b      ENEMYSHOT_Status(a1),d0
    subq.b      #1,d0
    bne         .next

    tst.b       ENEMYSHOT_DeathTimer(a1)
    bne         .die

    move.b      ENEMYSHOT_PosY(a1),d0
    sub.b       d1,d0
    add.b       #$28,d0
    bmi         .next

    move.b      ENEMYSHOT_PosX(a1),d0
    sub         d2,d0
    bcc         .pos

    neg.b       d0

.pos
    move.b      d0,d1
    RANDOM
    and.b       #$f,d0
    add.b       #8,d0
    add.b       d1,d0
    move.b      d0,ENEMYSHOT_DeathTimer(a1)

.next
    lea         ENEMYSHOT_Sizeof(a1),a1
    dbra        d7,.loop
    rts

.die
    subq.b      #1,ENEMYSHOT_DeathTimer(a1)
    bne         .next

    moveq       #$d,d0
    bsr         SfxPlay

    move.b      #2,ENEMYSHOT_Status(a1)
    move.b      #$f,ENEMYSHOT_Type(a1)               ; set fire animation
    move.b      #$18,ENEMYSHOT_DeathTimer(a1)
    move.b      #-1,ENEMYSHOT_BobIdPrev(a1)
    clr.b       ENEMYSHOT_Counter(a1)

    moveq       #0,d0
    move.b      ENEMYSHOT_Type(a1),d0
    add.w       d0,d0
    add.w       d0,d0
    lea         EnemyShotBobLookup(a5),a0
    move.l      (a0,d0.w),a0
    move.l      a0,ENEMYSHOT_BobPtr(a1)

    bra         .next


CloakShotsTouchPlayer:                         
    cmp.b       #PLAYERMODE_DEAD,PlayerStatus(a5)
    beq         .exit

    lea         EnemyShotList(a5),a1
    moveq       #ENEMYSHOT_COUNT-1,d7

.loop
    move.b      ENEMYSHOT_Status(a1),d0
    beq         .next

    cmp.b       #3,d0
    bcc         .next

    bsr         CheckEnemyShotCollision

.next
    lea         ENEMYSHOT_Sizeof(a1),a1
    dbra        d7,.loop
.exit
    rts



CloakBossShotFireLogic:                        
    lea         EnemyShotList(a5),a1
    moveq       #ENEMYSHOT_COUNT-1,d7

.loop
    cmp.b       #2,ENEMYSHOT_Status(a1)
    bne         .next
    bsr         EnemyShotAnim

    subq.b      #1,ENEMYSHOT_DeathTimer(a1)
    bne         .next

    clr.b       ENEMYSHOT_Status(a1)
.next
    lea         ENEMYSHOT_Sizeof(a1),a1
    dbra        d7,.loop
    rts
