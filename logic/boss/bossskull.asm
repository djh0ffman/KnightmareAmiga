;----------------------------------------------------------------------------
;
; boss 2 (skull)
;
;----------------------------------------------------------------------------

    include     "common.asm"


SkullBossLogic:                                   ; ...
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


BossSkullSetup:                                 ; ...
    ;ld          a, (GameFrame)
    ;and         3Fh                      ; '?'
    ;cp          1
    ;ret         nz
    ;ld          hl, BossPosY
    ;ld          a, (hl)
    ;add         a, 8
    ;ld          (hl), a
    ;ret         m
    ;cp          20h                      ; ' '
    ;ret         c
    ;call        ClearTileBoss            ; clears the tile boss from the screen as
                                                  ; tile bosses are integrated into the map data
                                                  ;
    ;call        TileBossSetMoveSpeed     ; sets the tile boss move speed
                                                  ; there are three different speeds depending on
                                                  ; distance to the player
    bsr         SetHealthBar

    bsr         SkullBossShadow
    subq.b      #1,BossTimer(a5)
    bne         .skip

    ;bsr         BossSetMoveSpeed
    ;jp          NextBossStatus
    ;cmp.b       #$d8,LevelPosition(a5)
    ;bne         .skip


    addq.b      #1,BossStatus(a5)
.skip
    rts

SkullBossShadow:
    move.l      BossBobShadowSlotPtr(a5),a4
 
    ;moveq       #0,d0
    ;move.b      BossPosY(a5),d0
    ;move.w      d0,Bob_Y(a4)
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

SkullBossInit:                                    ; ...

    ;ld          hl, 140h
    ;ld          (BossWaveSpeedY), hl
    move.b      #$40,BossWaveSpeedY(a5)
    move.b      #$1,BossWaveSpeedX(a5)

    ;ld          de, 180h
    ;ld          (BossSpeedXDec), de
    move.w      #$180,BossSpeedX(a5)

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

SkullBossMoveShoot:
    bsr         SkullBossShadow
    ;call        DecBossDeathTimer                    ; decrements the boss auto death timer
                                                  ; tests value to set carry
                                                  ;
    ;jr          z, SkullBossKill
    ;call        BossWaveMove                         ; moves the boss in a wave like motion in y and x position
    
    bsr         BossWaveMove
    bsr         SkullBossAnimate
    ;call        SkullBossShootLogic
    bsr         SkullBossShootLogic

    bsr         PlayerShotBossLogic
    tst.b       BossDeathFlag(a5)
    bne         KillBoss
    ;jr          nz, SkullBossKill
    ;call        sub_8EA2  ; check shot collisions
    bsr         SkullBossShotCollision
    ;ld          a, (TickCounter)
    ;and         0Fh
    ;ret         nz
    move.b      TickCounter(a5),d0
    and.b       #$1f,d0
    bne         .exit
    ;ld          b, a
    ;ld          ix, BossParams
    ;jp          loc_8EEB  ; add shots
    
    bsr         SkullBossAddShots
.exit
    rts


SkullBossShotCollision:
    ;ld          a, (PlayerStatus)
    ;cp          2
    ;ret         z
    cmp.b       #2,PlayerStatus(a5)
    beq         .exit
    ;ld          ix, EnemyShotList
    ;exx
    ;ld          b, 8
    lea         EnemyShotList(a5),a1
    moveq       #SKULL_SHOT_COUNT-1,d7

;loc_8EAF:                                         ; ...
.loop
    ;exx
    ;ld          a, (ix+0)
    ;dec         a
    ;jr          nz, loc_8EBC
    tst.b       ENEMYSHOT_Status(a1)                        ; TODO: decide if shots will catch fire!
    beq         .next

    ;call        CheckEnemyShotCollision2
    ;call        sub_8EC5
    bsr         CheckEnemyShotCollision
    bsr         BonesShotCollisionCheck

;loc_8EBC:                                         ; ...
.next
    ;exx
    ;ld          de, 10h
    ;add         ix, de
    ;djnz        loc_8EAF
    ;ret
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

SkullBossAddShots:                                         ; ...
    ;ld          hl, EnemyShotList
    ;ld          de, 10h
    ;ld          b, 5
    lea         EnemyShotList(a5),a1
    moveq       #SKULL_SHOT_COUNT-1,d7

;loc_8EF3:                                         ; ...
.loop
    ;ld          a, (hl)
    ;and         a
    ;jr          z, loc_8EFB
    tst.b       ENEMYSHOT_Status(a1)
    beq         .addshot
    ;add         hl, de
    ;djnz        loc_8EF3
    ;ret
    lea         ENEMYSHOT_Sizeof(a1),a1
    dbra        d7,.loop
    rts

;loc_8EFB:                                         ; ...
.addshot
    ;ld          (hl), 1
    move.b      #1,ENEMYSHOT_Status(a1)                     ; activate shot

    ;inc         hl                                 ; +1
    ;ld          (hl), 6
    move.b      #6,ENEMYSHOT_Type(a1)                       ; pickaxe fakes shot type 6 so to have same collision size as the bone shot

    ;inc         hl                                 ; +2
    ;inc         hl                                 ; +3
    ;ld          a, (BossPosY)
    ;add         a, 10h    
    ;ld          (hl), a
    move.w      BossPosY(a5),d0
    add.w       #$1000,d0
    move.w      d0,ENEMYSHOT_PosY(a1)

    ;inc         hl                                 ; +4
    ;inc         hl                                 ; +5
    ;ld          a, (BossPosX)
    ;add         a, 4
    ;ld          (hl), a

    move.w      BossPosX(a5),d0
    add.w       #$400,d0
    move.w      d0,ENEMYSHOT_PosX(a1)


    ;push        af
    ;inc         hl                                 ; +6
    ;ld          (hl), 0
    ;inc         hl                                 ; +7
    ;ld          (hl), 0
    clr.w       ENEMYSHOT_SpeedY(a1)

    ;inc         hl                                 ; +8
    ;ld          de, 180h
    ;pop         af
    ;ld          c, a
    ;ld          a, (byte_E3CF)
    ;and         2
    ;call        z, sub_8F3B
    ;ld          (hl), e
    ;inc         hl                                 ; +9
    ;ld          (hl), d
    move.w      #$180,d1
    move.b      BossPickAxeCount(a5),d2
    and.b       #2,d2
    beq         .noinvert
    neg.w       d1
.noinvert
    move.w      d1,ENEMYSHOT_SpeedX(a1)

    ;inc         hl                                 ; +a
    ;ld          (hl), 7Ch                            ; '|'
    move.b      #$7c,ENEMYSHOT_WaveX(a1)
    ;inc         hl                                 ; +b
    ;ld          (hl), 0Fh
    move.b      #$f,ENEMYSHOT_OffsetY(a1)
    ;inc         hl                                 ; +c
    ;ld          (hl), 64h                            ; 'd'
    move.b      #$74,ENEMYSHOT_WaveY(a1)
    ;inc         hl                                 ; +d
    ;ld          (hl), c
    move.b      ENEMYSHOT_PosX(a1),ENEMYSHOT_OffsetX(a1)
    ;inc         hl                                 ; +e
    ;ld          (hl), 0
    clr.b       ENEMYSHOT_Counter(a1)
    ;ld          hl, byte_E3CF
    ;inc         (hl)
    addq.b      #1,BossPickAxeCount(a5)

    clr.b       ENEMYSHOT_BobId(a1)
    clr.b       ENEMYSHOT_BobIdPrev(a1)

    ;PUSH        a4
    ;bsr         BobAllocate

    ;move.w      d0,ENEMYSHOT_BobSlot(a1)

    ;moveq       #0,d0
    ;move.b      ENEMYSHOT_PosY(a1),d0
    ;move.w      d0,Bob_Y(a4)
    ;move.b      ENEMYSHOT_PosX(a1),d0
    ;move.w      d0,Bob_X(a4)
    
    moveq       #$10*4,d0
    lea         EnemyShotBobLookup(a5),a0
    move.l      (a0,d0.w),a0
    move.l      a0,ENEMYSHOT_BobPtr(a1)
    ;move.l      (a0),a0
    ;BOBSET      a0,a4    
    ;sf          Bob_Hide(a4)
    ;POP         a4
    ;ret
    rts

SkullBossShootLogic:                              ; ...
    ;call        SkullBossMoveShots1
    ;call        BossMoveEnemyShot
    ;call        SkullBossMoveShots
    ;bsr         SkullBossMoveShots1
    lea         BobMatrix(a5),a4
    bsr         SkullBossMoveShots
    moveq       #SKULL_SHOT_COUNT-1,d7
    bsr         BossMoveEnemyShot
    bsr         SkullBossRemoveShots
    rts




SkullBossMoveShots:                                ; ...
    ;ld          ix, EnemyShotList
    ;ld          b, 8
    lea         EnemyShotList(a5),a1
    moveq       #SKULL_SHOT_COUNT-1,d7

;SkullBossShotLoop:                                ; ...
.loop
    ;ld          a, (ix+ENEMYSHOT_Status)
    ;and         a
    ;jr          z, SkullBossShotNext
    tst.b       ENEMYSHOT_Status(a1)
    beq         .next

    ;ld          a, (ix+ENEMYSHOT_OffsetY)
    ;sub         (ix+ENEMYSHOT_PosY)
    ;or          a
    ;jr          nz, loc_8F67
    ;inc         (ix+ENEMYSHOT_Counter)
    moveq       #0,d0       
    move.b      ENEMYSHOT_WaveY(a1),d0
    sub.b       ENEMYSHOT_PosY(a1),d0
    bne         .skipcount
    addq.b      #1,ENEMYSHOT_Counter(a1)

;loc_8F67:                                         ; ...
.skipcount
    ;ld          e, (ix+ENEMYSHOT_SpeedYDec)
    ;ld          d, (ix+ENEMYSHOT_SpeedY)
    ;call        sub_8FC5
    ;ld          (ix+ENEMYSHOT_SpeedYDec), l
    ;ld          (ix+ENEMYSHOT_SpeedY), h
    ext         d0
    asr.w       #2,d0
    add.w       d0,ENEMYSHOT_SpeedY(a1)

    ;xor         a
    ;bit         7, (ix+ENEMYSHOT_Counter)
    ;jr          nz, loc_8F94
    moveq       #0,d0

    btst        #7,ENEMYSHOT_Counter(a1)
    bne         .skipx

    ;ld          a, (ix+ENEMYSHOT_BobId)
    ;sub         (ix+ENEMYSHOT_PosX)
    ;ld          c, a
    ;or          a
    ;jr          nz, loc_8F94
    move.b      ENEMYSHOT_OffsetX(a1),d0
    sub.b       ENEMYSHOT_PosX(a1),d0
    bne         .skipx

    ;ld          a, (ix+ENEMYSHOT_Counter)
    ;cp          2
    ;ld          a, c
    ;jr          c, loc_8F94
    ;set         7, (ix+ENEMYSHOT_Counter)
    ;xor         a
    cmp.b       #2,ENEMYSHOT_Counter(a1)
    bcs         .skipx
    bset        #7,ENEMYSHOT_Counter(a1)
    moveq       #0,d0

;loc_8F94:                                         ; ...
.skipx
    ;ld          e, (ix+ENEMYSHOT_SpeedXDec)
    ;ld          d, (ix+ENEMYSHOT_SpeedX)
    ;call        sub_8FC5
    ;ld          (ix+ENEMYSHOT_SpeedXDec), l
    ;ld          (ix+ENEMYSHOT_SpeedX), h
    ext         d0
    asr.w       #2,d0
    add.w       d0,ENEMYSHOT_SpeedX(a1)

    ;ld          hl, SoundDataArea2
    ;ld          a, 1Bh                               ; pick axe sound
    ;cp          (hl)
    ;call        nz, 

    ;ld          a, (ix+ENEMYSHOT_Status)
    ;cp          2
    ;jr          z, SkullBossShotNext
    ;ld          a, (TickCounter)
    ;and         0Ch
    ;add         a, 7Ch                               ; '|'
    ;ld          (ix+ENEMYSHOT_SpriteId), a

;SkullBossShotNext:                                ; ...
.next
    ;ld          de, 10h
    ;add         ix, de
    ;djnz        SkullBossShotLoop
    ;ret
    lea         ENEMYSHOT_Sizeof(a1),a1
    dbra        d7,.loop
    rts



; pass d7 = number of shots!

BossMoveEnemyShot:                                ; ...
    ;ld          ix, EnemyShotList
    ;ld          b, 0Ah                               ; boss allows for 10 shots
    lea         EnemyShotList(a5),a1

;BossMoveEnemyShotLoop:                            ; ...
.loop
    ;push        bc
    ;ld          a, (ix+ENEMYSHOT.Status)
    ;dec         a
    move.b      ENEMYSHOT_Status(a1),d0
    subq.b      #1,d0
    bne         .next
    ;call        z, MoveEnemy                         ; move enemy
    ;pop         bc
    ;ld          de, 10h
    ;add         ix, de
    ;djnz        BossMoveEnemyShotLoop
    ;ret
    move.w      ENEMYSHOT_SpeedY(a1),d0
    add.w       d0,ENEMYSHOT_PosY(a1)
    move.w      ENEMYSHOT_SpeedX(a1),d0
    add.w       d0,ENEMYSHOT_PosX(a1)

    ;move.w      ENEMYSHOT_BobSlot(a1),d4
    
    ;moveq       #16,d0
    ;add.b       ENEMYSHOT_PosY(a1),d0
    ;sub.w       #16,d0
    ;move.w      d0,Bob_Y(a4,d4.w)
    
    ;cmp.w       ENEMYSHOT_PosY(a1),d0
    ;bcc         .removeshot
    move.b      ENEMYSHOT_PosX(a1),d0
    sub.b       #$f0,d0
    cmp.b       #8,d0

    ;moveq       #0,d0
    move.b      ENEMYSHOT_PosX(a1),d0
    ;move.w      d0,Bob_X(a4,d4.w)
    
    sub.b       #8,d0
    cmp.b       #$f0,d0                                     ; TODO: maybe wider edges??
    bcc         .removeshot

    ;bsr         EnemyShotAnim
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
    ;clr.b       Bob_Allocated(a4,d4.w)                      ; remove bob
    bra         .next


SkullBossRemoveShots:
    ;ld          ix, EnemyShotList
    ;inc         b
    ;ex          af, af'
    lea         EnemyShotList(a5),a1
    moveq       #SKULL_SHOT_COUNT-1,d7

;SkullBossMoveShotsLoop:                           ; ...
.loop
    ;ld          a, (ix+ENEMYSHOT.Status)
    ;and         a
    ;jr          z, SkullBossMoveShotsNext
    tst.b       ENEMYSHOT_Status(a1)
    beq         .next

    ;bit         7, (ix+ENEMYSHOT.SpeedY)
    ;jr          z, SkullBossMoveShotsNext
    btst        #7,ENEMYSHOT_SpeedY(a1)
    beq         .next

    ;ld          a, (BossPosY)
    ;sub         (ix+ENEMYSHOT.PosY)
    ;add         a, 18h
    ;cp          38h                                  ; '8'
    ;jr          nc, SkullBossMoveShotsNext
    move.b      BossPosY(a5),d0
    add.b       #$18,d0
    sub.b       ENEMYSHOT_PosY(a1),d0
    cmp.b       #$38,d0
    bcc         .next

    ;ld          a, (BossPosX)
    ;sub         (ix+ENEMYSHOT.PosX)
    ;add         a, 30h                               ; '0'
    ;cp          50h                                  ; 'P'
    ;jr          nc, SkullBossMoveShotsNext
    move.b      BossPosX(a5),d0
    sub.b       ENEMYSHOT_PosX(a1),d0
    add.b       #$30,d0
    cmp.b       #$50,d0
    bcc         .next

    ;ld          (ix+ENEMYSHOT.Status), 0
    ;ld          (ix+ENEMYSHOT.PosY), 0E0h
    clr.b       ENEMYSHOT_Status(a1)
    ;move.w      ENEMYSHOT_BobSlot(a1),d4
    ;clr.b       Bob_Allocated(a4,d4.w)


;SkullBossMoveShotsNext:                           ; ...
.next
    ;ld          de, 10h
    ;add         ix, de
    ;djnz        SkullBossMoveShotsLoop
    lea         ENEMYSHOT_Sizeof(a1),a1
    dbra        d7,.loop
    rts
