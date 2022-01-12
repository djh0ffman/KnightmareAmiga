

;----------------------------------------------------------------------------
;
;  ghost
;
;----------------------------------------------------------------------------

    include      "common.asm"

GhostLogic:
    moveq        #0,d0
    move.b       ENEMY_Status(a2),d0
    subq.b       #1,d0
    JMPINDEX     d0

GhostLogicList:
    dc.w         GhostInit-GhostLogicList
    dc.w         GhostLogic1-GhostLogicList
    dc.w         GhostLogic2-GhostLogicList
    dc.w         EnemyFireDeath-GhostLogicList      
    dc.w         EnemyBonusCheck-GhostLogicList
    dc.w         EnemyBonusWait-GhostLogicList     


GhostInit:
    ;call        EnemyClearParams
    bsr          EnemyClear

    ;ld          (ix+ENEMY_SpeedYDec), 30h         ; '0'
    ;ld          (ix+ENEMY_SpeedY), 1
    ;ld          (ix+ENEMY_SpriteId), 16h
    move.w       #$130,ENEMY_SpeedY(a2)

    ;ld          a, (ix+ENEMY_PosX)
    ;cp          80h                               ; check starting position and set to come in from the left or right
    ;ld          b, 18h                            ; pos and offset x
    ;ld          c, 3                              ; status
    ;ld          d, 6                              ; speed x
    ;jr          c, GhostInitSet
    moveq        #$18,d1
    moveq        #3,d2
    move.w       #$600,d3
    cmp.b        #$80,ENEMY_PosX(a2)
    bcc          .setval

    ;ld          b, 0E8h                           ; pos and offset x
    ;ld          c, 2                              ; status
    ;ld          d, 0FAh                           ; speed x
    neg          d1
    moveq        #2,d2
    neg          d3
    
;GhostInitSet:                                     ; ...
.setval
    ;ld          (ix+ENEMY_OffsetX), b
    ;ld          (ix+ENEMY_PosX), b
    ;ld          (ix+ENEMY_Status), c
    ;ld          (ix+ENEMY_SpeedX), d
    move.b       d1,ENEMY_OffsetX(a2)
    move.b       d1,ENEMY_PosX(a2)
    move.b       d2,ENEMY_Status(a2)
    move.w       d3,ENEMY_SpeedX(a2)
    ;ret
    rts

GhostLogic1:
    ;call        GhostWaveX
    bsr          GhostWaveX

    ;ld          a, (ix+ENEMY_PosX)
    ;cp          0E9h
    ;ret         c
    cmp.b        #$e9,ENEMY_PosX(a2)
    bcs          .exit
    ;ld          (ix+ENEMY_SpeedXDec), 0
    ;ld          (ix+ENEMY_SpeedX), 6
    ;ld          a, 18h
    ;ld          (ix+ENEMY_PosX), a
    ;ld          (ix+ENEMY_OffsetX), a
    ;jp          EnemyNextStatus
    move.w       #$600,ENEMY_SpeedX(a2)
    move.b       #$18,ENEMY_PosX(a2)
    move.b       #$18,ENEMY_OffsetX(a2)
    addq.b       #1,ENEMY_Status(a2)
.exit
    rts

GhostLogic2:
    ;call        GhostWaveX
    bsr          GhostWaveX
    
    ;ld          a, (ix+ENEMY_PosX)
    ;cp          17h
    ;ret         nc
    cmp.b        #$17,ENEMY_PosX(a2)
    bcc          .exit

    ;ld          (ix+ENEMY_SpeedXDec), 0
    ;ld          (ix+ENEMY_SpeedX), 0FAh
    ;ld          a, 0E8h
    ;ld          (ix+ENEMY_PosX), a
    ;ld          (ix+ENEMY_OffsetX), a
    move.w       #-$600,ENEMY_SpeedX(a2)
    move.b       #$e8,ENEMY_PosX(a2)
    move.b       #$e8,ENEMY_OffsetX(a2)

;EnemyPrevStatus:                                  ; ...
    ;ld          a, (ix+ENEMY_Status)
    ;and         a
    ;ret         z
    ;dec         (ix+ENEMY_Status)
    subq.b       #1,ENEMY_Status(a2)
.exit
    ;ret
    rts

GhostWaveX: 
    ;call        CalcWaveSpeedXFull
    moveq        #1,d2
    CALCWAVEX
    ;ld          a, (ix+ENEMY_SpeedX)
    ;rla
    ;ld          a, 16h                            ; ghost sprite id (left or right)
    ;jr          nc, GhostSetSprite
    ;inc         a                                 ; switch left / right
    moveq        #1,d1                             ; bob id
    move.b       ENEMY_SpeedX(a2),d0
    lsl.b        #1,d0
    bcs          .setsprite
    moveq        #0,d1

;GhostSetSprite:                                   ; ...
.setsprite
    ;ld          (ix+ENEMY_SpriteId), a
    move.b       d1,ENEMY_BobId(a2)
    bsr          MoveEnemy
    bra          EnemyShotLogic
