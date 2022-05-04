
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
    tst.b             BossDeathFlag(a5)
    bne               .run

    tst.b             BossStatus(a5)
    bne               .exit

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


EnemyCollisionLogic:                       
    tst.b             ENEMY_DeathFlag(a2)
    bne               .exit

    move.b            ENEMY_Id(a2),d0
    and.w             #$f,d0

    ;cmp.b             #7,d0
    ;bne               .skipbones

    ;ld          a, (ix+ENEMY.Status)
    ;cp          4                                         ; bones status 4
    ;ret         nc                                        ; >= so no check

;SkipBonesCheck:                            
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

    cmp.b             #PLAYERMODE_DEAD,PlayerStatus(a5)
    bcc               .exit

    cmp.b             #POWERUP_TRANSPARENT,PlayerStatus+PLAYER_PowerUp(a5)
    bcs               EnemyKillsPlayer                                        ; less powerup, kill the player
    beq               .exit                                                   ; transparent, no kill

    bsr               KillEnemyScore                                          ; red power, kill enemy with bonus but not player
.exit
    rts
; ---------------------------------------------------------------------------

EnemyKillsPlayer:  
    bsr               KillPlayer
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
    lea               EnemyList(a5),a2
    moveq             #ENEMY_COUNT-1,d0
    moveq             #ENEMY_Sizeof,d1
.loop
    tst.b             (a2)
    beq               .found
    add.l             d1,a2
    dbra              d0,.loop
    move              #1,ccr
    rts

.found
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


AddEnemy:                                  
    bsr               FindEnemySlot
    bcc               .found
    rts

.found
    RANDOM
    move.b            d0,ENEMY_Random(a2)

    move.b            ATTACKWAVE_Type(a1),d0
    move.b            d0,ENEMY_Id(a2)

    bsr               PrepEnemyBobs

    move.b            #1,ENEMY_Status(a2)
    move.b            #-1,ENEMY_ShootStatus(a2)

    btst              #6,ENEMY_Id(a2)
    beq               .loady


    moveq             #0,d0
    move.b            EnemyBonusSlot(a5),d0
    move.w            d0,d2
    mulu              #BONUS_Sizeof,d0
    
    lea               EnemyBounsCounts(a5),a0
    add.l             d0,a0

    lsl.b             #4,d2
    move.b            BONUS_Count1(a0),d0
    move.b            d0,d1
    or.b              d2,d0
    move.b            d0,ENEMY_ShootStatus(a2)

    addq.b            #1,BONUS_Count1(a0)

    move.b            ENEMY_Id(a2),d0
    and.w             #$f,d0

    lea               WaveRepeatList,a3

    move.b            (a3,d0),d0
    cmp.b             #1,d0
    bne               .skipsome

    moveq             #-1,d0
.skipsome
    move.b            d0,BONUS_Count2(a0)
    tst.b             d1
    bne               .loady

    move.b            PlayerStatus+PLAYER_PosX(a5),TempX(a5)

.loady 
    moveq             #0,d0
    move.b            ATTACKWAVE_Type(a1),d0
    and.b             #$f,d0

    lea               EnemyStartPosY,a0
    move.b            (a0,d0.w),d0

    clr.w             ENEMY_PosY(a2)
    move.b            d0,ENEMY_PosY(a2)

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

    move.b            TempX(a5),d0
    btst.b            #6,ENEMY_Id(a2)
    bne               .notplayerx
    move.b            PlayerStatus+PLAYER_PosX(a5),d0

.notplayerx
    moveq             #$50,d2
    cmp.b             #$87,d0
    bcc               .loadx
    move.b            #$b0,d2
.loadx
    clr.w             ENEMY_PosX(a2)
    move.b            d2,ENEMY_PosX(a2)

    lea               EnemyWaitDelay,a0
    move.b            ENEMY_Id(a2),d0
    and.w             #$f,d0
    move.b            (a0,d0.w),ATTACKWAVE_WaitDelay(a1)

    tst.b             ATTACKWAVE_RepeatCount(a1)
    bne               .exit

    btst              #6,ATTACKWAVE_Type(a1)
    beq               .done 

    move.b            EnemyBonusSlot(a5),d0
    addq.b            #1,d0
    and.w             #3,d0
    move.b            d0,EnemyBonusSlot(a5)

    mulu              #BONUS_Sizeof,d0
    lea               EnemyBounsCounts(a5),a0
    add.l             d0,a0
    clr.b             BONUS_Count1(a0)
    clr.b             BONUS_Count2(a0)
    clr.b             BONUS_Count3(a0)

.done
    addq.b            #1,ATTACKWAVE_SpawnCount(a1)
    move.b            ATTACKWAVE_SpawnCount(a1),d0
    cmp.b             ATTACKWAVE_SpawnTotal(a1),d0
    bcs               .exit

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
    tst.b             FreezeStatus(a5)
    beq               .nofreeze

    tst.b             ENEMY_DeathFlag(a2)
    bne               .nofreeze
    bra               UpdateEnemyShadow
    
.nofreeze
    move.b            ENEMY_Id(a2),d0
    and.w             #$f,d0

RunEnemyLogic:                             
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
    move.b            ENEMY_Random(a2),d0
    add.b             TickCounter(a5),d0
    and.b             #3,d0                                                  
    bne               .skip

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

    move.w            ENEMY_SpeedY(a2),d0
    asr.w             #1,d0                                                   ; half speed, running every frame
    add.w             d0,ENEMY_PosY(a2)

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

.noshadow
    rts

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
    PUSH              a4
    move.w            ENEMY_BobSlot(a2),d4
    lea               (a4,d4.w),a4

    subq.w            #1,Bob_Y(a4)

    moveq             #0,d0
    move.b            ENEMY_FireCount(a2),d0
    btst              #0,TickCounter(a5)
    beq               .frameone
    addq.b            #1,d0

.frameone
    add.w             d0,d0
    add.w             d0,d0
    lea               FireDeathBobPtrs(a5),a0
    move.l            (a0,d0.w),a0

    BOBSET            a0,a4
    sf                Bob_Hide(a4)
    POP               a4

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

EnemyBonusCheck:
    cmp.b             #PLAYERMODE_DEAD,PlayerStatus(a5)
    beq               RemoveEnemy

    btst              #6,ENEMY_Id(a2)
    beq               RemoveEnemy

    moveq             #0,d0
    move.b            ENEMY_ShootStatus(a2),d0
    lsr.b             #4,d0

    lea               EnemyBounsCounts(a5),a0
    mulu              #BONUS_Sizeof,d0
    lea               (a0,d0.w),a0

    move.b            BONUS_Count2(a0),d0
    addq.b            #1,BONUS_Count3(a0)
    cmp.b             BONUS_Count3(a0),d0
    bne               RemoveEnemy

    move.w            #1000,d0
    bsr               AddScore

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

ResetEnemyStatus:                          

; ---------------------------------------------------------------------------

EnemyBonusWait:                            
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
