

    include             "common.asm"

;----------------------------------------------------------------------------
;
; clear enemy shots
;
;----------------------------------------------------------------------------

KillEnemyShots:
    PUSHM               d0/d1/a0
    ;lea                 BobMatrix(a5),a4
    lea                 EnemyShotList(a5),a0
    moveq               #ENEMYSHOT_COUNT-1,d0
.loop
    ;tst.b               ENEMYSHOT_Status(a0)
    ;beq                 .skip

    clr.b               ENEMYSHOT_Status(a0)                            ; clear status
    ;move.w              ENEMYSHOT_BobSlot(a0),d1                        ; remove bob
    ;clr.b               Bob_Allocated(a4,d1.w)

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

ShootAtPlayer:                                    ; ...
    addq.b              #1,ENEMY_ShotCounter(a2)                        ; add another to shot counter as we are running every frame
    ;ld          a, (PlayerY)
    ;add         a, 8
    ;sub         (ix+ENEMY_PosY)
    ;jr          nc, ShootAtPlayerPosY
    ;neg
    move.b              PlayerStatus+PLAYER_PosY(a5),d0
    add.b               #8,d0
    sub.b               ENEMY_PosY(a2),d0
    bcc                 .notnegy
    neg                 d0
.notnegy
;ShootAtPlayerPosY:                                ; ...
    ;cp          18h
    ;ret         c                                        
    cmp.b               #$18,d0
    bcs                 .exit                                           ; too close, don't shoot

    ;ld          a, (PlayerX)
    ;add         a, 8
    ;sub         (ix+ENEMY_PosX)
    ;jr          nc, ShootAtPlayerPosX
    ;neg
    move.b              PlayerStatus+PLAYER_PosX(a5),d0
    add.b               #8,d0
    sub.b               ENEMY_PosX(a2),d0
    bcc                 .notnegx
    neg                 d0
.notnegx
;ShootAtPlayerPosX:                                ; ...
    ;cp          18h
    ;ret         c                                         ; too close, don't shoot
    cmp.b               #$18,d0
    bcs                 .exit                                           ; too close, don't shoot

    ;ld          b, (ix+ENEMY_Id)
    ;ld          a, (EnemyShotsActive)
    ;and         a
    ;jr          nz, ShootAtPlayerAdd
    move.b              ENEMY_Id(a2),d1
    tst.b               EnemyShotsActive(a5)
    bne                 .shoot

    ;ld          a, (Level)
    ;cp          4
    ;jr          nc, ShootAtPlayerAdd
    cmp.b               #4,Level(a5)
    bcc                 .shoot

    ;ld          a, b
    ;rla
    ;ret         nc
    lsl.b               #1,d1
    bcc                 .exit
    ;ld          a, (ix+ENEMY_ShootStatus)
    ;cp          0FFh
    ;jr          z, ShootAtPlayerAdd
    cmp.b               #-1,ENEMY_ShootStatus(a2)
    beq                 .shoot

    ;and         1
    ;ret         nz
    and.b               #1,d1
    bne                 .exit

;ShootAtPlayerAdd:                                 ; ...
.shoot
    ;ld          a, b
    ;and         0Fh                                       ; enemy id
    ;ld          hl, EnemyShotIds
    ;call        ADD_A_HL
    ;ld          c, 4
    ;ld          b, (hl)
    ;jp          AddEnemyShot                              ; add enemy shot    
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
    ;ld         hl, EnemyShotSpeeds         ; enemy shot speeds
    ;                                              ;
    ;                                              ; +0 = speed y
    ;                                              ; +2 = speed x
    ;ld         (ShotSpeedPointer), hl
    move.l              #HoodieShotSpeeds,ShotSpeedPointer(a5)

    ;ld         a, b
    ;ld         (ShotTypeTemp), a ; this is not needed

    ;ld         hl, ShotRepeatCount
    ;dec        a
    ;add        a, l
    ;ld         l, a
    ;jr         nc, AddEnemyShot1
    ;inc        h
    lea                 ShotRepeatCount,a0
    moveq               #0,d1
    move.b              d5,d1                                           ; shot type
    sub.b               #1,d1
    add.l               d1,a0

AddEnemyShot1:                                    ; ...
    ;ld         a, (hl)
    moveq               #0,d6
    move.b              (a0),d6                                         ; Shot repeat count

    ;ld         (RepeatShotMax), a
    ;call       CalcAngleToPlayer
    
    ;ld         hl, ShotAngle
    ;ld         (hl), a
    ;inc        l
    ;ld         b, (hl)
    ;inc        l
    ;xor        a
    ;ld         (hl), a

    bsr                 CalcAngleToPlayer
    move.b              d0,ShotAngle(a5)


    ;call       GetEnemyShotSlot            ; finds an empty emeny shot slot
                                                  ;
                                                  ; returns
                                                  ;
                                                  ; hl = pointer to shot structure
                                                  ; c = shot id
    ;ret        nc                          ; no shot slot found, quit
    bsr                 GetEnemyShotSlot                                ; TODO: is this an early exit?
    bcs                 .exit

    ;ld         a, (ShotTypeTemp)
    ;cp         5
    ;jr         z, AddEnemyShot2
    ;cp         0Ah                         ; arrow
    ;jr         nz, AddEnemyShot3           ; not arrow, skip angle
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
    ;ld         hl, ShotAngle
    ;ld         b, (hl)
    ;inc        l
    ;ld         a, (hl)
    ;add        a, a
    ;ld         c, a
    ;add        a, a
    ;add        a, c
    ;sub        b
    ;neg
    ;dec        l
    ;ld         (hl), a

;AddEnemyShot3:                                    ; ...
.addenemyshot3     
    ;xor        a
    ;ld         (EnemyShotId), a
    ;ld         iy, EnemyShotList
    clr.b               EnemyShotId(a5)
    lea                 EnemyShotList(a5),a1

;AddEnemyShotLoop:                                 ; ...
.loop
    ;ld         a, (iy+ENEMYSHOT_Status)
    ;or         a
    ;jr         nz, EnemyShotSkip
    
    tst.b               ENEMYSHOT_Status(a1)
    bne                 .shotskip
    
    bsr                 EnemyShotPosInit

    ;ld         hl, AddEnemyShotRepeat      ; pushes to stack to run after calling add code
    ;push       hl

    ;call       EnemyShotPosInit            ; set the shot position
    ;ld         a, (ShotTypeTemp)
    ;dec        a
    ;call       JumpIndex_A
    bsr                 EnemyShotJump
    

;AddEnemyShotRepeat:                               ; ...

    ;ld         hl, RepeatShotCount
    ;inc        (hl)                        ; add to shot count
    ;ld         a, (hl)
    ;dec        l
    ;cp         (hl)                        ; compare with max
    ;ret        z                           ; max hit, quit
    subq.b              #1,d6
    beq                 .exit

;EnemyShotSkip:                                    ; ...
.shotskip
    ;ld         de, 10h
    ;add        iy, de
    lea                 ENEMYSHOT_Sizeof(a1),a1

    ;ld         hl, EnemyShotId
    ;inc        (hl)
    ;ld         a, (hl)
    ;cp         8                           ; max shots
    ;ret        z                           ; reached, so quit
    ;jr         AddEnemyShotLoop
    addq.b              #1,EnemyShotId(a5)
    cmp.b               #8,EnemyShotId(a5)                              ; TODO: this is a bit nasty
    beq                 .exit
    bra                 .loop

;EnemyShotExit:
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

; TODO: work out how destructable shots work!

EnemyShotPosInit:                                 ; ...
    clr.b               ENEMYSHOT_BobId(a1)
    clr.b               ENEMYSHOT_BobIdPrev(a1)
    clr.b               ENEMYSHOT_DeathTimer(a1)
    ;inc        (iy+ENEMYSHOT_Status)
    ;push       iy
    ;pop        hl
    ;inc        l
    ;ld         a, (ShotTypeTemp)                  ; ENEMYSHOT_Type
    ;ld         (hl), a
    ;inc        l
    ;inc        l
    ;ld         e, (ix+ENEMY.PosY)
    ;ld         (hl), e                            ; ENEMYSHOT_PosY
    ;inc        l
    ;inc        l
    ;ld         d, (ix+ENEMY.PosX)
    ;ld         (hl), d                            ; ENEMYSHOT_PosX
    move.b              d5,ENEMYSHOT_Type(a1)
    addq.b              #1,ENEMYSHOT_Status(a1)
    move.w              ENEMY_PosY(a2),ENEMYSHOT_PosY(a1)
    move.w              ENEMY_PosX(a2),ENEMYSHOT_PosX(a1)

    ;PUSH                a4
    ;bsr                 BobAllocate
    ;sf                  Bob_Hide(a4)
    ;move.w              d0,ENEMYSHOT_BobSlot(a1)

    ;moveq               #0,d0
    ;move.b              ENEMYSHOT_PosY(a1),d0
    ;move.w              d0,Bob_Y(a4)
    ;move.b              ENEMYSHOT_PosX(a1),d0
    ;move.w              d0,Bob_X(a4)

    move.w              d5,d0
    add.w               d0,d0
    add.w               d0,d0
    lea                 EnemyShotBobLookup(a5),a0
    move.l              (a0,d0.w),a0
    move.l              a0,ENEMYSHOT_BobPtr(a1)
    ;move.l              (a0),a0
    ;BOBSET              a0,a4
    ;POP                 a4

    ;push       iy
    ;pop        de
    ;ld         a, 0Ah
    ;add        a, e
    ;ld         e, a
    ;ld         a, (iy+ENEMYSHOT_Type)
    ;dec        a
    ;ld         hl, EnemyShotSpriteIdList2
    ;add        a, l
    ;ld         l, a
    ;jr         nc, EnemyShotPosInit1              ; ENEMYSHOT_SpriteId
    ;inc        h

EnemyShotPosInit1:                                ; ...
    ;ldi                                           ; ENEMYSHOT_SpriteId
    ;ld         a, 0Fh
    ;ld         (de), a                            ; ENEMYSHOT_Unknown
    ;ld         a, (iy+ENEMYSHOT_Type)
    ;cp         0Bh                                ; shot type B?
    ;ret        nz                                 ; not B, quit
    ;ld         a, 8                               ; swap out unknown with 8
    ;ld         (de), a
    ;ret
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
    ;ld         hl, EnemyList
    ;ld         b, 7                   ; max 7 enemies
    lea                 EnemyShotList(a5),a1
    moveq               #ENEMYSHOT_COUNT-1,d0
    moveq               #ENEMYSHOT_Sizeof,d1
.loop
    ;ld         a, (hl)
    ;and        a
    ;jr         z, FoundEnemySlot
    ;ld         a, 20h                 ; ' '
    ;call       ADD_A_HL
    ;djnz       FindEnemySlotLoop
    ;or         1
    ;ret
    tst.b               ENEMYSHOT_Status(a1)
    beq                 .found
    add.l               d1,a1
    dbra                d0,.loop
    move                #1,ccr
    rts

.found
    ;push       hl
    ;pop        ix
    ;ret
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
    ;ld          a, (BossStatus)
    ;or          a
    ;jr          z, EnemyShotMoveNoBoss
    tst.b               BossStatus(a5)
    beq                 .noboss
    ;ld          a, (BossId)
    ;cp          1                                    ; boss id 1
    ;ret         z                                    ; quit
    ;cp          3                                    ; boss id 3
    ;ret         z                                    ; quit
    move.b              BossId(a5),d0
    cmp.b               #1,d0                                           ; boss id 1
    beq                 .exit                                           ; quit
    cmp.b               #3,d0                                           ; boss id 3
    beq                 .exit                                           ; quit


;EnemyShotMoveNoBoss:                              ; ...
    ;xor         a
    ;ld          (EnemyShotId), a
    ;ld          iy, EnemyShotList
.noboss
    lea                 EnemyShotList(a5),a1
    lea                 BobMatrix(a5),a4
    moveq               #ENEMYSHOT_COUNT-1,d7

;EnemyShotLoop:                                    ; ...
.loop
    ;ld          hl, EnemyShotNext                    ; strcutre size
    ;push        hl                                   ; push onto stack to run after jump
    ;ld          a, (iy+ENEMYSHOT_Status)
    ;dec         a
    ;jp          z, loc_8207
    ;dec         a
    ;jp          z, CheckEnemyShotCollision
    ;dec         a
    ;jp          z, loc_8212
    ;jp          loc_81F6
    
    ;move.b             ENEMYSHOT_Status(a1),d0
    ;subq.b             #1,d0
    tst.b               ENEMYSHOT_Status(a1)
    beq                 .skip
    bsr                 EnemyShotUpdate
    
    lea                 BobMatrix(a5),a4
    bsr                 CheckEnemyShotCollision
.skip
;EnemyShotNext:                                    ; ...
    ;ld          de, 10h                              ; strcutre size
    ;add         iy, de                               ; move to next shot
    ;ld          hl, EnemyShotId
    ;inc         (hl)                                 ; increase counter
    ;ld          a, (hl)
    ;cp          8                                    ; max enemy shots
    ;ret         nc                                   ; max reached, quit
    ;jr          EnemyShotLoop
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

    ;move.w              ENEMYSHOT_BobSlot(a1),d4    

    ;moveq               #0,d0
    move.b              ENEMYSHOT_PosY(a1),d0
    ;move.w              d0,Bob_Y(a4,d4.w)    

    cmp.b               #$c8,d0
    bcc                 RemoveEnemyShot

    move.b              ENEMYSHOT_PosX(a1),d0
    ;move.w              d0,Bob_X(a4,d4.w)    

    sub.b               #8,d0
    cmp.b               #$f0,d0     
    bcc                 RemoveEnemyShot

    bra                 EnemyShotAnim

RemoveEnemyShot:
    ;move.w              ENEMYSHOT_BobSlot(a1),d4    
    ;clr.b               Bob_Allocated(a4,d4.w)
    clr.b               ENEMYSHOT_Status(a1)
    rts

;----------------------------------------------------------------------------
;
; check enemy shot collision with player
;
; a1 = enemy shot structure
;
;----------------------------------------------------------------------------


CheckEnemyShotCollision:                          ; ...
    ;ld          a, (PlayerStatus)
    ;cp          PLAYERMODE_DEAD
    ;ret         nc
    cmp.b               #PLAYERMODE_DEAD,PlayerStatus(a5)
    bcc                 .nohit

    ;push        iy
    ;pop         ix

;CheckEnemyShotCollision2:                         ; ...
    ;ld          a, (PlayerPowerUp)
    ;and         a                                        ; no power up?
    ;jr          z, CheckEnemyShotCollision3              ; check collisions
    move.b              PlayerStatus+PLAYER_PowerUp(a5),d0
    beq                 .playercheck
    ;dec         a                                        ; power up 1?
    ;jr          z, CheckSheildShotCollision              ; check collisions
    subq.b              #1,d0
    beq                 .sheildcheck
    ;dec         a                                        ; power up 2 or higher?
    ;jr          z, BonesShotCollisionCheck               ; specific code for checking if bones collide with player shots
    subq.b              #1,d0
    beq                 BonesShotCollisionCheck

;CheckEnemyShotCollision3:                         ; ...
.playercheck
    ;call        CheckCollisionLogic
    GETPLAYERDIM
    GETENEMYSHOTDIM
    CHECKCOLLISION
    bcs                 BonesShotCollisionCheck
    ;jr          c, BonesShotCollisionCheck               ; specific code for checking if bones collide with player shots
    ;ld          (iy+ENEMYSHOT.Status), 0
    ;ld          (iy+ENEMYSHOT.PosY), 0E0h
    bsr                 RemoveEnemyShot

    ;ld          a, (PlayerPowerUp)
    ;cp          POWERUP_RED
    ;ret         z
    cmp.b               #POWERUP_RED,PlayerStatus+PLAYER_PowerUp(a5)
    bcs                 KillPlayer
.nohit
    rts



;CheckSheildShotCollision:                         ; ...
.sheildcheck
    ;call               GetEnemyBoxDim                                  ; returns
                                                  ;
                                                  ; hl = enemy y/x
                                                  ; bc - enemy box dimensions
    ;ld                 a, (PlayerY)
    ;sub                9
    ;ld                 (TempPositionY), a
    ;ld                 a, (PlayerX)
    ;ld                 (TempPositionX), a
    ;ld                 de, 810h                                        ; shield box size
    ;call               CheckCollision                                  ; collision detect
    ;jr                 c, CheckEnemyShotCollision3

    GETENEMYSHOTDIM
    GETSHIELDDIM
    CHECKCOLLISION
    bcs                 .playercheck

    ;ld                 a, 11h
    moveq               #$11,d0
    bsr                 SfxPlay

    ;xor                a
    ;ld                 (ix+ENEMYSHOT.Status), a  ; remove shot
    ;ld                 (ix+ENEMYSHOT.PosY), 0E0h
    bsr                 RemoveEnemyShot

    ;ld                 a, (iy+ENEMYSHOT.Type)                          ; ; ?? iy is the same as ix
    ;cp                 7                                               ; enemy shot type 7
    ;ld                 hl, PlayerSheildPower
    ;ld                 a, (hl)
    ;ld                 b, 1                                            ; sheild reduction value
    ;jr                 c, CheckSheildShotCollision1                    ; shot is less than type 7, only takes 1 hit from sheild
    ;ld                 b, 4

    move.b              PlayerStatus+PLAYER_SheildPower(a5),d0
    moveq               #1,d1
    cmp.b               #7,ENEMYSHOT_Type(a1)
    bcs                 .lower
    moveq               #4,d1
;CheckSheildShotCollision1:                        ; ...
.lower
    ;sub                b
    ;ld                 (hl), a
    sub.b               d1,d0
    move.b              d0,PlayerStatus+PLAYER_SheildPower(a5)
    bpl                 .exit
    ;ret                p
    ;xor                a
    ;ld                 (hl), a
    ;ld                 (PlayerPowerUp), a
    ;ret
    clr.b               PlayerStatus+PLAYER_SheildPower(a5)
    clr.b               PlayerStatus+PLAYER_PowerUp(a5)
.exit
    rts
;----------------------------------------------------------------------------
;
; bones shot check
;
;----------------------------------------------------------------------------


BonesShotCollisionCheck:                          ; TODO: bones shot collision
    ;ld                 a, (BossStatus)                                 ; specific code for checking if bones collide with player shots
    ;cp                 4
    ;ret                nc                                              ; boss status > 4, quit
    ;ld                 a, (iy+ENEMYSHOT.Type)
    ;cp                 6
    ;ret                nz                                              ; not enemy shot type 6 (bones), quit
    cmp.b               #6,ENEMYSHOT_Type(a1)
    bne                 .exit

    ;ld                 hl, PlayerShot1
    ;ld                 a, (hl)
    ;rla                                                                ; check shot bit is alive
    ;jr                 c, BonesSkipShot1
    ;call               CheckBonesPlayerShotCollision
    ;ld                 hl, PlayerShot1Type
    ;jr                 nc, BonesShotKill
    lea                 PlayerShot1(a5),a2
    btst.b              #7,PLAYERSHOT_Status(a2)
    bne                 .skip1

    nop

    GETPLAYERSHOTDIM    a2,a0
    GETENEMYSHOTDIM
    CHECKCOLLISION
    bcc                 .killshot

;BonesSkipShot1:                                   ; ...
.skip1
    ;ld                 hl, PlayerShot2
    ;ld                 a, (hl)
    ;rla                                                                ; check shot bit is alive
    ;jr                 c, BonesSkipShot2
    lea                 PlayerShot2(a5),a2
    btst.b              #7,PLAYERSHOT_Status(a2)
    bne                 .skip2

    ;call               CheckBonesPlayerShotCollision
    ;ld                 hl, PlayerShot2Type
    ;jr                 nc, BonesShotKill
    GETPLAYERSHOTDIM    a2,a0
    GETENEMYSHOTDIM
    CHECKCOLLISION
    bcc                 .killshot
    
;BonesSkipShot2:                                   ; ...
.skip2
    ;ld                 hl, PlayerShot3
    ;ld                 a, (hl)
    ;rla                                                                ; check shot bit is alive
    ;jr                 c, BonesSkipShot3
    lea                 PlayerShot3(a5),a2
    btst.b              #7,PLAYERSHOT_Status(a2)
    bne                 .exit

    ;call               CheckBonesPlayerShotCollision
    ;ld                 hl, PlayerShot3Type
    ;jr                 c, BonesSkipShot3
    GETPLAYERSHOTDIM    a2,a0
    GETENEMYSHOTDIM
    CHECKCOLLISION
    bcs                 .exit

;BonesShotKill:                                    ; ...
.killshot
    ;ld                 a, (hl)
    ;srl                a
    ;cp                 3                                               ; check shot type
    ;jr                 nc, BonesShotKillSkip
    cmp.b               #3,PLAYERSHOT_WeaponId(a2)
    bcc                 .skipremove
    ;dec                l
    ;dec                l
    ;dec                l
    ;dec                l
    ;dec                l
    ;set                7, (hl)                                         ; set shot inactive
    bset                #7,PLAYERSHOT_Status(a2)                        ; disable shot
    ;move.w              PLAYERSHOT_BobSlot(a2),d4
    ;clr.b               Bob_Allocated(a4,d4.w)                          ; remove bob

;BonesShotKillSkip:                                ; ...
.skipremove
    ;ld                 a, 4Dh                                          ; 'M'
    ;call               SetSound
    ;ld                 (ix+0), 3
    ;ld                 (ix+0Dh), 7
    clr.b               ENEMYSHOT_Status(a1)
    ;move.w              ENEMYSHOT_BobSlot(a1),d4
    ;clr.b               Bob_Allocated(a4,d4.w)       

;BonesSkipShot3:                                   ; ...
    ;push               ix
    ;pop                iy
    ;ret
.exit
    rts

;----------------------------------------------------------------------------
;
; add enemy shot type jump
;
;----------------------------------------------------------------------------

EnemyShotJump:

    ;ld         a, (ShotTypeTemp)
    ;dec        a
    ;call       JumpIndex_A
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
    ;ld                  a, (RepeatShotCount) 
    ;ld                  hl, UnkownShotData
    ;call                ADD_A_HL
    ;ld                  a, (hl)
    ;add                 a, (iy+ENEMYSHOT.PosX)
    ;ld                  (iy+ENEMYSHOT.PosX), a
    ;ld                  bc, 300h
    ;ld                  de, 0
    ;jr                  SetEnemyShotSpeed_
    moveq               #$c,d0                                          ; TODO: fix this shit
    btst                #1,d6
    beq                 .other
    moveq               #-$1c,d0

.other
    ;move.b              RepeatShotCount(a5),d1
    add.b               d0,ENEMYSHOT_PosX(a1)

    move.w              #$300/2,ENEMYSHOT_SpeedY(a1)
    clr.w               ENEMYSHOT_SpeedX(a1)
    rts


AddBatBossSparyShot:                              ; ...
    ;ld                  hl, ShotAngle
    ;ld                  a, (hl)
    ;add                 a, 0Ah                                          ; add to angle
    ;ld                  (hl), a
    ;jr                  AddBullet
    add.b               #$a,ShotAngle(a5)
    bra                 AddBullet

AddHoodieSprayShot:
    ;ld                 hl, (ShotSpeedPointer)
    ;ld                 c, (hl)
    ;inc                hl
    ;ld                 b, (hl)
    ;inc                hl
    ;ld                 e, (hl)
    ;inc                hl
    ;ld                 d, (hl)
    ;inc                hl
    ;ld                 (ShotSpeedPointer), hl
    ;jr                 SetEnemyShotSpeed_
    move.l              ShotSpeedPointer(a5),a0
    move.w              (a0)+,ENEMYSHOT_SpeedY(a1)
    move.w              (a0)+,ENEMYSHOT_SpeedX(a1)
    move.l              a0,ShotSpeedPointer(a5)
    rts

AddDevilSparyShot:                                ; ...
    ;ld                 hl, ShotAngle
    ;ld                 a, (hl)
    ;add                a, 10h                                          ; add to angle
    ;ld                 (hl), a
    add.b               #$10,ShotAngle(a5)

;AddBullet:                                        ; ...
    ;call               CalcEnemyShotSpeed
    bra                 CalcEnemyShotSpeed
;SetEnemyShotSpeed_:                               ; ...
    ;jp                 SetEnemyShotSpeed


;----------------------------------------------------------------------------
;
; add standard bullet
;
;----------------------------------------------------------------------------

AddBullet:
    ;call       CalcEnemyShotSpeed
    ;jp         SetEnemyShotSpeed
    bra                 CalcEnemyShotSpeed


;----------------------------------------------------------------------------
;
; add arrow
;
;----------------------------------------------------------------------------

AddArrow:                                         ; ...
    ;ld          a, (ShotAngle)
    ;rra
    ;rra
    ;rra
    ;rra
    ;and         0Fh
    ;ld          de, EnemyShotSpriteIdList
    ;add         a, e
    ;ld          e, a
    ;jr          nc, AddArrow1
    ;inc         d                                        ; overflow add

;AddArrow1:                                        ; ...
    ;ld          a, (de)
    ;ld          (iy+ENEMYSHOT.SpriteId), a
    ;jr          AddBullet
    
    ;move.w              ENEMYSHOT_BobSlot(a1),d4
    ;moveq               #0,d0
    ;move.b              ShotAngle(a5),d0
    ;lsr.b               #5,d0
    ;add.w               d0,d0                                           
    ;add.w               d0,d0
    ;move.l              ENEMYSHOT_BobPtr(a1),a0
    ;move.l              (a0,d0.w),a0
    sub.w               #$800,ENEMYSHOT_PosY(a1)
    sub.w               #$800,ENEMYSHOT_PosX(a1)

    move.b              ShotAngle(a5),d0
    add.b               #$8,d0
    lsr.b               #4,d0
    add.b               d0,ENEMYSHOT_BobId(a1)

    ;PUSH                a4
    ;lea                 (a4,d4),a4
    ;BOBSET              a0,a4
    ;POP                 a4

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
    ;cmp.b               ENEMYSHOT_BobIdPrev(a1),d0
    ;beq                 .skip

    move.b              d0,ENEMYSHOT_BobIdPrev(a1)
    ;move.w              ENEMYSHOT_BobSlot(a1),d4
    add.w               d0,d0                                           
    add.w               d0,d0
    move.l              ENEMYSHOT_BobPtr(a1),a0
    move.l              (a0,d0.w),a0

    ;PUSH                a4
    ;lea                 (a4,d4),a4
    ;st                  Bob_Hide(a4,d4.w)
    ;BOBSET              a0,a4
    ;POP                 a4

    moveq               #0,d0
    move.b              ENEMYSHOT_PosY(a1),d0
    moveq               #0,d4
    move.b              ENEMYSHOT_PosX(a1),d4

    PUSHM               a1/d7
    bsr                 BobDrawDirect
    POPM                a1/d7

.skip
    rts