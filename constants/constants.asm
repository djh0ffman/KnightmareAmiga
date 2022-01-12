
;----------------------------------------------------------------------------
;
; constants
;
;----------------------------------------------------------------------------

DEBUG_STATS              = 0
DEBUG_NOSOUND            = 0
DEBUG_LEVEL              = 0         ; level id ( that means zero based )

DEBUG_CHECKPOINT         = 0
DEBUG_INVINCIBLE         = 0
DEBUG_INFINITELIVES      = 0
DEBUG_NOTILE             = 0
DEBUG_WEAPON             = 0
DEBUG_STARTSTATUS        = 0         ; 0 = title / 3 = game / 9 = ending
DEBUG_CHEAT              = 0
DEBUG_MAXLEVEL           = 0

DEBUG_STARTLIVES         = 3         ; should be 3
DEBUG_AUTOFIRE           = 1

PLAYERMODE_PLAY          = 0
PLAYERMODE_DEMO          = 1
PLAYERMODE_DEAD          = 2         ; ...
PLAYERMODE_BOSSBEAT      = 3

INIT_DMA                 = %1000001111110000

CIAA                     = $00bfe001

TOTAL_SCORES             = 10
SCORE_SIZE               = TOTAL_SCORES*8
SAVE_IDENTIFIER          = "KMSV"

SAVE_SIZE                = (SCORE_SIZE)+4
SAVE_SIZE_SECTOR         = (SAVE_SIZE/$200)+1
SAVE_POS                 = (11*80*2)-SAVE_SIZE_SECTOR-2
; Screen variables

SCREEN_MARGIN            = 32
SCREEN_EDGE              = SCREEN_MARGIN/2/8
SCREEN_DISPLAY_WIDTH     = 256
SCREEN_DISPLAY_HEIGHT    = (TILES_Y-1)*TILE_HEIGHT
SCREEN_WIDTH             = SCREEN_DISPLAY_WIDTH+SCREEN_MARGIN
SCREEN_HEIGHT            = 212
SCREEN_HEIGHT_GAME       = TILES_Y*TILE_HEIGHT
SCREEN_HEIGHT_DISPLAY    = (TILES_Y*TILE_HEIGHT)/2
SCREEN_HUD_HEIGHT        = 20               
SCREEN_DEPTH             = 5
SCREEN_COLORS            = 1<<SCREEN_DEPTH
SCREEN_WIDTH_BYTE        = SCREEN_WIDTH/8
SCREEN_SIZE              = SCREEN_WIDTH_BYTE*SCREEN_HEIGHT
SCREEN_SIZE_GAME         = SCREEN_WIDTH_BYTE*SCREEN_HEIGHT_GAME
SCREEN_MOD               = SCREEN_WIDTH_BYTE*(SCREEN_DEPTH-1)+(SCREEN_MARGIN/8)
SCREEN_STRIDE            = SCREEN_WIDTH_BYTE*SCREEN_DEPTH
SCREEN_GAME_TOTAL        = SCREEN_SIZE_GAME*SCREEN_DEPTH
SCREEN_HUD_TOTAL         = SCREEN_WIDTH_BYTE*SCREEN_HUD_HEIGHT*SCREEN_DEPTH
SCREEN_HALF              = (SCREEN_HEIGHT_GAME/2)*SCREEN_STRIDE

MENU_DEPTH               = 3
MENU_MOD                 = SCREEN_WIDTH_BYTE*(MENU_DEPTH-1)+(SCREEN_MARGIN/8)
MENU_STRIDE              = SCREEN_WIDTH_BYTE*MENU_DEPTH

; $3d38 6 colors
; $45e8 7 colors
; $52e8 8 colors
TITLE_CODE_BUFFER_SIZE   = $52e8 

TITLE_FIELD_HEIGHT       = 84

TITLE_WIDTH              = 256
TITLE_HEIGHT             = 55
TITLE_DEPTH              = 3
TITLE_WIDTH_BYTE         = TITLE_WIDTH/8
TITLE_WIDTH_WORD         = TITLE_WIDTH/16
TITLE_BLIT_MOD           = SCREEN_WIDTH_BYTE-(TITLE_WIDTH/8) 
TITLE_BLIT_SIZE          = ((TITLE_HEIGHT*TITLE_DEPTH)<<6)+TITLE_WIDTH_WORD    

TITLE_MAX_SCROLL         = 128
TITLE_START_WIDTH        = TITLE_WIDTH*10
TITLE_START_HEIGHT       = TITLE_HEIGHT*10

TITLE_SCALE_PERC         = 90


TITLE_SPRITE_X           = $5c
TITLE_SPRITE_Y1          = $a0
TITLE_SPRITE_Y2          = TITLE_SPRITE_Y1+14
TITLE_SPRITE_Y3          = TITLE_SPRITE_Y2+14

TITLE_SPRITE_SIZE        = 4+(8*4)
TITLE_SPRITE_BLOCK       = (TITLE_SPRITE_SIZE*3)+4
TITLE_SPRITE_OFFSET2     = TITLE_SPRITE_SIZE
TITLE_SPRITE_OFFSET3     = TITLE_SPRITE_OFFSET2+TITLE_SPRITE_SIZE

CASTLE_WIDTH             = 256
CASTLE_WIDTH_BYTE        = CASTLE_WIDTH/8
CASTLE_HEIGHT            = 128
CASTE_DEPTH              = 3
CASTLE_SIZE              = CASTLE_WIDTH_BYTE*CASTLE_HEIGHT*CASTE_DEPTH

CLOUDS_WIDTH             = 320
CLOUDS_WIDTH_BYTE        = CLOUDS_WIDTH/8
CLOUDS_HEIGHT            = 212
CLOUDS_DEPTH             = 3
CLOUDS_SIZE              = CLOUDS_WIDTH_BYTE*CLOUDS_HEIGHT*CLOUDS_DEPTH
CLOUDS_PLANE_MOD         = ((CLOUDS_WIDTH-TITLE_WIDTH)/8)-2

TITLE_BUFFER_SIZE        = TITLE_WIDTH_BYTE*TITLE_DEPTH*TITLE_HEIGHT

HUD_DEPTH                = 5
HUD_HEIGHT               = 20
HUD_WIDTH                = 256
HUD_WIDTH_BYTE           = 256/8
HUD_MOD                  = HUD_WIDTH_BYTE*(HUD_DEPTH-1)
HUD_STRIDE               = HUD_WIDTH_BYTE*HUD_DEPTH

HUD_TOTAL                = SCREEN_WIDTH_BYTE*HUD_HEIGHT
;HUD_WIDTH_BYTE           = SCREEN_DISPLAY_WIDTH/8
HUD_LINE2                = HUD_WIDTH_BYTE*8

SCREEN_BLTSIZE           = ((SCREEN_HEIGHT_GAME*2)<<6)+((SCREEN_WIDTH*SCREEN_DEPTH)/32)
SCREEN_DEPTH_LOOKUP      = 256


SCREEN_START             = $2c
SCREEN_END               = $1
SCREEN_HUD_WAIT          = $eb-$2c
SCREEN_HSTART            = $a1       ; for sprite offset
SCREEN_OFFSET60          = -8

SCREEN_TILE_SIZE         = SCREEN_STRIDE*TILE_HEIGHT

HUD_Y_OFFSET             = SCREEN_HEIGHT-SCREEN_HUD_HEIGHT
HUD_START_LINE           = $eb       ; copper based line position

TILE_HEIGHT              = 32
TILE_WIDTH               = 32

TILES_X                  = 8
TILES_Y                  = 12

TILE_SIZE                = (TILE_WIDTH/8)*TILE_HEIGHT*SCREEN_DEPTH
TILE_MOD                 = SCREEN_WIDTH_BYTE-(TILE_WIDTH/8)
TILE_BLTSIZE             = ((TILE_HEIGHT*SCREEN_DEPTH)<<6)+(TILE_WIDTH/16)
TILE_LINE_BLTSIZE        = ((SCREEN_DEPTH)<<6)+(TILE_WIDTH/16)

QBLOCK_MOD               = SCREEN_WIDTH_BYTE-2

TILE_SCREEN_LINE_BLTSIZE = ((SCREEN_DEPTH)<<6)+((TILES_X*TILE_WIDTH)/16)
TILE_SCREEN_LINE_BLTMOD  = SCREEN_WIDTH_BYTE-((TILES_X*TILE_WIDTH)/8)

MAP_START                = 59
MAP_HEIGHT               = 60
COLL_MAP_SIZE            = (TILES_X*4)*(MAP_HEIGHT*4)
MAP_SIZE                 = MAP_HEIGHT*TILES_X
LEVEL_START              = 0

BLITPRI_ENABLE           = $8400     ; enable blitter priority
BLITPRI_DISABLE          = $0400     ; disable blitter priority


FIN_WIDTH                = 128
FIN_WIDTH_BYTE           = FIN_WIDTH/8
FIN_HEIGHT               = 192
FIN_DEPTH                = 6

FIN_SCREEN_WIDTH         = 256
FIN_SCREEN_HEIGHT        = 212
FIN_SCREEN_WIDTH_BYTE    = FIN_SCREEN_WIDTH/8
FIN_SCREEN_DEPTH         = 6
FIN_SCREEN_MOD           = FIN_SCREEN_WIDTH_BYTE*(FIN_SCREEN_DEPTH-1)
FIN_SCREEN_SIZE          = FIN_SCREEN_STRIDE*FIN_SCREEN_HEIGHT
FIN_SCREEN_STRIDE        = FIN_SCREEN_WIDTH_BYTE*FIN_SCREEN_DEPTH

CREDITS_ROLL             = 25

; --- copper template offsets

COPPER_VERT              = cpVert-cpCopper
COPPER_SPRITE            = cpSprite-cpCopper 
COPPER_PALETTE           = cpPalette-cpCopper
COPPER_PLANES1           = cpPlanes1-cpCopper
;COPPER_SPLIT_WAIT        = cpSplit-cpCopper
;COPPER_PLANES2           = cpPlanes2-cpCopper
COPPER_VERT_HUD          = cpVertHUD-cpCopper
COPPER_VERT_HUD2         = cpVertHUD2-cpCopper
COPPER_HUD_ENABLE        = (cpHUDEnable-cpCopper)+2
COPPER_PLANES_HUD        = cpPlanesHUD-cpCopper
COPPER_SIZEOF            = cpEnd-cpCopper

BOSS_BAR_MAX             = 60

BLIT_COUNT               = 64        ; Max blit restores
BLIT_WIDTH_MAX           = 8         ; words
BLIT_HEIGHT_MAX          = $400/SCREEN_DEPTH

                     RSRESET
Blit_Y               rs.w       1
Blit_Height          rs.w       1
Blit_X               rs.w       1
Blit_Width           rs.w       1
Blit_Modulo          rs.w       1
Blit_Sizeof          rs.w       0

BOB_COUNT                = 64        ; TODO: sanitize this shizzle!

                     RSRESET
Bob_Allocated        rs.b       1
Bob_Hide             rs.b       1
Bob_Y                rs.w       1
Bob_X                rs.w       1
Bob_Sort             rs.w       1
Bob_Layer            rs.w       1
Bob_OffsetY          rs.w       1 
Bob_OffsetX          rs.w       1
Bob_TopMargin        rs.w       1 
Bob_Height           rs.w       1
Bob_Width            rs.w       1
Bob_MaskBlit         rs.w       1    ; color for mask only blit ( 0 = no mask blit )
Bob_DataSize         rs.w       1
Bob_Data             rs.l       1
Bob_Mask             rs.l       1
Bob_StrideLookUp     rs.l       1
Bob_Sizeof           rs.b       0


                     RSRESET
BobObj_Height        rs.w       1
BobObj_WidthWords    rs.w       1
BobObj_OffsetY       rs.w       1
BobObj_OffsetX       rs.w       1
BobObj_Layer         rs.w       1
BobObj_DataSize      rs.w       1
BobObj_Data          rs.w       0


; player power up modes

POWERUP_NONE             = 0
POWERUP_SHIELD           = 1
POWERUP_TRANSPARENT      = 2         ; ...
POWERUP_RED              = 3         ; ...
POWERUP_GRADIUS          = 4
POWERUP_PRINCESS         = 5         ; this is NOT a power up, more a hack to select a different sprite :D