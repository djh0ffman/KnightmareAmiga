
                          RSRESET
ScreenStart:              rs.b       1                                   ; playfield start position on screen
ScreenEnd:                rs.b       1                                   ; playfield end position on screen
ScreenBuffer:             rs.l       2                                   ; two screen buffers		
ScreenBufferClean:        rs.l       1                                   ; background saving buffer
CopperBuffer:             rs.l       2                                   ; two copper buffers
RestoreLineOffset:        rs.l       1                                   ; offset inside the tile section

StrideLookUp:             rs.l       SCREEN_HEIGHT_GAME
ScreenDepthLookUp:        rs.w       SCREEN_DEPTH_LOOKUP                 ; 256 is this enough or too much?

TitleBuffers:             rs.l       5                                   ; three screen buffers for title
TitleCloudPtr:            rs.l       1
TitleCastlePtr:           rs.l       1
TitleCodeBufferPtr:       rs.l       1
TitleJumpTablePtr:        rs.l       1
TitleCastlePos:           rs.w       1
TitleSinePos:             rs.w       1
TitleRenderStatus:        rs.w       1
TitleCopperPtr:           rs.l       2
TitleYScalePtrs:          rs.l       4
TitleYStart:              rs.l       1
TitleYDelta:              rs.w       1
TitleHeight:              rs.w       1
TitleWidth:               rs.w       1 
TitleYOffset:             rs.w       1
TitleYOffsets:            rs.w       4
TitleScale:               rs.l       1
TitleStatus:              rs.w       1
TitleFrameCount:          rs.w       1
TitleSelectPos:           rs.w       1
TitleSpriteTextPtrs:      rs.l       3
TitleSpritePtrs:          rs.l       8
TitleScrollLookUp:        rs.b       TITLE_MAX_SCROLL                    ; max scroll?
TitleWaitCounter:         rs.w       1
TitleFramePrev:           rs.b       1
TitleFrameDisplayed:      rs.b       1

PalFlag:                  rs.w       1

DisableCopper:            rs.b       1
AnotherSpare:             rs.b       1
DoubleBuffer:             rs.w       1
LogoPos:                  rs.w       1

CreditsPtr:               rs.l       1
CreditsCounter:           rs.w       1
CreditsCharCount:         rs.w       1

InterruptCount:           rs.b       1
InterruptPrev:            rs.b       1
InterruptFlag:            rs.b       1
InterruptSpare:           rs.b       1

SpriteDirty:              rs.w       1
SpritePtrs:               rs.l       8 
SpritePtrsBackup:         rs.l       8 

RandomSeed:               rs.l       1                                   ; seed for random number generator

MainPalette:              rs.w       SCREEN_COLORS
WorkPalette:              rs.w       SCREEN_COLORS
MenuPalette:              rs.w       SCREEN_COLORS

LastTileBuffer:           rs.l       1

PaletteStatus:            rs.w       1
PaletteDirty:             rs.w       1                                   ; trigger to load the palette
PaletteColorCount:        rs.w       1
PalettePointer:           rs.l       1   


MapPointer:               rs.l       1
MapPosition:              rs.w       1
MapScrollOffset:          rs.w       1
MapScrollTick:            rs.b       1
MapBlitCount:             rs.b       1

MapBlitQueue:             rs.l       MAPBLIT_Sizeof*32
MapBlitQueuePtr:          rs.l       1

BobTopCrop:               rs.w       1
BobCurrentId:             rs.w       1

BobLivePtr:               rs.l       1                                   ; current live sprite pointer
BobLiveCount:             rs.w       1                                   ; count of sprites live sprites
BobNoShift:               rs.w       1
BobLivePtrs:              rs.l       BOB_COUNT
BobMatrix:                rs.b       Bob_Sizeof*BOB_COUNT
BobMatrixCopy:            rs.b       Bob_Sizeof*BOB_COUNT

BlitDupeCount:            rs.w       1                                   ; count of blits in the frame
BlitDupePtr:              rs.l       1                                   ; pointer to the current blit restore queue
BlitDupeQueue:            rs.b       Blit_Sizeof*BLIT_COUNT              ; data

BlitCount:                rs.w       2                                   ; count of blits in the frame
BlitQueuePtrs:            rs.l       2                                   ; pointer to the current blit restore queue
BlitQueueActivePtrs:      rs.l       2                                   ; pointer to the current blit restore queue
BlitQueueMapOffset:       rs.w       2
BlitQueue1:               rs.b       Blit_Sizeof*BLIT_COUNT              ; data
BlitQueue2:               rs.b       Blit_Sizeof*BLIT_COUNT              ; data
BlitHeightLookUp:         rs.w       BLIT_HEIGHT_MAX
BlitStridePtrs:           rs.l       BLIT_WIDTH_MAX
BlitStrideLookUp:         rs.w       BLIT_HEIGHT_MAX*BLIT_WIDTH_MAX

SOUND_MAX_COUNT    = 64                                                  ; TODO: this is a bullshit value

SoundIndex:               rs.l       SOUND_MAX_COUNT
SoundCount:               rs.w       1                                   ; count of the sounds loaded
SoundListLoaded:          rs.b       SOUND_MAX_COUNT                     ; list of room sounds which have been loaded
SoundBufferPtr:           rs.l       1                                   ; current buffer position for rending sounds
SoundPointers:            rs.l       SOUND_MAX_COUNT                     ; sound pointers based on sfx id (after unpacking)
ModStartPat:              rs.w       1                                   ; start pattern of the unpacked module data
ModPatternPtr:            rs.l       1                                   ; pointer to packed mod pattern data
PtSfx_Params:             rs.b       PtSfx_Sizeof                        ; pt replay sfx structure

ModSamplePtrs:            rs.l       MODSAMPLE_COUNT
ModLastUnpacked:          rs.w       1

ModPatPtr:                rs.l       1
PowerUpSfxActive:         rs.b       1
ModPreviousPat:           rs.b       1
ModPreviousTempo:         rs.w       1
ModPreviousSpeed:         rs.b       1
SfxDisable:               rs.b       1
ModFadeStatus:            rs.b       1
ModFadeVolume:            rs.b       1
ModFadeWait:              rs.b       1
ModFadeCounter:           rs.b       1

ScoreChar:                rs.b       1
ScorePosY:                rs.b       1
ScorePosX:                rs.b       1
ScorePos:                 rs.b       1
ScoreHold:                rs.b       1
ScoreTimer:               rs.b       1
ScorePtr:                 rs.l       1
ScoreBoard:               rs.b       SCORE_SIZE

                        ; -- graphics pointers
TilePointers:             rs.l       MAX_TILE_COUNT
QBlockBobPtrs:            rs.l       10
PlayerShotBobPtrs:        rs.l       20                                  ; TODO: sanatize!

ShadowBobPtrs:            rs.l       2

PlayerBobPtrs:            rs.l       4
PlayerSheildBobPtrs:      rs.l       4
PlayerTransBobPtrs:       rs.l       4
PlayerRedBobPtrs:         rs.l       4
PlayerGradiusBobPtrs:     rs.l       4
PlayerDeathBobPtrs:       rs.l       11

QBlockPtr:                rs.l       1                                   ; pointer to current QBlock data

PowerUpBobPtrs:           rs.l       5
PowerUpBobPtrs1:          rs.l       4
PowerUpBobPtrs2:          rs.l       4
WeaponPowerUpBobPtrs1:    rs.l       9
WeaponPowerUpBobPtrs2:    rs.l       9

MAX_ENEMY_BOBS     = 8
EnemyBobPtrs:             rs.l       MAX_ENEMY_BOBS*16                   ; array of bob pointers TODO: sort this
EnemyBobLookup:           rs.l       16

BossBobPtrs:              rs.l       4
BossBobShadowPtrs:        rs.l       2

FireDeathBobPtrs:         rs.l       8

HUDImagePtrs:             rs.l       2

MAX_ENEMYSHOT_BOBS = 16
EnemyShotBobPtrs:         rs.l       MAX_ENEMYSHOT_BOBS*16               ; array of bob pointers TODO: sort this
EnemyShotBobLookup:       rs.l       17
EnemyShotId:              rs.b       1
EnemyShotSpare:           rs.b       1
EnemyTypes:               rs.l       1
EnemyActive:              rs.l       1

EyeBobPtrs:               rs.l       4 
EyeList:                  rs.b       EYE_Sizeof*EYE_COUNT
EyeDeathCount:            rs.b       1

Shrink:                   rs.b       1

TickCounter:              rs.b       1
MapReadyFlag:             rs.b       1

OptionAutoFire:           rs.b       1
OptionVideo:              rs.b       1

SfxId:                    rs.b       1
MusicId:                  rs.b       1
SoundMenuId:              rs.b       1
SoundMenuSpare:           rs.b       1

;------------ game vars


HiScore:                  rs.l       1                                  
 
GameStatus:               rs.b       1                                   ; move of the game (in menu, demo, playing etc.)
GameSubStatus:            rs.b       1                                   ; used for substatus within the main status
ControlConfig:            rs.b       1                                   ; bit 6 - set to in game
WaitCounter:              rs.b       1 

Score:                    rs.l       1                                   ; clear point on game reboot

TextStat:                 rs.b       10

ShopPos:                  rs.b       1
PermaSpeed:               rs.b       1
PermaShield:              rs.b       1
PermaWeapon:              rs.b       1

ShopEntered:              rs.b       1
PauseFlag:                rs.b       1


TickInProgress:           rs.b       1 
LevelId2:                 rs.b       1 

ContinuePos:              rs.b       1
ContinueState:            rs.b       1

Controls2Trigger:         rs.b       1 
Controls2Hold:            rs.b       1 

ControlsTrigger:          rs.b       1 
ControlsHold:             rs.b       1 
FKeysTrigger:             rs.b       1
FKeysHold:                rs.b       1
Joystick:                 rs.b       1
Joystick2:                rs.b       1

KonamiLogoCount:          rs.b       1 
DemoPlayIndex:            rs.b       1 
DemoPlayWait:             rs.b       1 
AdvanceStageFlag:         rs.b       1 

LevelInitFlag:            rs.b       1
GameRunning:              rs.b       1

LivesPrev:                rs.b       1 
StagePrev:                rs.b       1 
SpeedPrev:                rs.b       1 
ShieldPrev:               rs.b       1 

Lives:                    rs.b       1 
Stage:                    rs.b       1 
Level:                    rs.b       1 
ExtraLifeScore:           rs.b       1 

GameFrame:                rs.b       1
LevelPosition:            rs.b       1
BossId:                   rs.b       1
CheckPoint:               rs.b       1
LevelCheckPoint:          rs.b       1

PowerUpTimerHi:           rs.b       1
PowerUpTimerLo:           rs.b       1
FreezeTimerHi:            rs.b       1
FreezeTimerLo:            rs.b       1
FreezeFlag:               rs.b       1
FreezeStatus:             rs.b       1

FreezeTimeGameFrame:      rs.b       1


EnemyList:                rs.b       ENEMY_Sizeof*ENEMY_COUNT
BossFakeEnemy:            rs.b       ENEMY_Sizeof

BossEnemy1:               rs.b       ENEMY_Sizeof
BossEnemy2:               rs.b       ENEMY_Sizeof
BossEnemy3:               rs.b       ENEMY_Sizeof

TempX:                    rs.b       1
TempY:                    rs.b       1

PlayerXTemp:              rs.b       1
PlayerYTemp:              rs.b       1

PlayerGateAngle:          rs.b       1
EndingTimer:              rs.b       1

PlayerStatus:             rs.b       PLAYER_Sizeof
PlayerStatusBackup:       rs.b       PLAYER_Sizeof
PrincessStatus:           rs.b       PLAYER_Sizeof

PlayerTiles:              rs.b       8

;-----------------------
PowerUpStatus:            rs.b       1                                   ; 0 = inactive / 1 = active
PowerUpType:              rs.b       1                                   ; 0 = weapon / 1 = powerup
PowerUpPosY:              rs.w       1
PowerUpPosX:              rs.w       1
PowerUpSpeedY:            rs.w       1
PowerUpSpeedX:            rs.w       1
PowerUpAngle1:            rs.b       1 
PowerUpAngle2:            rs.b       1 
PowerUpHitCountPrev:      rs.b       1 
PowerUpHitCount:          rs.b       1
PowerUpBobSlotPtr:        rs.l       1
;-----------------------

ShotSpeedPointer:         rs.l       1
EnemyShotList:            rs.b       ENEMYSHOT_Sizeof*ENEMYSHOT_COUNT
ShotAngle:                rs.b       1
TestAngle:                rs.b       1

EnemyShotsActive:         rs.b       1
AttackWaveTimer:          rs.b       1
AttackWaveActive:         rs.b       1
AttackWavePos:            rs.b       1
AttackWave1:              rs.b       ATTACKWAVE_Sizeof
AttackWave2:              rs.b       ATTACKWAVE_Sizeof

EnemyBonusSlot:           rs.b       1
EnemyBonusSpare:          rs.b       1
EnemyBounsCounts:         rs.b       BONUSCOUNT_MAX*BONUS_Sizeof

PlayerShot1:              rs.b       PLAYERSHOT_Sizeof
PlayerShot2:              rs.b       PLAYERSHOT_Sizeof
PlayerShot3:              rs.b       PLAYERSHOT_Sizeof
PlayerShot4:              rs.b       PLAYERSHOT_Sizeof

BossStatus:               rs.b       1
BossHitCount:             rs.b       1
BossPosY:                 rs.w       1
BossPosX:                 rs.w       1
BossSpeedY:               rs.w       1
BossSpeedX:               rs.w       1
BossOffsetY:              rs.b       1
BossOffsetX:              rs.b       1
BossWaveSpeedY:           rs.b       1
BossWaveSpeedX:           rs.b       1
BossWaveOffsetY:          rs.b       1
BossWaveOffsetX:          rs.b       1
BossPickAxeCount:         rs.b       1
BossBobId:                rs.b       1
BossHitMax:               rs.b       1
BossBarLoad:              rs.b       1
BossIsSafe:               rs.b       1
BossDeathTimer:           rs.b       1
BossDeadFlag:             rs.b       1
BossTimer:                rs.b       1
BossDestX:                rs.b       1
BossDestXOffset:          rs.b       1
BossDeathFlag:            rs.b       1
BossEnemySpawnPosX:       rs.b       1

BossAttackFlag:           rs.b       1
BossAttackTimer:          rs.b       1
BossAttackHeight:         rs.w       1

BossBobSlotPtr:           rs.l       1
BossBobSlotPtr2:          rs.l       1
BossBobShadowSlotPtr:     rs.l       1

QBlockRenderCount:        rs.w       1
ActiveQBlocks:            rs.b       QBLOCK_Sizeof*QBLOCK_COUNT

ScorePrev:                rs.l       1
HiScorePrev:              rs.l       1


CollisionMap:             rs.b       COLL_MAP_SIZE
MapBuffer:                rs.b       MAP_SIZE

Variables_SizeOf:         rs.w       0
