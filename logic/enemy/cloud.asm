;----------------------------------------------------------------------------
;
; cloud
;
;----------------------------------------------------------------------------

    include      "common.asm"

CloudLogic:
    moveq        #0,d0
    move.b       ENEMY_Status(a2),d0
    subq.b       #1,d0
    JMPINDEX     d0

CloudLogicList:
    dc.w         CloudInit-CloudLogicList          ; ...
    dc.w         CloudFloat-CloudLogicList
    dc.w         CloudAttack-CloudLogicList
    dc.w         CloudAnimMove-CloudLogicList      ; sprite id
    dc.w         EnemyFireDeath-CloudLogicList
    dc.w         EnemyBonusCheck-CloudLogicList
    dc.w         EnemyBonusWait-CloudLogicList


CloudInit:                                        ; ...
    ;call       EnemyClearParams
    bsr          EnemyClear

    ;ld         (ix+ENEMY_SpeedYDec), 80h
    ;ld         (ix+ENEMY_SpriteId), 1Ch
    ;ld         (ix+ENEMY_OffsetY), 10h
    ;ld         (ix+ENEMY_Counter2), 0
    move.w       #$80,ENEMY_SpeedY(a2)
    move.b       #$10,ENEMY_OffsetY(a2)
    clr.b        ENEMY_Counter2(a2)

    ;ld         a, (ix+ENEMY_PosX)
    ;cp         80h
    ;ld         a, 10h                       ; pos y
    ;ld         bc, 100h                     ; speed x
    ;jr         c, CloudInitSet
    ;ld         a, 0F0h                      ; pos Y
    ;ld         bc, 0FF00h                   ; speed x
    move.w       #$1000,d1                         ; pos y
    move.w       #$100,d2                          ; speed x
    cmp.b        #$80,ENEMY_PosX(a2)
    bcc          .initset

    move.w       #$f000,d1                         ; pos y
    move.w       #-$100,d2                         ; speed x



;CloudInitSet:                                     ; ...
.initset
    ;ld         (ix+ENEMY_PosX), a
    ;ld         (ix+ENEMY_SpeedXDec), c
    ;ld         (ix+ENEMY_SpeedX), b
    move.w       d1,ENEMY_PosX(a2)
    move.w       d2,ENEMY_SpeedX(a2)
    addq.b       #1,ENEMY_Status(a2)
;EnemyNextStatus_______:                           ; ...
    ;jp         EnemyNextStatus_
    rts

;----------------------------------------------------------------------------
;
; cloud float logic
;
;----------------------------------------------------------------------------

CloudFloat:          
    ;call       CalcWaveSpeedYFull
    moveq        #1,d2
    CALCWAVEY
    ;call       CloudAnimMove                ; sprite id
    bsr          CloudAnimMove
    ;ld         a, (ix+ENEMY_Counter2)
    ;add        a, 20h                       ; ' '
    ;ld         (ix+ENEMY_Counter2), a
    ;jr         nc, CloudFloat2
    ;inc        (ix+ENEMY_OffsetY)
    move.b       ENEMY_Counter2(a2),d0
    add.b        #$10,d0
    bcc          .skipoffset

    addq.b       #1,ENEMY_OffsetY(a2)
.skipoffset
    move.b       d0,ENEMY_Counter2(a2)

;CloudFloat2:                                      ; ...
    ;ld         a, (ix+ENEMY_PosY)
    ;cp         60h                          ; '`'
    ;ret        nc
    cmp.b        #$60,ENEMY_PosY(a2)
    bcc          .exit

    ;ld         a, (ix+ENEMY_PosX)
    ;cp         18h                          ; left boundary
    ;jr         nc, CloudFloatMoveLeft       ; right boundary
    ;ld         bc, 100h                     ; speed x
    ;jr         CloudSetSpeedX
    move.b       ENEMY_PosX(a2),d0
    move.w       #$100,d1                          ; speed x
    cmp.b        #$18,d0
    bcc          .left
    bra          .setspeed


;CloudFloatMoveLeft:                               ; ...
.left
    ;cp         0E8h                         ; right boundary
    ;ret        c
    ;ld         bc, 0FF00h                   ; speed x
    move.w       #-$100,d1                         ; speed x
    cmp.b        #$e8,d0
    bcs          .exit

;CloudSetSpeedX:                                   ; ...
.setspeed
    ;ld         (ix+ENEMY_SpeedXDec), c
    ;ld         (ix+ENEMY_SpeedX), b
    ;ret
    move.w       d1,ENEMY_SpeedX(a2)
.exit
    rts

; ---------------------------------------------------------------------------
;
; cloud hit, attack player
;
; ---------------------------------------------------------------------------

CloudAttack:   
    ;call       CalcAngleToPlayer
    bsr          CalcAngleToPlayer

;CalcSpeedFast:                                    ; ...
    ;call       CalcSpeed                    ; calculates the y and x speed of a shot based on the supplied angle
    bsr          CalcSpeed

    ;ld         h, b
    ;ld         l, c
    ;add        hl, hl
    ;add        hl, hl
    ;add        hl, hl
    ;ld         (ix+ENEMY_SpeedYDec), l
    ;ld         (ix+ENEMY_SpeedY), h
    asl.w        #3,d1
    move.w       d1,ENEMY_SpeedY(a2)

    ;ld         h, d
    ;ld         l, e
    ;add        hl, hl
    ;add        hl, hl
    ;add        hl, de
    ;ld         (ix+ENEMY_SpeedXDec), l
    ;ld         (ix+ENEMY_SpeedX), h
    asl.w        #3,d2
    move.w       d2,ENEMY_SpeedX(a2)

    ;jr         EnemyNextStatus_______
    addq.b       #1,ENEMY_Status(a2)

    rts
; ---------------------------------------------------------------------------
;
; cloud animate and move
;
; ---------------------------------------------------------------------------

CloudAnimMove:                                    ; ...
    ANIMATE2
    bra          MoveEnemy
    ;ld         b, 1Ch                       ; sprite id

EnemyAnimateMove:                                 ; ...
    ;call       AnimateEnemy                 ; animate enemy
                                                  ;
                                                  ; b = base sprite id
    ;jp         MoveEnemy                    ; move enemy
; End of function BlueKnightAnimMove              ;
                                                  ; will move an enemy by adding the speed to the pos values.
                                                  ;
                                                  ; MoveEnemy - assumes IX is the enemy pointer
                                                  ; MoveEnemy1 - called by the boss routines with the stack containing the pointer to the boss data