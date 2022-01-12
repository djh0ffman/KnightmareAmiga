;----------------------------------------------------------------------------
;
; boss 5 (big knight)
;
;----------------------------------------------------------------------------

    include     "common.asm"

BigKnightLogic:                                    ; ...
    ;ld         a, (BossStatus)
    ;dec        a
    ;ret        m
    ;cp         2
    ;jr         nz, TileBossSkipDraw
    ;push       af
    ;call       DrawTileBoss
    ;pop        af
;    call       JumpIndex_A
    moveq       #0,d0
    move.b      BossStatus(a5),d0
    bne         .run
    rts
.run
    subq.b      #1,d0
    JMPINDEX    d0

BigKinghtIndex:
    dc.w        BossLoad-BigKinghtIndex           
    dc.w        BossWitchSetup-BigKinghtIndex     
    dc.w        Boss1MoveAttack-BigKinghtIndex    
    dc.w        BossDeathFlash-BigKinghtIndex     
    dc.w        BossDeathFlash-BigKinghtIndex     
    dc.w        BossFireDeath1-BigKinghtIndex     
    dc.w        BossFireDeath2-BigKinghtIndex     
    dc.w        Boss1Dummy-BigKinghtIndex         


RedKnightHelmet:
    ;ld          a, (BossId)
    ;cp          4
    ;ret         nz
    cmp.b       #4,BossId(a5)
    bne         .exit

    ;ld          hl, TileBossAnimId2
    ;ld          a, (GameFrame)
    ;and         7Fh
    ;jr          nz, RedKnightAttackMove1
    ;inc         (hl)
    moveq       #0,d1                             ; hidden flag
    btst        #7,GameFrame(a5)
    bne         .skip

    addq.b      #1,d1

;RedKnightAttackMove1:                             ; ...
.skip
    move.b      d1,BossIsSafe(a5)

    move.l      BossBobSlotPtr2(a5),a4
    move.b      d1,Bob_Hide(a4)

    ;bit         0, (hl)
    ;ret         z
    ;or          a
    ;jr          nz, RedKnightAttackMove2
    ;ld          a, 47h                            ; 'G'
    ;call       

    move.b      GameFrame(a5),d0
    and.b       #$7f,d0
    bne         .exit
    
    moveq       #$17,d0
    bsr         SfxPlay


;RedKnightAttackMove2:                             ; ...
    ;ld          de, TilesRedKnightBoss3
    ;ld          bc, 303h                          ; tile height and width
    ;ld          a, (BossPosY)
    ;add         a, 8
    ;ld          l, a
    ;ld          a, (BossPosX)
    ;add         a, 8
    ;ld          h, a
    ;jp          DrawTiles
.exit
    rts