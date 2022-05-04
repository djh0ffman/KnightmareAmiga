;----------------------------------------------------------------------------
;
; player shot logic
;
;----------------------------------------------------------------------------

    include             "common.asm"

ClearPlayerShots:
    lea                 PlayerShot1(a5),a0
    move.w              #PLAYERSHOT_COUNT-1,d7

    move.b              #$80,d0                                             ; shot status / id
.shotloop
    move.b              d0,(a0)
    addq.b              #1,d0
    lea                 PLAYERSHOT_Sizeof(a0),a0
    dbra                d7,.shotloop
    rts


PlayerAddLazer:



;----------------------------------------------------------------------------
;
; add player shot
;
; this is what happens when you fire
;
; in 
; a0 = player structure
;
; during
; a1 = shot structure (first?)
;----------------------------------------------------------------------------


PlayerAddShot: 
    moveq               #0,d2 
    move.b              PLAYER_WeaponId(a0),d2
    cmp.b               #POWERUP_GRADIUS,PLAYER_PowerUp(a0)
    bne                 .notgradius

    moveq               #12,d2                                              ; gradius laser

.notgradius
    move.l              d2,d0
    add.w               d0,d0
    lea                 PlayerShotData,a1
    add.l               d0,a1

    move.b              (a1)+,d7                                            ; max shot loops
    moveq               #0,d6
    move.b              (a1),d6                                             ; offset x

    lea                 PlayerShot1(a5),a1  

.loop
    btst                #7,(a1)
    beq                 .next

    move.b              d2,d0                                               ; restore weapon id
    lsr.b               #1,d0                                               ; shift right half
    cmp.b               #4,d0                                               ; weapon fire ball?
    bne                 PlayerAddShotLogic                                  ; no, add shot

    btst.b              #7,PlayerShot1(a5)                                  ; fire shot, check all shots are free
    beq                 .next
    btst.b              #7,PlayerShot2(a5)                                  ; fire shot, check all shots are free
    beq                 .next
    btst.b              #7,PlayerShot3(a5)                                  ; fire shot, check all shots are free
    beq                 .next

    bra                 PlayerAddShotLogic

.next
    lea                 PLAYERSHOT_Sizeof(a1),a1
    subq.b              #1,d7
    bne                 .loop
    rts
; ---------------------------------------------------------------------------
;
; adds a shot ?
;
; d2 = shot type
;
; ---------------------------------------------------------------------------

PlayerAddShotLogic:
    moveq               #0,d3
    move.b              PLAYER_PosY(a0),d3                                  ; get player pos y
    sub.b               #8,d3                                               ; sub 8

    moveq               #0,d4
    move.b              PLAYER_PosX(a0),d4                                  ; get player pos x
    add.b               d6,d4                                               ; add shot offset x

    lea                 PlayerShotYSpeeds,a2
    move.w              d2,d6
    add.w               d6,d6
    move.w              (a2,d6.w),d6                                        ; speed y

    bsr                 PlayerShotSetup

    move.b              d2,d0
    lsr.b               #1,d0
    cmp.b               #4,d0
    bne                 .exit                                               ; not fire ball, only one shot per fire

    ; setup other two fire balls
    ; set x speed of shot one
    cmp.b               #9,d2
    beq                 .fireform

    add.b               #$10,PLAYERSHOT_PosY(a1)
    add.b               #$10,d3

    lea                 PLAYERSHOT_Sizeof(a1),a1                            ; next shot
    bsr                 PlayerShotSetup
    move.w              #-$300/2,PLAYERSHOT_SpeedX(a1)
    move.w              #-$759/2,PLAYERSHOT_SpeedY(a1)

    lea                 PLAYERSHOT_Sizeof(a1),a1                            ; next shot
    bsr                 PlayerShotSetup
    move.w              #$300/2,PLAYERSHOT_SpeedX(a1)
    move.w              #-$759/2,PLAYERSHOT_SpeedY(a1)

    bra                 .exit

.fireform
    add.b               #$10,d3

    lea                 PLAYERSHOT_Sizeof(a1),a1                            ; next shot
    sub.b               #$10,d4
    bsr                 PlayerShotSetup

    lea                 PLAYERSHOT_Sizeof(a1),a1                            ; next shot
    add.b               #$20,d4
    bsr                 PlayerShotSetup

.exit
    move.w              d2,d0                          ; get shot sfx id
    lsr.b               #1,d0
    move.b              PlayerShotSfxList(pc,d0.w),d0
    bsr                 SfxPlay
    rts


PlayerShotSfxList:
    dc.b                3,3,4,5,6,6,7,7                                     ; $44??  last one is the lazer?
    even

PlayerShotSetup:
    and.b               #%01101111,PLAYERSHOT_Status(a1)                    ; clear statuses
    move.b              d2,PLAYERSHOT_WeaponId(a1)
    move.b              d3,PLAYERSHOT_PosY(a1)                              ; set shot pos y
    move.b              d4,PLAYERSHOT_PosX(a1)                              ; set shot pos x
    move.w              d6,PLAYERSHOT_SpeedY(a1)                            ; set speed y
    clr.w               PLAYERSHOT_SpeedX(a1)                               ; set speed x

    move.l              #BoomerangSpeeds,PLAYERSHOT_BoomerangPtr(a1)        ; set this

    clr.b               PLAYERSHOT_FrameId(a1)
    clr.b               PLAYERSHOT_MoveCounter(a1)

    clr.b               PLAYERSHOT_LazerCount(a1)

    moveq               #0,d0
    move.b              PLAYERSHOT_WeaponId(a1),d0
    add.w               d0,d0
    add.w               d0,d0
    lea                 PlayerShotDims,a2
    move.l              (a2,d0.w),PLAYERSHOT_Width(a1)  

    moveq               #0,d0
    move.b              PLAYERSHOT_WeaponId(a1),d0
    lea                 PlayerShotBobIdList,a2
    move.b              (a2,d0.w),d0                                        ; core bob id
    move.b              d0,PLAYERSHOT_BobId(a1)

.exit
    rts

;----------------------------------------------------------------------------
;
; update player shots
;
; moves shots.. does stuff
;
;----------------------------------------------------------------------------

UpdatePlayerShots:
    lea                 PlayerShot1(a5),a1
    moveq               #3-1,d7

.loop
    btst                #7,PLAYERSHOT_Status(a1)
    bne                 .next

    bsr                 UpdateShotLogic
.next
    lea                 PLAYERSHOT_Sizeof(a1),a1
    dbra                d7,.loop
    rts

;----------------------------------------------------------------------------
;
; update a shot
;
; moves shots.. does stuff
;
; a0 = player shot structure
;
;----------------------------------------------------------------------------


UpdateShotLogic:
    move.b              PLAYERSHOT_WeaponId(a1),d5
    lsr.b               #1,d5
    cmp.b               #3,d5                                               ; boomerang
    bne                 .notboomer

    move.w              PlayerStatus+PLAYER_PosX(a5),PLAYERSHOT_PosX(a1)

    move.l              PLAYERSHOT_BoomerangPtr(a1),a0
    move.w              (a0)+,d1
    tst.w               (a0)
    beq                 .dataend
    btst.b              #0,TickCounter(a5)
    beq                 .dataend
    move.l              a0,PLAYERSHOT_BoomerangPtr(a1)
.dataend
    add.w               d1,PLAYERSHOT_PosY(a1)

    move.b              PLAYERSHOT_PosY(a1),d0
    move.b              PlayerStatus+PLAYER_PosY(a5),d1
    add.b               #8,d1
    sub.b               d0,d1
    cmp.b               #$a,d1
    bcc                 .inrangex
    bra                 .removeshot

.notboomer
    cmp.b               #6,d5                                                        
    bne                 .notlazer

    ; -- gradius lazer logic  
    addq.b              #1,PLAYERSHOT_LazerCount(a1)
    cmp.b               #8,PLAYERSHOT_LazerCount(a1)
    bcc                 .lazermax

    moveq               #0,d0
    move.w              PLAYERSHOT_Height(a1),d0
    add.b               #8,d0

    move.w              d0,PLAYERSHOT_Height(a1)
    move.b              PlayerStatus+PLAYER_PosX(a5),d1                     
    add.b               #6,d1
    move.b              d1,PLAYERSHOT_PosX(a1)

    moveq               #0,d1
    move.b              PlayerStatus+PLAYER_PosY(a5),d1     
    add.w               #8,d1
    sub.w               d0,d1
    bpl                 .lazery
.lazerclip
    add.w               d1,PLAYERSHOT_Height(a1)
    bmi                 .removeshot
    beq                 .removeshot
    clr.w               d1

.lazery
    move.b              d1,PLAYERSHOT_PosY(a1)
    bra                 .inrangex

    ; -- lazer at max length move and check range
.lazermax
    moveq               #0,d1
    move.b              PLAYERSHOT_PosY(a1),d1
    add.b               PLAYERSHOT_SpeedY(a1),d1
    bpl                 .lazery
    ext.w               d1
    bra                 .lazerclip



    ; -- normal shot logic
.notlazer
    move.w              PLAYERSHOT_SpeedY(a1),d1
    add.w               d1,PLAYERSHOT_PosY(a1)

    move.w              PLAYERSHOT_SpeedX(a1),d1
    add.w               d1,PLAYERSHOT_PosX(a1)

    move.b              PLAYERSHOT_PosY(a1),d0
    sub.b               #$E5,d0
    cmp.b               #$a,d0                                              ;a
    bcc                 .inrangey
    bra                 .removeshot

.inrangey
    move.b              PLAYERSHOT_PosX(a1),d0
    add.b               #9,d0
    cmp.b               #9,d0
    bcc                 .inrangex
    bra                 .removeshot

.inrangex
    bsr                 ShotPowerUpCollisionCheck                           ; TODO: early out of draw?
    
    ; ---- bob animate
    moveq               #0,d0
    move.b              PLAYERSHOT_BobId(a1),d0

    cmp.b               #3,d5
    beq                 .animboomer
    cmp.b               #4,d5
    bne                 .setbob

    ; flame animate
    move.b              TickCounter(a5),d1
    and.w               #3,d1
    add.b               d1,d0
    bra                 .setbob

    ; boomerang animate
.animboomer
    addq.b              #1,PLAYERSHOT_MoveCounter(a1)
    move.b              PLAYERSHOT_MoveCounter(a1),d1
    lsr.b               #2,d1
    and.w               #3,d1
    add.b               d1,d0

.setbob
    lea                 PlayerShotBobPtrs(a5),a0
    add.w               d0,d0
    add.w               d0,d0
    move.l              (a0,d0.w),a0                                        ; bob data

    moveq               #16,d0
    add.b               PLAYERSHOT_PosY(a1),d0
    sub.w               #16,d0
    moveq               #0,d4
    move.b              PLAYERSHOT_PosX(a1),d4

    cmp.b               #12,PLAYERSHOT_WeaponId(a1)
    bne                 .skiplazer

    move.w              PLAYERSHOT_Height(a1),BobObj_Height(a0)             ; determine height of lazer

.skiplazer
    PUSHM               a1/d7
    bsr                 BobDrawDirect
    POPM                a1/d7
    bra                 .exit

.removeshot
    bset                #7,PLAYERSHOT_Status(a1)                            ; disable shot
.exit
    rts

;----------------------------------------------------------------------------
;
; shot powerup collision check
;
; a1 = player shot structure
;
;----------------------------------------------------------------------------

ShotPowerUpCollisionCheck:                     
    move.b              PowerUpStatus(a5),d0
    subq.b              #1,d0
    bne                 .exit

    GETPLAYERSHOTDIM    a1,a2
    GETPOWERUPDIM
    CHECKCOLLISION
    bcs                 .exit

    moveq               #$e,d0
    bsr                 SfxPlay
    
    move.b              #2,PowerUpStatus(a5)

    bset                #7,PLAYERSHOT_Status(a1)                            ; kill shot
.exit
    rts

;----------------------------------------------------------------------------
;
; player shot boss check
;
; checks if player shots hit boss
; if boss is killed, return in carry flag
;
;----------------------------------------------------------------------------


PlayerShotBossLogic:                           
    lea                 BobMatrix(a5),a4

    moveq               #0,d0
    move.b              BossId(a5),d0
    add.w               d0,d0
    add.w               d0,d0
    lea                 BossHitBoxDimensionList,a2
    add.l               d0,a2

PlayerShotBossCheck1:                          
    lea                 PlayerShot1(a5),a1
    moveq               #3-1,d7
                  
.loop
    btst                #7,PLAYERSHOT_Status(a1)
    bne                 .next

    moveq               #0,d0
    move.b              PLAYERSHOT_WeaponId(a1),d0
    add.w               d0,d0
    lea                 PlayerShotHitBoxList,a3
    add.l               d0,a3

    move.b              BOSSBOX_OffsetY(a2),d4
    add.b               (a3),d4

    move.b              d4,d3
    add.b               BOSSBOX_Height(a2),d3

    move.b              BossPosX(a5),d0
    sub.b               PLAYERSHOT_PosX(a1),d0
    neg                 d0
    add.b               d4,d0

    cmp.b               d3,d0
    bcc                 .next

    move.b              BOSSBOX_OffsetX(a2),d4
    move.b              BOSSBOX_Width(a2),d3

    move.b              BossPosY(a5),d0
    sub.b               PLAYERSHOT_PosY(a1),d0
    neg                 d0
    add                 d4,d0
    cmp.b               d0,d3
    bcs                 .nothit

    bsr                 PlayerShotHitBoss
.nothit
                 
.next
    lea                 PLAYERSHOT_Sizeof(a1),a1
    dbra                d7,.loop
    rts


;----------------------------------------------------------------------------
;
; player shot hit boss
;
;----------------------------------------------------------------------------

PlayerShotHitBoss:                             
    bset                #7,PLAYERSHOT_Status(a1)

    tst.b               BossDeathFlag(a5)
    bne                 .exit

    tst.b               BossIsSafe(a5)
    beq                 .hitboss

    moveq               #$38,d0                                             ; boss is safe, play other sfx
    bra                 SfxPlay

.hitboss
    moveq               #$37,d0
    bsr                 SfxPlay

    move.b              BossHitMax(a5),d2

    move.b              BossHitCount(a5),d0
    add.b               1(a3),d0
    move.b              d0,BossHitCount(a5)

    bsr                 CalcBossHealth

    cmp.b               d2,d0
    bcs                 .exit

    move.b              #1,BossDeathFlag(a5)
    move.w              #10000,d0
    bsr                 AddScore

.exit
    rts

