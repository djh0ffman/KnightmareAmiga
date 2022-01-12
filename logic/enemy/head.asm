

;----------------------------------------------------------------------------
;
;  head
;
;----------------------------------------------------------------------------

    include      "common.asm"

HeadLogic:
    moveq        #0,d0
    move.b       ENEMY_Status(a2),d0
    subq.b       #1,d0
    JMPINDEX     d0

HeadLogicList:
    dc.w         HeadInit-HeadLogicList
    dc.w         HeadLogic1-HeadLogicList
    dc.w         HeadLogic2-HeadLogicList
    dc.w         HeadLogic3-HeadLogicList
    dc.w         HeadLogic4-HeadLogicList
    dc.w         HeadShootAnimate-HeadLogicList
    dc.w         EnemyFireDeath-HeadLogicList      
    dc.w         EnemyBonusCheck-HeadLogicList
    dc.w         EnemyBonusWait-HeadLogicList     

    
HeadInit:
    ;call        EnemyClearParams
    bsr          EnemyClear

    ;ld          (ix+ENEMY_SpeedY), 3
    ;ld          (ix+ENEMY_SpriteId), 0Dh
    move.w       #$300,ENEMY_SpeedY(a2)

    ;ld          a, (ix+ENEMY_PosX)
    ;cp          80h
    ;ld          a, 20h                            ; ' '
    ;jr          c, HeadInitSetX
    ;ld          a, 0E0h
    moveq        #$20,d0
    cmp.b        #$80,ENEMY_PosX(a2)
    bcc          .setval
    neg          d0

;HeadInitSetX:        
.setval
    ;ld          (ix+ENEMY_PosX), a
    ;jr          EnemyNextStatus____
    move.b       d0,ENEMY_PosX(a2)
    addq.b       #1,ENEMY_Status(a2)
    rts

HeadLogic1:          
    ;call        HeadShootAnimate
    bsr          HeadShootAnimate

    ;ld          a, (ix+ENEMY_PosY)
    ;cp          0E0h
    ;ret         nc
    ;cp          50h                               ; 'P'
    ;ret         c
    move.b       ENEMY_PosY(a2),d0
    cmp.b        #$e0,d0
    bcc          .exit
    cmp.b        #$50,d0
    bcs          .exit

    ;ld          (ix+ENEMY_OffsetY), 50h           ; 'P'
    move.b       #$50,ENEMY_OffsetY(a2)

    ;ld          a, (ix+ENEMY_PosX)
    ;cp          80h
    ;ld          a, 90h
    ;jr          nc, HeadLogic1SetOffsetX
    ;ld          a, 70h                            ; 'p'
    moveq        #-$70,d0
    cmp.b        #$80,ENEMY_PosX(a2)
    bcc          .setval
    neg          d0

;HeadLogic1SetOffsetX:
.setval
    ;ld          (ix+ENEMY_OffsetX), a
    move.b       d0,ENEMY_OffsetX(a2)

;EnemyNextStatus____: 
    ;jp          EnemyNextStatus___
    addq.b       #1,ENEMY_Status(a2)
.exit
    rts


HeadLogic2:          
    ;call        HeadWaveShootAnimate
    bsr          HeadWaveShootAnimate

    ;ld          a, (ix+ENEMY_PosY)
    ;cp          4Fh                               ; 'O'
    ;ret         nc
    cmp.b        #$4f,ENEMY_PosY(a2)
    bcc          .exit

    ;ld          (ix+ENEMY_OffsetX), 80h
    move.b       #$80,ENEMY_OffsetX(a2)
;HeadLogicKillSpeedXNext:                          ; ...

    ;xor         a
    ;ld          (ix+ENEMY_SpeedXDec), a
    ;ld          (ix+ENEMY_SpeedX), a
    ;jr          EnemyNextStatus____
    clr.w        ENEMY_SpeedX(a2)
    addq.b       #1,ENEMY_Status(a2)
.exit
    rts

HeadLogic3:          
    ;call        HeadWaveShootAnimate
    bsr          HeadWaveShootAnimate

    ;ld          a, (ix+ENEMY_PosY)
    ;cp          50h                               ; 'P'
    ;ret         c
    cmp.b        #$50,ENEMY_PosY(a2)
    bcs          .exit

    ;ld          a, (ix+ENEMY_PosX)
    ;cp          80h
    ;ld          a, 70h                            ; 'p'
    ;jr          nc, HeadLogic3SetOffsetX
    moveq        #$70,d0
    cmp.b        #$80,ENEMY_PosX(a2)
    bcc          .setval

    neg          d0
    ;ld          a, 90h
.setval
;HeadLogic3SetOffsetX:
    ;ld          (ix+ENEMY_OffsetX), a
    ;jr          HeadLogicKillSpeedXNext
    move.b       d0,ENEMY_OffsetX(a2)
    clr.w        ENEMY_SpeedX(a2)
    addq.b       #1,ENEMY_Status(a2)
.exit
    rts


HeadLogic4:          
    ;call        HeadWaveShootAnimate
    bsr          HeadWaveShootAnimate

    ;ld          a, (ix+ENEMY_PosY)
    ;cp          4Fh                               ; 'O'
    ;ret         nc
    ;jr          HeadLogicKillSpeedXNext
    cmp.b        #$4f,ENEMY_PosY(a2)
    bcc          .exit
    clr.w        ENEMY_SpeedX(a2)
    addq.b       #1,ENEMY_Status(a2)
.exit
    rts
; ---------------------------------------------------------------------------

HeadWaveShootAnimate:
    ;call        CalcWaveSpeedXHalf
    ;call        CalcWaveSpeedYHalf
    moveq        #2,d2
    CALCWAVEX
    moveq        #2,d2
    CALCWAVEY
    

HeadShootAnimate:    
    ;ld          b, 0Dh

;EnemyShootAnimate:   
    ;call        AnimateEnemy                      ; animate enemy
    ;jp          EnemyShotLogic_
    ANIMATE2
    bsr          MoveEnemy
    bra          EnemyShotLogic