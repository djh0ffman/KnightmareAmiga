
;----------------------------------------------------------------------------
;
;  bat 1
;
;----------------------------------------------------------------------------

    include      "common.asm"

Bat1Logic:
    moveq        #0,d0
    move.b       ENEMY_Status(a2),d0
    subq.b       #1,d0
    JMPINDEX     d0

Bat1LogicList:
    dc.w         BatWaveInit-Bat1LogicList         ; BatWaveInit-BlobLogicList        
    dc.w         BatWaveLogic-Bat1LogicList        ; BatWaveLogic-BlobLogicList          
    dc.w         EnemyFireDeath-Bat1LogicList      
    dc.w         EnemyBonusCheck-Bat1LogicList
    dc.w         EnemyBonusWait-Bat1LogicList     

BatWaveInit: 
    ;call        EnemyClearParams
    bsr          EnemyClear
    ;ld          (ix+ENEMY_SpeedYDec), 30h         ; '0'
    ;ld          (ix+ENEMY_SpeedY), 1
    ;ld          (ix+ENEMY_SpriteId), 9
    ;ld          (ix+ENEMY_OffsetX), 80h
    ;ld          b, 6
    ;ld          hl, BatWaveStartX
    ;ld          a, (ix+ENEMY_PosX)
    move.w       #$130,ENEMY_SpeedY(a2)
    move.b       #$80,ENEMY_OffsetX(a2)

    moveq        #6,d1
    lea          BatWaveStartX(pc),a0
    move.b       ENEMY_PosX(a2),d0
;BatWaveFindStartX:                                ; ...
.loop
    ;cp          (hl)
    ;jr          z, BatWaveSetSpeedX
    ;inc         hl
    ;djnz        BatWaveFindStartX
    ;ret
    cmp.b        (a0)+,d0
    beq          .setx
    subq.b       #1,d1
    bne          .loop
    rts

;BatWaveSetSpeedX:
.setx
    ;ld          a, 6
    ;sub         b
    moveq        #6,d0
    sub.b        d1,d0
    ;ld          hl, BatWaveSpeedX
    ;call        ADD_A_HL
    lea          BatWaveSpeedX(pc),a0
    ;ld          a, (hl)
    move.b       (a0,d0.w),d0
    ;ld          (ix+ENEMY_SpeedX), a
    ;jp          EnemyNextStatus
    move.b       d0,ENEMY_SpeedX(a2)
    addq.b       #1,ENEMY_Status(a2)
    rts

BatWaveStartX:
    dc.b         $28, $50, $7F, $80, $0B0, $0D8
BatWaveSpeedX:
    dc.b         0, 5, $0FA, 6, $0FB, $0FF 



BatWaveLogic:                                     ; ...
    ;ld          c, 0
    moveq        #0,d2

BatWaveLogic1:                                    ; ...
    ;call        CalcWaveSpeedX                    ; enemy wave move logic
                                                  ;
                                                  ; c = value shift count (shifts the resulting value c times)
    CALCWAVEX

; =============== S U B R O U T I N E =======================================


BatSharedLogic:
    ANIMATE2
    ;call        BatSfxAnimate
    addq.b       #1,ENEMY_FrameCount(a2)
    move.b       ENEMY_FrameCount(a2),d1
    and.b        #$f,d1
    bne          .skipsfx
    moveq        #1,d0
    tst.b        ENEMY_SpeedX(a2)
    bmi          .dosfx
    moveq        #2,d0
.dosfx
    bsr          SfxPlay
.skipsfx
;EnemyShotLogic_:                                  ; ...
    ;call        EnemyShotLogic                    ; enemy shot logic
    bsr          EnemyShotLogic
                                                  ; will shoot at player based on screen position and ....
                                                  ;
    bra          MoveEnemy