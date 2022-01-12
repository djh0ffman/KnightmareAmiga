
                               RSRESET 
Title_Buffer1                  rs.b       TITLE_BUFFER_SIZE
Title_Buffer2                  rs.b       TITLE_BUFFER_SIZE
Title_Buffer3                  rs.b       TITLE_BUFFER_SIZE
Title_Buffer4                  rs.b       TITLE_BUFFER_SIZE
Title_Buffer5                  rs.b       TITLE_BUFFER_SIZE
Title_Castle                   rs.b       CASTLE_SIZE
Title_Clouds                   rs.b       CLOUDS_SIZE
Title_CodeBuffer               rs.b       TITLE_CODE_BUFFER_SIZE
Title_JumpTable                rs.l       TITLE_WIDTH
Title_YScale1                  rs.w       TITLE_FIELD_HEIGHT+3
Title_YScale2                  rs.w       TITLE_FIELD_HEIGHT+3
Title_YScale3                  rs.w       TITLE_FIELD_HEIGHT+3
Title_YScale4                  rs.w       TITLE_FIELD_HEIGHT+3
Title_Copper1                  rs.b       COPPER_MENU_HEADER+COPPER_MENU_BUFFERSIZE
Title_Copper2                  rs.b       COPPER_MENU_HEADER+COPPER_MENU_BUFFERSIZE
Title_Sprites                  rs.b       TITLE_SPRITE_BLOCK*8
Title_BufferSize               rs.b       0

                               RSRESET
Sound_Type                     rs.w       1
Sound_ModStart                 rs.w       0                                            ; temporary, needs a separate structure for modules maybe?
Sound_Period                   rs.w       1
Sound_Volume                   rs.w       1
Sound_Priority                 rs.b       1
Sound_Channel                  rs.b       1
Sound_Rand                     rs.b       1
Sound_Looped                   rs.b       1
Sound_PackedSize               rs.w       1                                            ; packed size in bytes
Sound_Size                     rs.w       1                                            ; size in words
Sound_Data                     rs.w       0


                               RSRESET                                                 ; PT Replay Sfx Structure
PtSfx_Ptr                      rs.l       1                                            ;     void *sfx_ptr (pointer to sample start in Chip RAM, even address)
PtSfx_Len                      rs.w       1                                            ;     WORD sfx_len  (sample length in words)
PtSfx_Per                      rs.w       1                                            ;     WORD sfx_per  (hardware replay period for sample)
PtSfx_Vol                      rs.w       1                                            ;     WORD sfx_vol  (volume 0..64, is unaffected by the song's master volume)
PtSfx_Cha                      rs.b       1                                            ;     BYTE sfx_cha  (0..3 selected replay channel, -1 selects best channel)
PtSfx_Pri                      rs.b       1                                            ;     BYTE sfx_pri  (unsigned priority, must be non-zero)
PtSfx_Sizeof                   rs.b       0


                               RSRESET
MAPBLIT_A                      rs.l       1
MAPBLIT_D                      rs.l       1
MAPBLIT_ModA                   rs.w       1
MAPBLIT_ModD                   rs.w       1
MAPBLIT_Size                   rs.w       1
MAPBLIT_Sizeof                 rs.b       0

                               RSRESET 
PLAYER_Status:                 rs.b       1                                            ; ...
PLAYER_Spare:                  rs.b       1
PLAYER_PosY:                   rs.w       1                                            ; ...
PLAYER_PosX:                   rs.w       1                                            ; ...
PLAYER_SpeedY:                 rs.w       1
PLAYER_SpeedX:                 rs.w       1
PLAYER_AnimFrame2:             rs.b       1                                            ; ...
PLAYER_AnimFrame:              rs.b       1                                            ; ...
PLAYER_Anim:                   rs.w       1                                            ; ...
;PLAYER_Anim:                   rs.b       1    ; ...
PLAYER_WeaponId:               rs.b       1 
PLAYER_Speed:                  rs.b       1
PLAYER_Timer:                  rs.b       1                                            ; ...
PLAYER_PowerUp:                rs.b       1                                            ; ...
PLAYER_PowerUpTimeDec:         rs.b       1                                            ; ...
PLAYER_PowerUpTime:            rs.b       1                                            ; ...
PLAYER_SheildPower:            rs.b       1 
PLAYER_Spare2:                 rs.b       1
PLAYER_PosYTemp:               rs.w       1 
;PLAYER_field_11:               rs.b       1 
PLAYER_PosXTemp:               rs.w       1 
;PLAYER_field_13:               rs.b       1 
PLAYER_field_14:               rs.b       1 
PLAYER_field_15:               rs.b       1 
PLAYER_field_16:               rs.b       1 
PLAYER_field_17:               rs.b       1 
PLAYER_PowerUpPrev:            rs.b       1 
PLAYER_SheildPowerBak:         rs.b       1 
PLAYER_SpeedBak:               rs.b       1 
PLAYER_WeaponIdBak:            rs.b       1 
PLAYER_BobSlot:                rs.w       1 
;PLAYER_field_1D:               rs.b       1 
;PLAYER_field_1E:               rs.b       1 
PLAYER_Sizeof:                 rs.b       0
;PLAYER_field_1F:          rs.b       1 

ENEMY_COUNT      = 7

                               RSRESET
ENEMY_Status:                  rs.b       1                                            ; ...
ENEMY_Id:                      rs.b       1                                            ; ...
;ENEMY_PosYDec:            rs.b       1
ENEMY_PosY:                    rs.w       1                                            ; ...
;ENEMY_PosXDec:            rs.b       1
ENEMY_PosX:                    rs.w       1                                            ; ...
;ENEMY_SpeedYDec:          rs.b       1    ; ...
ENEMY_SpeedY:                  rs.w       1                                            ; ...
;ENEMY_SpeedXDec:          rs.b       1    ; ...
ENEMY_SpeedX:                  rs.w       1                                            ; ...

ENEMY_SpriteId:                rs.b       1                                            ; ...
ENEMY_HitPoints:               rs.b       1                                            ; ...
ENEMY_OffsetY:                 rs.b       1                                            ; ...
ENEMY_OffsetX:                 rs.b       1                                            ; ...
ENEMY_WaitCounter:             rs.b       1                                            ; ...
ENEMY_ShotCounter:             rs.b       1                                            ; ...
ENEMY_Direction:               rs.b       1                                            ; ...
ENEMY_ShootStatus:             rs.b       1                                            ; ...
ENEMY_Counter2:                rs.b       1                                            ; ...
ENEMY_field_13:                rs.b       1
ENEMY_BonesDeathCount:         rs.b       1                                            ; ...
ENEMY_BonesSpeed:              rs.b       1                                            ; ...
ENEMY_SpriteSlotId:            rs.b       1                                            ; ...
ENEMY_Safe:                    rs.b       1
ENEMY_FrameCount:              rs.b       1                                            ; ...
ENEMY_DeathFlag:               rs.b       1
ENEMY_AnimTick:                rs.b       1
ENEMY_FireCount:               rs.b       1
ENEMY_BobIdPrev:               rs.b       1
ENEMY_BobId:                   rs.b       1

ENEMY_BobSlot:                 rs.w       1                                            ; -- my stuff ish
ENEMY_ShadowSlot:              rs.w       1                                            ; -- slot for shadow if enemy has one
ENEMY_BobSlot2:                rs.w       1                                            ; -- slot for 2nd bob (bones)
ENEMY_BobPtr:                  rs.l       1
ENEMY_AnimPtr:                 rs.l       1
ENEMY_Random:                  rs.b       1
ENEMY_Spare:                   rs.b       1
;ENEMY_field_1E:                rs.b       1
;ENEMY_field_1f:                rs.b       1

ENEMY_Sizeof:                  rs.b       0


QBLOCK_COUNT     = 16

                               RSRESET
QBLOCK_Type:                   rs.b       1                                            ; ...
QBLOCK_HitCount:               rs.b       1                                            ; ...
QBLOCK_PosY:                   rs.b       1                                            ; ...
QBLOCK_PosX:                   rs.b       1                                            ; ...
QBLOCK_FreezeFlag:             rs.b       1                                            ; ...
QBLOCK_FreezeTimerDec:         rs.b       1                                            ; ...
QBLOCK_FreezeTimer:            rs.b       1                                            ; ...
QBLOCK_FreezeTimeGameFrame:    rs.b       1                                            ; ...
QBLOCK_MaxHits:                rs.b       1                                            ; ...
QBLOCK_LevelPos:               rs.b       1                                            ; ...
QBLOCK_Remove:                 rs.b       1 
QBLOCK_DrawCount:              rs.b       1 
QBLOCK_BobIdPrev:              rs.b       1 
QBLOCK_BobId:                  rs.b       1 
QBLOCK_SubType:                rs.b       1
QBLOCK_Spare:                  rs.b       1
QBLOCK_BobSlot:                rs.w       1 
;QBLOCK_field_F:                rs.b       1 
QBLOCK_Sizeof:                 rs.b       0


                               RSRESET
QBLOCKDATA_Type:               rs.b       1                                            ; ...
QBLOCKDATA_LevelPos:           rs.b       1
QBLOCKDATA_PosX:               rs.b       1
QBLOCKDATA_SubType:            rs.b       1
QBLOCKDATA_Sizeof:             rs.b       0



PLAYERSHOT_COUNT = 4                                                                   ; TODO: verify?!
                               RSRESET
PLAYERSHOT_Status:             rs.b       1                                            ; ...
PLAYERSHOT_WeaponId:           rs.b       1
;PLAYERSHOT_PosYDec:            rs.b       1    ; ...
PLAYERSHOT_PosY:               rs.w       1                                            ; ...
;PLAYERSHOT_PosXDec:            rs.b       1    ; ...
PLAYERSHOT_PosX:               rs.w       1                                            ; ...
PLAYERSHOT_SpeedY:             rs.w       1
PLAYERSHOT_SpeedX:             rs.w       1
PLAYERSHOT_FrameId:            rs.b       1                                            ; ...
PLAYERSHOT_MoveCounter:        rs.b       1                                            ; ...
PLAYERSHOT_field_F:            rs.b       1
PLAYERSHOT_BoomerangLo:        rs.b       1                                            ; ...
PLAYERSHOT_BoomerangHi:        rs.b       1                                            ; ...
PLAYERSHOT_LazerCount:         rs.b       1
PLAYERSHOT_BobIdPrev:          rs.b       1
PLAYERSHOT_BobId:              rs.b       1
PLAYERSHOT_BoomerangPtr:       rs.l       1
PLAYERSHOT_BobSlot:            rs.w       1
PLAYERSHOT_Width:              rs.w       1
PLAYERSHOT_Height:             rs.w       1
;PLAYERSHOT_field_D:            rs.b       1
;PLAYERSHOT_field_E:            rs.b       1

PLAYERSHOT_Sizeof:             rs.b       0

ATTACKWAVE_COUNT = 2
                               RSRESET
ATTACKWAVE_Type:               rs.b       1                                            ; ...
ATTACKWAVE_WaitDelay:          rs.b       1                                            ; ...
ATTACKWAVE_SpawnCount:         rs.b       1                                            ; ...
ATTACKWAVE_RepeatAgain:        rs.b       1                                            ; ...
ATTACKWAVE_RepeatWait:         rs.b       1                                            ; ...
ATTACKWAVE_RepeatCount:        rs.b       1                                            ; ...
ATTACKWAVE_SpawnTotal:         rs.b       1                                            ; ...
ATTACKWAVE_SpriteSlotId:       rs.b       1                                            ; ...
ATTACKWAVE_LoadSprites:        rs.b       1                                            ; ...
ATTACKWAVE_field_9:            rs.b       1
ATTACKWAVE_field_A:            rs.b       1
ATTACKWAVE_field_B:            rs.b       1
ATTACKWAVE_field_C:            rs.b       1
ATTACKWAVE_field_D:            rs.b       1
ATTACKWAVE_field_E:            rs.b       1
ATTACKWAVE_field_F:            rs.b       1
ATTACKWAVE_Sizeof:             rs.b       0

ENEMYSHOT_COUNT  = 8
                               RSRESET
ENEMYSHOT_Status:              rs.b       1 
ENEMYSHOT_Type:                rs.b       1 
;ENEMYSHOT_PosYDec:             rs.b       1 
ENEMYSHOT_PosY:                rs.w       1 
;ENEMYSHOT_PosXDec:             rs.b       1 
ENEMYSHOT_PosX:                rs.w       1 
;ENEMYSHOT_SpeedYDec:           rs.b       1 
ENEMYSHOT_SpeedY:              rs.w       1 
;ENEMYSHOT_SpeedXDec:           rs.b       1 
ENEMYSHOT_SpeedX:              rs.w       1 
ENEMYSHOT_BobId:               rs.b       1 
ENEMYSHOT_BobIdPrev:           rs.b       1 
ENEMYSHOT_DeathTimer:          rs.b       1 
ENEMYSHOT_Counter:             rs.b       1 
ENEMYSHOT_WaveY:               rs.b       1  
ENEMYSHOT_WaveX:               rs.b       1  
ENEMYSHOT_OffsetY:             rs.b       1  
ENEMYSHOT_OffsetX:             rs.b       1  
ENEMYSHOT_BobSlot:             rs.w       1
ENEMYSHOT_BobPtr:              rs.l       1
ENEMYSHOT_Sizeof:              rs.b       0

                               RSRESET
BOSSBOX_OffsetY:               rs.b       1                                            ; ...
BOSSBOX_Height:                rs.b       1                                            ; ...
BOSSBOX_OffsetX:               rs.b       1                                            ; ...
BOSSBOX_Width:                 rs.b       1 


BONUSCOUNT_MAX   = 4

                               RSRESET
BONUS_Count1                   rs.b       1
BONUS_Count2                   rs.b       1
BONUS_Count3                   rs.b       1
BONUS_Spare                    rs.b       1                                            ; i like em even!
BONUS_Sizeof                   rs.b       1


EYE_COUNT        = 6

                               RSRESET
EYE_Status:                    rs.b       1                                            ; ...
EYE_HitCount:                  rs.b       1                                            ; ...
EYE_AnimId:                    rs.b       1                                            ; ...
EYE_Color:                     rs.b       1                                            ; ...
EYE_TimerOffset:               rs.b       1                                            ; ...
EYE_Timer:                     rs.b       1                                            ; ...
EYE_OffsetY:                   rs.b       1                                            ; ...
EYE_OffsetX:                   rs.b       1                                            ; ...
EYE_MaxHits:                   rs.b       1                                            ; ...
EYE_field_9:                   rs.b       1 
EYE_field_A:                   rs.b       1 
EYE_FireCounter:               rs.b       1 
EYE_Hide:                      rs.b       1 
EYE_Random:                    rs.b       1 
EYE_BobIdPrev:                 rs.b       1 
EYE_BobId:                     rs.b       1 
EYE_BobSlot:                   rs.w       1
EYE_BobPtr:                    rs.l       1
EYE_Sizeof:                    rs.b       0