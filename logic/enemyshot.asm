

    include             "common.asm"

;----------------------------------------------------------------------------
;
; clear enemy shots
;
;----------------------------------------------------------------------------

KillEnemyShots:
    PUSHM               d0/d1/a0
    lea                 EnemyShotList(a5),a0
    moveq               #ENEMYSHOT_COUNT-1,d0
.loop
    clr.b               ENEMYSHOT_Status(a0)                            ; clear status

.skip
    lea                 ENEMYSHOT_Sizeof(a0),a0
    dbra                d0,.loop
    POPM                d0/d1/a0
    rts


;----------------------------------------------------------------------------
;
; enemy shot logic
;
; will shoot at player based on screen position and ....
;
; in
; a2 = enemy structure
; a4 = bob matrix
;
;----------------------------------------------------------------------------


EnemyShotLogic:   
    cmp.b               #$c0,ENEMY_PosY(a2)                             ; enemy position $c0
    bcc                 .exit                                           ; yes, dont shoot

    move.b              ENEMY_Id(a2),d2
    and.w               #$f,d2
    lea                 EnemyShotCounterMax,a0

    move.b              (a0,d2.w),d1                                    ; contains the number of shot positions for the given enemy

    move.b              Stage(a5),d4
    subq.b              #1,d4
    and.w               #$f,d4                                          ; stage

    cmp.b               #3,d4                                           ; stage 3 or higher, use full counter list
    bcc                 .harderlater

    subq.b              #1,d1

.harderlater
    lea                 EnemyShotCounterList,a0                         ; contains the enemys counter list
    move.w              d2,d0
    add.w               d0,d0
    add.w               d0,d0
    move.l              (a0,d0.w),a0                                    ; shot counter list

    moveq               #0,d0
    move.b              ENEMY_ShotCounter(a2),d0
    cmp.b               #3,d4                                           ; stage
    bcc                 .alwaysshoot

    cmp.b               #$ff,d0
    beq                 .exit

.alwaysshoot
    move.b              TickCounter(a5),d3
    and.b               #1,d3
    beq                 .loop                                           ; skip each frame

    addq.b              #1,d0                                           ; move shot counter up
    move.b              d0,ENEMY_ShotCounter(a2)

.loop
    cmp.b               (a0)+,d0                                        
    beq                 ShootAtPlayer
    subq.b              #1,d1
    bne                 .loop

.exit
    rts

; ---------------------------------------------------------------------------
;
; shoot at player
;
; sorts out direction, speed and type of shot
;
; in
; a2 = enemy structure
;
; ---------------------------------------------------------------------------

ShootAtPlayer:                             
    addq.b              #1,ENEMY_ShotCounter(a2)                        ; add another to shot counter as we are running every frame

    move.b              PlayerStatus+PLAYER_PosY(a5),d0
    add.b               #8,d0
    sub.b               ENEMY_PosY(a2),d0
    bcc                 .notnegy
    neg                 d0
.notnegy
    cmp.b               #$18,d0
    bcs                 .exit                                           ; too close, don't shoot

    move.b              PlayerStatus+PLAYER_PosX(a5),d0
    add.b               #8,d0
    sub.b               ENEMY_PosX(a2),d0
    bcc                 .notnegx
    neg                 d0
.notnegx
    cmp.b               #$18,d0
    bcs                 .exit                                           ; too close, don't shoot

    move.b              ENEMY_Id(a2),d1
    tst.b               EnemyShotsActive(a5)
    bne                 .shoot

    cmp.b               #4,Level(a5)
    bcc                 .shoot

    lsl.b               #1,d1
    bcc                 .exit
    cmp.b               #-1,ENEMY_ShootStatus(a2)
    beq                 .shoot

    and.b               #1,d1
    bne                 .exit

.shoot
    lea                 EnemyShotIds,a0
    move.b              ENEMY_Id(a2),d0
    and.w               #$f,d0
    move.b              (a0,d0.w),d0
    bra                 AddEnemyShot
.exit
    rts





; ---------------------------------------------------------------------------
;
; add enemy shot
;
; d0 = shot type
; a2 = enemy structure
;
; ---------------------------------------------------------------------------

AddEnemyShot:
    move.w              d0,d5                                           ; shot type temp

    move.l              #HoodieShotSpeeds,ShotSpeedPointer(a5)

    lea                 ShotRepeatCount,a0
    moveq               #0,d1
    move.b              d5,d1                                           ; shot type
    sub.b               #1,d1
    add.l               d1,a0

AddEnemyShot1:                             
    moveq               #0,d6
    move.b              (a0),d6                                         ; Shot repeat count

    bsr                 CalcAngleToPlayer
    move.b              d0,ShotAngle(a5)


    bsr                 GetEnemyShotSlot                                ; TODO: is this an early exit?
    bcs                 .exit

    cmp.b               #5,d5
    beq                 .addenemyshot2
    cmp.b               #$a,d5
    bne                 .addenemyshot3

    nop
.addenemyshot2  
    move.w              d6,d0                                           ; shot repeat max

    add.w               d0,d0
    add.w               d0,d0
    add.w               d6,d0
    add.w               d6,d0                                           ; * 6

    sub.b               d0,ShotAngle(a5)
.addenemyshot3     
    clr.b               EnemyShotId(a5)
    lea                 EnemyShotList(a5),a1

.loop
    tst.b               ENEMYSHOT_Status(a1)
    bne                 .shotskip
    
    bsr                 EnemyShotPosInit

    bsr                 EnemyShotJump
    
    subq.b              #1,d6
    beq                 .exit

.shotskip
    lea                 ENEMYSHOT_Sizeof(a1),a1

    addq.b              #1,EnemyShotId(a5)
    cmp.b               #8,EnemyShotId(a5)                              ; TODO: this is a bit nasty
    beq                 .exit
    bra                 .loop

.exit
    rts

;----------------------------------------------------------------------------
;
; enemy shot init
;
; in
; a1 = shot structure
; a2 = enemy structure
; d5 = enemy shot type
;
;----------------------------------------------------------------------------

EnemyShotPosInit:                          
    clr.b               ENEMYSHOT_BobId(a1)
    clr.b               ENEMYSHOT_BobIdPrev(a1)
    clr.b               ENEMYSHOT_DeathTimer(a1)

    move.b              d5,ENEMYSHOT_Type(a1)
    addq.b              #1,ENEMYSHOT_Status(a1)
    move.w              ENEMY_PosY(a2),ENEMYSHOT_PosY(a1)
    move.w              ENEMY_PosX(a2),ENEMYSHOT_PosX(a1)

    move.w              d5,d0
    add.w               d0,d0
    add.w               d0,d0
    lea                 EnemyShotBobLookup(a5),a0
    move.l              (a0,d0.w),a0
    move.l              a0,ENEMYSHOT_BobPtr(a1)

EnemyShotPosInit1:                         
    rts

;----------------------------------------------------------------------------
;
; find enemy slot
;
; out
; a1 = enemy structure
;
;----------------------------------------------------------------------------

GetEnemyShotSlot:
    lea                 EnemyShotList(a5),a1
    moveq               #ENEMYSHOT_COUNT-1,d0
    moveq               #ENEMYSHOT_Sizeof,d1
.loop
    tst.b               ENEMYSHOT_Status(a1)
    beq                 .found
    add.l               d1,a1
    dbra                d0,.loop
    move                #1,ccr
    rts

.found
    move                #0,ccr
    rts
        



; ---------------------------------------------------------------------------
;
; calc angle to gate
;
; in 
; a2 = enemy structure
;
; out 
; d0 = angle
;
; 5 bits per axis
; ---------------------------------------------------------------------------

CalcAngleToGate:
    moveq               #$20,d0

    moveq               #0,d1
    move.b              PlayerStatus+PLAYER_PosY(a5),d1
    sub.w               d1,d0
    asl.w               #3,d0

    moveq               #0,d1
    move.b              #$78,d1

    moveq               #0,d2
    move.b              PlayerStatus+PLAYER_PosX(a5),d2
    sub.w               d2,d1
    asr.w               #3,d1

    and.w               #%111111000000,d0
    and.b               #%000000111111,d1
    or.b                d1,d0

    lea                 AngleLookUp,a0
    move.b              (a0,d0.w),d0
    and.w               #$ff,d0
    rts

; ---------------------------------------------------------------------------
;
; calc angle to player
;
; in 
; a2 = enemy structure
;
; out 
; d0 = angle
;
; 6 bits per axis
;
; ---------------------------------------------------------------------------

CalcAngleToPlayer:
    moveq               #8,d0
    add.b               PlayerStatus+PLAYER_PosY(a5),d0
CalcAngleToPlayer1:
    moveq               #0,d1
    move.b              ENEMY_PosY(a2),d1
    sub.w               d1,d0
    asl.w               #3,d0

    moveq               #8,d1
    add.b               PlayerStatus+PLAYER_PosX(a5),d1

    moveq               #0,d2
    move.b              ENEMY_PosX(a2),d2
    sub.w               d2,d1
    asr.w               #3,d1

    and.w               #%111111000000,d0
    and.b               #%000000111111,d1
    or.b                d1,d0

    lea                 AngleLookUp,a0
    move.b              (a0,d0.w),d0
    and.w               #$ff,d0
    rts

;----------------------------------------------------------------------------
;
; calc enemy shot speed
;
; takes angle and turns it into speed y / x
;
;----------------------------------------------------------------------------

CalcEnemyShotSpeed:
    moveq               #0,d0
    move.b              ShotAngle(a5),d0
    bsr                 CalcSpeed

    lea                 EnemyShotMulti,a0
    moveq               #0,d0
    move.b              ENEMYSHOT_Type(a1),d0
    add.w               d0,d0
    add.l               d0,a0                                           ; multiplier data

    tst.b               EnemyShotsActive(a5)
    bne                 .nextval
    cmp.b               #4,Level(a5)
    bcs                 .calcspeed

.nextval 
    addq.l              #1,a0                                           ; use 2nd value

.calcspeed
    move.b              (a0),d0
    and.w               #$f,d0
    subq.b              #2,d0
    cmp.b               #1,d0
    bcs                 .nomulti

    and.w               #$f,d0
    muls                d0,d1
    muls                d0,d2
.nomulti
    move.w              d1,ENEMYSHOT_SpeedY(a1)                         ; TODO: mutiplier?
    move.w              d2,ENEMYSHOT_SpeedX(a1)
    rts




; =============== S U B R O U T I N E =======================================

; calculates the y and x speed of a shot based on the supplied angle
;
; in
; d0 = shot angle
;
; out
; d1 = speed y
; d2 = speed x

CalcSpeed:
    lea                 Sinus,a0

    move.b              d0,d1
    and.w               #$ff,d1
    add.w               d1,d1
    move.w              (a0,d1.w),d1

    move.b              d0,d2
    add.b               #$40,d2                                         ; cosine
    and.w               #$ff,d2
    add.w               d2,d2
    move.w              (a0,d2.w),d2

    rts

;----------------------------------------------------------------------------
;
; add enemy shot type jump
;
;----------------------------------------------------------------------------

EnemyShotMove:
    tst.b               BossStatus(a5)
    beq                 .noboss

    move.b              BossId(a5),d0
    cmp.b               #1,d0                                           ; boss id 1
    beq                 .exit                                           ; quit
    cmp.b               #3,d0                                           ; boss id 3
    beq                 .exit                                           ; quit

.noboss
    lea                 EnemyShotList(a5),a1
    lea                 BobMatrix(a5),a4
    moveq               #ENEMYSHOT_COUNT-1,d7

.loop
    tst.b               ENEMYSHOT_Status(a1)
    beq                 .skip
    bsr                 EnemyShotUpdate
    
    lea                 BobMatrix(a5),a4
    bsr                 CheckEnemyShotCollision
.skip
    lea                 ENEMYSHOT_Sizeof(a1),a1
    dbra                d7,.loop
.exit    
    rts

;----------------------------------------------------------------------------
;
; enemy shot update
;
;----------------------------------------------------------------------------

EnemyShotUpdate:
    move.w              ENEMYSHOT_SpeedY(a1),d0
    add.w               d0,ENEMYSHOT_PosY(a1)
    move.w              ENEMYSHOT_SpeedX(a1),d0
    add.w               d0,ENEMYSHOT_PosX(a1)

    move.b              ENEMYSHOT_PosX(a1),d0
    sub.b               #$f0,d0
    cmp.b               #8,d0
    bcs                 RemoveEnemyShot

    move.b              ENEMYSHOT_PosY(a1),d0

    cmp.b               #$c8,d0
    bcc                 RemoveEnemyShot

    move.b              ENEMYSHOT_PosX(a1),d0

    sub.b               #8,d0
    cmp.b               #$f0,d0     
    bcc                 RemoveEnemyShot

    bra                 EnemyShotAnim

RemoveEnemyShot:
    clr.b               ENEMYSHOT_Status(a1)
    rts

;----------------------------------------------------------------------------
;
; check enemy shot collision with player
;
; a1 = enemy shot structure
;
;----------------------------------------------------------------------------


CheckEnemyShotCollision:                   
    cmp.b               #PLAYERMODE_DEAD,PlayerStatus(a5)
    bcc                 .nohit

    move.b              PlayerStatus+PLAYER_PowerUp(a5),d0
    beq                 .playercheck

    subq.b              #1,d0
    beq                 .sheildcheck

    subq.b              #1,d0
    beq                 BonesShotCollisionCheck

.playercheck
    GETPLAYERDIM
    GETENEMYSHOTDIM
    CHECKCOLLISION
    bcs                 BonesShotCollisionCheck
    bsr                 RemoveEnemyShot

    cmp.b               #POWERUP_RED,PlayerStatus+PLAYER_PowerUp(a5)
    bcs                 KillPlayer
.nohit
    rts


.sheildcheck
    GETENEMYSHOTDIM
    GETSHIELDDIM
    CHECKCOLLISION
    bcs                 .playercheck

    moveq               #$11,d0
    bsr                 SfxPlay

    bsr                 RemoveEnemyShot

    move.b              PlayerStatus+PLAYER_SheildPower(a5),d0
    moveq               #1,d1
    cmp.b               #7,ENEMYSHOT_Type(a1)
    bcs                 .lower
    moveq               #4,d1
.lower
    sub.b               d1,d0
    move.b              d0,PlayerStatus+PLAYER_SheildPower(a5)
    bpl                 .exit
    clr.b               PlayerStatus+PLAYER_SheildPower(a5)
    clr.b               PlayerStatus+PLAYER_PowerUp(a5)
.exit
    rts
;----------------------------------------------------------------------------
;
; bones shot check
;
;----------------------------------------------------------------------------


BonesShotCollisionCheck:                    
    cmp.b               #6,ENEMYSHOT_Type(a1)
    bne                 .exit

    lea                 PlayerShot1(a5),a2
    btst.b              #7,PLAYERSHOT_Status(a2)
    bne                 .skip1

    nop

    GETPLAYERSHOTDIM    a2,a0
    GETENEMYSHOTDIM
    CHECKCOLLISION
    bcc                 .killshot

.skip1
    lea                 PlayerShot2(a5),a2
    btst.b              #7,PLAYERSHOT_Status(a2)
    bne                 .skip2

    GETPLAYERSHOTDIM    a2,a0
    GETENEMYSHOTDIM
    CHECKCOLLISION
    bcc                 .killshot
    
.skip2
    lea                 PlayerShot3(a5),a2
    btst.b              #7,PLAYERSHOT_Status(a2)
    bne                 .exit

    GETPLAYERSHOTDIM    a2,a0
    GETENEMYSHOTDIM
    CHECKCOLLISION
    bcs                 .exit

.killshot
    cmp.b               #3,PLAYERSHOT_WeaponId(a2)
    bcc                 .skipremove
    bset                #7,PLAYERSHOT_Status(a2)                        ; disable shot

.skipremove
    clr.b               ENEMYSHOT_Status(a1)
.exit
    rts

;----------------------------------------------------------------------------
;
; add enemy shot type jump
;
;----------------------------------------------------------------------------

EnemyShotJump:
    move.b              ENEMYSHOT_Type(a1),d0
    and.w               #$f,d0

    JMPINDEX            d0

AddShotIndex:
    dc.w                AddBullet-AddShotIndex                          ; AddArrow
    dc.w                AddArrow-AddShotIndex                           ; AddArrow
    dc.w                AddBullet-AddShotIndex                          ; AddBullet
    dc.w                AddBullet-AddShotIndex                          ; AddBullet
    dc.w                AddBullet-AddShotIndex                          ; AddBullet
    dc.w                AddDevilSparyShot-AddShotIndex                  ; AddDevilSparyShot
    dc.w                AddBullet-AddShotIndex                          ; AddBullet
    dc.w                AddHoodieSprayShot-AddShotIndex                 ; AddHoodieSprayShot
    dc.w                AddBullet-AddShotIndex                          ; AddBullet
    dc.w                AddBullet-AddShotIndex                          ; AddBullet
    dc.w                AddBatBossSparyShot-AddShotIndex                ; AddBatBossSparyShot
    dc.w                AddBullet-AddShotIndex                          ; AddBullet
    dc.w                AddKnightAxe-AddShotIndex                       ; Knight Axe               ; unidentified shot  pickaxe??
    dc.w                AddBullet-AddShotIndex                          ; AddBullet
    dc.w                AddBullet-AddShotIndex                          ; AddBullet


AddKnightAxe:
    moveq               #$c,d0                                          
    btst                #1,d6
    beq                 .other
    moveq               #-$1c,d0

.other
    add.b               d0,ENEMYSHOT_PosX(a1)

    move.w              #$300/2,ENEMYSHOT_SpeedY(a1)
    clr.w               ENEMYSHOT_SpeedX(a1)
    rts


AddBatBossSparyShot:                       
    add.b               #$a,ShotAngle(a5)
    bra                 AddBullet

AddHoodieSprayShot:
    move.l              ShotSpeedPointer(a5),a0
    move.w              (a0)+,ENEMYSHOT_SpeedY(a1)
    move.w              (a0)+,ENEMYSHOT_SpeedX(a1)
    move.l              a0,ShotSpeedPointer(a5)
    rts

AddDevilSparyShot:                         
    add.b               #$10,ShotAngle(a5)

    bra                 CalcEnemyShotSpeed

;----------------------------------------------------------------------------
;
; add standard bullet
;
;----------------------------------------------------------------------------

AddBullet:
    bra                 CalcEnemyShotSpeed


;----------------------------------------------------------------------------
;
; add arrow
;
;----------------------------------------------------------------------------

AddArrow:                                  
    sub.w               #$800,ENEMYSHOT_PosY(a1)
    sub.w               #$800,ENEMYSHOT_PosX(a1)

    move.b              ShotAngle(a5),d0
    add.b               #$8,d0
    lsr.b               #4,d0
    add.b               d0,ENEMYSHOT_BobId(a1)

    bra                 CalcEnemyShotSpeed

;----------------------------------------------------------------------------
;
; enemy shot animate jump
;
;----------------------------------------------------------------------------

EnemyShotAnim:
    move.b              ENEMYSHOT_Type(a1),d0
    and.w               #$f,d0
    JMPINDEX            d0

ShotAnimIndex:
    dc.w                AnimateDummy-ShotAnimIndex                      ;0 AddArrow
    dc.w                AnimateDummy-ShotAnimIndex                      ;1 AddArrow
    dc.w                AnimateBullet-ShotAnimIndex                     ;2 AddBullet
    dc.w                AnimateBullet-ShotAnimIndex                     ;3 AddBullet
    dc.w                AnimateDummy-ShotAnimIndex                      ;4 AddBullet
    dc.w                AnimateDummy-ShotAnimIndex                      ;5 AddDevilSparyShot
    dc.w                AnimateBone-ShotAnimIndex                       ;6 AddBullet ; Bone
    dc.w                AnimateBullet-ShotAnimIndex                     ;7 AddHoodieSprayShot
    dc.w                AnimateDummy-ShotAnimIndex                      ;8 AddBullet - lightning
    dc.w                AnimateDummy-ShotAnimIndex                      ;9 AddBullet
    dc.w                AnimateDummy-ShotAnimIndex                      ;a AddBatBossSparyShot
    dc.w                AnimateDummy-ShotAnimIndex                      ;b AddBullet
    dc.w                AnimateBone-ShotAnimIndex                       ;c Knight Boss Axe 
    dc.w                AnimateDummy-ShotAnimIndex                      ;d AddBullet
    dc.w                AnimateDummy-ShotAnimIndex                      ;e AddBullet
    dc.w                AnimateShotFire-ShotAnimIndex                   ;f AddBullet - FIRE!



AnimateShotFire:
    moveq               #0,d0
    move.b              ENEMYSHOT_Counter(a1),d0
    addq.b              #1,ENEMYSHOT_Counter(a1)
    lsr.b               #3,d0

    btst                #0,TickCounter(a5)
    beq                 .skip
    addq.b              #1,d0
.skip
    cmp.b               #3,d0
    bcs                 .showit
    rts

.showit
    move.b              d0,ENEMYSHOT_BobId(a1)
    bra                 SetShotBob
    rts

AnimateDummy:
    moveq               #0,d0
    move.b              ENEMYSHOT_BobId(a1),d0
    bra                 SetShotBob

AnimateBullet:
    move.b              ENEMYSHOT_BobId(a1),d0
    move.b              TickCounter(a5),d1
    and.b               #1,d1
    add.b               d1,d0
    cmp.b               #3,d0
    bcs                 .inrange
    moveq               #0,d0
.inrange
    move.b              d0,ENEMYSHOT_BobId(a1)
    bra                 SetShotBob
    
AnimateBone:
    moveq               #0,d0
    move.b              ENEMYSHOT_BobId(a1),d0

    move.b              TickCounter(a5),d1
    and.b               #3,d1
    bne                 .skip
    
    addq.b              #1,d0
    and.b               #3,d0
    move.b              d0,ENEMYSHOT_BobId(a1)
.skip
    bra                 SetShotBob

AnimatePickAxe:
    moveq               #0,d0
    move.b              ENEMYSHOT_BobId(a1),d0

    move.b              TickCounter(a5),d1
    and.b               #3,d1
    bne                 .skip
    
    addq.b              #1,d0
    and.b               #3,d0
    move.b              d0,ENEMYSHOT_BobId(a1)

    cmp.b               #2,d0
    beq                 .whoosh
    
    tst.b               d0
    bne                 .skip

.whoosh
    moveq               #1,d0
    bsr                 SfxPlay

.skip
    bra                 SetShotBob

; d0 = bob id

SetShotBob:
    move.b              d0,ENEMYSHOT_BobIdPrev(a1)

    add.w               d0,d0                                           
    add.w               d0,d0
    move.l              ENEMYSHOT_BobPtr(a1),a0
    move.l              (a0,d0.w),a0

    moveq               #0,d0
    move.b              ENEMYSHOT_PosY(a1),d0
    moveq               #0,d4
    move.b              ENEMYSHOT_PosX(a1),d4

    PUSHM               a1/d7
    bsr                 BobDrawDirect
    POPM                a1/d7

.skip
    rts