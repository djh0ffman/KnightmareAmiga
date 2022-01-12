
;----------------------------------------------------------------------------
;
;  enemy logic
;
;----------------------------------------------------------------------------

    include           "common.asm"

ClearEnemies:
    lea               EnemyList(a5),a2 
    move.w            #(ENEMY_COUNT*ENEMY_Sizeof)-1,d7
.clear
    clr.b             (a2)+
    dbra              d7,.clear
    rts

EnemyLogic:
    ;ld         a, (BossStatus)
    ;and        a
    ;ret        nz
    tst.b             BossDeathFlag(a5)
    bne               .run

    tst.b             BossStatus(a5)
    bne               .exit
    ;ld         a, (LevelPosition)        ; starts at zero, increments 1 per 8 pixels of the map
                                                  ; this is linked to other data to determine where items appear
                                                  ; within a level
    ;cp         0CAh  ; moved to scroll logic
    ;call       nc, KillAllEnemy          ; qblock power kill all on screen enemies
                                                  ;
                                                

    ;call       UpdateEnemySprites
    
    ;ld         a, (FreezeStatus)
    ;and        a
    ;jr         nz, .skipwave
    ;call       SetupAttackWave
    ;call       AttackWaveLogic
.run
    tst.b             FreezeStatus(a5)
    bne               .skipwave
    bsr               SetupAttackWave
    bsr               AttackWaveLogic

.skipwave
    lea               EnemyList(a5),a2                                        ; constant in this loop
    moveq             #ENEMY_COUNT-1,d7
    lea               BobMatrix(a5),a4                                        ; constant in this loop
    
.loop
    tst.b             ENEMY_Status(a2)
    beq               .skipenemy

    bsr               ProcessEnemyLogic
    bsr               EnemyPlayerShotLogic
    bsr               EnemyCollisionLogic
.skipenemy
    lea               ENEMY_Sizeof(a2),a2
    dbra              d7,.loop
.exit
    rts


EnemyCollisionLogic:                              ; ...
    ;call        GetEnemyDeathStatus                       ; get enemy death status
    ;cp          (hl)                                      ; compare status
    ;ret         nc                                        ; status below death, quit
    tst.b             ENEMY_DeathFlag(a2)
    bne               .exit

    ;ld          a, (ix+ENEMY.Id)
    ;and         0Fh
    ;cp          7                                         ; enemy id bones
    ;jr          nz, SkipBonesCheck                        ; not bones, do collision check
    move.b            ENEMY_Id(a2),d0
    and.w             #$f,d0

    ;cmp.b             #7,d0
    ;bne               .skipbones

    ;ld          a, (ix+ENEMY.Status)
    ;cp          4                                         ; bones status 4
    ;ret         nc                                        ; >= so no check

;SkipBonesCheck:                                   ; ...
;.skipbones
    ;ld          iy, PlayerStatus
    ;call        CheckEnemyCollision                       ; check player collides with enemy
    ;ret         c                                         ; no collision, quit
 
    ; check enemy hits shield
    cmp.b             #POWERUP_SHIELD,PlayerStatus+PLAYER_PowerUp(a5)
    bne               .skipshield

    GETENEMYDIM
    GETSHIELDDIM
    CHECKCOLLISION
    bcs               .skipshield

    ; enemy collided with shield
    ; kill enemy and remove shield
    move.b            #POWERUP_NONE,PlayerStatus+PLAYER_PowerUp(a5)
    clr.b             PlayerStatus+PLAYER_SheildPower(a5)
    bra               KillEnemyScore

.skipshield
    GETENEMYDIM
    GETPLAYERDIM
    CHECKCOLLISION
    bcs               .exit

    ;ld          iy, PlayerStatus
    ;ld          a, (iy+PLAYER.Status)                     ; get player status
    ;cp          2                                         ; 2 = alive
    ;ret         nc                                        ; great than 2, must already be dead
    cmp.b             #PLAYERMODE_DEAD,PlayerStatus(a5)
    bcc               .exit
    ;ld          a, (iy+PLAYER.PowerUp)                    ; check player powerup
    ;cp          2                                         ; transparent powerup
    ;jr          c, EnemyKillsPlayer                       ; less powerup, kill the player
    ;ret         z
    cmp.b             #POWERUP_TRANSPARENT,PlayerStatus+PLAYER_PowerUp(a5)
    bcs               EnemyKillsPlayer                                        ; less powerup, kill the player
    beq               .exit                                                   ; transparent, no kill
    ; red power up? 
    ;jp          PlayerShotHitBonus
    bsr               KillEnemyScore                                          ; red power, kill enemy with bonus but not player
.exit
    rts
; ---------------------------------------------------------------------------

EnemyKillsPlayer:  
    ;call        KillPlayer
    bsr               KillPlayer
    ;jp          KillEnemy
    bra               KillEnemy


;----------------------------------------------------------------------------
;
; find enemy slot
;
; out
; a2 = enemy structure
;
;----------------------------------------------------------------------------


FindEnemySlot:
    ;ld         hl, EnemyList
    ;ld         b, 7                   ; max 7 enemies
    lea               EnemyList(a5),a2
    moveq             #ENEMY_COUNT-1,d0
    moveq             #ENEMY_Sizeof,d1
.loop
    ;ld         a, (hl)
    ;and        a
    ;jr         z, FoundEnemySlot
    ;ld         a, 20h                 ; ' '
    ;call       ADD_A_HL
    ;djnz       FindEnemySlotLoop
    ;or         1
    ;ret
    tst.b             (a2)
    beq               .found
    add.l             d1,a2
    dbra              d0,.loop
    move              #1,ccr
    rts

.found
    ;push       hl
    ;pop        ix
    ;ret
    move              #0,ccr
    rts
        
;----------------------------------------------------------------------------
;
;  add fire logic
;
; d2 = y
; d3 = x
;
;----------------------------------------------------------------------------


AddFireEnemy:
    bsr               FindEnemySlot
    bcc               .found
    rts

.found
    move.w            d2,ENEMY_PosY(a2)
    move.w            d3,ENEMY_PosX(a2)
    move.w            #-1,ENEMY_ShadowSlot(a2)
    move.w            #-1,ENEMY_BobSlot2(a2)
    clr.b             ENEMY_FireCount(a2)
    move.b            #6,ENEMY_WaitCounter(a2)
    move.b            #1,ENEMY_DeathFlag(a2)
    RANDOM
    move.b            d0,ENEMY_Random(a2)
    and.b             #$1f,d0
    add.b             d0,d2
    add.b             d0,d3
    PUSHM             d2/d3
    move.b            #2,ENEMY_Id(a2)                                         ; bat but this is no bat
    move.b            #3,ENEMY_Status(a2)                                     ; straight to the fire
    bsr               BobAllocate
    move.w            d0,ENEMY_BobSlot(a2)
    POPM              d2/d3
    move.w            d2,Bob_Y(a4)
    move.w            d3,Bob_X(a4)
    
    moveq             #$d,d0
    bra               SfxPlayAllChan

    rts
;----------------------------------------------------------------------------
;
;  add logic
;
; a1 = attack wave structure
;
;----------------------------------------------------------------------------


AddEnemy:                                         ; ...
    ;call       FindEnemySlot
    ;ret        nz
    bsr               FindEnemySlot
    bcc               .found
    rts

.found
    RANDOM
    move.b            d0,ENEMY_Random(a2)

    move.b            ATTACKWAVE_Type(a1),d0
    move.b            d0,ENEMY_Id(a2)

    bsr               PrepEnemyBobs

    ;ld         (ix+ENEMY_Status), 1
    ;ld         (ix+ENEMY_ShootStatus), 0FFh

    move.b            #1,ENEMY_Status(a2)
    move.b            #-1,ENEMY_ShootStatus(a2)

    ;ld         a, (iy+ATTACKWAVE_SpriteSlotId)
    ;ld         (ix+ENEMY_SpriteSlotId), a

    ;ld         a, (iy+ATTACKWAVE_Type)
    ;ld         (ix+ENEMY_Id), a


    ;bit        6, a
    ;jr         z, loc_734F
    btst              #6,ENEMY_Id(a2)
    beq               .loady

    ;ld         hl, unk_E1E2
    ;ld         a, (hl)
    ;push       af
    ;ld         c, a
    ;add        a, a
    ;add        a, c
    ;inc        hl
    ;call       ADD_A_HL


    moveq             #0,d0
    move.b            EnemyBonusSlot(a5),d0
    move.w            d0,d2
    mulu              #BONUS_Sizeof,d0
    
    lea               EnemyBounsCounts(a5),a0
    add.l             d0,a0

    ;pop        af
    ;rla
    ;rla
    ;rla
    ;rla
    ;and        0F0h
    ;ld         c, a
    ;ld         a, (hl)
    ;ld         b, a
    ;or         c
    ;ld         (ix+ENEMY_ShootStatus), a

    lsl.b             #4,d2
    move.b            BONUS_Count1(a0),d0
    move.b            d0,d1
    or.b              d2,d0
    move.b            d0,ENEMY_ShootStatus(a2)

    ;inc        (hl)
    addq.b            #1,BONUS_Count1(a0)

    ;inc        hl
    ;ld         a, (ix+ENEMY_Id)
    ;and        0Fh
    move.b            ENEMY_Id(a2),d0
    and.w             #$f,d0

    ;ld         de, WaveRepeatList
    ;call       ADD_A_DE
    lea               WaveRepeatList,a3

    ;ld         a, (de)
    ;cp         1
    ;jr         nz, loc_7344
    ;ld         a, 0FFh
    move.b            (a3,d0),d0
    cmp.b             #1,d0
    bne               .skipsome

    moveq             #-1,d0
;loc_7344:                                         ; ...
.skipsome
    ;ld         (hl), a
    move.b            d0,BONUS_Count2(a0)
    ;ld         a, b
    ;and        a
    ;jr         nz, loc_734F
    tst.b             d1
    bne               .loady

    ;ld         a, (PlayerX)
    ;ld         (TempX), a
    move.b            PlayerStatus+PLAYER_PosX(a5),TempX(a5)

.loady  ; loc_734F
    ;ld         a, (iy+ATTACKWAVE_Type)
    ;and        0Fh
    moveq             #0,d0
    move.b            ATTACKWAVE_Type(a1),d0
    and.b             #$f,d0

    ;ld         hl, EnemyStartPosY
    ;call       ADD_A_HL
    ;ld         a, (hl)

    lea               EnemyStartPosY,a0
    move.b            (a0,d0.w),d0

    ;ld         (ix+ENEMY_PosY), a
    clr.w             ENEMY_PosY(a2)
    move.b            d0,ENEMY_PosY(a2)

    ;ld         hl, EnemyStartPosX1
    ;ld         a, (iy+ATTACKWAVE_SpawnCount)
    ;ld         c, a
    ;and        7
    ;call       ADD_A_HL
    ;ld         a, c
    ;and        a
    ;ld         c, (hl)
    ;jr         nz, EnemyLoadPosX
    lea               EnemyStartPosX1,a0
    moveq             #0,d0
    move.b            ATTACKWAVE_SpawnCount(a1),d0
    move.b            d0,d2
    and.b             #7,d0
    add.l             d0,a0
    move.b            d2,d0
    move.b            (a0),d2
    tst.b             d0
    bne               .loadx

    ;ld         a, (ix+ENEMY_Id)
    ;bit        6, a
    ;ld         a, (TempXD)
    ;jr         nz, loc_737C
    ;ld         a, (PlayerX)
    move.b            TempX(a5),d0
    btst.b            #6,ENEMY_Id(a2)
    bne               .notplayerx
    move.b            PlayerStatus+PLAYER_PosX(a5),d0

.notplayerx
    ;cp         87h
    ;ld         c, 50h                             ; 'P'
    ;jr         nc, EnemyLoadPosX
    ;ld         c, 0B0h
    moveq             #$50,d2
    cmp.b             #$87,d0
    bcc               .loadx
    move.b            #$b0,d2
.loadx
    ;ld         (ix+ENEMY_PosX), c
    clr.w             ENEMY_PosX(a2)
    move.b            d2,ENEMY_PosX(a2)

    ;ld         hl, EnemyStartPosX2
    ;ld         a, (ix+ENEMY_Id)
    ;and        0Fh
    ;call       ADD_A_HL
    ;ld         a, (hl)
    ;ld         (iy+ATTACKWAVE_WaitDelay), a

    lea               EnemyWaitDelay,a0
    move.b            ENEMY_Id(a2),d0
    and.w             #$f,d0
    move.b            (a0,d0.w),ATTACKWAVE_WaitDelay(a1)

    ;ld         a, (iy+ATTACKWAVE_RepeatCount)
    ;and        a
    ;ret        nz
    tst.b             ATTACKWAVE_RepeatCount(a1)
    bne               .exit

    ;ld         a, (iy+ATTACKWAVE_Type)
    ;bit        6, a
    ;jr         z, loc_73B9
    btst              #6,ATTACKWAVE_Type(a1)
    beq               .done 

    ;ld         hl, unk_E1E2
    ;inc        (hl)
    ;ld         a, (hl)
    ;and        3
    ;ld         (hl), a
    move.b            EnemyBonusSlot(a5),d0
    addq.b            #1,d0
    and.w             #3,d0
    move.b            d0,EnemyBonusSlot(a5)

    ;ld         hl, unk_E1E3
    ;ld         c, a
    ;add        a, a
    ;add        a, c
    ;call       ADD_A_HL
    ;xor        a
    ;ld         (hl), a
    ;inc        hl
    ;ld         (hl), a
    ;inc        hl
    ;ld         (hl), a
    mulu              #BONUS_Sizeof,d0
    lea               EnemyBounsCounts(a5),a0
    add.l             d0,a0
    clr.b             BONUS_Count1(a0)
    clr.b             BONUS_Count2(a0)
    clr.b             BONUS_Count3(a0)

.done
    ;inc        (iy+ATTACKWAVE_SpawnCount)
    ;ld         a, (iy+ATTACKWAVE_SpawnCount)
    ;cp         (iy+ATTACKWAVE_SpawnTotal)
    ;ret        c
    addq.b            #1,ATTACKWAVE_SpawnCount(a1)
    move.b            ATTACKWAVE_SpawnCount(a1),d0
    cmp.b             ATTACKWAVE_SpawnTotal(a1),d0
    bcs               .exit

    ;xor        a
    ;ld         (iy+ATTACKWAVE), a                 ; finish attack wave
    ;ld         (iy+ATTACKWAVE_WaitDelay), a
    ;ld         (iy+ATTACKWAVE_SpawnCount), a
    ;ret
    moveq             #0,d0
    move.b            d0,ATTACKWAVE_Type(a1)
    move.b            d0,ATTACKWAVE_WaitDelay(a1)
    move.b            d0,ATTACKWAVE_SpawnCount(a1)
.exit
    rts


;----------------------------------------------------------------------------
;
; prep enemy bobs
;
;----------------------------------------------------------------------------

PrepEnemyBobs:
    move.w            #-1,ENEMY_BobSlot2(a2)
    move.w            #-1,ENEMY_ShadowSlot(a2)
    move.b            ENEMY_Id(a2),d3
    and.w             #$f,d3
    lea               EnemyShadowOffsets,a0
    move.b            (a0,d3.w),d3
    beq               .noshadow

    move.w            d3,ENEMY_ShadowSlot(a2)

.noshadow

    bsr               BobAllocate
    move.w            d0,ENEMY_BobSlot(a2)

    move.b            ENEMY_Id(a2),d0
    and.w             #$f,d0
    move.w            d0,d1
    add.w             d0,d0
    add.w             d0,d0
    lea               EnemyBobLookup(a5),a0
    move.l            (a0,d0.w),ENEMY_BobPtr(a2)                              ; set enemy bob pointer
    rts


;----------------------------------------------------------------------------
;
; process enemy logic
;
; in
; a2 = enemy structure
;
;----------------------------------------------------------------------------


ProcessEnemyLogic:                                
    ;ld         a, (FreezeStatus)
    ;and        a
    ;jr         z, EnemyLogicNoFreeze
    tst.b             FreezeStatus(a5)
    beq               .nofreeze

    ;call       GetEnemyDeathStatus                       ; get enemy death status

    ;cp         (hl)
    ;ret        c
    tst.b             ENEMY_DeathFlag(a2)
    bne               .nofreeze
    bra               UpdateEnemyShadow
    
.nofreeze
    ;ld         a, (ix+ENEMY_Id)
    ;and        0Fh
    move.b            ENEMY_Id(a2),d0
    and.w             #$f,d0

RunEnemyLogic:                                    ; ...
    ;ld         hl, EnemyLogicList                        ; 0 - devil
    ;call       ADD_AX2_HL_LDHL
    ;jp         JumpEnemyLogic                            ; enemy status
    lea               BobMatrix(a5),a4
    JMPINDEX          d0

EnemyLogicList:
    dc.w              DevilLogic-EnemyLogicList                               ; 0 DevilLogicList-EnemyLogicList             ; 0 - devil
    dc.w              Bat1Logic-EnemyLogicList                                ; 1 Bat1LogicList-EnemyLogicList              ; 1 - bats
    dc.w              Bat2Logic-EnemyLogicList                                ; 2 Bat2LogicList-EnemyLogicList              ; 2 - more bats?
    dc.w              BatLowLogic-EnemyLogicList                              ; 3 BatLowLogicList-EnemyLogicList            ; 3 - bat low entry
    dc.w              GargoyleLogic-EnemyLogicList                            ; 4 GargoyleLogicList-EnemyLogicList          ; 4 - gargoyle
    dc.w              HeadLogic-EnemyLogicList                                ; 5 HeadLogicList-EnemyLogicList              ; 5 - floating head
    dc.w              HoodieLogic-EnemyLogicList                              ; 6 HoodLogicList-EnemyLogicList              ; 6 - hoodie
    dc.w              BonesLogic-EnemyLogicList                               ; 7 BonesLogicList-EnemyLogicList             ; 7 - bones
    dc.w              GhostLogic-EnemyLogicList                               ; 8 GhostLogicList-EnemyLogicList             ; 8 - ghost
    dc.w              BlueKnightLogic-EnemyLogicList                          ; 9 BlueKnightLogicList-EnemyLogicList        ; 9 - blue knights
    dc.w              FireballLogic-EnemyLogicList                            ; a FireballLogicList-EnemyLogicList          ; A - fireball
    dc.w              SpikeBallLogic-EnemyLogicList                           ; b SpikeBallLogicList-EnemyLogicList         ; B - spike ball
    dc.w              CloudLogic-EnemyLogicList                               ; c CloudLogicList-EnemyLogicList             ; C - clouds
    dc.w              BlinkerLogic-EnemyLogicList                             ; d BlinkerLogicList-EnemyLogicList           ; D - floating head blinker
    dc.w              BlobLogic-EnemyLogicList                                ; e BlobLogicList-EnemyLogicList              ; E - blob
    dc.w              KongLogic-EnemyLogicList                                ; f KongLogicList-EnemyLogicList              ; F - kong



;----------------------------------------------------------------------------
;
; enemy clear
;
; clears some details
;
;----------------------------------------------------------------------------


EnemyClear:
    ;lea               ENEMY_SpeedY(a2),a0
    ;REPT              (ENEMY_BobSlot-ENEMY_SpeedY)/2
    ;clr.w             (a0)+
    ;ENDR
    clr.w             ENEMY_SpeedY(a2)
    clr.w             ENEMY_SpeedX(a2)
    clr.b             ENEMY_SpriteId(a2)
    clr.b             ENEMY_OffsetX(a2)
    clr.b             ENEMY_OffsetY(a2)
    clr.b             ENEMY_WaitCounter(a2)
    clr.b             ENEMY_ShotCounter(a2)
    clr.b             ENEMY_DeathFlag(a2)
    clr.b             ENEMY_Safe(a2)
    clr.b             ENEMY_BobId(a2)
    clr.b             ENEMY_FrameCount(a2)
    move.b            #-1,ENEMY_BobIdPrev(a2)
    move.b            #1,ENEMY_HitPoints(a2)
    clr.b             ENEMY_BonesDeathCount(a2)
    rts

;----------------------------------------------------------------------------
;
; animate 2
;
; animates enemy for 2 frames
;
;----------------------------------------------------------------------------

Animate2:
    ;ld          a, (TickCounter)
    ;bit         3, a
    ;jr          z, AnimateEnemySkip
    ;inc         b
    ;ld          (ix+ENEMY_SpriteId), b
    ;ret
    moveq             #0,d1
    move.b            ENEMY_Random(a2),d0
    add.b             TickCounter(a5),d0
    btst              #3,d0
    beq               .skip
    addq.b            #1,d1
.skip
    move.b            d1,ENEMY_BobId(a2)
    rts
        
;----------------------------------------------------------------------------
;
; animate seqeunce
;
; animates a sequnce of id's
;
;----------------------------------------------------------------------------

AnimatePingPong:
    ;ld          a, (TickCounter)
    ;bit         3, a
    ;jr          z, AnimateEnemySkip
    ;inc         b
    ;ld          (ix+ENEMY_SpriteId), b
    ;ret
    move.b            ENEMY_Random(a2),d0
    add.b             TickCounter(a5),d0
    and.b             #3,d0                                                  
    bne               .skip

    ;addq.b      #1,ENEMY_AnimTick(a2)

    move.l            ENEMY_AnimPtr(a2),a0
    moveq             #0,d0
    move.b            ENEMY_AnimTick(a2),d0
    add.l             d0,a0

    addq.b            #1,d0
    move.b            (a0)+,d1
    tst.b             (a0)
    bpl               .store

    moveq             #0,d0                                                   ; reset tick

.store
    move.b            d0,ENEMY_AnimTick(a2)
    move.b            d1,ENEMY_BobId(a2)
.skip
    rts
;----------------------------------------------------------------------------
;
; move enemy
;
; a2 = enemy structure
;
;----------------------------------------------------------------------------

MoveEnemy: 
    move.w            ENEMY_BobSlot(a2),d0
    lea               (a4,d0.w),a3                                            ; bob structure used multiple times below so copy direct location to a3
    ;inc         l
    ;inc         l                                         ; move to PosYDec
    ;ld          d, h                                      ; copy pointer to de
    ;ld          e, l
    ;inc         e
    ;inc         e
    ;inc         e
    ;inc         e                                         ; de = speedYdec
    ;ld          a, (de)                                   ; load speed
    ;add         a, (hl)                                   ; add position
    ;ld          (hl), a                                   ; store new value
    ;inc         l                                         ; move to integer value
    ;inc         e                                         ; move to integer value
    ;ld          a, (de)                                   ; load speed
    ;adc         a, (hl)                                   ; add position (including carry)
    ;ld          (hl), a                                   ; store value

    ;move.w      ENEMY_PosY(a2),d0
    ;add.w       ENEMY_SpeedY(a2),d0
    ;move.w      d0,ENEMY_PosY(a2)
    move.w            ENEMY_SpeedY(a2),d0
    asr.w             #1,d0                                                   ; half speed, running every frame
    add.w             d0,ENEMY_PosY(a2)

    ; range check
    ;cp          0A8h                                      ; range check 1
    ;jr          c, MoveEnemyInRangeY                      ; move to x
    ;cp          0E8h
    ;jr          c, MoveEnemyOutRange                      ; set y pos $e0 (out of range for sprite)


;MoveEnemyInRangeY:                                ; ...
    ;inc         l                                         ; move to x
    ;inc         e                                         ; move to x
    ;ld          a, (de)                                   ; load speed x
    ;add         a, (hl)                                   ; add pos x
    ;ld          (hl), a                                   ; store new pos x
    ;inc         l                                         ; move to integer value
    ;inc         e                                         ; move to integer value
    ;ld          a, (de)                                   ; load speed
    ;adc         a, (hl)                                   ; add pos (including carry)
    ;ld          (hl), a                                   ; store new pos
    ;sub         8
    ;cp          0F0h                                      ; range check
    ;ret         c                                         ; in range
    ;dec         l
    ;dec         l                                         ; move back to y pos
    ;move.w      ENEMY_PosX(a2),d0
    ;add.w       ENEMY_SpeedX(a2),d0
    ;move.w      d0,ENEMY_PosX(a2)

    ;move.w      ENEMY_PosX(a2),d0
    ;add.w       ENEMY_SpeedX(a2),d0
    ;move.w      d0,ENEMY_PosX(a2)

    move.w            ENEMY_SpeedX(a2),d0
    asr.w             #1,d0                                                   ; half speed, running every frame
    add.w             d0,ENEMY_PosX(a2)

    moveq             #16,d0
    add.b             ENEMY_PosY(a2),d0
    sub.w             #16,d0
    move.w            d0,Bob_Y(a3)

    cmp.w             #$c8,d0
    bgt               RemoveEnemy

    moveq             #0,d0
    move.b            ENEMY_PosX(a2),d0
    move.w            d0,Bob_X(a3)

    sub.b             #8,d0
    cmp.b             #$f0,d0                                                 ; TODO: maybe wider edges??
    bcc               RemoveEnemy

UpdateEnemyBob:
    moveq             #0,d0
    move.b            ENEMY_BobId(a2),d0  
    cmp.b             ENEMY_BobIdPrev(a2),d0
    beq               UpdateEnemyShadow

    move.b            d0,ENEMY_BobIdPrev(a2)

    move.w            ENEMY_BobSlot(a2),d1
    lea               (a4,d1.w),a3                                            ; bob structure used multiple times below so copy direct location to a3
    
    move.l            ENEMY_BobPtr(a2),a0

    add.w             d0,d0
    add.w             d0,d0
    move.l            (a0,d0.w),a0

    BOBSET            a0,a3
    sf                Bob_Hide(a3)

UpdateEnemyShadow:
    move.w            ENEMY_ShadowSlot(a2),d0                                 ; update shadow is it exists
    bmi               .noshadow

    move.l            ShadowBobPtrs(a5),a0

    move.b            TickCounter(a5),d1
    add.b             ENEMY_Random(a2),d1
    and.b             #1,d1
    beq               .other
    beq               .loadshadow

    move.l            ShadowBobPtrs+4(a5),a0
.other
    moveq             #16,d0
    add.b             ENEMY_PosY(a2),d0
    sub.w             #16,d0
    add.w             ENEMY_ShadowSlot(a2),d0
    moveq             #0,d4
    move.b            ENEMY_PosX(a2),d4
    PUSHM             a2/a4/d7
    bsr               BobDrawDirect
    POPM              a2/a4/d7

.loadshadow
    ;BOBSET            a0,a4
    ;move.w            d3,Bob_OffsetY(a4)
    ;POP               a4
.noshadow
    rts

;MoveEnemyOutRange:                                ; ...
    ;ld          (hl), 0E0h                                ; set y pos $e0 (out of range for sprite)
    ;dec         l
    ;dec         l
    ;dec         l
    ;ld          (hl), 0                                   ; remove enemy
    ;ret

 ;----------------------------------------------------------------------------
;
; remove enemy
;
; in 
; a2 = enemy structure
; a4 = bob matrix
;----------------------------------------------------------------------------

RemoveEnemy:
    tst.b             ENEMY_Status(a2)                                        ; enemy not active, dont remove
    beq               .skip
    clr.b             ENEMY_Status(a2) 
    move.w            ENEMY_BobSlot(a2),d0
    clr.b             Bob_Allocated(a4,d0.w)
    move.w            ENEMY_BobSlot2(a2),d0                                   ; update shadow is it exists
    bmi               .skip
    clr.b             Bob_Allocated(a4,d0.w)
.skip
    rts



;----------------------------------------------------------------------------
;
; enemy fire death
;
;----------------------------------------------------------------------------


EnemyFireDeath:
    ;ld          a, (TickCounter)
    ;bit         1, a
    ;ld          a, 1
    ;jr          z, EnemyFireDeath1Blink
    ;inc         a
    PUSH              a4
    move.w            ENEMY_BobSlot(a2),d4
    lea               (a4,d4.w),a4

    subq.w            #1,Bob_Y(a4)

    moveq             #0,d0
    move.b            ENEMY_FireCount(a2),d0
    btst              #0,TickCounter(a5)
    beq               .frameone
    addq.b            #1,d0

    ;cmp.w             #0,Bob_Y(a4)
    ;ble               .frameone

.frameone
    add.w             d0,d0
    add.w             d0,d0
    lea               FireDeathBobPtrs(a5),a0
    move.l            (a0,d0.w),a0

    BOBSET            a0,a4
    sf                Bob_Hide(a4)
    POP               a4

    ;ld          (ix+ENEMY_SpriteId), a
    ;dec         (ix+ENEMY_WaitCounter)
    ;ret         nz
    ;ld          a, 6
    ;jp          DevilWaitNextStatus
    ;addq.b            #1,ENEMY_Status(a2)
    subq.b            #1,ENEMY_WaitCounter(a2)
    bne               .exit

    move.b            #6,ENEMY_WaitCounter(a2)    
    addq.b            #1,ENEMY_FireCount(a2)
    cmp.b             #5,ENEMY_FireCount(a2)
    bcs               .exit

    addq.b            #1,ENEMY_Status(a2)
.exit
    rts         
; ---------------------------------------------------------------------------

EnemyFireDeath2:                                  ; ...
    ;ld          a, (TickCounter)
    ;bit         1, a
    ;ld          a, 2
    ;jr          z, EnemyFireDeath2Blink
    ;inc         a

EnemyFireDeath2Blink:                             ; ...
    ;ld          (ix+ENEMY_SpriteId), a
    ;dec         (ix+ENEMY_WaitCounter)
    ;ret         nz
    ;ld          a, 6
    ;jp          DevilWaitNextStatus
; ---------------------------------------------------------------------------

;EnemyFireDeath3:                                  ; ...
EnemyBonusCheck:
    ;ld          a, (TickCounter)
    ;bit         1, a
    ;ld          a, 3
    ;jr          z, EnemyFireDeath3Blink
    ;xor         a

EnemyFireDeath3Blink:                             ; ...
    ;ld          (ix+ENEMY_SpriteId), a
    ;dec         (ix+ENEMY_WaitCounter)
    ;ret         nz
    ;ld          a, (PlayerStatus)
    ;cp          2
    ;jr          z, ResetEnemyStatus
    cmp.b             #PLAYERMODE_DEAD,PlayerStatus(a5)
    beq               RemoveEnemy

    ;ld          a, (ix+ENEMY_Id)
    ;bit         6, a
    ;jr          z, ResetEnemyStatus
    btst              #6,ENEMY_Id(a2)
    beq               RemoveEnemy

    ;ld          a, (ix+ENEMY_ShootStatus)
    ;rra
    ;rra
    ;rra
    ;rra
    ;and         0Fh
    moveq             #0,d0
    move.b            ENEMY_ShootStatus(a2),d0
    lsr.b             #4,d0


    ;ld          hl, unk_E1E4
    ;ld          c, a
    ;add         a, a
    ;add         a, c
    ;call        ADD_A_HL
    ;ld          a, (hl)
    ;inc         hl
    ;inc         (hl)
    ;cp          (hl)
    ;jr          nz, ResetEnemyStatus
    lea               EnemyBounsCounts(a5),a0
    mulu              #BONUS_Sizeof,d0
    lea               (a0,d0.w),a0

    move.b            BONUS_Count2(a0),d0
    addq.b            #1,BONUS_Count3(a0)
    cmp.b             BONUS_Count3(a0),d0
    bne               RemoveEnemy

    move.w            #1000,d0
    bsr               AddScore

    ;ld          de, 1000h
    ;call        AddScore                                  ; add score
                                                  ;
                                                  ; de = score 0000xxxx
                                                  ; bc = score xxxx0000
                                                  ;
    ;ld          a, 8
    ;ld          (ix+ENEMY_SpriteId), 4
    ;jp          DevilWaitNextStatus
    move.b            #32,ENEMY_WaitCounter(a2)
    addq.b            #1,ENEMY_Status(a2)
    
    PUSH              a4
    move.w            ENEMY_BobSlot(a2),d4
    lea               (a4,d4.w),a4

    tst.w             Bob_Y(a4)
    bpl               .onscreen
    clr.w             Bob_Y(a4)
.onscreen
    lea               BobBonus1000_0,a0
    BOBSET            a0,a4

    POP               a4
    
    rts
; ---------------------------------------------------------------------------

ResetEnemyStatus:                                 ; ...
    ;ld          (ix+ENEMY_Status), 0
    ;ld          (ix+ENEMY_PosY), 0E0h
    ;ret
; ---------------------------------------------------------------------------

EnemyBonusWait:                                   ; ...
    ;dec         (ix+ENEMY_WaitCounter)
    ;ret         nz
    ;jr          ResetEnemyStatus
    subq.b            #1,ENEMY_WaitCounter(a2)
    move.b            ENEMY_WaitCounter(a2),d0
    beq               RemoveEnemy
    cmp.b             #16,d0
    bcc               .noflash

    move.w            ENEMY_BobSlot(a2),d4
    and.b             #1,d0
    move.b            d0,Bob_Hide(a4,d4.w)
    
.noflash
    rts


    ; enemy code includes
    incdir            "logic/enemy"
    include           "blob.asm"
    include           "bat1.asm"
    include           "bat2.asm"
    include           "blueknight.asm"
    include           "cloud.asm"
    include           "gargoyle.asm"
    include           "bones.asm"
    include           "spikeball.asm"
    include           "devil.asm"
    include           "batlow.asm"
    include           "fireball.asm"
    include           "ghost.asm"
    include           "head.asm"
    include           "hoodie.asm"
    include           "kong.asm"
    include           "blinker.asm"

    include           "logic/enemyshot.asm"
