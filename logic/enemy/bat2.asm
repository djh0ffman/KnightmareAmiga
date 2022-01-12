
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
    ;call        EnemyClearParams
    bsr         EnemyClear
    ;ld          (ix+ENEMY_SpeedY), 2
    ;ld          (ix+ENEMY_SpriteId), 9
    move.w      #$200,ENEMY_SpeedY(a2)

    ;ld          a, (PlayerX)
    ;ld          c, a
    move.b      PlayerStatus+PLAYER_PosX(a5),d2

    ;ld          a, (ix+ENEMY_ShootStatus)
    ;cp          0FFh
    ;jr          z, Bat2Init2
    move.b      ENEMY_ShootStatus(a2),d0
    cmp.b       #-1,d0
    beq         .init2
    ;and         0Fh
    ;ld          hl, PlayerXTemp
    ;jr          nz, Bat2Init1
    ;ld          (hl), c
    lea         PlayerXTemp(a5),a0
    and.b       #$f,d0
    bne         .init1
    move.b      d2,(a0)
;Bat2Init1:                                        ; ...
.init1
    ;ld          c, (hl)
    move        (a0),d2

;Bat2Init2:                                        ; ...
.init2
    ;ld          a, c
    ;cp          80h
    ;ld          bc, 380h                     ; speed x
    ;ld          de, 2010h                    ; offset x / pos x
    move.w      #$0380,d0                          ; speed X
    move.b      #$20,d3                            ; offset x
    move.w      #$1000,d4                          ; pos x

    cmp.b       #$80,d2
    bcc         .setspeed
    ;jr          nc, Bat2SetSpeed
    ;ld          bc, 0FC80h                   ; speed X
    ;ld          de, 0E0F0h                   ; offset x / pos x

    neg         d0                                 ; speed X
    neg         d3                                 ; offset x
    neg         d4                                 ; pos x
;Bat2SetSpeed:                                     ; ...
.setspeed
    move.w      d0,ENEMY_SpeedX(a2)
    move.b      d3,ENEMY_OffsetX(a2)
    move.w      d4,ENEMY_PosX(a2)
    ;ld          (ix+ENEMY_SpeedXDec), c
    ;ld          (ix+ENEMY_SpeedX), b
    ;ld          (ix+ENEMY_OffsetX), d
    ;ld          (ix+ENEMY_PosX), e
    ;jr          EnemyNextStatus
    addq.b      #1,ENEMY_Status(a2)
    rts
; ---------------------------------------------------------------------------

Bat2Run:
    ;ld          c, 1
    ;jp          BatWaveLogic1
    moveq       #2,d2
    bra         BatWaveLogic1
