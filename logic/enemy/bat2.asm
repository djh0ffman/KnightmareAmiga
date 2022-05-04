
;----------------------------------------------------------------------------
;
;  bat 2
;
;----------------------------------------------------------------------------

    include     "common.asm"

Bat2Logic:
    moveq       #0,d0
    move.b      ENEMY_Status(a2),d0
    subq.b      #1,d0
    JMPINDEX    d0

Bat2LogicList:
    dc.w        Bat2Init-Bat2LogicList        
    dc.w        Bat2Run-Bat2LogicList
    dc.w        EnemyFireDeath-Bat2LogicList      
    dc.w        EnemyBonusCheck-Bat2LogicList
    dc.w        EnemyBonusWait-Bat2LogicList     

; ---------------------------------------------------------------------------
Bat2Dummy:
    rts

Bat2Init: 
    bsr         EnemyClear
    move.w      #$200,ENEMY_SpeedY(a2)

    move.b      PlayerStatus+PLAYER_PosX(a5),d2

    move.b      ENEMY_ShootStatus(a2),d0
    cmp.b       #-1,d0
    beq         .init2

    lea         PlayerXTemp(a5),a0
    and.b       #$f,d0
    bne         .init1
    move.b      d2,(a0)
.init1
    move        (a0),d2

.init2
    move.w      #$0380,d0                          ; speed X
    move.b      #$20,d3                            ; offset x
    move.w      #$1000,d4                          ; pos x

    cmp.b       #$80,d2
    bcc         .setspeed

    neg         d0                                 ; speed X
    neg         d3                                 ; offset x
    neg         d4                                 ; pos x
.setspeed
    move.w      d0,ENEMY_SpeedX(a2)
    move.b      d3,ENEMY_OffsetX(a2)
    move.w      d4,ENEMY_PosX(a2)

    addq.b      #1,ENEMY_Status(a2)
    rts
; ---------------------------------------------------------------------------

Bat2Run:
    moveq       #2,d2
    bra         BatWaveLogic1
