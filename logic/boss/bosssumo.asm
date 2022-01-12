;----------------------------------------------------------------------------
;
; boss 6 (sumo)
;
;----------------------------------------------------------------------------

    include           "common.asm"

SumoLogic:                                    ; ...
    ;ld         a, (BossStatus)
    ;dec        a
    ;ret        m
    ;cp         2
    ;jr         nz, TileBossSkipDraw
    ;push       af
    ;call       DrawTileBoss
    ;pop        af
;    call       JumpIndex_A
    moveq             #0,d0
    move.b            BossStatus(a5),d0
    bne               .run
    rts
.run
    subq.b            #1,d0
    JMPINDEX          d0

SumoIndex:
    dc.w              BossLoad-SumoIndex           
    dc.w              BossWitchSetup-SumoIndex     
    dc.w              Boss1MoveAttack-SumoIndex    
    dc.w              BossDeathFlash-SumoIndex     
    dc.w              BossDeathFlash-SumoIndex     
    dc.w              BossFireDeath1-SumoIndex     
    dc.w              BossFireDeath2-SumoIndex     
    dc.w              Boss1Dummy-SumoIndex         


SUMOATTACK_Y      = $50
SUMOATTACK_HEIGHT = 128
SUMOATTACK_YSTART = SUMOATTACK_Y-SUMOATTACK_HEIGHT

SumoAttack:
    ;ld          a, (BossId)
    ;cp          5
    ;ret         nz
    ;ld          hl, BossAttackParams
    ;bit         7, (hl)                      ; is attack active?
    ;jr          nz, SumoBossMove
    cmp.b             #5,BossId(a5)
    bne               .exit

    btst              #7,BossAttackFlag(a5)
    bne               .checkattack

;SumoBossAttack1:                                  ; ...
    move.l            BossBobSlotPtr2(a5),a4
    cmp.w             #SUMOATTACK_HEIGHT,BossAttackHeight(a5)
    bge               .donemoving
    move.b            TickCounter(a5),d0
    and.b             #1,d0
    bne               .dontmove
    addq.w            #8,BossAttackHeight(a5)
.dontmove
    move.w            #SUMOATTACK_YSTART,d0
    add.w             BossAttackHeight(a5),d0
    move.w            d0,Bob_Y(a4)
    bra               .checkcol

.donemoving
    subq.b            #1,BossAttackTimer(a5)
    bne               .checkcol

    st                Bob_Hide(a4)
    move.b            #$80,BossAttackFlag(a5)
    rts

.checkcol
    GETPLAYERDIM
    move.w            Bob_X(a4),d1
    swap              d1
    move.w            #SUMOATTACK_Y,d1
    moveq             #16,d2
    swap              d2
    move.w            BossAttackHeight(a5),d2
    CHECKCOLLISION
    bcc               KillPlayer
    rts

    ;inc         hl
    ;inc         (hl)
    ;ld          a, (hl)
    ;inc         hl
    ;and         3
    ;jr          nz, SumoBossAttack2
    ;inc         (hl)

;SumoBossAttack2:                                  ; ...
    ;ld          a, (hl)
    ;inc         hl
    ;ld          de, TilesSumoAttack
    ;ld          b, a
    ;cp          11h
    ;jr          nc, loc_8D4C
    ;sub         10h
    ;neg
    ;add         a, a
    ;call        ADD_A_DE
    ;ld          c, 2
    ;ld          h, (hl)
    ;ld          l, 50h                       ; 'P'
    ;call        DrawTiles
    ;jr          CheckTouchTileBoss
    rts

; ---------------------------------------------------------------------------

;SumoBossMove:                                     ; ...
.checkattack
    ;ld          a, (PlayerX)
    ;ld          b, a
    ;ld          a, (BossPosX)
    ;add         a, 1Ah
    ;sub         b
    ;cp          5
    ;jr          c, loc_8D39
    move.b            BossPosX(a5),d0
    add.b             #$1a,d0
    sub.b             PlayerStatus+PLAYER_PosX(a5),d0
    cmp.b             #5,d0
    bcs               .initattack
    ;ld          a, (TickCounter)
    ;and         7Fh
    ;ret         nz
    move.b            TickCounter(a5),d1
    and.b             #$7f,d1
    bne               .exit

;loc_8D39:                                         ; ...
.initattack
    ;xor         a
    ;ld          (hl), a
    clr.b             BossAttackFlag(a5)
    move.b            #$10,BossAttackTimer(a5)
    ;inc         a
    ;ld          (BossAttackY), a
    clr.w             BossAttackHeight(a5)
    ;ld          a, (BossPosX)
    ;add         a, 18h
    ;ld          (BossAttackX), a
    moveq             #0,d0
    move.b            BossPosX(a5),d0
    add.b             #$18,d0
;    move.b      d0,BossAttackX(a5)

    move.l            BossBobSlotPtr2(a5),a4

    move.w            d0,Bob_X(a4)
    move.w            #SUMOATTACK_YSTART,Bob_Y(a4)               ; sumo attack heigh 112 
    move.w            #SUMOATTACK_Y,Bob_TopMargin(a4)
    sf                Bob_Hide(a4)

    move.l            BossBobPtrs+8(a5),a0
    ;lea               BobBossSumoAttack_0,a0
    BOBSET            a0,a4

    ;ld          a, 5Ah                       ; 'Z'
    ;jp       
    moveq             #$1a,d0
    bsr               SfxPlay
.exit
    rts
; ---------------------------------------------------------------------------

loc_8D4C:                                         ; ...
    ;cp          15h
    ;jr          c, CheckTouchTileBoss
    ;ld          hl, BossAttackParams
    ;set         7, (hl)
    ;ld          hl, 3940h
    ;call        SetVramAddresWR
    ;exx
    ;ld          hl, unk_E9E0
    ;ld          b, 0
    ;call        j_VramOutLoop
    ;ld          b, 80h
    ;jr          j_VramOutLoop