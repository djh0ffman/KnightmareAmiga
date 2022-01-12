
    include           "common.asm"

;----------------------------------------------------------------------------
;
;  power up logic
;
;----------------------------------------------------------------------------

; weapon order

; arrow
; fireball
; boomerrang
; sword
; fire arrow

PowerUpLogic:                                     ; ...
    tst.b             PowerUpStatus(a5)
    bne               PowerUpActive

    tst.b             BossStatus(a5)
    bne               .exit

    tst.b             FreezeStatus(a5)
    bne               .exit

    moveq             #0,d0
    move.b            Level(a5),d0
    add.w             d0,d0
    add.w             d0,d0
    lea               PowerUpLevelData,a0
    move.l            (a0,d0.w),a0

    move.b            LevelPosition(a5),d1                       
    lsr.b             #1,d1                

.loop
    move.b            (a0)+,d0
    cmp.b             #-1,d0
    beq               .exit                                               ; end of data

    and.b             #$7f,d0
    cmp.b             d1,d0
    beq               PowerUpInit
    bra               .loop

.exit
    rts
;----------------------------------------------------------------------------
;
;  power up init
;
; in 
; d0 = power up type
;----------------------------------------------------------------------------


PowerUpInit:
    bsr               LoadPowerUpDefaults

    move.b            #1,PowerUpStatus(a5)
    move.b            -1(a0),d0
    rol.b             #1,d0
    and.b             #1,d0
    move.b            d0,PowerUpType(a5)

    move.b            PlayerStatus+PLAYER_PosX(a5),d0
    move.b            #$28,d1
    cmp.b             d1,d0
    bcs               .setx
    move.b            #$d0,d1
    cmp.b             d1,d0
    bcc               .setx
    move.b            d0,d1

.setx
    clr.w             PowerUpPosX(a5)
    move.b            d1,PowerUpPosX(a5)

    bsr               BobAllocate
    move.l            a4,PowerUpBobSlotPtr(a5)
   
    moveq             #16,d0
    add.b             PowerUpPosY(a5),d0
    sub.w             #16,d0
    move.w            d0,Bob_Y(a4)

    moveq             #0,d0
    move.b            PowerUpPosX(a5),d0
    move.w            d0,Bob_X(a4)
    rts

RemovePowerUp:
    move.l            PowerUpBobSlotPtr(a5),a4                            ; remove bob and reset the powerup stats
    clr.b             Bob_Allocated(a4)
    bra               LoadPowerUpDefaults

;----------------------------------------------------------------------------
;
;  power up collision / collect etc.
;
;----------------------------------------------------------------------------

PowerUpActive:
    bsr               PowerUpBobLogic

    cmp.b             #PLAYERMODE_DEAD,PlayerStatus(a5)
    bcc               .skipcollision

    GETPLAYERDIM
    GETPOWERUPDIM
    CHECKCOLLISION
    bcc               PowerUpCollect

.skipcollision
    move.b            PowerUpStatus(a5),d0
    cmp.b             #2,d0
    bne               .skipshot                                           ; not hit

    move.b            PowerUpType(a5),d0
    moveq             #$08,d1                                             ; hit count
    moveq             #$03,d2
    tst.b             d0
    beq               .skip
    moveq             #$07,d1                                             ; hit count
    moveq             #$01,d2   

.skip
    addq.b            #1,PowerUpHitCount(a5)
    move.b            PowerUpHitCount(a5),d0
    cmp.b             d1,d0
    bcs               .skipreset

    clr.b             PowerUpHitCount(a5)                                 ; reset hit counter
    moveq             #0,d0

.skipreset
    move.b            d0,d4 

    move.b            PowerUpAngle2(a5),d0                                ; start moving
    cmp.b             d2,d0
    bcc               .skipshot

    lsr.b             #2,d4
    move.b            d4,PowerUpAngle2(a5)
          
.skipshot
    bsr               PowerUpCalcSpeed
    move.b            #1,PowerUpStatus(a5)

    move.w            PowerUpSpeedY(a5),d0
    add.w             d0,PowerUpPosY(a5)

    move.l            PowerUpBobSlotPtr(a5),a4
    moveq             #16,d0
    add.b             PowerUpPosY(a5),d0
    cmp.b             #$d0,d0                                             ; off screen, remove
    bcc               RemovePowerUp
    sub.w             #16,d0
    move.w            d0,Bob_Y(a4)

    moveq             #0,d0
    move.b            PowerUpPosX(a5),d0
    move.w            d0,Bob_X(a4)

    rts
; =============== S U B R O U T I N E =======================================


LoadPowerUpDefaults:
    clr.b             PowerUpStatus(a5)
    move.b            #-1,PowerUpHitCountPrev(a5)
    clr.b             PowerUpHitCount(a5)
    move.w            #$f000,PowerUpPosY(a5)
    move.w            #$009F/2,PowerUpSpeedY(a5)
    clr.b             PowerUpAngle1(a5)
    clr.b             PowerUpAngle2(a5)
    rts

;----------------------------------------------------------------------------
;
;  power up collision / collect
;
;----------------------------------------------------------------------------

PowerUpCollect:
    bsr               PowerUpCollectMain
    bra               RemovePowerUp


PowerUpCollectMain:
    lea               WeaponIdList,a0
    tst.b             PowerUpType(a5)
    beq               .weapon
    lea               PowerUpIdList,a0
.weapon
    moveq             #0,d0
    move.b            PowerUpHitCount(a5),d0
    move.b            (a0,d0.w),d4                                        ; power up id

    move.w            #200,d0
    tst.b             PowerUpHitCount(a5)
    bne               .addscore
    move.w            #1000,d0
       
.addscore
    bsr               AddScore

    tst.b             d4                                                  ; power up id = 0, just do sfx as we've added score
    beq               PowerUpSfx
      
    bsr               PowerUpCollectSfx

    tst.b             PowerUpType(a5)                                     ; 0 = weapon / 1 = powerup
    bne               PowerUpApply

    ; weapon apply
    move.b            PlayerStatus+PLAYER_WeaponId(a5),d0
    and.b             #$fe,d0
    cmp.b             d0,d4
    bne               .diffweapon
    addq.b            #1,d4

.diffweapon
    move.b            d4,PlayerStatus+PLAYER_WeaponId(a5)
    rts
; ---------------------------------------------------------------------------

PowerUpApply: 
    cmp.b             #POWERUP_GRADIUS,PlayerStatus+PLAYER_PowerUp(a5)
    beq               .exit                                               ; gradius powerup, nothing else works

    move.b            d4,d0
    beq               .exit                                               ; no power up and score already added
    subq.b            #1,d0
    beq               PowerUpSpeed

    move.b            d0,PlayerStatus+PLAYER_PowerUp(a5)

    cmp.b             #POWERUP_RED,d0
    bne               .skipautofire                                       ; if red power up, disable autofire

    clr.b             PlayerStatus(a5)                                    ; reset player to not be in auto-fire

.skipautofire

    subq.b            #1,d0
    beq               .shield

    move.b            #45,PowerUpTimerHi(a5)                              
    move.b            #14,PowerUpTimerLo(a5)                             
    
    bsr               PowerTimerRender
    bsr               PowerTimerDisplay
.exit
    rts

.shield
    move.b            #$1e,PlayerStatus+PLAYER_SheildPower(a5)
    bsr               PowerTimerRemove
    rts
; ---------------------------------------------------------------------------

PowerUpSpeed:
    move.b            PlayerStatus+PLAYER_Speed(a5),d0
    addq.b            #1,d0
    cmp.b             #4,d0                                               ; max speed 4
    bcs               .under
    moveq             #4,d0    
.under
    move.b            d0,PlayerStatus+PLAYER_Speed(a5)
    rts

; ---------------------------------------------------------------------------

PowerUpSfx:
    moveq             #$12,d0
    bra               SfxPlay

PowerUpCalcSpeed:
    move.b            PowerUpAngle2(a5),d0
    add.b             PowerUpAngle1(a5),d0
    move.b            d0,PowerUpAngle1(a5)
    bsr               CalcSpeed                                           ; calculates the y and x speed of a shot based on the supplied angle

    asr.w             #1,d1
    add.w             d1,PowerUpPosX(a5)
    rts

; ---------------------------------------------------------------------------
;
; power up bob logic
; 
; select the right bob for the job
;
; ---------------------------------------------------------------------------

PowerUpBobLogic:
    moveq             #0,d0
    move.b            PowerUpHitCount(a5),d0
    subq.b            #2,d0
    bpl               .skipreset
    moveq             #0,d0
.skipreset

    tst.b             PowerUpType(a5)
    beq               .weapon

    tst.b             d0
    bne               .powerup

    move.l            WeaponPowerUpBobPtrs1(a5),a0
    btst              #3,TickCounter(a5)
    beq               .otherp
    move.l            WeaponPowerUpBobPtrs2(a5),a0
.otherp
    bra               .setbob

.powerup
    ; power up bob select
    subq.b            #1,d0
    add.w             d0,d0
    add.w             d0,d0
    lea               PowerUpBobPtrs1(a5),a0
    btst              #3,TickCounter(a5)
    beq               .otherpup
    lea               PowerUpBobPtrs2(a5),a0
.otherpup
    move.l            (a0,d0.w),a0
    bra               .setbob



    ; weapon select bob
.weapon
    tst.b             d0
    bne               .show

    lea               PowerUpBobPtrs(a5),a0
    moveq             #0,d0
    move.b            TickCounter(a5),d0
    and.b             #3,d0
    add.w             d0,d0
    add.w             d0,d0
    move.l            (a0,d0.w),a0
    bra               .setbob

.show
    ;subq.b            #1,d0
    cmp.b             #4,d0
    bne               .notsword
    move.b            PlayerStatus+PLAYER_WeaponId(a5),d1
    lsr.b             #1,d1
    cmp.b             #2,d1
    bne               .notsword
    addq.b            #2,d0
.notsword
    add.w             d0,d0
    add.w             d0,d0
    lea               WeaponPowerUpBobPtrs1(a5),a0
    btst              #3,TickCounter(a5)
    beq               .listone
    lea               WeaponPowerUpBobPtrs2(a5),a0
.listone
    move.l            (a0,d0.w),a0
.setbob
    move.l            PowerUpBobSlotPtr(a5),a4
    sf                Bob_Hide(a4)
    BOBSET            a0,a4
.exit
    rts

; ---------------------------------------------------------------------------
;
; power up timer logic
; 
; does countdown and resets to shield if still have it
;
; in
; a0 = player structure
; ---------------------------------------------------------------------------
    
PowerUpTimerLogic:                                ; ...
    cmp.b             #POWERUP_TRANSPARENT,PLAYER_PowerUp(a0)
    bcs               .exit

    bsr               PowerTimerRender

    move.b            PowerUpTimerLo(a5),d0
    move.b            PowerUpTimerHi(a5),d1
    
    subq.b            #1,PowerUpTimerLo(a5)
    bcc               .sfxplay

    moveq             #14,d1
    cmp.b             #POWERUP_GRADIUS,PLAYER_PowerUp(a0)
    bne               .notgradius
    moveq             #59,d1

.notgradius
    move.b            d1,PowerUpTimerLo(a5)                               ; TODO: hz value
    subq.b            #1,PowerUpTimerHi(a5) 
    bcc               .sfxplay

    cmp.b             #POWERUP_GRADIUS,PlayerStatus+PLAYER_PowerUp(a5)
    bne               .notgrad

    bsr               MusicRestore

.notgrad
    moveq             #POWERUP_NONE,d2
    tst.b             PLAYER_SheildPower(a0)
    beq               .nosheild
    moveq             #POWERUP_SHIELD,d2

.nosheild    
    move.b            d2,PLAYER_PowerUp(a0)

    bsr               PowerTimerRemove
.sfxplay
    cmp.b             #4,PowerUpTimerHi(a5)
    bcc               .exit
    cmp.b             #14,PowerUpTimerLo(a5)
    bne               .exit

    moveq             #$32,d0
    bsr               SfxPlay

.exit
    rts
    