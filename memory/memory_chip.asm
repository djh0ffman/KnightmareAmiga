;----------------------------------------------------------------------------
;
; chip ram areas
;
;----------------------------------------------------------------------------

                 include    "common.asm"
                    
                 section    knightmare_bss_chip,bss_c
WorkArea:
Screen1:         ds.b       SCREEN_GAME_TOTAL
Screen2:         ds.b       SCREEN_GAME_TOTAL

Hud:             ds.b       HUD_TOTAL

TileBuffer:      ds.b       MAX_TILE_BIN
BossBuffer:      ds.b       MAXBOSSSIZE
WorkAreaEnd:

Copper1:         ds.b       COPPER_SIZEOF
Copper2:         ds.b       COPPER_SIZEOF


ModSmpBuffer:    ds.b       MODSAMPLE_BUFFER

TrackBuffer:     ds.b       $3300