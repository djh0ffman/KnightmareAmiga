
;----------------------------------------------------------------------------
;
;  blue knight
;
;----------------------------------------------------------------------------

    include     "common.asm"
BlueKnightLogic:
    moveq       #0,d0
    move.b      ENEMY_Status(a2),d0
    subq.b      #1,d0
    JMPINDEX    d0

BlueKnightLogicList:
    dc.w        BlueKnightInit-BlueKnightLogicList     
    dc.w        BlueKnightLogic1-BlueKnightLogicList
    dc.w        BlueKnightLogic2-BlueKnightLogicList
    dc.w        EnemyFireDeath-BlueKnightLogicList      ;EnemyFireDeath1-BlueKnightLogicList
    dc.w        EnemyBonusWait-BlueKnightLogicList      ;EnemyBonusWait-BlueKnightLogicList
; ---------------------------------------------------------------------------

BlueKnightDummy:
    rts

BlueKnightInit:                                   ; ...
    ;call       EnemyClearParams
    bsr         EnemyClear

    ;ld         (ix+ENEMY_SpeedY), 1
    ;ld         (ix+ENEMY_SpriteId), 18h
    ;ld         (ix+ENEMY_HitPoints), 3
    ;jr         EnemyNextStatus_
    move.w      #$100,ENEMY_SpeedY(a2)
    move.b      #3,ENEMY_HitPoints(a2)
    addq.b      #1,ENEMY_Status(a2)
    rts

; ---------------------------------------------------------------------------

BlueKnightLogic1:                                 ; ...
    ;call       BlueKnightShared
    bsr         BlueKnightShared

    ;ld         a, (ix+ENEMY_PosY)
    ;cp         0C0h                         ; wait till knight at this position
    ;ret        nc
    cmp.b       #$c0,ENEMY_PosY(a2)
    bcc         .exit

    ;ld         a, (PlayerY)
    ;sub        (ix+ENEMY_PosY)
    ;cp         40h                          ; '@'                         ; and this distance to player
    ;ret        nc
    move.b      PlayerStatus+PLAYER_PosY(a5),d0
    sub.b       ENEMY_PosY(a2),d0
    cmp.b       #$40,d0
    bcc         .exit

    ;ld         a, (ix+ENEMY_PosX)
    ;cp         80h
    ;ld         bc, 120h                     ; speed x
    ;jr         c, BlueKnightSetSpeed
    move.w      #$0120,d1
    cmp.b       #$80,ENEMY_PosX(a2)
    bcs         .setspeed

    ;ld         bc, 0FEE0h                   ; speed x
    move.w      #$fee0,d1

;BlueKnightSetSpeed:                               ; ...
.setspeed
    ;ld         (ix+ENEMY_SpeedXDec), c
    ;ld         (ix+ENEMY_SpeedX), b
    ;xor        a
    move.w      d1,ENEMY_SpeedX(a2)

    ;ld         (ix+ENEMY_SpeedYDec), a
    ;ld         (ix+ENEMY_SpeedY), a
    clr.w       ENEMY_SpeedY(a2)

    ;ld         a, 30h                       ; '0'
    ;ld         (ix+ENEMY_WaitCounter), a
    move.b      #$30,ENEMY_WaitCounter(a2)

; START OF FUNCTION CHUNK FOR BlueKnightAnimMove


    ;jp         EnemyNextStatus
    addq.b      #1,ENEMY_Status(a2)
.exit
    rts

; ---------------------------------------------------------------------------

BlueKnightLogic2:                                 ; ...
    ;call       BlueKnightShared
    bsr         BlueKnightShared
    ;dec        (ix+ENEMY_WaitCounter)
    ;ret        nz
    subq.b      #1,ENEMY_WaitCounter(a2)
    bne         .exit

    ;xor        a
    ;ld         (ix+ENEMY_SpeedXDec), a      ; clear speed x
    ;ld         (ix+ENEMY_SpeedX), a
    ;ld         (ix+ENEMY_SpeedYDec), 80h    ; set speed y
    ;ld         (ix+ENEMY_SpeedY), 1
    clr.w       ENEMY_SpeedX(a2)
    move.w      #$180,ENEMY_SpeedY(a2)
.exit
    ;ret
    rts

; =============== S U B R O U T I N E =======================================


BlueKnightShared:                                 ; ...
    ;call       EnemyShotLogic               ; enemy shot logic
    bsr         EnemyShotLogic
; End of function BlueKnightShared                ;
                                                  ; will shoot at player based on screen position and ....
                                                  ;

; =============== S U B R O U T I N E =======================================


BlueKnightAnimMove:                               ; ...

; FUNCTION CHUNK AT 7AFE SIZE 00000009 BYTES
; FUNCTION CHUNK AT 7EFB SIZE 00000003 BYTES

    ;ld         b, 18h
    ;jp         EnemyAnimateMove
    ANIMATE2
    bra         MoveEnemy
