
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

BlueKnightInit:                                
    bsr         EnemyClear

    move.w      #$100,ENEMY_SpeedY(a2)
    move.b      #3,ENEMY_HitPoints(a2)
    addq.b      #1,ENEMY_Status(a2)
    rts

; ---------------------------------------------------------------------------

BlueKnightLogic1:                              
    bsr         BlueKnightShared

    cmp.b       #$c0,ENEMY_PosY(a2)
    bcc         .exit

    move.b      PlayerStatus+PLAYER_PosY(a5),d0
    sub.b       ENEMY_PosY(a2),d0
    cmp.b       #$40,d0
    bcc         .exit

    move.w      #$0120,d1
    cmp.b       #$80,ENEMY_PosX(a2)
    bcs         .setspeed

    move.w      #$fee0,d1
                          
.setspeed
    move.w      d1,ENEMY_SpeedX(a2)

    clr.w       ENEMY_SpeedY(a2)

    move.b      #$30,ENEMY_WaitCounter(a2)

    addq.b      #1,ENEMY_Status(a2)
.exit
    rts

; ---------------------------------------------------------------------------

BlueKnightLogic2:                              
    bsr         BlueKnightShared
    subq.b      #1,ENEMY_WaitCounter(a2)
    bne         .exit

    clr.w       ENEMY_SpeedX(a2)
    move.w      #$180,ENEMY_SpeedY(a2)
.exit
    rts


BlueKnightShared:                              
    bsr         EnemyShotLogic


BlueKnightAnimMove:                            
    ANIMATE2
    bra         MoveEnemy
