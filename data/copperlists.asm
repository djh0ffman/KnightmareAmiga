                include    "common.asm"

NullSprite:     dc.l       0,0

;----------------------------------------------------------------------------
;
; main copper list template
;
;----------------------------------------------------------------------------

cpCopper:                
                dc.w       BPLCON0,$5200                        ; set as 1 bp display
                dc.w       BPLCON1,$0000                        ; set scroll 0
                dc.w       BPLCON2,$0024
                dc.w       BPL1MOD,SCREEN_MOD
                dc.w       BPL2MOD,SCREEN_MOD
                dc.w       DDFSTRT,$48                          ; datafetch start stop (256 accross)
                dc.w       DDFSTOP,$c0
cpVert:         dc.w       DIWSTRT,$2ca1                        ; window start stop (256 * 212) 
                dc.w       DIWSTOP,$00a1

cpSprite: 
                dc.w       SPR0PTH,0
                dc.w       SPR0PTL,0
                dc.w       SPR1PTH,0
                dc.w       SPR1PTL,0
                dc.w       SPR2PTH,0
                dc.w       SPR2PTL,0
                dc.w       SPR3PTH,0
                dc.w       SPR3PTL,0
                dc.w       SPR4PTH,0
                dc.w       SPR4PTL,0
                dc.w       SPR5PTH,0
                dc.w       SPR5PTL,0
                dc.w       SPR6PTH,0
                dc.w       SPR6PTL,0
                dc.w       SPR7PTH,0
                dc.w       SPR7PTL,0

cpPalette:
                dc.w       COLOR00,$000
                dc.w       COLOR01,$000
                dc.w       COLOR02,$000
                dc.w       COLOR03,$000
                dc.w       COLOR04,$000
                dc.w       COLOR05,$000
                dc.w       COLOR06,$000
                dc.w       COLOR07,$000
                dc.w       COLOR08,$000
                dc.w       COLOR09,$000
                dc.w       COLOR10,$000
                dc.w       COLOR11,$000
                dc.w       COLOR12,$000
                dc.w       COLOR13,$000
                dc.w       COLOR14,$000
                dc.w       COLOR15,$000
                dc.w       COLOR16,$000
                dc.w       COLOR17,$000
                dc.w       COLOR18,$000
                dc.w       COLOR19,$000
                dc.w       COLOR20,$000
                dc.w       COLOR21,$000
                dc.w       COLOR22,$000
                dc.w       COLOR23,$000
                dc.w       COLOR24,$000
                dc.w       COLOR25,$000
                dc.w       COLOR26,$000
                dc.w       COLOR27,$000
                dc.w       COLOR28,$000
                dc.w       COLOR29,$000
                dc.w       COLOR30,$000
                dc.w       COLOR31,$000

;                dc.w       $2acf,$fffe                          ;  TODO: adjust this for NTSC

cpPlanes1:	
                dc.w       BPL1PTH,$0
                dc.w       BPL1PTL,$0
                dc.w       BPL2PTH,$0
                dc.w       BPL2PTL,$0
                dc.w       BPL3PTH,$0
                dc.w       BPL3PTL,$0
                dc.w       BPL4PTH,$0
                dc.w       BPL4PTL,$0
                dc.w       BPL5PTH,$0
                dc.w       BPL5PTL,$0



cpVertHUD:      dc.w       (HUD_START_LINE<<8)+$cf,$fffe        ;  end of game playfield
                dc.w       BPLCON0,$0200                        ; disable bitplanes


                dc.w       BPL1MOD,HUD_MOD
                dc.w       BPL2MOD,HUD_MOD

cpPlanesHUD:	
                dc.w       BPL1PTH,$0
                dc.w       BPL1PTL,$0
                dc.w       BPL2PTH,$0
                dc.w       BPL2PTL,$0
                dc.w       BPL3PTH,$0
                dc.w       BPL3PTL,$0
                dc.w       BPL4PTH,$0
                dc.w       BPL4PTL,$0
                dc.w       BPL5PTH,$0
                dc.w       BPL5PTL,$0


                dc.w       COLOR01,$112
                dc.w       COLOR02,$223
                dc.w       COLOR03,$334
                dc.w       COLOR04,$445
                dc.w       COLOR05,$556
                dc.w       COLOR06,$667
                dc.w       COLOR07,$778
                dc.w       COLOR08,$889
                dc.w       COLOR09,$99A
                dc.w       COLOR10,$AAB
                dc.w       COLOR11,$BBC
                dc.w       COLOR12,$CCD
                dc.w       COLOR13,$DDE
                dc.w       COLOR14,$EEF
                dc.w       COLOR15,$49F
                dc.w       COLOR16,$255
                dc.w       COLOR17,$281
                dc.w       COLOR18,$492
                dc.w       COLOR19,$7B2
                dc.w       COLOR20,$BD2
                dc.w       COLOR21,$552
                dc.w       COLOR22,$B24
                dc.w       COLOR23,$B62
                dc.w       COLOR24,$D69
                dc.w       COLOR25,$F87
                dc.w       COLOR26,$EE0
                dc.w       COLOR27,$44E
                dc.w       COLOR28,$2BF
                dc.w       COLOR29,$BBB
                dc.w       COLOR30,$BDF
                dc.w       COLOR31,$FFF

cpVertHUD2:     dc.w       ((HUD_START_LINE+1)<<8)+$cf,$fffe    ;  end of game playfield
cpHUDEnable:    dc.w       BPLCON0,$0200                        ; disable bitplanes


                dc.l       COPPER_HALT
                dc.l       COPPER_HALT



cpEnd:




cpCopperFin:                
                dc.w       BPLCON0,$6200                        ; set as 1 bp display
                dc.w       BPLCON1,$0000                        ; set scroll 0
                dc.w       BPLCON2,$0000
                dc.w       BPL1MOD,FIN_SCREEN_MOD
                dc.w       BPL2MOD,FIN_SCREEN_MOD
                dc.w       DDFSTRT,$48                          ; datafetch start stop (256 accross)
                dc.w       DDFSTOP,$c0
cpVertFin:      dc.w       DIWSTRT,$2ca1                        ; window start stop (256 * 212) 
                dc.w       DIWSTOP,$00a1


cpSpriteFin: 
                dc.w       SPR0PTH,0
                dc.w       SPR0PTL,0
                dc.w       SPR1PTH,0
                dc.w       SPR1PTL,0
                dc.w       SPR2PTH,0
                dc.w       SPR2PTL,0
                dc.w       SPR3PTH,0
                dc.w       SPR3PTL,0
                dc.w       SPR4PTH,0
                dc.w       SPR4PTL,0
                dc.w       SPR5PTH,0
                dc.w       SPR5PTL,0
                dc.w       SPR6PTH,0
                dc.w       SPR6PTL,0
                dc.w       SPR7PTH,0
                dc.w       SPR7PTL,0

cpPaletteFin:
                dc.w       COLOR00,$333
                dc.w       COLOR01,$fff
                dc.w       COLOR02,$000
                dc.w       COLOR03,$000
                dc.w       COLOR04,$000
                dc.w       COLOR05,$000
                dc.w       COLOR06,$000
                dc.w       COLOR07,$000
                dc.w       COLOR08,$000
                dc.w       COLOR09,$000
                dc.w       COLOR10,$000
                dc.w       COLOR11,$000
                dc.w       COLOR12,$000
                dc.w       COLOR13,$000
                dc.w       COLOR14,$000
                dc.w       COLOR15,$000
                dc.w       COLOR16,$000
                dc.w       COLOR17,$000
                dc.w       COLOR18,$000
                dc.w       COLOR19,$000
                dc.w       COLOR20,$000
                dc.w       COLOR21,$000
                dc.w       COLOR22,$000
                dc.w       COLOR23,$000
                dc.w       COLOR24,$000
                dc.w       COLOR25,$000
                dc.w       COLOR26,$000
                dc.w       COLOR27,$000
                dc.w       COLOR28,$000
                dc.w       COLOR29,$000
                dc.w       COLOR30,$000
                dc.w       COLOR31,$000

cpPlanesFin:	
                dc.w       BPL1PTH,$0
                dc.w       BPL1PTL,$0
                dc.w       BPL2PTH,$0
                dc.w       BPL2PTL,$0
                dc.w       BPL3PTH,$0
                dc.w       BPL3PTL,$0
                dc.w       BPL4PTH,$0
                dc.w       BPL4PTL,$0
                dc.w       BPL5PTH,$0
                dc.w       BPL5PTL,$0
                dc.w       BPL6PTH,$0
                dc.w       BPL6PTL,$0

                dc.l       COPPER_HALT
                dc.l       COPPER_HALT

; -------------------------- temp castle

cpMenuCastle:
                dc.w       BPL1PTH,$0
                dc.w       BPL1PTL,$0
                dc.w       BPL3PTH,$0
                dc.w       BPL3PTL,$0
                dc.w       BPL5PTH,$0
                dc.w       BPL5PTL,$0

                dc.w       BPL1MOD,-2
cpMenuCastlePal:
                dc.w       COLOR01,$000
                dc.w       COLOR02,$000
                dc.w       COLOR03,$000
                dc.w       COLOR04,$000
                dc.w       COLOR05,$000
                dc.w       COLOR06,$000
                dc.w       COLOR07,$000
cpMenuCastleEnd:

; -------------------------- MENU

COPPER_MENU_HEADER     = cpMenuEnd-cpMenu
COPPER_MENU_PALETTE    = cpMenuPalette-cpMenu
COPPER_MENU_SPRITES    = cpMenuSprites-cpMenu
COPPER_MENU_PLANES     = cpMenuPlanes-cpMenu
COPPER_MENU_BUFFERSIZE = $1000

cpMenu:
                dc.w       BPLCON0,$6600                        ; 6 planes dual playfield
                dc.w       BPLCON1,$0000                        ; set scroll 0
                dc.w       BPLCON2,$0024
                dc.w       BPL1MOD,-32
                dc.w       BPL2MOD,CLOUDS_PLANE_MOD
                dc.w       DDFSTRT,$40                          ; datafetch start stop (256 accross)
                dc.w       DDFSTOP,$c0
cpVertMenu:     dc.w       DIWSTRT,$2ca1                        ; window start stop (256 * 212) 
                dc.w       DIWSTOP,$00a1

cpMenuPalette:
                dc.w       COLOR00,$000
                dc.w       COLOR01,$000
                dc.w       COLOR02,$000
                dc.w       COLOR03,$000
                dc.w       COLOR04,$000
                dc.w       COLOR05,$000
                dc.w       COLOR06,$000
                dc.w       COLOR07,$000
                dc.w       COLOR08,$000
                dc.w       COLOR09,$000
                dc.w       COLOR10,$000
                dc.w       COLOR11,$000
                dc.w       COLOR12,$000
                dc.w       COLOR13,$000
                dc.w       COLOR14,$000
                dc.w       COLOR15,$000
                dc.w       COLOR16,$000
                dc.w       COLOR17,$000
                dc.w       COLOR18,$000
                dc.w       COLOR19,$000
                dc.w       COLOR20,$000
                dc.w       COLOR21,$000
                dc.w       COLOR22,$000
                dc.w       COLOR23,$000
                dc.w       COLOR24,$000
                dc.w       COLOR25,$000
                dc.w       COLOR26,$000
                dc.w       COLOR27,$000
                dc.w       COLOR28,$000
                dc.w       COLOR29,$000
                dc.w       COLOR30,$000
                dc.w       COLOR31,$000

cpMenuSprites: 
                dc.w       SPR0PTH,0
                dc.w       SPR0PTL,0
                dc.w       SPR1PTH,0
                dc.w       SPR1PTL,0
                dc.w       SPR2PTH,0
                dc.w       SPR2PTL,0
                dc.w       SPR3PTH,0
                dc.w       SPR3PTL,0
                dc.w       SPR4PTH,0
                dc.w       SPR4PTL,0
                dc.w       SPR5PTH,0
                dc.w       SPR5PTL,0
                dc.w       SPR6PTH,0
                dc.w       SPR6PTL,0
                dc.w       SPR7PTH,0
                dc.w       SPR7PTL,0

;                dc.w       $2b01,$ff00     
cpMenuPlanes:
                dc.w       BPL1PTH,$0
                dc.w       BPL1PTL,$0
                dc.w       BPL3PTH,$0
                dc.w       BPL3PTL,$0
                dc.w       BPL5PTH,$0
                dc.w       BPL5PTL,$0
cpMenuEnd:

;cpMenuDynamic:
;                dcb.b      $1000                                ; TODO: maybe move this

