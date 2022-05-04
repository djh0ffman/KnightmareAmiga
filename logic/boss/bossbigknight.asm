;----------------------------------------------------------------------------
;
; boss 5 (big knight)
;
;----------------------------------------------------------------------------

    include     "common.asm"

BigKnightLogic:                                 
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
    cmp.b       #4,BossId(a5)
    bne         .exit

    moveq       #0,d1                             ; hidden flag
    btst        #7,GameFrame(a5)
    bne         .skip

    addq.b      #1,d1

.skip
    move.b      d1,BossIsSafe(a5)

    move.l      BossBobSlotPtr2(a5),a4
    move.b      d1,Bob_Hide(a4)

    move.b      GameFrame(a5),d0
    and.b       #$7f,d0
    bne         .exit
    
    moveq       #$17,d0
    bsr         SfxPlay

.exit
    rts