;----------------------------------------------------------------------------
;
; player shot logic
;
;----------------------------------------------------------------------------

    include             "common.asm"

ClearPlayerShots:

    ;ld         hl, PlayerShot1
    ;ld         bc, 400h

;ClearPlayerShotsLoop:                             ; ...
    ;ld         a, 80h
    ;or         c
    ;ld         (hl), a
    ;ld         de, 10h
    ;add        hl, de
    ;inc        c
    ;djnz       ClearPlayerShotsLoop

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
    ;ld          a, (ix+PLAYER_WeaponId)
    ;ld          c, a                                        ; save weapon id
    ;ld          hl, PlayerShotData                          ; pairs
                                                  ;
                                                  ; +0 = max shot count / loop
                                                  ; +1 = shot offset x
    ;add         a, a
    ;call        ADD_A_HL

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

    ;ld          b, (hl)                                    
    ;inc         hl
    ;ld          d, (hl)                                     
    ;ld          hl, PlayerShot1
    move.b              (a1)+,d7                                            ; max shot loops
    moveq               #0,d6
    move.b              (a1),d6                                             ; offset x

    lea                 PlayerShot1(a5),a1  

.loop
    ;bit         7, (hl)
    ;jr          z, PlayerAddShotNext
    btst                #7,(a1)
    beq                 .next

    ;ld          a, c                                        ; restore weapon id
    ;srl         a                                           
    ;cp          4                                           
    ;jr          nz, PlayerAddShotLogic                      ; no, add shot
    move.b              d2,d0                                               ; restore weapon id
    lsr.b               #1,d0                                               ; shift right half
    cmp.b               #4,d0                                               ; weapon fire ball?
    bne                 PlayerAddShotLogic                                  ; no, add shot

    ;push        hl                                          ; yes, pop player shot pointer into iy
    ;pop         iy
    ;ld          a, (iy+10h)                                 ; check all fire shots are not active
    ;or          (iy+20h)
    ;rla
    ;jr          c, PlayerAddShotLogic                       ; not active add a shot logic
    btst.b              #7,PlayerShot1(a5)                                  ; fire shot, check all shots are free
    beq                 .next
    btst.b              #7,PlayerShot2(a5)                                  ; fire shot, check all shots are free
    beq                 .next
    btst.b              #7,PlayerShot3(a5)                                  ; fire shot, check all shots are free
    beq                 .next

    bra                 PlayerAddShotLogic

.next
    ;ld          a, 10h
    ;call        ADD_A_HL
    ;djnz        PlayerAddShotLoop
    ;ret
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
    ;ld          hl, PlayerShotSfxList
    ;call        ADD_A_HL
    ;ld          a, (hl)                                     ; get shot sfx id
    move.w              d2,d0
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

    ;PUSH                d2
    ;bsr                 BobAllocate
    ;POP                 d2
    ;move.w              d0,PLAYERSHOT_BobSlot(a1)
    
    ;sf                  Bob_Hide(a4)
    ;move.w              d3,Bob_Y(a4)
    ;move.w              d4,Bob_X(a4)

    moveq               #0,d0
    move.b              PLAYERSHOT_WeaponId(a1),d0
    lea                 PlayerShotBobIdList,a2
    move.b              (a2,d0.w),d0                                        ; core bob id
    move.b              d0,PLAYERSHOT_BobId(a1)

.exit
    rts


    ;ld         de, 0F680h
    ;cp         2
    ;jr         z, PlayerShotMoveYBounds
    ;ld         de, 0F700h
    ;cp         4
    ;jr         z, PlayerShotMoveYBounds
    ;ld         de, 0F800h

;----------------------------------------------------------------------------
;
; update player shots
;
; moves shots.. does stuff
;
;----------------------------------------------------------------------------

UpdatePlayerShots:
    ;ld         ix, PlayerShot1
    ;ld         b, 3
    lea                 PlayerShot1(a5),a1
    moveq               #3-1,d7

;PlayerShotLoop:  
.loop
    ;push       bc
    ;bit        7, (ix+PLAYERSHOT_Status)
    ;jr         nz, PlayerShotNext             ; shot not active, next
    btst                #7,PLAYERSHOT_Status(a1)
    bne                 .next

    ;lea                 BobMatrix(a5),a4
    ;move.w              PLAYERSHOT_BobSlot(a1),d4
    ;lea                 (a4,d4.w),a4

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

    ;moveq               #0,d0
    ;move.b              PLAYERSHOT_PosX(a1),d0
    ;move.w              d0,Bob_X(a4)

    ;moveq               #16,d0
    ;add.b               PLAYERSHOT_PosY(a1),d0
    ;sub.w               #16,d0
    ;move.w              d0,Bob_Y(a4)

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
    ;moveq               #0,d0
    ;move.b              PLAYERSHOT_PosX(a1),d0
    ;move.w              d0,Bob_X(a4)

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

    ;move.b              PLAYERSHOT_WeaponId(a1),d1                          ; TODO: clean this shit up
    ;lsr.b               #1,d1
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

    ;st                  Bob_Hide(a4)
    PUSHM               a1/d7
    bsr                 BobDrawDirect
    POPM                a1/d7
    bra                 .exit

.removeshot
    bset                #7,PLAYERSHOT_Status(a1)                            ; disable shot
    ;clr.b               Bob_Allocated(a4)                                   ; remove bob
.exit
    rts

;----------------------------------------------------------------------------
;
; shot powerup collision check
;
; a1 = player shot structure
;
;----------------------------------------------------------------------------

ShotPowerUpCollisionCheck:                        ; ...
    ;ld         a, (PowerUpStatus)              ; 0 = inactive / 1 = active
    ;dec        a
    ;ret        nz
    move.b              PowerUpStatus(a5),d0
    subq.b              #1,d0
    bne                 .exit

    ;push       ix
    ;pop        hl
    ;inc        l
    ;inc        l
    ;call       GetPlayerShotDim                ; get player shot dimensions
                                                  ;
                                                  ; hl = player shot pointer (starting at pos y)
                                                  ; de = player shot box
    ;ld         hl, PowerUpPosY
    ;ld         a, (hl)
    ;inc        l
    ;inc        l
    ;ld         h, (hl)
    ;ld         l, a
    ;ld         bc, 1010h                       ; power up box size (16x16)

    ;call       CheckCollision                  ; collision detect

    GETPLAYERSHOTDIM    a1,a2
    GETPOWERUPDIM
    CHECKCOLLISION
    bcs                 .exit
                                                  ;
                                                  ; bc = box size
                                                  ; hl = position y / x
    ;ret        c                               ; shot did not hit powerup, quit
    ;ld         a, 0Eh
    ;call      
    moveq               #$e,d0
    bsr                 SfxPlay
    
    ;set        7, (ix+PLAYERSHOT_Status)       ; set shot colission bit
    ;ld         a, 2
    ;ld         (PowerUpStatus), a              ; 0 = inactive / 1 = active

    move.b              #2,PowerUpStatus(a5)

    bset                #7,PLAYERSHOT_Status(a1)                            ; kill shot
    ;lea                 BobMatrix(a5),a4
    ;move.w              PLAYERSHOT_BobSlot(a1),d0
    ;lea                 (a4,d0.w),a4
    ;clr.b               Bob_Allocated(a4)
.exit
    ;ret
    rts

;----------------------------------------------------------------------------
;
; player shot boss check
;
; checks if player shots hit boss
; if boss is killed, return in carry flag
;
;----------------------------------------------------------------------------


PlayerShotBossLogic:                              ; ...
    ;call                PlayerShotBossCheck                                 ; checks if the player shots hit the boss
    ;ld                  a, (BossDeathFlag)
    ;and                 a
    ;ret
;    bsr                 PlayerShotBossCheck
;    rts

;PlayerShotBossCheck:                              ; ...
    ;ld                  a, (BossId)
    ;add                 a, a
    ;add                 a, a                                                ; * 4
    ;ld                  hl, BossHitBoxDimensionList
    ;call                ADD_A_HL
    lea                 BobMatrix(a5),a4

    moveq               #0,d0
    move.b              BossId(a5),d0
    add.w               d0,d0
    add.w               d0,d0
    lea                 BossHitBoxDimensionList,a2
    add.l               d0,a2

PlayerShotBossCheck1:                             ; ...
    ;ld                  de, BossHitBoxOffsetY
    ;ld                  bc, 4
    ;ldir
    ;ld                  ix, PlayerShot1
    ;ld                  b, 3
    lea                 PlayerShot1(a5),a1
    moveq               #3-1,d7

;PlayerShotBossCheckLoop:                          ; ...
.loop
    ;bit                 7, (ix+PLAYERSHOT_Status)
    ;jr                  nz, PlayerShotBossCheckNext
    btst                #7,PLAYERSHOT_Status(a1)
    bne                 .next

    ;ld                  a, (ix+PLAYERSHOT_WeaponId)
    ;ld                  hl, PlayerShotHitBoxList                            ; player shot boss hit data
                                                  ;
                                                  ; +0 = shot height
                                                  ; +1 = number of hit points
    ;add                 a, a
    ;call                ADD_A_HL
    moveq               #0,d0
    move.b              PLAYERSHOT_WeaponId(a1),d0
    add.w               d0,d0
    lea                 PlayerShotHitBoxList,a3
    add.l               d0,a3

    ;ld                  a, (BossHitBoxOffsetY)
    ;add                 a, (hl)                                             ; shot height
    ;ld                  e, a
    move.b              BOSSBOX_OffsetY(a2),d4
    add.b               (a3),d4

    ;ld                  a, (BossHitBoxHeight)
    ;add                 a, e
    ;ld                  d, a
    move.b              d4,d3
    add.b               BOSSBOX_Height(a2),d3

    ;ld                  a, (BossPosX)
    ;sub                 (ix+PLAYERSHOT_PosX)
    ;neg
    ;add                 a, e
    move.b              BossPosX(a5),d0
    sub.b               PLAYERSHOT_PosX(a1),d0
    neg                 d0
    add.b               d4,d0

    ;cp                  d
    ;jr                  nc, PlayerShotBossCheckNext
    cmp.b               d3,d0
    bcc                 .next

    ;ld                  a, (BossHitBoxxOffsetX)
    ;ld                  e, a
    ;ld                  a, (BossHitBoxWidth)
    ;ld                  d, a
    move.b              BOSSBOX_OffsetX(a2),d4
    move.b              BOSSBOX_Width(a2),d3

    ;ld                  a, (BossPosY)
    ;sub                 (ix+PLAYERSHOT_PosY)
    ;neg
    ;add                 a, e
    ;cp                  d
    ;call                c, PlayerShotHitBoss
    move.b              BossPosY(a5),d0
    sub.b               PLAYERSHOT_PosY(a1),d0
    neg                 d0
    add                 d4,d0
    cmp.b               d0,d3
    bcs                 .nothit

    bsr                 PlayerShotHitBoss
.nothit

;PlayerShotBossCheckNext:                          ; ...
.next
    ;ld                  de, 10h
    ;add                 ix, de
    ;djnz                PlayerShotBossCheckLoop
    ;ret
    lea                 PLAYERSHOT_Sizeof(a1),a1
    dbra                d7,.loop
    rts


;----------------------------------------------------------------------------
;
; player shot hit boss
;
;----------------------------------------------------------------------------

PlayerShotHitBoss:                                ; ...
    ;ld                  (ix+PLAYERSHOT_PosY), 0E0h
    ;set                 7, (ix+PLAYERSHOT_Status)
    ;move.w              PLAYERSHOT_BobSlot(a1),d0                           ; remove player shot
    ;clr.b               Bob_Allocated(a4,d0.w)
    bset                #7,PLAYERSHOT_Status(a1)

    ;ld                  a, (BossDeathFlag)
    ;and                 a
    ;ret                 nz
    tst.b               BossDeathFlag(a5)
    bne                 .exit

    tst.b               BossIsSafe(a5)
    beq                 .hitboss

    ;call                IsBoss2Safe
    ;ld                  a, 0Ch
    ;jp                  z,                                        ; yes, play no hit sound

    ;call                IsBoss4Safe
    ;ld                  a, 0Ch
    ;jp                  z,                                        ; yes play no hit sound
    ;ld                  a, 0Bh
    ;call                                                          ; boss not safe, play hit sound and continue
    moveq               #$38,d0                                             ; boss is safe, play other sfx
    bra                 SfxPlay

.hitboss
    moveq               #$37,d0
    bsr                 SfxPlay

    ;inc                 hl
    ;ld                  e, (hl)                                             ; shot hit points
    ;ld                  a, (BossId)
    ;ld                  hl, BossHitCountList
    ;call                ADD_A_HL
    ;ld                  c, (hl)                                             ; max hit points for this boss

    ;lea                 BossHitCountList,a0
    ;moveq               #0,d0
    ;move.b              BossId(a5),d0
    ;move.b              (a0,d0.w),d2
    move.b              BossHitMax(a5),d2

    ;ld                  hl, BossHitCount
    ;ld                  a, (hl)
    ;add                 a, e                                                ; add this shots hit points to boss hit count
    ;ld                  (hl), a                                             ; save it
    move.b              BossHitCount(a5),d0
    add.b               1(a3),d0
    move.b              d0,BossHitCount(a5)

    ;cp                  c                                                   ; check boss hit points
    ;ret                 c                                                   ; under max, quit

    bsr                 CalcBossHealth

    cmp.b               d2,d0
    bcs                 .exit

    ;ld                  a, 1
    ;ld                  (BossDeathFlag), a                                  ; set boss hit flag
    ;pop                 bc
    ;ld                  de, 0                                               ; score 0000xxxx
    ;ld                  c, 1                                                ; score xxxx0000
    move.b              #1,BossDeathFlag(a5)
    move.w              #10000,d0
    bsr                 AddScore

    ;jp                  AddScore1
; End of function PlayerShotHitBoss
.exit
    rts

