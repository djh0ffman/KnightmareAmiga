    include           "common.asm"

;----------------------------------------------------------------------------
;
; player mode logic
;
;----------------------------------------------------------------------------

PlayerModeLogic:      
    lea               PlayerStatus(a5),a0
    moveq             #0,d0
    move.b            PLAYER_Status(a0),d0
    JMPINDEX          d0    

PlayerModeLogicJumpIndex:
    dc.w              PlayerModeMove-PlayerModeLogicJumpIndex                ; PlayerModeMove
    dc.w              PlayerModeShoot-PlayerModeLogicJumpIndex               ; PlayerModeShoot
    dc.w              PlayerModeDead-PlayerModeLogicJumpIndex                ; PlayerModeDead
    dc.w              PlayerModeEndLevel1-PlayerModeLogicJumpIndex           ; PlayerModeEndLevel1

; ---------------------------------------------------------------------------

PlayerModeDummy:
    rts

;----------------------------------------------------------------------------
;
; player mode move
;
;----------------------------------------------------------------------------

PlayerModeMove:       
    bsr               PlayerControl

    cmp.b             #POWERUP_RED,PLAYER_PowerUp(a0)
    beq               UpdatePlayerSprites

    btst              #4,ControlsTrigger(a5)
    beq               UpdatePlayerSprites                         

    move.b            #1,PLAYER_Status(a0)
    clr.b             PLAYER_Timer(a0)

    bra               UpdatePlayerSprites

;----------------------------------------------------------------------------
;
; player mode move
;
;----------------------------------------------------------------------------

PlayerModeShoot:      
    bsr               PlayerControl

    addq.b            #1,PLAYER_Timer(a0)
    move.b            PLAYER_Timer(a0),d0
    cmp.b             #1,d0                                                  ; PLAYER_Timer(a0)
    bne               .noshot

    bsr               PlayerAddShot
    bra               UpdatePlayerSprites

.noshot
    cmp.b             #6,d0                                                  ; PLAYER_Timer(a0)
    bne               .notdone

    tst.b             OptionAutoFire(a5)
    beq               .noautofire

    btst              #4,ControlsHold(a5)
    beq               .noautofire

    clr.b             PLAYER_Timer(a0)
    bra               UpdatePlayerSprites

.noautofire
    clr.b             PLAYER_Status(a0)
.notdone
    bra               UpdatePlayerSprites


;----------------------------------------------------------------------------
;
; player control
;
; manages the player control
;
; sets the speed of the player depending on the direction
; also set speed to max if red power up active
;
;----------------------------------------------------------------------------

PlayerControl:      
    lea               PlayerSpeeds,a4

    moveq             #4,d0                                                  ; red is full speed                                
    cmp.b             #POWERUP_RED,PLAYER_PowerUp(a0)
    bcc               .redpower
    move.b            PLAYER_Speed(a0),d0
.redpower
    add.w             d0,d0                                                  ; --- PLAYER CONTROL
    add.w             d0,d0                                       
    lea               (a4,d0.w),a4                                           ; player speeds
    moveq             #0,d3                                                  ; anim speed
    move.w            (a4),d2                                                ; player move speed
    move.w            d2,d3                                                  ; player anim move speed

    move.b            ControlsHold(a5),d0
    and.b             #3,d0
    beq               PlayerLeftRight

    move.w            PLAYER_PosY(a0),d1
    move.w            d1,PLAYER_PosYTemp(a0)
    btst              #0,d0
    beq               .down
    neg.w             d2                                                     ; up
.down
    add.w             d2,d1
    cmp.w             #$2000,d1
    bcc               PlayerTopInRange
    move.w            #$2000,d1

PlayerTopInRange:                
    cmp.w             #$af00,d1
    bcs               PlayerBottomInRange
    move.w            #$af00,d1

PlayerBottomInRange:             
    move.w            d1,PLAYER_PosY(a0)
    add.w             (a4),d3

PlayerLeftRight:                 
    move.b            ControlsHold(a5),d0
    and.b             #$c,d0
    beq               PlayerAnimate

    move.w            PLAYER_PosX(a0),d1
    move.w            d1,PLAYER_PosXTemp(a0)
    move.w            2(a4),d2                                               ; left right move speed
    btst              #2,d0
    beq               .right
    neg.w             d2                                                     ; left
.right
    add.w             d2,d1

    cmp.w             #$0300,d1
    bcc               PlayerInRangeLeft
    move.w            #$0300,d1

PlayerInRangeLeft:         
    cmp.w             #$ef00,d1     
    bcs               PlayerInRangeRight
    move.w            #$ef00,d1

PlayerInRangeRight:               
    move.w            d1,PLAYER_PosX(a0)
    add.w             2(a4),d3

PlayerAnimate:          
    add.w             d3,PLAYER_Anim(a0)

    move.b            PLAYER_Anim(a0),d0                                     ; animate player
    lsr.b             #3,d0
    and.b             #7,d0                                                  ; 4 frames / 8 loop
    cmp.b             #4,d0                                                  ; first 4
    bcs               .nopong 

    not.b             d0                                                     ; reverse for other 4
    and.b             #3,d0
.nopong
    move.b            d0,PLAYER_AnimFrame(a0)

    bsr               GetPlayerTiles

    tst.b             BossStatus(a5)
    beq               .skipbosscheck

    GETPLAYERDIM
    GETBOSSDIM
    CHECKCOLLISION

    bcc               KillPlayer

.skipbosscheck
    cmp.b             #$b0,PLAYER_PosY(a0)
    bcs               PowerUpTimerLogic

    move.b            #$af,PLAYER_PosY(a0)                  ; proof I accidentally made the game screen longer
    bra               KillPlayer


;----------------------------------------------------------------------------
;
; update player sprites
;
; sets player position / anim frame
;
; a0 = bob data
; d0 = y position
; d1 = x position
; d2 = slot id
;
;----------------------------------------------------------------------------

UpdatePlayerSprites:
    lea               BobMatrix(a5),a4
    move.w            PLAYER_BobSlot(a0),d0
    lea               (a4,d0.w),a4                                           ; bob structure

    moveq             #0,d0
    moveq             #0,d1
    move.b            PLAYER_PosY(a0),d0
    move.b            PLAYER_PosX(a0),d1

    move.w            d0,Bob_Y(a4)
    move.w            d1,Bob_X(a4)

    sf                Bob_Hide(a4)

    moveq             #0,d4
    move.b            PLAYER_AnimFrame(a0),d4

    lea               PlayerBobPtrs(a5),a3
    move.b            PLAYER_PowerUp(a0),d0
    beq               .setbob

    cmp.b             #POWERUP_PRINCESS,d0
    beq               .setprincess

    lea               PlayerSheildBobPtrs(a5),a3
    cmp.b             #POWERUP_SHIELD,d0
    beq               .setbob

    lea               PlayerTransBobPtrs(a5),a3
    cmp.b             #POWERUP_TRANSPARENT,d0
    beq               .setbob

    lea               PlayerRedBobPtrs(a5),a3
    cmp.b             #POWERUP_RED,d0
    beq               .setbob

    lea               PlayerGradiusBobPtrs(a5),a3
    moveq             #1,d4                                                  ;  centre
    move.b            ControlsHold(a5),d0
    and.b             #%1100,d0
    beq               .setbob                                                ; not left or right

    moveq             #0,d4                                                  ; left frame
    btst              #2,d4
    bne               .setbob
    moveq             #2,d4                                                  ; right frame

.setbob
    add.w             d4,d4
    add.w             d4,d4

    move.l            (a3,d4.w),a3
    BOBSET            a3,a4
    rts

.setprincess
    lea               BobPrincess_0,a3
    BOBSET            a3,a4
    rts

;----------------------------------------------------
;
; player speeds - two bytes
;
; +0 = speed y
; +1 = speed x
;----------------------------------------------------

PlayerSpeeds:
    dc.w              $0E<<4, $10<<4                                 
    dc.w              $13<<4, $15<<4                                    
    dc.w              $17<<4, $1A<<4                                    
    dc.w              $1C<<4, $1E<<4                                    
    dc.w              $20<<4, $24<<4                                    


;----------------------------------------------------
;
; kill player
;
; triggers death seqeunce and freezes scrolling
;
;----------------------------------------------------

KillPlayer:        
    if                DEBUG_INVINCIBLE=1
    rts
    endif

    cmp.b             #PLAYERMODE_DEAD,PlayerStatus(a5)
    beq               .exit
    move.b            #PLAYERMODE_DEAD,PlayerStatus(a5)

    move.b            #$e0,PlayerStatus+PLAYER_Timer(a5)
    clr.b             PlayerStatus+PLAYER_AnimFrame(a5)
    clr.b             MapReadyFlag(a5)                                       ; stop scrolling

    clr.b             PowerUpSfxActive(a5)
    clr.b             SfxDisable(a5)

    moveq             #0,d0
    moveq             #MOD_DEATH,d1
    bra               MusicSet

.exit
    rts

;----------------------------------------------------
;
; player mode dead
;
; flashes player then plays death animation 
;
;----------------------------------------------------

PlayerModeDead:    
    bsr               ScrollTick

    subq.b            #1,PLAYER_Timer(a0)
    move.b            PLAYER_Timer(a0),d0
    beq               .donedieing
    cmp.b             #$a0,d0
    bcc               .flash

    lea               BobMatrix(a5),a4                                       ; death animation
    move.w            PLAYER_BobSlot(a0),d0
    lea               (a4,d0.w),a4       

    sf                Bob_Hide(a4)
    lea               PlayerDeathBobPtrs(a5),a3
    moveq             #0,d0
    move.b            PLAYER_AnimFrame(a0),d0
    cmp.b             #11,d0
    beq               .animdone

    add.w             d0,d0
    add.w             d0,d0
    move.l            (a3,d0.w),a3

    BOBSET            a3,a4

    move.b            TickCounter(a5),d0
    and.b             #7,d0
    bne               .skip

    move.b            PLAYER_AnimFrame(a0),d0
    addq.b            #1,PLAYER_AnimFrame(a0)
.skip
    rts
.animdone
    st                Bob_Hide(a4)
    rts

    ; flicker player
.flash
    lea               BobMatrix(a5),a4
    move.w            PLAYER_BobSlot(a0),d0
    lea               (a4,d0.w),a4  
    move.b            TickCounter(a5),d0
    and.b             #1,d0
    move.b            d0,Bob_Hide(a4)
    rts

.donedieing
    clr.b             GameRunning(a5)
    clr.b             PlayerStatus+PLAYER_SheildPower(a5)
    clr.b             PlayerStatus+PLAYER_Speed(a5)
    clr.b             PlayerStatus+PLAYER_WeaponId(a5)
    clr.b             PlayerStatus+PLAYER_PowerUp(a5)
    
    move.b            PermaSpeed(a5),PlayerStatus+PLAYER_Speed(a5)
    move.b            PermaShield(a5),PlayerStatus+PLAYER_SheildPower(a5)
    beq               .skipshield
    move.b            #POWERUP_SHIELD,PlayerStatus+PLAYER_PowerUp(a5)
.skipshield
    move.b            PermaWeapon(a5),PlayerStatus+PLAYER_WeaponId(a5)

    if                DEBUG_INFINITELIVES=0
    subq.b            #1,Lives(a5)
    endif

    bsr               ClearAllSprites

    rts

;----------------------------------------------------
;
; player mode end level
;
; walk through the gates
;
;----------------------------------------------------

PlayerModeEndLevel1:
    moveq             #0,d0
    move.b            PLAYER_Timer(a0),d0
    JMPINDEX          d0

PlayerModeEndList:
    dc.w              PlayerModeEndInit-PlayerModeEndList
    dc.w              PlayerModeEndWalk-PlayerModeEndList
    dc.w              PlayerModeEndGateInit-PlayerModeEndList
    dc.w              PlayerModeEndGateWalk-PlayerModeEndList
    dc.w              PlayerModeEndDone-PlayerModeEndList


PlayerModeEndInit:
    PUSH              a0
    bsr               CalcAngleToGate
    move.b            d0,PlayerGateAngle(a5)
    bsr               CalcSpeed
    POP               a0

    move.w            d1,PLAYER_SpeedY(a0)
    move.w            d2,PLAYER_SpeedX(a0)

    moveq             #0,d0
    moveq             #MOD_START,d1
    bsr               MusicSet

    addq.b            #1,PLAYER_Timer(a0)
    rts

PlayerModeEndWalk:
    bsr               PlayerAutoWalk
    cmp.b             #$20,PLAYER_PosY(a0)
    bcc               .notgate
    addq.b            #1,PLAYER_Timer(a0)
    lea               BobMatrix(a5),a4
    move.w            PLAYER_BobSlot(a0),d0
    move.w            #$16,Bob_TopMargin(a4)
.notgate
    rts

PlayerModeEndGateInit:
    clr.w             PLAYER_SpeedX(a0)
    move.w            #-$b0/2,PLAYER_SpeedY(a0)
    addq.b            #1,PLAYER_Timer(a0)
    rts

PlayerModeEndGateWalk:
    bsr               PlayerAutoWalk
    cmp.b             #$7,PLAYER_PosY(a0)
    bcc               .notgate
    addq.b            #1,PLAYER_Timer(a0)
.notgate
    rts


PlayerModeEndDone:
    lea               BobMatrix(a5),a4
    move.w            PLAYER_BobSlot(a0),d0
    clr.w             Bob_TopMargin(a4)
    st                Bob_Hide(a4,d0.w)

    cmp.b             #7,Level(a5)
    bne               .skiplast

    tst.b             _mt_Enable
    bne               .notyet
.skiplast
    move.b            #1,AdvanceStageFlag(a5)
.notyet
    rts

;----------------------------------------------------
;
; player auto walk
;
; walks the player and animates
;
;----------------------------------------------------


PlayerAutoWalk:
    move.w            PLAYER_SpeedY(a0),d0
    add.w             d0,PLAYER_PosY(a0)
    move.w            PLAYER_SpeedX(a0),d0
    add.w             d0,PLAYER_PosX(a0)

    add.w             #$100,PLAYER_Anim(a0)

    move.b            PLAYER_Anim(a0),d0                                     ; animate player
    lsr.b             #3,d0
    and.b             #7,d0                                                  ; 4 frames / 8 loop
    cmp.b             #4,d0                                                  ; first 4
    bcs               .nopong 

    not.b             d0                                                     ; reverse for other 4
    and.b             #3,d0
.nopong
    move.b            d0,PLAYER_AnimFrame(a0)

    bsr               UpdatePlayerSprites

    rts


;----------------------------------------------------------------------------
;
; init player bob pointers
;
; sets the bob pack used for the player
;
;----------------------------------------------------------------------------

PlayerInitBobPtrs:
    lea               BobPlayerNormal,a0
    lea               PlayerBobPtrs(a5),a1
    bsr               SetDataPointers

    lea               BobPlayerShield,a0
    lea               PlayerSheildBobPtrs(a5),a1
    bsr               SetDataPointers

    lea               BobPlayerTrans,a0
    lea               PlayerTransBobPtrs(a5),a1
    bsr               SetDataPointers

    lea               BobPlayerRed,a0
    lea               PlayerRedBobPtrs(a5),a1
    bsr               SetDataPointers

    lea               BobPlayerDeath,a0
    lea               PlayerDeathBobPtrs(a5),a1
    bsr               SetDataPointers

    lea               BobPlayerGradius,a0
    lea               PlayerGradiusBobPtrs(a5),a1
    bsr               SetDataPointers

    rts