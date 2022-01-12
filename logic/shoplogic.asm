

;----------------------------------------------------------------------------
;
; shop logic
;
; allows player to select a perma power-up
;
; speed (1 to 4)
; weapons 1 - 4 
;
;----------------------------------------------------------------------------

    include     "common.asm"

ShopLogic:
    JMPINDEX    d1

ShopLogicIndex:
    dc.w        ShopInit-ShopLogicIndex
    dc.w        ShopClear-ShopLogicIndex
    dc.w        ShopDraw-ShopLogicIndex
    dc.w        ShopSelect-ShopLogicIndex
    dc.w        ShopClear-ShopLogicIndex
    dc.w        ShopRestore-ShopLogicIndex
    dc.w        ShopExit-ShopLogicIndex


;----------------------------------------------------------------------------
;
; shop innit
;
; prep / stop flipping screen
;
;----------------------------------------------------------------------------

ShopInit:
    clr.b       ShopPos(a5)

    sf          DoubleBuffer(a5)
    clr.b       Shrink(a5)
    
    bsr         MusicSave

    moveq       #0,d1
    moveq       #MOD_WARP,d1
    PUSHMOST
    bsr         MusicSet
    POPMOST
    addq.b      #1,GameSubStatus(a5)

    bsr         SpriteBackup
    rts


;----------------------------------------------------------------------------
;
; shop clear
;
; clears the game screen
;
;----------------------------------------------------------------------------

ShopClear:
    bsr         ClearHorizontal
    bne         .exit
    add.b       #1,GameSubStatus(a5)
    clr.b       Shrink(a5)
.exit
    rts


;----------------------------------------------------------------------------
;
; shop draw
;
; clears the game screen
;
;----------------------------------------------------------------------------

SHOP_ITEMS  = 7
;SHOP_WIDTH  = SCREEN_DISPLAY_WIDTH/SHOP_ITEMS
SHOP_WIDTH  = 32
SHOP_ITEM_Y = (SCREEN_DISPLAY_HEIGHT/4)-32-4

ShopDraw:
    lea         TextShop,a0
    bsr         TextPlotMain
    lea         TextShop1,a0
    bsr         TextPlotMain
    lea         TextShop2,a0
    bsr         TextPlotMain
    lea         TextShop3,a0
    bsr         TextPlotMain

    move.l      #SHOP_WIDTH/2,d4
    lea         PowerUpBobPtrs1(a5),a1
    bsr         .draw
    bsr         .draw
    lea         WeaponPowerUpBobPtrs1+4(a5),a1
    bsr         .draw
    bsr         .draw
    bsr         .draw

    cmp.b       #4,PermaWeapon(a5)
    bne         .swordskip
    addq.l      #8,a1                                              ; skip to double sword icon
.swordskip
    bsr         .draw
    move.l      #SHOP_ITEM_Y,d0
    lea         BobShopExit_0,a0
    bsr         BobDrawOnly
    bsr         PlotShopArrow
    addq.b      #1,GameSubStatus(a5)
    rts

.draw
    move.l      #SHOP_ITEM_Y,d0
    move.l      (a1)+,a0
    PUSHM       d4/a1
    bsr         BobDrawOnly
    POPM        d4/a1
    add.w       #SHOP_WIDTH,d4
    rts

ClearShopArrow:
    move.b      #" ",d2
    bra         DrawShopArrow

PlotShopArrow:
    move.b      #"%",d2

DrawShopArrow:
    move.w      #(SHOP_ITEM_Y/8)+1,d0
    moveq       #0,d1
    move.b      ShopPos(a5),d1
    mulu        #SHOP_WIDTH,d1
    lsr.w       #3,d1
    addq.b      #1,d1
    bsr         CharPlotMain
    rts


;----------------------------------------------------------------------------
;
; shop logic
;
;----------------------------------------------------------------------------

ShopSelect:
    move.b      ControlsTrigger(a5),d0
    btst        #2,d0
    bne         .left
    btst        #3,d0
    bne         .right
    btst        #4,d0
    bne         .select
.exit
    rts

.select
    moveq       #0,d0
    move.b      ShopPos(a5),d0
    cmp.b       #SHOP_ITEMS-1,d0
    beq         ShopLeave
    add.w       d0,d0
    move.w      ShopPrices(pc,d0.w),d0

    cmp.l       Score(a5),d0
    bhi         .cantafford
    sub.l       d0,Score(a5)
    bra         ShopPowerUp


.cantafford
    moveq       #50,d0
    bra         SfxPlay
    

.left
    tst.b       ShopPos(a5)
    beq         .exit
    bsr         ClearShopArrow
    subq.b      #1,ShopPos(a5)
    bra         .plot

.right
    cmp.b       #SHOP_ITEMS-1,ShopPos(a5)
    beq         .exit
    bsr         ClearShopArrow
    addq.b      #1,ShopPos(a5)
.plot
    bsr         PlotShopArrow
.sfx
    moveq       #$12,d0
    bra         SfxPlay


ShopPrices:
    dc.w        20000                                              ; speed
    dc.w        40000                                              ; sheild
    dc.w        50000                                              ; weapon
    dc.w        50000                                              ; weapon
    dc.w        50000                                              ; weapon
    dc.w        50000                                              ; weapon

ShopPowerUp:
    moveq       #0,d0
    move.b      ShopPos(a5),d0
    beq         .speed
    subq.b      #1,d0
    beq         .shield

    subq.b      #1,d0
    ; weapon
    move.b      ShopWeapons(pc,d0.w),d0
    cmp.b       PermaWeapon(a5),d0
    bne         .diff
    addq.b      #1,d0
.diff
    move.b      d0,PermaWeapon(a5)
    move.b      d0,PlayerStatus+PLAYER_WeaponId(a5)
    bra         ShopLeave

.shield
    move.b      #$1e,PermaShield(a5)
    move.b      #$1e,PlayerStatus+PLAYER_SheildPower(a5)
    move.b      #POWERUP_SHIELD,PlayerStatus+PLAYER_PowerUp(a5)
    bra         ShopLeave


.speed
    cmp.b       #4,PermaSpeed(a5)
    bcc         ShopLeave
    addq.b      #1,PermaSpeed(a5)
    move.b      PermaSpeed(a5),d0
    cmp.b       PlayerStatus+PLAYER_Speed(a5),d0
    bcs         ShopLeave
    move.b      d0,PlayerStatus+PLAYER_Speed(a5)
    ;bra         ShopLeave

ShopLeave:
    addq.b      #1,GameSubStatus(a5)
    clr.b       Shrink(a5)
    moveq       #$10,d0
    bra         SfxPlay

ShopWeapons:
    dc.b        2, 8, 6, 4
    even


;----------------------------------------------------------------------------
;
; shop restore
;
; restores the game screen and starts the game
;
;----------------------------------------------------------------------------

ShopRestore:
    moveq       #0,d0
    move.b      Shrink(a5),d0

    moveq       #(SCREEN_HEIGHT_DISPLAY/16)-1,d7
.loop
    bsr         RestoreScreenLine
    add.b       #16,d0
    dbra        d7,.loop

    addq.b      #1,Shrink(a5)
    cmp.b       #16,Shrink(a5)
    bcs         .exit
    add.b       #1,GameSubStatus(a5)
.exit
    rts


;----------------------------------------------------------------------------
;
; shop exit
;
; return to game
;
;----------------------------------------------------------------------------

ShopExit:
    st          DoubleBuffer(a5)
    bsr         MusicRestore

    bsr         SpriteRestore
    moveq       #5,d0
    bra         SetGameStatus
