
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
    ;call        EnemyClearParams
    bsr         EnemyClear

    ;ld          (ix+ENEMY_SpriteId), 11h
    ;ld          (ix+ENEMY_BonesDeathCount), 4
    ;ld          (ix+ENEMY_BonesSpeed), 0
    move.b      #4,ENEMY_BonesDeathCount(a2)
    clr.b       ENEMY_BonesSpeed(a2)
    

    ;ld          a, (ix+ENEMY_PosX)
    ;cp          80h
    ;ld          a, 20h                            ; ' '
    ;ld          b, 0
    ;jr          c, BonesInit1
    ;ld          a, 0E0h
    ;inc         b
    moveq       #0,d1                                                          ; direction
    moveq       #$20,d2                                                        ; pos x
    cmp.b       #$80,ENEMY_PosX(a2)
    bcc         .setvals
    addq.b      #1,d1
    moveq       #$20,d2
;BonesInit1:          
.setvals
    ;ld          (ix+ENEMY_PosX), a
    ;ld          (ix+ENEMY_Direction), b
    ;jp          EnemyNextStatus___
    move.b      d1,ENEMY_Direction(a2)
    move.b      d2,ENEMY_PosX(a2)
    addq.b      #1,ENEMY_Status(a2)
    rts

; ---------------------------------------------------------------------------

BonesWalkInit:       
    ;ld          a, (ix+ENEMY_Direction)
    ;and         a
    ;ld          hl, BonesSpeedRight
    ;jr          z, BonesWalkInit1
    ;ld          hl, BonesSpeedLeft

;BonesWalkInit1:      
    ;ld          a, (ix+ENEMY_BonesSpeed)
    ;push        af
    ;call        ADD_AX2_HL_LDDE
    moveq       #0,d0
    move.b      ENEMY_BonesSpeed(a2),d0
    add.w       d0,d0
    move.w      BonesSpeedX(pc,d0.w),d1

    tst.b       ENEMY_Direction(a2)
    beq         .right
    neg.w       d1
.right
    ;ld          (ix+ENEMY_SpeedXDec), e
    ;ld          (ix+ENEMY_SpeedX), d
    move.w      d1,ENEMY_SpeedX(a2)
    ;pop         af
    ;ld          hl, BonesSpeedDown
    ;call        ADD_AX2_HL_LDDE
    move.w      BonesSpeedDown(pc,d0.w),ENEMY_SpeedY(a2)
    ;ld          (ix+ENEMY_SpeedYDec), e
    ;ld          (ix+ENEMY_SpeedY), d
    ;jr          EnemyNextStatus_____
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
    ;ld          b, 11h
    ;call        EnemyShootAnimate
    ANIMATE2
    bsr         MoveEnemy
    bsr         EnemyShotLogic

    ;ld          a, (ix+ENEMY_Direction)
    ;and         a
    ;ld          a, (ix+ENEMY_PosX)
    ;jr          nz, BonesCheckEdge2               ; left edge
    move.b      ENEMY_PosX(a2),d0
    tst.b       ENEMY_Direction(a2)
    bne         .checkleft

    ;cp          0E0h                              ; right edge
    ;ret         c
    ;jr          BonesChangeDir                    ; flip direction
    cmp.b       #$e0,d0
    bcs         .exit
    bra         .changedir

;BonesCheckEdge2:     
.checkleft
    ;cp          21h                               ; '!'                         ; left edge
    ;ret         nc
    cmp.b       #$21,d0
    bcc         .exit

;BonesChangeDir:      
.changedir
    ;ld          a, (ix+ENEMY_Direction)           ; flip direction
    ;xor         1
    ;ld          (ix+ENEMY_Direction), a
    ;jp          EnemyPrevStatus                   ; back to walking down logic
    eor.b       #1,ENEMY_Direction(a2)
    subq.b      #1,ENEMY_Status(a2)
.exit
    rts

; ---------------------------------------------------------------------------

BonesHit:            
    ;ld          de, 100h
    ;call        AddScore                          ; add score
                                                  ;
                                                  ; de = score 0000xxxx
                                                  ; bc = score xxxx0000
                                                  ;
    ;ld          (ix+ENEMY_SpriteId), 13h          ; setup split anim
    ;ld          (ix+ENEMY_Counter2), 2
    ;ld          a, 6

;EnemyWaitNextStatus: 
    ;ld          (ix+ENEMY_WaitCounter), a

    ;jp          EnemyNextStatus___
    ; prep 2nd part of bones bob split
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

    
    ;move.b      #1,ENEMY_DeathFlag(a2)
    move.b      #1,ENEMY_Safe(a2)
    move.b      #23,ENEMY_WaitCounter(a2)
    addq.b      #1,ENEMY_Status(a2)
    move.w      #100,d0
    bra         AddScore
; ---------------------------------------------------------------------------

BonesSplitAnim:      
    ;dec         (ix+ENEMY_WaitCounter)
    ;ret         nz
    ;inc         (ix+ENEMY_SpriteId)
    ;ld          (ix+ENEMY_WaitCounter), 6         ; frame wait between bones split
    ;dec         (ix+ENEMY_Counter2)
    ;ret         nz
    ;ld          a, 20h                            ; ' '                      ; wait value
    ;jr          EnemyWaitNextStatus

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
    ;dec         (ix+ENEMY_WaitCounter)
    ;ret         nz
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
    ;ld          (ix+ENEMY_SpriteId), 15h
    ;ld          (ix+ENEMY_Counter2), 2
    ;ld          a, 9
    moveq       #9,d0
    bsr         SfxPlay

    ;ld          a, 6
    ;jr          EnemyWaitNextStatus
    move.b      #23,ENEMY_WaitCounter(a2)
    addq.b      #1,ENEMY_Status(a2)
    
.exit
    rts
; ---------------------------------------------------------------------------

BonesJoin:           
    ;dec         (ix+ENEMY_WaitCounter)
    ;ret         nz
    ;dec         (ix+ENEMY_SpriteId)
    ;ld          (ix+ENEMY_WaitCounter), 6
    ;dec         (ix+ENEMY_Counter2)
    ;ret         nz
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
    ;clr.b       ENEMY_DeathFlag(a2)
    clr.b       ENEMY_Safe(a2)
    move.b      #-1,ENEMY_BobIdPrev(a2)                                        ; force bob update
    ;ld          a, (ix+ENEMY_BonesSpeed)
    ;inc         a                                 ; each time they are hit, the y speed increases
    ;cp          4                                 ; with a max of 4
    ;jr          c, BonesReset
    ;ld          a, 4

;BonesReset:          
    ;ld          (ix+ENEMY_BonesSpeed), a
    ;ld          (ix+ENEMY_Status), 2
    ;ret
    addq.b      #1,ENEMY_BonesSpeed(a2)
    move.b      #2,ENEMY_Status(a2)
.exit
    rts

