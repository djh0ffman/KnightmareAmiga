
;----------------------------------------------------------------------------
;
;  bones
;
;----------------------------------------------------------------------------

    include     "common.asm"

BonesLogic:
    moveq       #0,d0
    move.b      ENEMY_Status(a2),d0
    subq.b      #1,d0
    JMPINDEX    d0

BonesLogicList:
    dc.w        BonesInit-BonesLogicList
    dc.w        BonesWalkInit-BonesLogicList
    dc.w        BonesWalk-BonesLogicList
    dc.w        BonesHit-BonesLogicList
    dc.w        BonesSplitAnim-BonesLogicList
    dc.w        BonesJoinInit-BonesLogicList
    dc.w        BonesJoin-BonesLogicList
    dc.w        EnemyFireDeath-BonesLogicList        
    dc.w        EnemyBonusCheck-BonesLogicList
    dc.w        EnemyBonusWait-BonesLogicList    


BonesInit:           
    bsr         EnemyClear

    move.b      #4,ENEMY_BonesDeathCount(a2)
    clr.b       ENEMY_BonesSpeed(a2)
    
    moveq       #0,d1                                                          ; direction
    moveq       #$20,d2                                                        ; pos x
    cmp.b       #$80,ENEMY_PosX(a2)
    bcc         .setvals
    addq.b      #1,d1
    moveq       #$20,d2
      
.setvals
    move.b      d1,ENEMY_Direction(a2)
    move.b      d2,ENEMY_PosX(a2)
    addq.b      #1,ENEMY_Status(a2)
    rts

; ---------------------------------------------------------------------------

BonesWalkInit:       
    moveq       #0,d0
    move.b      ENEMY_BonesSpeed(a2),d0
    add.w       d0,d0
    move.w      BonesSpeedX(pc,d0.w),d1

    tst.b       ENEMY_Direction(a2)
    beq         .right
    neg.w       d1
.right
    move.w      d1,ENEMY_SpeedX(a2)
    move.w      BonesSpeedDown(pc,d0.w),ENEMY_SpeedY(a2)
    addq.b      #1,ENEMY_Status(a2)
    rts

BonesSpeedX:
    dc.w        $180 
    dc.w        $200
    dc.w        $280
    dc.w        $300
BonesSpeedDown:
    dc.w        $60  
    dc.w        $90
    dc.w        $0C0
    dc.w        $100

BonesWalk:           
    ANIMATE2
    bsr         MoveEnemy
    bsr         EnemyShotLogic

    move.b      ENEMY_PosX(a2),d0
    tst.b       ENEMY_Direction(a2)
    bne         .checkleft

    cmp.b       #$e0,d0
    bcs         .exit
    bra         .changedir

.checkleft
    cmp.b       #$21,d0
    bcc         .exit
    
.changedir
    eor.b       #1,ENEMY_Direction(a2)
    subq.b      #1,ENEMY_Status(a2)
.exit
    rts

; ---------------------------------------------------------------------------

BonesHit:            
    PUSH        a4
    move.l      ENEMY_BobPtr(a2),a0
    move.l      4*2(a0),a0                                                     ; 3rd bob in the bones collection

    move.w      ENEMY_BobSlot(a2),d4
    lea         (a4,d4.w),a4
    BOBSET      a0,a4                                                          ; setup torso

    bsr         BobAllocate
    move.w      d0,ENEMY_BobSlot2(a2)                                          ; borrowing the shadow slot ;)
    moveq       #0,d0
    move.b      ENEMY_PosX(a2),d0
    move.w      d0,Bob_X(a4)

    move.l      ENEMY_BobPtr(a2),a0
    move.l      4*3(a0),a0                                                     ; 4th bob in the bones collection
    BOBSET      a0,a4                                                          ; setup head
    POP         a4

    move.b      #1,ENEMY_Safe(a2)
    move.b      #23,ENEMY_WaitCounter(a2)
    addq.b      #1,ENEMY_Status(a2)
    move.w      #100,d0
    bra         AddScore
; ---------------------------------------------------------------------------

BonesSplitAnim:      
    moveq       #0,d0
    move.b      ENEMY_WaitCounter(a2),d0
    move.b      BonesSine(pc,d0),d0                                            ; y offset
    add.b       ENEMY_PosY(a2),d0  

    move.w      ENEMY_BobSlot(a2),d4                                           ; torso bob
    move.w      d0,Bob_Y(a4,d4.w)
    subq.w      #1,Bob_X(a4,d4.w)

    move.w      ENEMY_BobSlot2(a2),d4                                          ; head bob
    move.w      d0,Bob_Y(a4,d4.w)
    addq.w      #1,Bob_X(a4,d4.w)
    sf          Bob_Hide(a4,d4.w)

    subq.b      #1,ENEMY_WaitCounter(a2)
    bpl         .exit
    addq.b      #1,ENEMY_Status(a2)
    move.b      #$40,ENEMY_WaitCounter(a2)
.exit
    rts
; ---------------------------------------------------------------------------
BonesSine:
    dc.b        0,-4,-8,-12,-16,-20,-23,-26,-28,-30,-31,-31,-31,-31,-30,-28
    dc.b        -26,-23,-20,-17,-13,-9,-4,0
    even

BonesJoinInit:       
    tst.b       MapScrollTick(a5)
    beq         .nomove

    addq.b      #1,ENEMY_PosY(a2)                                              ; keep moving bobs down screen with scroll
    move.w      ENEMY_BobSlot(a2),d4
    addq.w      #1,Bob_Y(a4,d4.w)
    move.w      ENEMY_BobSlot2(a2),d4
    addq.w      #1,Bob_Y(a4,d4.w)

.nomove
    subq.b      #1,ENEMY_WaitCounter(a2)
    bne         .exit

    moveq       #9,d0
    bsr         SfxPlay

    move.b      #23,ENEMY_WaitCounter(a2)
    addq.b      #1,ENEMY_Status(a2)
    
.exit
    rts
; ---------------------------------------------------------------------------

BonesJoin:           
    moveq       #0,d0
    move.b      ENEMY_WaitCounter(a2),d0
    move.b      BonesSine(pc,d0),d0                                            ; y offset
    add.b       ENEMY_PosY(a2),d0  

    move.w      ENEMY_BobSlot(a2),d4                                           ; torso bob
    move.w      d0,Bob_Y(a4,d4.w)
    addq.w      #1,Bob_X(a4,d4.w)

    move.w      ENEMY_BobSlot2(a2),d4                                          ; head bob
    move.w      d0,Bob_Y(a4,d4.w)
    subq.w      #1,Bob_X(a4,d4.w)

    subq.b      #1,ENEMY_WaitCounter(a2)
    bne         .exit

    clr.b       Bob_Allocated(a4,d4.w)

    clr.b       ENEMY_Safe(a2)
    move.b      #-1,ENEMY_BobIdPrev(a2)                                        ; force bob update

    addq.b      #1,ENEMY_BonesSpeed(a2)
    move.b      #2,ENEMY_Status(a2)
.exit
    rts

