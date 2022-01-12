

;----------------------------------------------------------------------------
;
;  bat low
;
;----------------------------------------------------------------------------

    include      "common.asm"

BatLowLogic:
    moveq        #0,d0
    move.b       ENEMY_Status(a2),d0
    subq.b       #1,d0
    JMPINDEX     d0

BatLowLogicList:
    dc.w         BatLowInit-BatLowLogicList      
    dc.w         BatLowLogic1-BatLowLogicList        
    dc.w         BatLowLogic2-BatLowLogicList   
    dc.w         EnemyFireDeath-BatLowLogicList      
    dc.w         EnemyBonusCheck-BatLowLogicList
    dc.w         EnemyBonusWait-BatLowLogicList     


BatLowInit:
    ;call        EnemyClearParams
    bsr          EnemyClear

    ;ld          (ix+ENEMY_SpeedYDec), 0C0h
    ;ld          (ix+ENEMY_SpeedY), 0FFh
    ;ld          (ix+ENEMY_SpriteId), 9
    ;ld          (ix+ENEMY_OffsetY), 30h            ; '0'
    ;ld          (ix+ENEMY_OffsetX), 80h
    move.w       #-$40,ENEMY_SpeedY(a2)
    move.b       #$30,ENEMY_OffsetY(a2)
    move.b       #$80,ENEMY_OffsetX(a2)

    ;ld          a, (ix+ENEMY_PosX)
    ;cp          80h
    ;ld          b, 3                               ; speed x
    ;ld          c, 10h                             ; pos x
    ;jr          c, BatLowInitSet
    move.w       #$300,d1
    moveq        #$10,d2
    cmp.b        #$80,ENEMY_PosX(a2)
    bcs          .setvals
    ;ld          b, 0FDh                            ; speed x
    ;ld          c, 0F0h                            ; pos x
    neg.w        d1
    neg.b        d2
    
;BatLowInitSet:
.setvals
    ;ld          (ix+ENEMY_SpeedX), b
    ;ld          (ix+ENEMY_PosX), c
    move.w       d1,ENEMY_SpeedX(a2)
    move.b       d2,ENEMY_PosX(a2)

;EnemyNextStatus:
    ;ld          a, (ix+ENEMY_Status)
    ;and         a
    ;ret         z
    ;inc         (ix+ENEMY_Status)
    ;ret
    addq.b       #1,ENEMY_Status(a2)
    rts


BatLowLogic1:
    ;call        BatSharedLogic
    bsr          BatSharedLogic

    ;ld          a, (ix+ENEMY_PosX)
    ;sub         80h
    ;jr          nc, BatLowLogic1Edge
    ;neg
    move.b       ENEMY_PosX(a2),d0
    sub.b        #$80,d0
    bcc          .edge
    neg.b        d0

;BatLowLogic1Edge:                                 ; ...
.edge
    ;cp          5
    ;ret         nc                                 ; not at edge
    cmp.b        #5,d0
    bcc          .exit
    ;ld          (ix+ENEMY_SpeedYDec), 0
    ;ld          (ix+ENEMY_SpeedY), 0
    clr.w        ENEMY_SpeedY(a2)
    ;jr          EnemyNextStatus
    addq.b       #1,ENEMY_Status(a2)
.exit
    rts

BatLowLogic2:                                     ; ...
    ;call        CalcWaveSpeedYHalf
    ;ld          c, 1
    ;jp          BatWaveLogic1
    moveq        #1,d2
    CALCWAVEY
    moveq        #1,d2
    bra          BatWaveLogic1