;----------------------------------------------------------------------------
;
;  qblock code
;
;----------------------------------------------------------------------------

    include             "common.asm"

ClearQBlocks:
    lea                 ActiveQBlocks(a5),a0
    move.w              #(QBLOCK_Sizeof*QBLOCK_COUNT)-1,d7
.qclear
    clr.b               (a0)+
    dbra                d7,.qclear
    rts

;----------------------------------------------------------------------------
;
;  qblock init
;
; does qblock setup. if checkpoint is > 0 will add initial qblocks on screen
;
;----------------------------------------------------------------------------


QBlockInit:
    lea                 QBlockList,a0
    moveq               #0,d0
    move.b              Level(a5),d0
    add.w               d0,d0
    add.w               d0,d0
    move.l              (a0,d0.w),a1                                        ; QBlockData

    lea                 ActiveQBlocks(a5),a0                                ; Active QBlocks

    cmp.b               #9,CheckPoint(a5)                                   ; end of level, no qblocks
    beq                 .done

    moveq               #0,d0
    move.b              LevelPosition(a5),d0
    beq                 .done                                               ; start of level, just store the pointer
    move.w              d0,d1
    sub.w               #6*4,d1                                             ; start position

.loop
    move.b              QBLOCKDATA_LevelPos(a1),d2
    cmp.b               d1,d2
    bcs                 .next
    cmp.b               d0,d2
    bhi                 .done

    PUSHM               d0/d1
    bsr                 AddQBlock
    move.b              LevelPosition(a5),d0
    addq.b              #2,d0
    sub.b               QBLOCKDATA_LevelPos(a1),d0
    lsl.b               #3,d0 
    subq.b              #1,d0                                               ; off by one
    move.b              d0,QBLOCK_PosY(a0)
    lea                 QBLOCK_Sizeof(a0),a0
    POPM                d0/d1

.next
    addq.l              #QBLOCKDATA_Sizeof,a1                               ; move to next qblock data
    bra                 .loop
.done
    move.l              a1,QBlockPtr(a5)
    rts


;----------------------------------------------------------------------------
;
;  process qblocks
;
; processes the qblock collision / collection logic
; also adds new qblocks as they appear through the level
;
;----------------------------------------------------------------------------

ProcessQBlocks:
    clr.w               QBlockRenderCount(a5)

    cmp.b               #$d8,LevelPosition(a5)
    bcc                 .quit
    moveq               #QBLOCK_COUNT-1,d7
    lea                 ActiveQBlocks(a5),a0

.loop
    bsr                 QBlockLogic
    bsr                 QBlockRender

    lea                 QBLOCK_Sizeof(a0),a0
    dbra                d7,.loop
.quit
    rts


;----------------------------------------------------------------------------
;
; qblock logic
;
; a0 = active qblock params
;
;----------------------------------------------------------------------------


QBlockLogic:                                   
    move.b              QBLOCK_Type(a0),d0
    btst                #7,d0
    bne                 QBlockPlayerCollision

    tst.b               d0
    bne                 QBlockShotColLogic

    move.l              QBlockPtr(a5),a1
    move.b              LevelPosition(a5),d0
    
    addq.b              #2,d0                                               ; NOTE: moved qblocks early due to appearing 16 pixels early on Amiga
    cmp.b               QBLOCKDATA_LevelPos(a1),d0
    bne                 .quit
            
    bsr                 AddQBlock                                           ; add question block
    
    addq.l              #QBLOCKDATA_Sizeof,a1                               ; move to next qblock data
    move.l              a1,QBlockPtr(a5)
.quit
    rts



;----------------------------------------------------------------------------
;
; qblock touch check
;
; a0 = qblock structure
; d0 = qblock type
;
;----------------------------------------------------------------------------


QBlockPlayerCollision:
    tst.b               QBLOCK_SubType(a0)
    bne                 .notcollected

    moveq               #0,d1
    move.b              d0,d1
    and.b               #7,d1
    cmp.b               #4,d1
    bcc                 .collect

.notcollected 
    btst                #6,d0
    bne                 .exit

    bsr                 CheckQBlockPlayerCollision
    bcs                 .exit

    cmp.b               #2,QBLOCK_SubType(a0)
    beq                 .collect
    
    moveq               #$12,d0
    bsr                 SfxPlay

    bra                 .collect
.exit 
    rts


.collect    
    bset                #6,QBLOCK_Type(a0)                                  ; set qblock as collected
    move.b              QBLOCK_Type(a0),d0                                  ; get qblock type for jump
    and.w               #7,d0                                               ; remove additional bits

    move.b              QBLOCK_SubType(a0),d1
    beq                 .skipsub
    moveq               #7,d0
    add.b               d1,d0

.skipsub
    JMPINDEX            d0

QBlockIndex:
    dc.w                QExtraLife-QBlockIndex                              ; ExtraLifeLogic
    dc.w                QScoreLogic-QBlockIndex                             ; QScoreLogic
    dc.w                QKillAllLogic-QBlockIndex                           ; QKillAllLogic
    dc.w                QFreezeLogic-QBlockIndex                            ; QFreezeLogic
    dc.w                QBlockerLogic-QBlockIndex                           ; QStandardLogic is actually the blocker
    dc.w                QLevelSkipLogic-QBlockIndex                         ; QLevelSkipLogic
    dc.w                QBlockBridgeLogic-QBlockIndex                       ; QBlockBridgeLogic
    dc.w                QBlockSideWarp-QBlockIndex                          ; QBlockerLogic
    dc.w                QBlockGradius-QBlockIndex                           ; brand new gradius powerup
    dc.w                QBlockShop-QBlockIndex

;----------------------------------------------------------------------------
;
; qblock penguin shop :D
;
;----------------------------------------------------------------------------

QBlockShop:
    bclr                #6,QBLOCK_Type(a0) 
    tst.b               MapScrollTick(a5)
    bne                 .skip

    bset                #6,QBLOCK_Type(a0) 

    clr.b               PowerUpSfxActive(a5)   
    clr.b               SfxDisable(a5)

    move.b              #1,ShopEntered(a5)
    moveq               #11,d0
    bra                 SetGameStatus
.skip
    rts

;----------------------------------------------------------------------------
;
; qblock gradius powerup :D
;
;----------------------------------------------------------------------------

QBlockGradius:
    move.b              #1,ShopEntered(a5)
    move.b              #4,QBLOCK_BobId(a0)
    move.b              #2,QBLOCK_DrawCount(a0)
    move.b              #POWERUP_GRADIUS,PlayerStatus+PLAYER_PowerUp(a5)
    move.b              #59,PowerUpTimerLo(a5)
    move.b              #30,PowerUpTimerHi(a5)

    bsr                 MusicSave

    moveq               #0,d0
    moveq               #MOD_GRADIUS,d1
    PUSHMOST
    bsr                 MusicSet
    POPMOST

    bra                 PowerTimerDisplay

;----------------------------------------------------------------------------
;
; qblock extra life
;
;----------------------------------------------------------------------------

QExtraLife: 
    move.b              #4,QBLOCK_BobId(a0)
    move.b              #2,QBLOCK_DrawCount(a0)

ExtraLifeLogic:                                
    cmp.b               #99,Lives(a5)
    beq                 .exit

    addq.b              #1,Lives(a5)

    bsr                 PowerUpCollectSfx

.exit
    rts


;----------------------------------------------------------------------------
;
; qblock score logic
;
; score add!
;
;----------------------------------------------------------------------------

QScoreLogic:                                   
    move.b              #4,QBLOCK_BobId(a0)
    move.b              #2,QBLOCK_DrawCount(a0)
    move.l              #500,d0
    bra                 AddScore


;----------------------------------------------------------------------------
;
; qblock kill all logic
;
; kill all enemies
;
;----------------------------------------------------------------------------
QKillAllLogic:
    move.b              #4,QBLOCK_BobId(a0)
    move.b              #2,QBLOCK_DrawCount(a0)
    PUSH                a0
    bsr                 KillAllEnemy
    POP                 a0

    moveq               #$16,d0
    bra                 SfxPlay

KillAllEnemy:                                  
    lea                 EnemyList(a5),a2
    moveq               #ENEMY_COUNT-1,d6

                          
.loop    
    tst.b               ENEMY_Status(a2)
    beq                 .next
    tst.b               ENEMY_DeathFlag(a2)
    bne                 .next

    bsr                 KillEnemyBonus
                       
.next
    lea                 ENEMY_Sizeof(a2),a2
    dbra                d6,.loop

    bsr                 KillEnemyShots

    rts

;----------------------------------------------------------------------------
;
; qblock freeze time
;
;----------------------------------------------------------------------------

QFreezeLogic: 
    move.b              #4,QBLOCK_BobId(a0)
    move.b              #2,QBLOCK_DrawCount(a0)

    move.b              #1,FreezeFlag(a5)
    move.b              #1,FreezeStatus(a5)
    move.b              #10,FreezeTimerHi(a5)
    clr.b               FreezeTimerLo(a5)
    move.b              GameFrame(a5),FreezeTimeGameFrame(a5)

    bsr                 FreezeTimerDisplay

    bra                 KillEnemyShots
    

;----------------------------------------------------------------------------
;
; qblock level skip
;
;----------------------------------------------------------------------------

QLevelSkipLogic:
    bsr                 CheckQBlockPlayerCollision
    bcs                 .exit

    moveq               #6-1,d5
    move.b              QBLOCK_LevelPos(a0),d0
    lea                 LevelSkipData,a1
                       
.loop
    cmp.b               (a1)+,d0
    beq                 .found
    addq.l              #1,a1
    dbra                d5,.loop
.exit
    rts

.found
    clr.b               PowerUpSfxActive(a5)   
    clr.b               SfxDisable(a5)
    
NextLevel:                                     
    move.b              (a1),d0
    add.b               d0,Stage(a5)

    move.b              Level(a5),d1
    add.b               d0,d1
    and.b               #7,d1
    move.b              d1,Level(a5)

    move.b              #1,AdvanceStageFlag(a5)

    moveq               #0,d0
    moveq               #MOD_WARP,d1
    bsr                 MusicSet

    clr.b               QBLOCK_Type(a0)
    clr.b               QBLOCK_HitCount(a0)
    rts

;----------------------------------------------------------------------------
;
; qblock bridge
;
;----------------------------------------------------------------------------

QBlockBridgeLogic:
    tst.b               QBLOCK_Remove(a0)
    beq                 .doit
    rts
.doit
    move.b              #1,QBLOCK_Remove(a0)

    move.w              MapPosition(a5),d2 
    lsl.w               #5,d2                                               ; * 32 ( pixels )

    move.w              MapScrollOffset(a5),d3
    and.w               #TILE_HEIGHT-1,d3
    add.w               d3,d2                                               ; map current position ( pixel )

    sub.w               #32,d2                                              ; offset by 16 for qblock

    move.w              #%111111111000,d3                                   ; decimal mask

    moveq               #0,d0
    move.b              QBLOCK_PosY(a0),d0
    moveq               #0,d1
    move.b              QBLOCK_PosX(a0),d1
    sub.b               #8,d1

    add.w               d2,d0                                               ; add map Y ( pixel )
    and.w               d3,d0                                               ; remove decimal
    lsl.w               #2,d0                                               ; shift y to tile line

    lsr.w               #3,d1                                               ; x pos in 8x8 tile ( divide by 8 )

    move.w              d0,d2                                               ; map y
    move.w              d1,d3                                               ; map x

    add.w               d1,d0                                               ; x + y = byte position in collision map

    lea                 CollisionMap(a5),a2
    lea                 (a2,d0.w),a2
    clr.l               (a2)                                                ; TODO: warning, if this is odd everything will explode
    clr.l               32(a2)
    clr.l               32*2(a2)
    clr.l               32*3(a2)

    lsr.w               #4,d2                                               ; tiles y
    and.w               #$fff8,d2
    add.w               #8,d2
    lsr.w               #2,d3                                               ; tiles x
    add.w               d3,d2                                               ; map position

    moveq               #0,d0
    move.b              Level(a5),d0
    lea                 BridgeTiles,a2
    move.b              (a2,d0.w),d0                                        ; bridge tile

    lea                 MapBuffer(a5),a2
    move.b              d0,(a2,d2)                                          ; replace tile with bridge tile

    rts


;----------------------------------------------------------------------------
;
; qblock blocker
;
;----------------------------------------------------------------------------

QBlockerLogic:
    tst.b               QBLOCK_Remove(a0)
    beq                 .drawblocker
    rts

.drawblocker
    move.b              #7,QBLOCK_BobId(a0)
    move.b              #2,QBLOCK_DrawCount(a0)

    move.b              #1,QBLOCK_Remove(a0)

    move.w              MapPosition(a5),d2 
    lsl.w               #5,d2                                               ; * 32 ( pixels )

    move.w              MapScrollOffset(a5),d3
    and.w               #TILE_HEIGHT-1,d3
    add.w               d3,d2                                               ; map current position ( pixel )

    sub.w               #16,d2                                              ; offset by 16 for qblock

    move.w              #%111111111000,d3                                   ; decimal mask

    moveq               #0,d0
    move.b              QBLOCK_PosY(a0),d0
    moveq               #0,d1
    move.b              QBLOCK_PosX(a0),d1

    and.w               d3,d2                                               ; did this fix it?
    and.w               d3,d0
 
    add.w               d2,d0                                               ; add map Y ( pixel )
    add.w               #8,d0
    lsl.w               #2,d0                                               ; shift y to tile line

    lsr.w               #3,d1                                               ; x pos in 8x8 tile ( divide by 8 )

    add.w               d1,d0                                               ; x + y = byte position in collision map

    lea                 CollisionMap(a5),a2
    move.b              #1,(a2,d0.w)
    move.b              #1,1(a2,d0.w)
    move.b              #1,32(a2,d0.w)
    move.b              #1,33(a2,d0.w)

    rts

;----------------------------------------------------------------------------
;
; qblock side warp
;
; warps player from either side of the screen
;
;----------------------------------------------------------------------------

QBlockSideWarp:
    moveq               #0,d1
    move.b              QBLOCK_PosX(a0),d1
    swap                d1
    move.b              QBLOCK_PosY(a0),d1
    sub.b               #$8,d1                                              ; TODO: make this sensible!

    move.l              #$00080010,d2                                       ; TODO: check if this is sensible
    GETPLAYERDIM
    CHECKCOLLISION
    bcs                 .exit

    move.b              ControlsHold(a5),d0
    move.b              QBLOCK_MaxHits(a0),d1
    btst                #0,QBLOCK_MaxHits(a0)
    beq                 .left

    btst                #3,d0
    beq                 .exit
    bra                 .moveplayer

.left
    btst                #2,d0
    beq                 .exit

.moveplayer
    move.w              PlayerStatus+PLAYER_PosX(a5),d0
    neg.w               d0
    sub.w               #$1000,d0
    move.w              d0,PlayerStatus+PLAYER_PosX(a5)

.exit
    rts

     


;----------------------------------------------------------------------------
;
; qblock shot collision logic
;
; checks collision with player shots
;
; in
; a0 = qblock structure
;
; during
; a1 = player shot structure
;
;----------------------------------------------------------------------------


QBlockShotColLogic:
    lea                 PlayerShotDims,a2
    lea                 PlayerShot1(a5),a1
    moveq               #3-1,d6 
                    
.loop
    btst                #7,PLAYERSHOT_Status(a1)
    bne                 .skip

    GETPLAYERSHOTDIM    a1,a2

    moveq               #0,d1
    move.b              QBLOCK_PosX(a0),d1
    swap                d1
    move.b              QBLOCK_PosY(a0),d1
    sub.b               #16,d1
    move.l              #$00080008,d2

    CHECKCOLLISION
    bcs                 .skip

    bset                #7,PLAYERSHOT_Status(a1)                            ; kill shot

    moveq               #$f,d0
    bsr                 SfxPlay

    addq.b              #1,QBLOCK_HitCount(a0)
    move.b              QBLOCK_HitCount(a0),d0
    cmp.b               QBLOCK_MaxHits(a0),d0
    bcs                 .skip

    bset                #7,QBLOCK_Type(a0)                                  ; set qblock flag as fully shot

    move.b              QBLOCK_Type(a0),d0                                  ; reveal power-up?
    and.b               #7,d0
    
    cmp.b               #6,d0
    bne                 .notbridge
    
    tst.b               QBLOCK_SubType(a0)
    bne                 .notbridge

    moveq               #-1,d0                                              ; -1 means draw a bridge

.notbridge
    cmp.b               #2,QBLOCK_SubType(a0)
    bne                 .notshop
    moveq               #9,d0                                               ; shop icon
.notshop
    move.b              d0,QBLOCK_BobId(a0)
    move.b              #2,QBLOCK_DrawCount(a0)
   
    moveq               #$10,d0
    bsr                 SfxPlay
                       
.skip
    lea                 PLAYERSHOT_Sizeof(a1),a1
    dbra                d6,.loop

    rts






;----------------------------------------------------------------------------
;
; qblock player collision logic
;
; checks collision with player and qblock
;
; in
; a0 = qblock structure
;
; during
; a1 = player shot structure
;
;----------------------------------------------------------------------------

CheckQBlockPlayerCollision:
    cmp.b               #PLAYERMODE_DEAD,PlayerStatus(a5)
    bcc                 .nocollision

    moveq               #0,d1
    move.b              QBLOCK_PosX(a0),d1
    swap                d1
    move.b              QBLOCK_PosY(a0),d1
    sub.b               #16,d1
    move.l              #$00080008,d2

    GETPLAYERDIM
    CHECKCOLLISION
    rts

.nocollision
    move                #1,CCR
    rts 
;----------------------------------------------------------------------------
;
; add question block
;
; a0 = active qblock ram properties
; a1 = qblock rom data (in current position)
;
; source data (3 bytes)
; +0 = qblock type ( high nibble ? / low nibble = type )
; +1 = qblock level position
; +2 = qblock x position
;
;----------------------------------------------------------------------------


AddQBlock:                                     
    move.b              QBLOCKDATA_Type(a1),d2
    cmp.b               #$15,d2
    bne                 .notlevelwarp

    move.b              LevelId2(a5),d0
    cmp.b               Stage(a5),d0

.notlevelwarp
    move.b              d2,d0
    and.b               #$1f,d0
    cmp.b               #$17,d0
    bcs                 .notwrap                    
    move.b              #$97,d0                                             ; screen wrap block

.notwrap
    clr.b               QBLOCK_Remove(a0)
    move.b              d0,QBLOCK_Type(a0)
    move.b              #-1,QBLOCK_PosY(a0)  
    move.b              QBLOCKDATA_PosX(a1),QBLOCK_PosX(a0)                 ; qblock x screen position
    move.b              #2,QBLOCK_DrawCount(a0)

    moveq               #0,d0
    move.b              d2,d0
    and.b               #$f,d0
    lea                 QBlockHitCounts,a3
    move.b              (a3,d0.w),d0

    moveq               #0,d4                                               ; hitcount

    btst                #5,d2
    beq                 .visible

    addq.b              #1,d4                                               ; hit count
    addq.b              #1,d0                                               ; max hits
.visible
    move.b              d0,QBLOCK_MaxHits(a0)
    move.b              d4,QBLOCK_HitCount(a0)
    move.b              QBLOCKDATA_LevelPos(a1),QBLOCK_LevelPos(a0)         ; qblock level position
 
    move.b              QBLOCKDATA_SubType(a1),QBLOCK_SubType(a0)

    moveq               #0,d0
    move.b              QBLOCK_PosX(a0),d0
    move.b              #8,QBLOCK_BobId(a0)
    move.b              #2,QBLOCK_DrawCount(a0)

.skip
    rts


;----------------------------------------------------------------------------
;
; moves qblocks with scroll
;
; triggers image drawing when needed
;
;----------------------------------------------------------------------------

QBlockUpdate:
    lea                 ActiveQBlocks(a5),a0

    moveq               #QBLOCK_COUNT-1,d7

.loop
    btst                #4,QBLOCK_Type(a0)
    beq                 .next                                               ; not active?

    moveq               #0,d1
    move.b              QBLOCK_PosY(a0),d1                             
    addq.b              #1,d1                                               ; move block down by 1

.noredraw
    cmp.b               #$cf,d1                                             ; max qblock position
    bcc                 .remove

    move.b              d1,QBLOCK_PosY(a0)
    bra                 .next

.remove
    clr.b               QBLOCK_Type(a0)                                     ; remove the qblock from processing

.next
    lea                 QBLOCK_Sizeof(a0),a0                                ; next qblock
    dbra                d7,.loop
    rts


;----------------------------------------------------------------------------
;
; triggers drawing under set circumstances
;
; a0 = qblock structure
;
;----------------------------------------------------------------------------

QBlockRender:
    lea                 QBlockBobPtrs(a5),a4

    tst.b               QBLOCK_DrawCount(a0)                                ; no draw count
    beq                 .next

    btst                #4,QBLOCK_Type(a0)
    beq                 .next                                               ; not active?

    tst.b               QBLOCK_HitCount(a0)                                 ; block invisible
    beq                 .next

    cmp.b               #-1,QBLOCK_PosY(a0)
    beq                 .next

.draw
    addq.w              #1,QBlockRenderCount(a5)

    moveq               #0,d0
    move.b              QBLOCK_BobId(a0),d0

    bmi                 .bridge

    add.w               d0,d0
    add.w               d0,d0
    move.l              (a4,d0.w),a1                                        ; get the pointer to the bob data
    
    bsr                 BlitQBlock

    bra                 .done

    ; blit the bridge instead
.bridge
    move.b              Level(a5),d0
    lea                 BridgeTiles,a1
    move.b              (a1,d0.w),d0
    
    lea                 TilePointers(a5),a1
    add.w               d0,d0
    add.w               d0,d0
    move.l              (a1,d0.w),a1                                        ; get the pointer to the bob data

    bsr                 BlitBridge

.done
    cmp.b               #$10,QBLOCK_PosY(a0)
    bcs                 .next

    subq.b              #1,QBLOCK_DrawCount(a0)                             ; reduce draw count
    bne                 .next                                               ; still more to do

    tst.b               QBLOCK_Remove(a0)                                   ; drawing finished, do we have a remove request?
    beq                 .next                                               ; no, skip to next

    clr.b               QBLOCK_Type(a0)                                     ; remove qblock
    clr.b               QBLOCK_Remove(a0)                                   ; remove the remove flag

.next
    rts
