;----------------------------------------------------------------------------
;
; boss 3 (bat?)
;
;----------------------------------------------------------------------------
    
    include     "common.asm"

BatBossLogic:
    moveq       #0,d0
    move.b      BossStatus(a5),d0
    bne         .run
    rts
.run
    subq.b      #1,d0
    JMPINDEX    d0

BatBossIndex:
    dc.w        BossLoad-BatBossIndex
    dc.w        BatBossSetup-BatBossIndex
    dc.w        BatBossInit-BatBossIndex
    dc.w        BatBossMoveShoot-BatBossIndex
    dc.w        BossDeathFlash-BatBossIndex         
    dc.w        BossFireDeath1-BatBossIndex             
    dc.w        BossFireDeath2-BatBossIndex            
    dc.w        Boss1Dummy-BatBossIndex                
  

BatBossSetup:
    bsr         SetHealthBar
    bsr         SkullBossShadow
    subq.b      #1,BossTimer(a5)
    bne         .skip
    addq.b      #1,BossStatus(a5)
.skip
    rts


BatBossInit:                                    ; ...

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




BatBossMoveShoot:
    bsr         SkullBossShadow
    ;call        DecBossDeathTimer                ; decrements the boss auto death timer
                                                  ; tests value to set carry
                                                  ;
    ;jp          z, KillBoss                      ; boss status
    ;call        BossWaveMove                     ; moves the boss in a wave like motion in y and x position
    bsr         BossWaveMove


    ;call        BatBossShotCollisionCheck
    ;jp          nz, KillBoss                     ; boss status
    bsr         PlayerShotBossLogic
    tst.b       BossDeathFlag(a5)
    bne         KillBoss

    move.b      TickCounter(a5),d0
    and.b       #$7f,d0
    bne         .skipshot

    lea         BossFakeEnemy(a5),a2             ; fake enemy structure for shot coords
    move.b      BossPosY(a5),d0
    move.b      d0,ENEMY_PosY(a2)
    move.b      BossPosX(a5),d0
    move.b      d0,ENEMY_PosX(a2)

    ;ld          a, (TileBossId)
    ;ld          hl, TileBossShotType
    ;call        ADD_A_HL
    ;ld          b, (hl)
    ;ld          ix, BossShotList
    ;call        AddEnemyShot                  ; add enemy shot
    moveq       #0,d0
    move.b      BossId(a5),d0
    lea         BossShotType,a0
    move.b      (a0,d0.w),d0
    bsr         AddEnemyShot    
    
    ;ld          a, (BossPosX)
    ;add         a, 0Ah
    ;ld          (byte_E585), a



    ;ld          a, (TileBossAnimId1)
    ;or          a
    ;ret         nz
    ;ld          a, (TickCounter)
    ;and         1Fh
    ;ret         nz
    ;ld          b, 0Ah
    ;ld          ix, BossParams
    ;jp          AddEnemyShot                     ; add enemy shot
                                                  ;
                                                  ; b = shot type
                                                  ; ix = pointer to enemy (for position info)
.skipshot
    move.b      #1,BossIsSafe(a5)

    moveq       #0,d0                            ; bob id
    btst.b      #6,TickCounter(a5)
    bne         .notflying

    move.b      TickCounter(a5),d1
    lsr.b       #2,d1
    cmp.b       #$40,d1
    bcc         .notflying

    clr.b       BossIsSafe(a5)
    addq.b      #1,d0
    btst        #0,d1
    bne         .notflying
    addq.b      #1,d0

.notflying
    move.b      d0,BossBobId(a5)

    bsr         BatBossAnimate

    rts

BatBossAnimate:
    ; update bob
    move.l      BossBobSlotPtr(a5),a4

    moveq       #0,d0
    move.b      BossPosY(a5),d0
    move.w      d0,Bob_Y(a4)
    move.b      BossPosX(a5),d0
    move.w      d0,Bob_X(a4)

    moveq       #0,d0
    move.b      BossBobId(a5),d0
    lea         BossBobPtrs(a5),a0
    add.w       d0,d0
    add.w       d0,d0
    move.l      (a0,d0.w),a0
    BOBSET      a0,a4
    rts

