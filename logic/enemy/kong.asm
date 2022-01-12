

;----------------------------------------------------------------------------
;
;  kong
;
;----------------------------------------------------------------------------

    include     "common.asm"

KongLogic:
    moveq       #0,d0
    move.b      ENEMY_Status(a2),d0
    subq.b      #1,d0
    JMPINDEX    d0

KongLogicList:
    dc.w        KongInit-KongLogicList
    dc.w        KongBigWalk-KongLogicList
    dc.w        KongHitSplit-KongLogicList
    dc.w        KongMiniLogic-KongLogicList
    dc.w        KongMiniAnimMove-KongLogicList
    dc.w        EnemyFireDeath-KongLogicList      
    dc.w        EnemyBonusCheck-KongLogicList
    dc.w        EnemyBonusWait-KongLogicList    

    
KongInit:                                         ; ...
    ;call        EnemyClearParams
    ;ld          (ix+ENEMY_SpriteId), 22h          ; '"'    ; sprite id
    bsr         EnemyClear

KongAttack:
    ;call        CalcAngleToPlayer
    ;call        CalcSpeed                         ; calculates the y and x speed of a shot based on the supplied angle
    bsr         CalcAngleToPlayer
    bsr         CalcSpeed
    ;ld          (ix+ENEMY_SpeedYDec), c
    ;ld          (ix+ENEMY_SpeedY), b
    ;ld          (ix+ENEMY_SpeedXDec), e
    ;ld          (ix+ENEMY_SpeedX), d
    move.w      d1,ENEMY_SpeedY(a2)
    move.w      d2,ENEMY_SpeedX(a2)

    ;jp          EnemyNextStatus_
    addq.b      #1,ENEMY_Status(a2)
    rts

KongBigWalk:                                      ; ...
    ;ld          b, 22h                            ; '"'
    ;jp          EnemyShootAnimate
    ANIMATE2
    bsr         MoveEnemy
    bra         EnemyShotLogic


KongHitSplit:                                     ; ...
    ;call        EnemyClearParams
    bsr         EnemyClear

    ;ld          (ix+ENEMY_SpeedX), 0F9h           ; make this kong move left
    ;ld          (ix+ENEMY_WaitCounter), 4
    ;call        EnemyNextStatus__
    move.w      #-$700,ENEMY_SpeedX(a2)
    move.b      #8,ENEMY_WaitCounter(a2)
    addq.b      #1,ENEMY_Status(a2)

    ;push        ix
    ;push        ix
    ;call        FindEnemySlot
    ;pop         hl
    ;jr          nz, KongHitSplitNoExtra
    ;push        ix
    ;pop         de
    ;ld          bc, 20h                           ; ' '                     ; got new enemy slot, copy this enemy
    ;ldir
    ;ld          (ix+ENEMY_SpeedX), 7              ; make new kong move right


    move.l      a2,a1                             ;backup current enemy pointer
    PUSH        a2   
    bsr         FindEnemySlot
    bcs         .notfound

    move.l      a2,a3
    moveq       #(ENEMY_Sizeof/2)-1,d0
.copyloop
    move.w      (a1)+,(a3)+
    dbra        d0,.copyloop

    move.w      #$700,ENEMY_SpeedX(a2)

    bsr         PrepEnemyBobs

;KongHitSplitNoExtra:                              ; ...
.notfound
    POP         a2

    ;pop         ix
    ;ret
    rts


; ---------------------------------------------------------------------------

KongMiniLogic:                                    ; ...
    ;call        KongMiniAnimMove
    bsr         KongMiniAnimMove

    ;ld          a, (ix+ENEMY_PosX)
    ;ld          b, a
    ;cp          18h
    ;jr          nc, KongMiniRangeLeft
    ;ld          b, 18h
    move.b      ENEMY_PosX(a2),d0
    cmp.b       #$18,d0
    bcc         .left
    moveq       #$18,d0
;KongMiniRangeLeft:                                ; ...
.left
    ;cp          0E8h
    ;jr          c, KongMiniRangeRight
    ;ld          b, 0E7h
    cmp.b       #$e8,d0
    bcs         .right
    moveq       #-$19,d0
;KongMiniRangeRight:                               ; ...
.right
    ;ld          (ix+ENEMY_PosX), b
    move.b      d0,ENEMY_PosX(a2)

    ;dec         (ix+ENEMY_WaitCounter)
    ;ret         nz
    subq.b      #1,ENEMY_WaitCounter(a2)
    bne         .exit

    ;call        CalcAngleToPlayer
    ;call        CalcSpeed                         ; calculates the y and x speed of a shot based on the supplied angle
    ;ld          h, b
    ;ld          l, c
    ;add         hl, hl                            ; double the speed
    ;ld          (ix+ENEMY_SpeedYDec), l
    ;ld          (ix+ENEMY_SpeedY), h
    ;ld          h, d
    ;ld          l, e
    ;add         hl, hl                            ; double the speed
    ;ld          (ix+ENEMY_SpeedXDec), l
    ;ld          (ix+ENEMY_SpeedX), h
    ;jr          EnemyNextStatus__
    bsr         CalcAngleToPlayer
    bsr         CalcSpeed
    asl.w       #1,d1
    asl.w       #1,d2
    move.w      d1,ENEMY_SpeedY(a2)
    move.w      d2,ENEMY_SpeedX(a2)
    addq.b      #1,ENEMY_Status(a2)
.exit
    rts

KongMiniAnimMove:                                 ; ...
    ;ld          b, 24h                            ; '$'
    ;jp          EnemyShootAnimate
    ANIMATE2
    addq.b      #2,ENEMY_BobId(a2)
    bsr         MoveEnemy
    bra         EnemyShotLogic
