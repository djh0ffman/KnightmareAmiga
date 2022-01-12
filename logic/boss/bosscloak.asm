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

    ;ld          hl, 140h
    ;ld          (BossWaveSpeedY), hl
    move.b      #$8,BossWaveSpeedY(a5)
    move.b      #$2,BossWaveSpeedX(a5)

    ;ld          de, 180h
    ;ld          (BossSpeedXDec), de
    move.w      #$280,BossSpeedX(a5)

    ;ld          bc, 0E10h
    ;ld          (BossDeathTimer), bc

    ;ld          hl, 100h
    ;ld          (BossSpeedYDec), hl
    move.w      #$100,BossSpeedY(a5)
    ;ld          hl, 7820h
    ;ld          (BossWaveOffsetYX), hl
    move.b      #$20,BossWaveOffsetY(a5)
    move.b      #$78,BossWaveOffsetX(a5)
    ;jr          NextBossStatus
    clr.b       BossIsSafe(a5)

    addq.b      #1,BossStatus(a5)

    rts


CloakBossMoveShoot:   
    bsr         SkullBossShadow
    ;call        DecBossDeathTimer                     ; decrements the boss auto death timer
                                                  ; tests value to set carry
                                                  ;
    ;jp          z, KillBoss                           ; boss status

    ;call        BossWaveMove                          ; moves the boss in a wave like motion in y and x position
    bsr         BossWaveMove
    bsr         SkullBossAnimate

    ;call        CloakBossMoveShootLogic
    bsr         CloakBossMoveShootLogic

    ;call        PlayerShotBossLogic                   ; checks if player shots hit boss

    ;jp          nz, KillBoss                          ; boss status
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

CloakBossMoveShootLogic:                          ; ...
    ;ld          a, (TickCounter)
    ;rra
    ;call        c, BossMoveEnemyShot
    lea         BobMatrix(a5),a4

    moveq       #ENEMYSHOT_COUNT-1,d7
    bsr         BossMoveEnemyShot

    ;call        CloakShotsMoveToPlayer
    bsr         CloakShotsMoveToPlayer

    ;call        CloakBossShotFireLogic
    bsr         CloakBossShotFireLogic

    ;call        CloakShotsTouchPlayer
    bsr         CloakShotsTouchPlayer

    ;jp          UpdateBossEnemyShotAttRam
    rts



CloakShotsMoveToPlayer:                           ; ...
    ;ld          a, (PlayerY)
    ;ld          l, a
    ;ld          a, (PlayerX)
    ;ld          h, a
    moveq       #0,d1
    moveq       #0,d2
    move.b      PlayerStatus+PLAYER_PosY(a5),d1
    move.b      PlayerStatus+PLAYER_PosX(a5),d2

    ;ld          ix, EnemyShotList
    ;ld          b, 0Ah                               ; 10 boss enemy shots
    lea         EnemyShotList(a5),a1
    moveq       #ENEMYSHOT_COUNT-1,d7

;CloakShotsMoveToPlayerLoop:                       ; ...
.loop
    ;ld          a, (ix+ENEMYSHOT_Status)
    ;dec         a
    ;jr          nz, CloakShotsMoveToPlayerNext
    move.b      ENEMYSHOT_Status(a1),d0
    subq.b      #1,d0
    bne         .next

    ;ld          a, (ix+ENEMYSHOT_DeathTimer)
    ;and         a
    ;jr          nz, CloakShotDie
    tst.b       ENEMYSHOT_DeathTimer(a1)
    bne         .die

    ;ld          a, (ix+ENEMYSHOT_PosY)
    ;sub         l
    ;add         a, 28h                               ; '('
    ;jp          m, CloakShotsMoveToPlayerNext
    move.b      ENEMYSHOT_PosY(a1),d0
    sub.b       d1,d0
    add.b       #$28,d0
    bmi         .next

    ;ld          a, r                                 ; first bit of rng!
    ;and         0Fh
    ;add         a, 8
    ;ld          c, a
    ;ld          a, (ix+ENEMYSHOT_PosX)
    ;sub         h
    ;jr          nc, loc_93BD

    move.b      ENEMYSHOT_PosX(a1),d0
    sub         d2,d0
    bcc         .pos

    ;neg
    neg.b       d0

;loc_93BD:                                         ; ...
.pos
    move.b      d0,d1
    ;sra         a
    ;add         a, c
    ;ld          (ix+ENEMYSHOT_DeathTimer), a
    RANDOM
    and.b       #$f,d0
    add.b       #8,d0
    add.b       d1,d0
    move.b      d0,ENEMYSHOT_DeathTimer(a1)

;CloakShotsMoveToPlayerNext:                       ; ...
.next
    ;ld          de, 10h
    ;add         ix, de
    ;djnz        CloakShotsMoveToPlayerLoop
    ;ret
    lea         ENEMYSHOT_Sizeof(a1),a1
    dbra        d7,.loop
    rts

;CloakShotDie:                                     ; ...
.die
    ;dec         (ix+ENEMYSHOT.DeathTimer)
    ;jr          nz, CloakShotsMoveToPlayerNext
    subq.b      #1,ENEMYSHOT_DeathTimer(a1)
    bne         .next

    ;ld          (ix+ENEMYSHOT.Status), 2
    ;ld          (ix+ENEMYSHOT.Type), 0Fh
    ;ld          (ix+ENEMYSHOT.DeathTimer), 18h
    ;jr          CloakShotsMoveToPlayerNext
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


CloakShotsTouchPlayer:                            ; ...
    ;ld          a, (PlayerStatus)
    ;cp          2
    ;ret         z
    ;ld          ix, EnemyShotList
    ;ld          b, 8
    cmp.b       #PLAYERMODE_DEAD,PlayerStatus(a5)
    beq         .exit

    lea         EnemyShotList(a5),a1
    moveq       #ENEMYSHOT_COUNT-1,d7

;CloakShotsTouchPlayerLoop:                        ; ...
.loop
    ;exx
    ;ld          a, (ix+ENEMYSHOT.Status)
    ;and         a
    ;jr          z, CloakShotsTouchPlayerNext
    move.b      ENEMYSHOT_Status(a1),d0
    beq         .next

    ;cp          3
    ;jr          nc, CloakShotsTouchPlayerNext
    cmp.b       #3,d0
    bcc         .next

    bsr         CheckEnemyShotCollision


;CloakShotsTouchPlayerNext:                        ; ...
.next
    ;exx
    ;ld          de, 10h
    ;add         ix, de
    ;djnz        CloakShotsTouchPlayerLoop
    ;ret
    lea         ENEMYSHOT_Sizeof(a1),a1
    dbra        d7,.loop
.exit
    rts



CloakBossShotFireLogic:                           ; ...
    ;ld          ix, EnemyShotList
    ;ld          de, 10h
    ;ld          b, 0Bh
    lea         EnemyShotList(a5),a1
    moveq       #ENEMYSHOT_COUNT-1,d7


;CloakBossShotFireLogicLoop:                       ; ...
.loop
    ;ld          a, (ix+ENEMYSHOT.Status)
    ;cp          2
    ;jr          nz, CloakBossShotFireLogicNext
    cmp.b       #2,ENEMYSHOT_Status(a1)
    bne         .next
    ;bit         2, (ix+ENEMYSHOT.DeathTimer)
    ;ld          c, 88h
    ;jr          z, CloakBossShotFireLogicBlink
    ;ld          c, 8Ch

;CloakBossShotFireLogicBlink:                      ; ...
    ;ld          (ix+ENEMYSHOT.SpriteId), c
    ;dec         (ix+ENEMYSHOT.DeathTimer)
    ;jr          nz, CloakBossShotFireLogicNext
    ;ld          (ix+ENEMYSHOT.Status), 0             ; kill the shot
    ;ld          (ix+ENEMYSHOT.PosY), 0E0h
    bsr         EnemyShotAnim

    subq.b      #1,ENEMYSHOT_DeathTimer(a1)
    bne         .next

    clr.b       ENEMYSHOT_Status(a1)
    ;move.w      ENEMYSHOT_BobSlot(a1),d4
    ;clr.b       Bob_Allocated(a4,d4.w)

;CloakBossShotFireLogicNext:                       ; ...
.next
    ;add         ix, de
    ;djnz        CloakBossShotFireLogicLoop
    ;ret
    lea         ENEMYSHOT_Sizeof(a1),a1
    dbra        d7,.loop
    rts
