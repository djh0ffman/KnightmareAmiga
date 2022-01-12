
;-------------------------------------
; mod list
;-------------------------------------

mod_0:	incbin	"assets/mods/output/gamestart.pat"	; dyn buffer = 0
	even
mod_1:	incbin	"assets/mods/output/bgm1.lz"	; buffer = 82088
	even
mod_2:	incbin	"assets/mods/output/boss1.lz"	; buffer = 59104
	even
mod_3:	incbin	"assets/mods/output/bgm2.lz"	; buffer = 69980
	even
mod_4:	incbin	"assets/mods/output/boss2.lz"	; buffer = 39360
	even
mod_5:	incbin	"assets/mods/output/prince_of_maresia.lz"	; buffer = 69084
	even
mod_6:	incbin	"assets/mods/output/bat_rock.lz"	; buffer = 57094
	even
mod_7:	incbin	"assets/mods/output/tavern_funk.lz"	; buffer = 58544
	even
mod_8:	incbin	"assets/mods/output/blind_panic.lz"	; buffer = 49284
	even
mod_9:	incbin	"assets/mods/output/another_level.lz"	; buffer = 44100
	even
mod_10:	incbin	"assets/mods/output/more_boss.lz"	; buffer = 62868
	even
mod_11:	incbin	"assets/mods/output/xakt.lz"	; buffer = 72064
	even
mod_12:	incbin	"assets/mods/output/under_his_eyes.lz"	; buffer = 81498
	even
mod_13:	incbin	"assets/mods/output/positive_trek.lz"	; buffer = 59480
	even
mod_14:	incbin	"assets/mods/output/boss_fronty_ii.lz"	; buffer = 45696
	even
mod_15:	incbin	"assets/mods/output/last_hurdle.lz"	; buffer = 37036
	even
mod_16:	incbin	"assets/mods/output/manbow_reprise.lz"	; buffer = 61434
	even
mod_17:	incbin	"assets/mods/output/powerup.pat"	; dyn buffer = 0
	even
mod_18:	incbin	"assets/mods/output/death.pat"	; dyn buffer = 0
	even
mod_19:	incbin	"assets/mods/output/gameover.pat"	; dyn buffer = 0
	even
mod_20:	incbin	"assets/mods/output/hiscore.lz"	; buffer = 0
	even
mod_21:	incbin	"assets/mods/output/warp.pat"	; dyn buffer = 0
	even
mod_22:	incbin	"assets/mods/output/bossdeath.pat"	; dyn buffer = 0
	even
mod_23:	incbin	"assets/mods/output/gradius.pat"	; dyn buffer = 0
	even
mod_24:	incbin	"assets/mods/output/title.lz"	; buffer = 6028
	even
mod_25:	incbin	"assets/mods/output/ending.lz"	; buffer = 0
	even

ModPackedList:
	dc.b	0
	dc.b	1
	dc.b	1
	dc.b	1
	dc.b	1
	dc.b	1
	dc.b	1
	dc.b	1
	dc.b	1
	dc.b	1
	dc.b	1
	dc.b	1
	dc.b	1
	dc.b	1
	dc.b	1
	dc.b	1
	dc.b	1
	dc.b	0
	dc.b	0
	dc.b	0
	dc.b	1
	dc.b	0
	dc.b	0
	dc.b	0
	dc.b	1
	dc.b	1
	even

ModList:
	dc.l	mod_0
	dc.l	mod_1
	dc.l	mod_2
	dc.l	mod_3
	dc.l	mod_4
	dc.l	mod_5
	dc.l	mod_6
	dc.l	mod_7
	dc.l	mod_8
	dc.l	mod_9
	dc.l	mod_10
	dc.l	mod_11
	dc.l	mod_12
	dc.l	mod_13
	dc.l	mod_14
	dc.l	mod_15
	dc.l	mod_16
	dc.l	mod_17
	dc.l	mod_18
	dc.l	mod_19
	dc.l	mod_20
	dc.l	mod_21
	dc.l	mod_22
	dc.l	mod_23
	dc.l	mod_24
	dc.l	mod_25

ModSmpList:
	dc.l	modsmplist_0
	dc.l	modsmplist_1
	dc.l	modsmplist_2
	dc.l	modsmplist_3
	dc.l	modsmplist_4
	dc.l	modsmplist_5
	dc.l	modsmplist_6
	dc.l	modsmplist_7
	dc.l	modsmplist_8
	dc.l	modsmplist_9
	dc.l	modsmplist_10
	dc.l	modsmplist_11
	dc.l	modsmplist_12
	dc.l	modsmplist_13
	dc.l	modsmplist_14
	dc.l	modsmplist_15
	dc.l	modsmplist_16
	dc.l	modsmplist_17
	dc.l	modsmplist_18
	dc.l	modsmplist_19
	dc.l	modsmplist_20
	dc.l	modsmplist_21
	dc.l	modsmplist_22
	dc.l	modsmplist_23
	dc.l	modsmplist_24
	dc.l	modsmplist_25

modsmplist_0:
	dc.b	-1

modsmplist_1:
	dc.b	2
	dc.b	3
	dc.b	4
	dc.b	5
	dc.b	6
	dc.b	7
	dc.b	8
	dc.b	9
	dc.b	10
	dc.b	11
	dc.b	-1

modsmplist_2:
	dc.b	12
	dc.b	13
	dc.b	14
	dc.b	15
	dc.b	16
	dc.b	17
	dc.b	18
	dc.b	19
	dc.b	20
	dc.b	21
	dc.b	22
	dc.b	23
	dc.b	24
	dc.b	25
	dc.b	-1

modsmplist_3:
	dc.b	26
	dc.b	28
	dc.b	29
	dc.b	30
	dc.b	31
	dc.b	32
	dc.b	33
	dc.b	34
	dc.b	35
	dc.b	36
	dc.b	37
	dc.b	38
	dc.b	39
	dc.b	40
	dc.b	41
	dc.b	42
	dc.b	43
	dc.b	44
	dc.b	45
	dc.b	-1

modsmplist_4:
	dc.b	24
	dc.b	28
	dc.b	29
	dc.b	30
	dc.b	46
	dc.b	31
	dc.b	32
	dc.b	33
	dc.b	42
	dc.b	44
	dc.b	45
	dc.b	-1

modsmplist_5:
	dc.b	24
	dc.b	47
	dc.b	48
	dc.b	49
	dc.b	13
	dc.b	50
	dc.b	32
	dc.b	51
	dc.b	52
	dc.b	7
	dc.b	8
	dc.b	9
	dc.b	33
	dc.b	-1

modsmplist_6:
	dc.b	53
	dc.b	54
	dc.b	55
	dc.b	56
	dc.b	57
	dc.b	58
	dc.b	59
	dc.b	60
	dc.b	61
	dc.b	62
	dc.b	33
	dc.b	-1

modsmplist_7:
	dc.b	30
	dc.b	63
	dc.b	65
	dc.b	33
	dc.b	12
	dc.b	35
	dc.b	36
	dc.b	37
	dc.b	39
	dc.b	41
	dc.b	52
	dc.b	42
	dc.b	43
	dc.b	44
	dc.b	45
	dc.b	-1

modsmplist_8:
	dc.b	12
	dc.b	13
	dc.b	47
	dc.b	48
	dc.b	49
	dc.b	60
	dc.b	25
	dc.b	24
	dc.b	62
	dc.b	-1

modsmplist_9:
	dc.b	62
	dc.b	12
	dc.b	2
	dc.b	5
	dc.b	3
	dc.b	33
	dc.b	66
	dc.b	67
	dc.b	32
	dc.b	-1

modsmplist_10:
	dc.b	54
	dc.b	68
	dc.b	69
	dc.b	70
	dc.b	53
	dc.b	12
	dc.b	61
	dc.b	60
	dc.b	33
	dc.b	28
	dc.b	30
	dc.b	46
	dc.b	31
	dc.b	-1

modsmplist_11:
	dc.b	50
	dc.b	26
	dc.b	13
	dc.b	62
	dc.b	24
	dc.b	51
	dc.b	32
	dc.b	71
	dc.b	33
	dc.b	68
	dc.b	69
	dc.b	70
	dc.b	60
	dc.b	72
	dc.b	73
	dc.b	74
	dc.b	75
	dc.b	-1

modsmplist_12:
	dc.b	12
	dc.b	47
	dc.b	48
	dc.b	49
	dc.b	13
	dc.b	32
	dc.b	24
	dc.b	25
	dc.b	62
	dc.b	72
	dc.b	33
	dc.b	7
	dc.b	9
	dc.b	68
	dc.b	70
	dc.b	-1

modsmplist_13:
	dc.b	62
	dc.b	33
	dc.b	61
	dc.b	53
	dc.b	54
	dc.b	4
	dc.b	76
	dc.b	77
	dc.b	78
	dc.b	79
	dc.b	80
	dc.b	32
	dc.b	-1

modsmplist_14:
	dc.b	32
	dc.b	13
	dc.b	62
	dc.b	24
	dc.b	71
	dc.b	68
	dc.b	69
	dc.b	70
	dc.b	33
	dc.b	60
	dc.b	46
	dc.b	31
	dc.b	-1

modsmplist_15:
	dc.b	50
	dc.b	62
	dc.b	33
	dc.b	29
	dc.b	31
	dc.b	43
	dc.b	44
	dc.b	45
	dc.b	42
	dc.b	-1

modsmplist_16:
	dc.b	32
	dc.b	62
	dc.b	7
	dc.b	8
	dc.b	9
	dc.b	81
	dc.b	82
	dc.b	-1

modsmplist_17:
	dc.b	-1

modsmplist_18:
	dc.b	-1

modsmplist_19:
	dc.b	-1

modsmplist_20:
	dc.b	-1

modsmplist_21:
	dc.b	-1

modsmplist_22:
	dc.b	-1

modsmplist_23:
	dc.b	-1

modsmplist_24:
	dc.b	87
	dc.b	-1

modsmplist_25:
	dc.b	-1

	even

; -------------------------
; 
; sample list
; 
; -------------------------

SampleList:
	dc.w	0				; -- static
	dc.l	smp_0			; ---- pointer - brassfixed
	dc.l	25120			; ---- size
	dc.w	0				; -- static
	dc.l	smp_1			; ---- pointer - newbass.8SVX
	dc.l	10652			; ---- size
	dc.w	1				; -- dynamic
	dc.l	smp_2			; ---- pointer - drums2.8SVX
	dc.l	3584			; ---- size
	dc.w	1				; -- dynamic
	dc.l	smp_3			; ---- pointer - tick1
	dc.l	1736			; ---- size
	dc.w	1				; -- dynamic
	dc.l	smp_4			; ---- pointer - tick2
	dc.l	2308			; ---- size
	dc.w	1				; -- dynamic
	dc.l	smp_5			; ---- pointer - drumsnare
	dc.l	3584			; ---- size
	dc.w	1				; -- dynamic
	dc.l	smp_6			; ---- pointer - br2.8SVX
	dc.l	11336			; ---- size
	dc.w	1				; -- dynamic
	dc.l	smp_7			; ---- pointer - br3.8SVX
	dc.l	7870			; ---- size
	dc.w	1				; -- dynamic
	dc.l	smp_8			; ---- pointer - br4.8SVX
	dc.l	13010			; ---- size
	dc.w	1				; -- dynamic
	dc.l	smp_9			; ---- pointer - br5.8SVX
	dc.l	16490			; ---- size
	dc.w	1				; -- dynamic
	dc.l	smp_10			; ---- pointer - arptest2-a.8SVX
	dc.l	13302			; ---- size
	dc.w	1				; -- dynamic
	dc.l	smp_11			; ---- pointer - arptest2-b.8SVX
	dc.l	8868			; ---- size
	dc.w	1				; -- dynamic
	dc.l	smp_12			; ---- pointer - menace.8SVX
	dc.l	13548			; ---- size
	dc.w	1				; -- dynamic
	dc.l	smp_13			; ---- pointer - boss-hat.8SVX
	dc.l	1434			; ---- size
	dc.w	1				; -- dynamic
	dc.l	smp_14			; ---- pointer - v1.8SVX
	dc.l	3460			; ---- size
	dc.w	1				; -- dynamic
	dc.l	smp_15			; ---- pointer - v2.8SVX
	dc.l	3518			; ---- size
	dc.w	1				; -- dynamic
	dc.l	smp_16			; ---- pointer - v3.8SVX
	dc.l	3474			; ---- size
	dc.w	1				; -- dynamic
	dc.l	smp_17			; ---- pointer - v4.8SVX
	dc.l	3462			; ---- size
	dc.w	1				; -- dynamic
	dc.l	smp_18			; ---- pointer - v5.8SVX
	dc.l	3502			; ---- size
	dc.w	1				; -- dynamic
	dc.l	smp_19			; ---- pointer - v6.8SVX
	dc.l	3508			; ---- size
	dc.w	1				; -- dynamic
	dc.l	smp_20			; ---- pointer - v7.8SVX
	dc.l	3500			; ---- size
	dc.w	1				; -- dynamic
	dc.l	smp_21			; ---- pointer - v8.8SVX
	dc.l	3496			; ---- size
	dc.w	1				; -- dynamic
	dc.l	smp_22			; ---- pointer - v9.8SVX
	dc.l	3486			; ---- size
	dc.w	1				; -- dynamic
	dc.l	smp_23			; ---- pointer - v10.8SVX
	dc.l	3492			; ---- size
	dc.w	1				; -- dynamic
	dc.l	smp_24			; ---- pointer - boss-kick.8SVX
	dc.l	3520			; ---- size
	dc.w	1				; -- dynamic
	dc.l	smp_25			; ---- pointer - boss-snare.8SVX
	dc.l	5704			; ---- size
	dc.w	1				; -- dynamic
	dc.l	smp_26			; ---- pointer - bass2.8SVX
	dc.l	3740			; ---- size
	dc.w	0				; -- static
	dc.l	smp_27			; ---- pointer - MOBIOUS2.8SVX
	dc.l	1402			; ---- size
	dc.w	1				; -- dynamic
	dc.l	smp_28			; ---- pointer - org3.8SVX
	dc.l	2978			; ---- size
	dc.w	1				; -- dynamic
	dc.l	smp_29			; ---- pointer - org4.8SVX
	dc.l	4694			; ---- size
	dc.w	1				; -- dynamic
	dc.l	smp_30			; ---- pointer - org5.8SVX
	dc.l	3464			; ---- size
	dc.w	1				; -- dynamic
	dc.l	smp_31			; ---- pointer - org7.8SVX
	dc.l	3464			; ---- size
	dc.w	1				; -- dynamic
	dc.l	smp_32			; ---- pointer - mg-bass1
	dc.l	7978			; ---- size
	dc.w	1				; -- dynamic
	dc.l	smp_33			; ---- pointer - noise
	dc.l	942			; ---- size
	dc.w	1				; -- dynamic
	dc.l	smp_34			; ---- pointer - tri-imust
	dc.l	20			; ---- size
	dc.w	1				; -- dynamic
	dc.l	smp_35			; ---- pointer - h3.8SVX
	dc.l	3518			; ---- size
	dc.w	1				; -- dynamic
	dc.l	smp_36			; ---- pointer - h4.8SVX
	dc.l	3572			; ---- size
	dc.w	1				; -- dynamic
	dc.l	smp_37			; ---- pointer - h5.8SVX
	dc.l	5088			; ---- size
	dc.w	1				; -- dynamic
	dc.l	smp_38			; ---- pointer - h7.8SVX
	dc.l	5390			; ---- size
	dc.w	1				; -- dynamic
	dc.l	smp_39			; ---- pointer - ms1
	dc.l	6432			; ---- size
	dc.w	1				; -- dynamic
	dc.l	smp_40			; ---- pointer - ms2
	dc.l	1764			; ---- size
	dc.w	1				; -- dynamic
	dc.l	smp_41			; ---- pointer - ms3
	dc.l	4332			; ---- size
	dc.w	1				; -- dynamic
	dc.l	smp_42			; ---- pointer - ella-snare
	dc.l	4402			; ---- size
	dc.w	1				; -- dynamic
	dc.l	smp_43			; ---- pointer - ella-kick
	dc.l	3856			; ---- size
	dc.w	1				; -- dynamic
	dc.l	smp_44			; ---- pointer - ella-hat1
	dc.l	2298			; ---- size
	dc.w	1				; -- dynamic
	dc.l	smp_45			; ---- pointer - elle-hat2
	dc.l	2048			; ---- size
	dc.w	1				; -- dynamic
	dc.l	smp_46			; ---- pointer - org6.8SVX
	dc.l	3572			; ---- size
	dc.w	1				; -- dynamic
	dc.l	smp_47			; ---- pointer - bongo1.8SVX
	dc.l	2690			; ---- size
	dc.w	1				; -- dynamic
	dc.l	smp_48			; ---- pointer - bongo2.8SVX
	dc.l	3354			; ---- size
	dc.w	1				; -- dynamic
	dc.l	smp_49			; ---- pointer - bongo3.8SVX
	dc.l	2486			; ---- size
	dc.w	1				; -- dynamic
	dc.l	smp_50			; ---- pointer - bass.8SVX
	dc.l	5960			; ---- size
	dc.w	1				; -- dynamic
	dc.l	smp_51			; ---- pointer - Clap BitNighties.8SVX
	dc.l	1726			; ---- size
	dc.w	1				; -- dynamic
	dc.l	smp_52			; ---- pointer - shaker.8SVX
	dc.l	1624			; ---- size
	dc.w	1				; -- dynamic
	dc.l	smp_53			; ---- pointer - rock-kick.8SVX
	dc.l	7364			; ---- size
	dc.w	1				; -- dynamic
	dc.l	smp_54			; ---- pointer - rock-snare.8SVX
	dc.l	7392			; ---- size
	dc.w	1				; -- dynamic
	dc.l	smp_55			; ---- pointer - ghi
	dc.l	3588			; ---- size
	dc.w	1				; -- dynamic
	dc.l	smp_56			; ---- pointer - g1
	dc.l	3146			; ---- size
	dc.w	1				; -- dynamic
	dc.l	smp_57			; ---- pointer - g2
	dc.l	3414			; ---- size
	dc.w	1				; -- dynamic
	dc.l	smp_58			; ---- pointer - g3
	dc.l	3226			; ---- size
	dc.w	1				; -- dynamic
	dc.l	smp_59			; ---- pointer - g4
	dc.l	3900			; ---- size
	dc.w	1				; -- dynamic
	dc.l	smp_60			; ---- pointer - mg-lead1
	dc.l	7176			; ---- size
	dc.w	1				; -- dynamic
	dc.l	smp_61			; ---- pointer - rock-cym.8SVX
	dc.l	7574			; ---- size
	dc.w	1				; -- dynamic
	dc.l	smp_62			; ---- pointer - mglead2
	dc.l	9372			; ---- size
	dc.w	1				; -- dynamic
	dc.l	smp_63			; ---- pointer - squarexx
	dc.l	50			; ---- size
	dc.w	0				; -- static
	dc.l	smp_64			; ---- pointer - squarexx2
	dc.l	50			; ---- size
	dc.w	1				; -- dynamic
	dc.l	smp_65			; ---- pointer - flute-test.8SVX
	dc.l	3370			; ---- size
	dc.w	1				; -- dynamic
	dc.l	smp_66			; ---- pointer - lv1.8SVX
	dc.l	1624			; ---- size
	dc.w	1				; -- dynamic
	dc.l	smp_67			; ---- pointer - lv2.8SVX
	dc.l	1732			; ---- size
	dc.w	1				; -- dynamic
	dc.l	smp_68			; ---- pointer - zak-tika1
	dc.l	1210			; ---- size
	dc.w	1				; -- dynamic
	dc.l	smp_69			; ---- pointer - zak-tika2
	dc.l	1162			; ---- size
	dc.w	1				; -- dynamic
	dc.l	smp_70			; ---- pointer - zak-tika3
	dc.l	3022			; ---- size
	dc.w	1				; -- dynamic
	dc.l	smp_71			; ---- pointer - zax-snaretika.8SVX
	dc.l	2844			; ---- size
	dc.w	1				; -- dynamic
	dc.l	smp_72			; ---- pointer - mg-riser
	dc.l	1878			; ---- size
	dc.w	1				; -- dynamic
	dc.l	smp_73			; ---- pointer - npad1.8SVX
	dc.l	7024			; ---- size
	dc.w	1				; -- dynamic
	dc.l	smp_74			; ---- pointer - npad2.8SVX
	dc.l	6596			; ---- size
	dc.w	1				; -- dynamic
	dc.l	smp_75			; ---- pointer - npad3.8SVX
	dc.l	6480			; ---- size
	dc.w	1				; -- dynamic
	dc.l	smp_76			; ---- pointer - stb1.8svx
	dc.l	2616			; ---- size
	dc.w	1				; -- dynamic
	dc.l	smp_77			; ---- pointer - stb2.8svx
	dc.l	2874			; ---- size
	dc.w	1				; -- dynamic
	dc.l	smp_78			; ---- pointer - stb3.8svx
	dc.l	2482			; ---- size
	dc.w	1				; -- dynamic
	dc.l	smp_79			; ---- pointer - stb4.8svx
	dc.l	2378			; ---- size
	dc.w	1				; -- dynamic
	dc.l	smp_80			; ---- pointer - EPIC-STAB.8SVX
	dc.l	6200			; ---- size
	dc.w	1				; -- dynamic
	dc.l	smp_81			; ---- pointer - man-stab1.8SVX
	dc.l	4692			; ---- size
	dc.w	1				; -- dynamic
	dc.l	smp_82			; ---- pointer - man-stab2.8SVX
	dc.l	2022			; ---- size
	dc.w	0				; -- static
	dc.l	smp_83			; ---- pointer - bosszap.8SVX
	dc.l	5672			; ---- size
	dc.w	0				; -- static
	dc.l	smp_84			; ---- pointer - squarexx1
	dc.l	44			; ---- size
	dc.w	0				; -- static
	dc.l	smp_85			; ---- pointer - squarexx3
	dc.l	200			; ---- size
	dc.w	0				; -- static
	dc.l	smp_86			; ---- pointer - squarexx4
	dc.l	20			; ---- size
	dc.w	1				; -- dynamic
	dc.l	smp_87			; ---- pointer - wind.8SVX
	dc.l	6028			; ---- size

MOD_COUNT = 26

ModNameList:
	dc.l	mod_name_0
	dc.l	mod_name_1
	dc.l	mod_name_2
	dc.l	mod_name_3
	dc.l	mod_name_4
	dc.l	mod_name_5
	dc.l	mod_name_6
	dc.l	mod_name_7
	dc.l	mod_name_8
	dc.l	mod_name_9
	dc.l	mod_name_10
	dc.l	mod_name_11
	dc.l	mod_name_12
	dc.l	mod_name_13
	dc.l	mod_name_14
	dc.l	mod_name_15
	dc.l	mod_name_16
	dc.l	mod_name_17
	dc.l	mod_name_18
	dc.l	mod_name_19
	dc.l	mod_name_20
	dc.l	mod_name_21
	dc.l	mod_name_22
	dc.l	mod_name_23
	dc.l	mod_name_24
	dc.l	mod_name_25

mod_name_0:	dc.b	8,2,"GAMESTART",0
mod_name_1:	dc.b	8,2,"LEVEL 1 - MSX REMIXED",0
mod_name_2:	dc.b	8,2,"BOSS 1 - MSX REMIXED",0
mod_name_3:	dc.b	8,2,"LEVEL 2 - MSX REMIXED",0
mod_name_4:	dc.b	8,2,"BOSS 2 - MSX REMIXED",0
mod_name_5:	dc.b	8,2,"LEVEL 3 - PRINCE OF MARESIA",0
mod_name_6:	dc.b	8,2,"BOSS 3 - BAT ROCK",0
mod_name_7:	dc.b	8,2,"LEVEL 4 - TAVERN FUNK",0
mod_name_8:	dc.b	8,2,"BOSS 4 - BLIND PANIC",0
mod_name_9:	dc.b	8,2,"LEVEL 5 - ANOTHER LEVEL",0
mod_name_10:	dc.b	8,2,"BOSS 5 - MORE BOSS",0
mod_name_11:	dc.b	8,2,"LEVEL 6 - XAKT",0
mod_name_12:	dc.b	8,2,"BOSS 6 - UNDER HIS EYES",0
mod_name_13:	dc.b	8,2,"LEVEL 7 - POSITIVE TREK",0
mod_name_14:	dc.b	8,2,"BOSS 7 - BOSS FRONTY II",0
mod_name_15:	dc.b	8,2,"LEVEL 8 - LAST HURDLE",0
mod_name_16:	dc.b	8,2,"BOSS 8 - MANBOW REPRISE",0
mod_name_17:	dc.b	8,2,"POWERUP",0
mod_name_18:	dc.b	8,2,"PLAYER DEATH",0
mod_name_19:	dc.b	8,2,"GAME OVER",0
mod_name_20:	dc.b	8,2,"HISCORE",0
mod_name_21:	dc.b	8,2,"WARP",0
mod_name_22:	dc.b	8,2,"BOSS DEATH",0
mod_name_23:	dc.b	8,2,"GRADIUS BONUS",0
mod_name_24:	dc.b	8,2,"TITLE",0
mod_name_25:	dc.b	8,2,"ENDING",0
	even
