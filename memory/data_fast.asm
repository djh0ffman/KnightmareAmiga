;----------------------------------------------------------------------------
;
; chip data
;
;----------------------------------------------------------------------------

                   section    knightmare_data_fast,data

                   include    "data/attackwaves.asm"
                   include    "data/enemydata.asm"
                   include    "data/qblocks.asm"
                   include    "data/enemybobs.asm"
                   include    "data/powerupdata.asm"
                   include    "data/playershotdata.asm"
                   include    "data/animation.asm"
                   include    "data/sintable.asm"
                   include    "data/bossdata.asm"
                   include    "data/levelpointers.asm"
                   include    "data/bridgetiles.asm"
                   include    "data/textdata.asm"
                   include    "data/bobincludesfast.asm"
                   include    "data/defaultscores.asm"
                
AngleLookUp:       incbin     "assets/angle2.bin"

MenuPal:           incbin     "assets/menu.pal"
KonamiLogoPal:     incbin     "assets/konamilogo.pal"

TitlePal:          dc.w       $000,$400,$700,$B11,$933,$F22,$F44,$F77
                   dc.w       $000,$002,$003,$004,$005,$006,$007,$018
                   dc.w       $000,$333,$255,$492,$BD2,$552,$B24,$B62
                   dc.w       $D69,$F92,$EE0,$44E,$2BF,$BBB,$BDF,$FFF

FinPal:            incbin     "assets/fin.pal"

TitlePalWhite:     dc.w       $000,$fff,$fff,$fff,$fff,$fff,$fff,$fff
                   dc.w       $000,$113,$115,$117,$119,$11A,$11C,$12F

CastleWorkPal:     dc.w       $000,$000,$000,$000,$000,$000,$000
CastlePal:         dc.w       $012,$013,$014,$015,$018,$01B,$01F
CastleWhitePal:    dc.w       $000,$000,$222,$FFF,$FFF,$FFF,$FFF
CastleBlackPal:    dc.w       $000,$000,$000,$000,$000,$000,$005

PalLevel1:         incbin     "assets/leveldata/palette_1.bin"
PalLevel2:         incbin     "assets/leveldata/palette_2.bin"
PalLevel3:         incbin     "assets/leveldata/palette_3.bin"
PalLevel4:         incbin     "assets/leveldata/palette_4.bin"
PalLevel5:         incbin     "assets/leveldata/palette_5.bin"
PalLevel6:         incbin     "assets/leveldata/palette_6.bin"
PalLevel7:         incbin     "assets/leveldata/palette_7.bin"
PalLevel8:         incbin     "assets/leveldata/palette_8.bin"

PalLevel1Gate:     incbin     "assets/leveldata/palettegate_1.bin"
PalLevel2Gate:     incbin     "assets/leveldata/palettegate_2.bin"
PalLevel3Gate:     incbin     "assets/leveldata/palettegate_3.bin"
PalLevel4Gate:     incbin     "assets/leveldata/palettegate_4.bin"
PalLevel5Gate:     incbin     "assets/leveldata/palettegate_5.bin"
PalLevel6Gate:     incbin     "assets/leveldata/palettegate_6.bin"
PalLevel7Gate:     incbin     "assets/leveldata/palettegate_7.bin"
PalLevel8Gate:     incbin     "assets/leveldata/palettegate_8.bin"

MapLevel1:         incbin     "assets/leveldata/map_1.lz"
                   even
MapLevel2:         incbin     "assets/leveldata/map_2.lz"
                   even
MapLevel3:         incbin     "assets/leveldata/map_3.lz"
                   even
MapLevel4:         incbin     "assets/leveldata/map_4.lz"
                   even
MapLevel5:         incbin     "assets/leveldata/map_5.lz"
                   even
MapLevel6:         incbin     "assets/leveldata/map_6.lz"
                   even
MapLevel7:         incbin     "assets/leveldata/map_7.lz"
                   even
MapLevel8:         incbin     "assets/leveldata/map_8.lz"
                   even
                  
TilesLevel1:       incbin     "assets/leveldata/tiles_1.shr"
                   even
TilesLevel2:       incbin     "assets/leveldata/tiles_2.shr"
                   even
TilesLevel3:       incbin     "assets/leveldata/tiles_3.shr"
                   even
TilesLevel4:       incbin     "assets/leveldata/tiles_4.shr"
                   even
TilesLevel5:       incbin     "assets/leveldata/tiles_5.shr"
                   even
TilesLevel6:       incbin     "assets/leveldata/tiles_6.shr"
                   even
TilesLevel7:       incbin     "assets/leveldata/tiles_7.shr"
                   even
TilesLevel8:       incbin     "assets/leveldata/tiles_8.shr"
                   even
                  
MapCollision1:     incbin     "assets/leveltiled/level1_col.bin"
MapCollision2:     incbin     "assets/leveltiled/level2_col.bin"
MapCollision3:     incbin     "assets/leveltiled/level3_col.bin"
MapCollision4:     incbin     "assets/leveltiled/level4_col.bin"
MapCollision5:     incbin     "assets/leveltiled/level5_col.bin"
MapCollision6:     incbin     "assets/leveltiled/level6_col.bin"
MapCollision7:     incbin     "assets/leveltiled/level7_col.bin"
MapCollision8:     incbin     "assets/leveltiled/level8_col.bin"

Clouds:            incbin     "assets/menu/clouds.lz"
                   even
Castle:            incbin     "assets/menu/castle.lz"
                   even

GfxFont2:          incbin     "assets/ascii-font.bin"
GfxFont            incbin     "assets/gfx/font.bin"

                   include    "data/soundlists.asm"

                   include    "data/samplesfast.asm"
                   include    "data/modincludes.asm"

FinPic:            incbin     "assets/fin-full.lz"
                   even
TitleLogo:         incbin     "assets/menu/title.lz"
                   even