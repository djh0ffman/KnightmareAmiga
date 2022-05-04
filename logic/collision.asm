;----------------------------------------------------------------------------
;
; collision logic
;
;----------------------------------------------------------------------------

    include             "common.asm"

;----------------------------------------------------------------------------
;
; unpacks the collision bit map into bytes for quicker access
;
;----------------------------------------------------------------------------

UnpackCollisionMap:
    moveq               #0,d0
    move.b              Level(a5),d0
    add.w               d0,d0
    add.w               d0,d0

    lea                 LevelCollisionList,a0
    move.l              (a0,d0.w),a0
    lea                 CollisionMap(a5),a1
    move.w              #(COLL_MAP_SIZE/8)-1,d7
    moveq               #1,d2                                               ; and byte

.loopbyte
    moveq               #8-1,d6
    move.b              (a0)+,d0
.loopbit
    rol.b               #1,d0
    move.b              d0,d1
    and.b               d2,d1
    move.b              d1,(a1)+
    dbra                d6,.loopbit
    dbra                d7,.loopbyte
    rts

;----------------------------------------------------------------------------
;
; gets the tiles from around the player
; and checks collision with map
;
; in
; a0 = player structure
;
;----------------------------------------------------------------------------

GetPlayerTiles:
    PUSHM               d0-d5/d7/a2/a3/a4
    moveq               #8-1,d7
    lea                 CollisionMap(a5),a2
    lea                 PlayerTileOffsetList(pc),a3
    lea                 PlayerTiles(a5),a4

    move.w              MapPosition(a5),d2 
    lsl.w               #5,d2                                               ; * 32 ( pixels )

    move.w              MapScrollOffset(a5),d3
    and.w               #TILE_HEIGHT-1,d3
    add.w               d3,d2                                               ; map current position ( pixel )

    move.w              #%111111111000,d3                                   ; decimal mask

    moveq               #0,d4
    move.b              PLAYER_PosY(a0),d4
    moveq               #0,d5
    move.b              PLAYER_PosX(a0),d5

.loop
    move.w              d4,d0                                               ; player y
    move.w              d5,d1                                               ; player x

    add.w               (a3)+,d0                                            ; add y offset
    add.w               (a3)+,d1                                            ; add x offset

    add.w               d2,d0                                               ; add map Y ( pixel )
    and.w               d3,d0                                               ; remove decimal
    lsl.w               #2,d0                                               ; shift y to tile line

    lsr.w               #3,d1                                               ; x pos in 8x8 tile ( divide by 8 )

    add.w               d1,d0                                               ; x + y = byte position in collision map

    move.b              (a2,d0.w),(a4)+                                     ; store collision tile flag

    dbra                d7,.loop

    cmp.b               #POWERUP_GRADIUS,PlayerStatus+PLAYER_PowerUp(a5)
    beq                 .none

    lea                 PlayerTiles(a5),a4

    ; player tile collision checks

    move.b              ControlsHold(a5),d0
    lsr.b               #1,d0
    bcc                 .down
    ; up
    move.b              0(a4),d1
    or.b                1(a4),d1
    beq                 .down

    move.w              PLAYER_PosYTemp(a0),PLAYER_PosY(a0)

.down
    lsr.b               #1,d0
    bcc                 .left
    ; down
    move.b              4(a4),d1
    or.b                5(a4),d1
    beq                 .left

    move.w              PLAYER_PosYTemp(a0),PLAYER_PosY(a0)

.left
    lsr.b               #1,d0
    bcc                 .right
    ; left
    tst.b               2(a4)
    bne                 .leftstop
    tst.b               0(a4)
    beq                 .right
    tst.b               4(a4)
    beq                 .right
.leftstop
    move.w              PLAYER_PosXTemp(a0),PLAYER_PosX(a0)

.right
    lsr.b               #1,d0
    bcc                 .none
    ;right
    tst.b               3(a4)
    bne                 .rightstop
    tst.b               1(a4)
    beq                 .none
    tst.b               5(a4)
    beq                 .none
.rightstop
    move.w              PLAYER_PosXTemp(a0),PLAYER_PosX(a0)

.none

    POPM                d0-d5/d7/a2/a3/a4
    rts

PlayerTileOffsetList:
    dc.w                $01, $04                                     
    dc.w                $01, $0B
    dc.w                $08, $02
    dc.w                $08, $0D
    dc.w                $0E, $04
    dc.w                $0E, $0B
    dc.w                -$7, $04
    dc.w                -$7, $0B



;----------------------------------------------------------------------------
;
; scroll move player
; checks player tiles and moves player down by one pixel
;
;----------------------------------------------------------------------------

ScrollMovePlayer:
    cmp.b               #POWERUP_GRADIUS,PlayerStatus+PLAYER_PowerUp(a5)
    beq                 .nomove
    lea                 PlayerTiles(a5),a4

    move.b              0(a4),d1
    or.b                1(a4),d1
    beq                 .nomove
    add.b               #1,PlayerStatus+PLAYER_PosY(a5)
.nomove
    rts

;----------------------------------------------------------------------------
;
; enemy player shot logic
;
; check to see if enemies make contact with player shots
;
; a2 = enemy structure
;
;----------------------------------------------------------------------------


EnemyPlayerShotLogic:                      
    tst.b               ENEMY_Safe(a2)
    bne                 .exit

    tst.b               ENEMY_DeathFlag(a2)
    bne                 .exit

    bsr                 PlayerShotCollisionCheck
.exit
    rts

PlayerShotCollisionCheck:                  
    moveq               #0,d0
    lea                 PlayerShot1(a5),a1
    move.b              (a1),d0
    lsl.b               #1,d0
    bcs                 .skip1
    bsr                 CheckShotCollisionWithEnemy
    bcc                 PlayerShotHit

.skip1
    lea                 PLAYERSHOT_Sizeof(a1),a1
    move.b              (a1),d0
    lsl.b               #1,d0
    bcs                 .skip2
    bsr                 CheckShotCollisionWithEnemy
    bcc                 PlayerShotHit

.skip2
    lea                 PLAYERSHOT_Sizeof(a1),a1
    move.b              (a1),d0
    lsl.b               #1,d0
    bcs                 .skip3
    bsr                 CheckShotCollisionWithEnemy
    bcc                 PlayerShotHit 
.skip3
    rts

;----------------------------------------------------------------------------
;
; player shot vs enemy - collision detection
;
; in 
; a1 = player shot
; a2 = enemy
;----------------------------------------------------------------------------


CheckShotCollisionWithEnemy:               
    GETPLAYERSHOTDIM    a1,a0
    GETENEMYDIM

    CHECKCOLLISION
    rts
;----------------------------------------------------------------------------
;
; player shot HIT enemy - adds score and stuff
;
; in 
; a1 = player shot
; a2 = enemy
;----------------------------------------------------------------------------


PlayerShotHit:
    moveq               #0,d1
    move.b              PLAYERSHOT_WeaponId(a1),d1
    move.w              d1,d2                                               ; weapon main
    lsr.b               #1,d2                                               ; weapon group
    cmp.b               #3,d2
    bcc                 .checkkong

    bset                #7,PLAYERSHOT_Status(a1)                            ; remove shot

.checkkong
    move.b              ENEMY_Id(a2),d0
    and.w               #$f,d0
    cmp.b               #$f,d0                                              ; is kong?
    bne                 .checkbones                                         ; no

    cmp.b               #3,ENEMY_Status(a2)
    bcc                 .checkbones

    tst.b               FreezeStatus(a5)
    bne                 .checkbones

    move.b              #3,ENEMY_Status(a2)                                 ; split kong

    moveq               #$1b,d0
    bra                 SfxPlay

.checkbones
    cmp.b               #7,d0                                               ; is bones?
    bne                 .checkcloud                                         ; no

    cmp.b               #POWERUP_GRADIUS,PlayerStatus+PLAYER_PowerUp(a5)
    beq                 .other

    subq.b              #1,ENEMY_BonesDeathCount(a2)
    beq                 .other

    tst.b               FreezeStatus(a5)
    bne                 .other

    move.b              #4,ENEMY_Status(a2)
    moveq               #$a,d0
    bra                 SfxPlay

.checkcloud
    cmp.b               #$c,d0                                              ; is clouds?
    bne                 .other                                              ; no
    
    cmp.b               #POWERUP_GRADIUS,PlayerStatus+PLAYER_PowerUp(a5)
    beq                 .other

    tst.b               FreezeStatus(a5)
    bne                 .other

    cmp.b               #3,ENEMY_Status(a2)
    bcc                 .exit                                               ; TODO: hmmm  not sure why i have to add this in?
    move.b              #3,ENEMY_Status(a2)

    moveq               #$25,d0
    bra                 SfxPlay


.other
    cmp.b               #3,d2
    bcc                 KillEnemyBonus
    subq.b              #1,ENEMY_HitPoints(a2)
    beq                 KillEnemyScore

    moveq               #$f,d0                                              ; enemy hit sfx
    bra                 SfxPlay

.exit
    rts




KillEnemyScore:
    lea                 EnemyScores,a0
    tst.b               FreezeStatus(a5)
    beq                 KillEnemyAddScore
KillEnemyBonus:
    lea                 EnemyScoresFreeze,a0
KillEnemyAddScore:
    move.b              ENEMY_Id(a2),d0
    and.w               #$f,d0
    add.w               d0,d0
    move.w              (a0,d0.w),d0
    bsr                 AddScore

KillEnemy:
    move.b              ENEMY_Id(a2),d0
    and.w               #$f,d0
    lea                 EnemyDeathStatusList,a0
    move.b              (a0,d0.w),ENEMY_Status(a2)
    clr.b               ENEMY_FireCount(a2)
    move.b              #6,ENEMY_WaitCounter(a2)
    move.b              #1,ENEMY_DeathFlag(a2)

    move.w              ENEMY_BobSlot2(a2),d0
    bmi                 .noslot2

    lea                 BobMatrix(a5),a4
    clr.b               Bob_Allocated(a4,d0.w)
    move.w              #-1,ENEMY_BobSlot2(a2)

.noslot2    
    move.b              #$d,d0                                              ; fire
    bra                 SfxPlay

