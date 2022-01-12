;----------------------------------------------------------------------------
;
;  qblock data
;
;----------------------------------------------------------------------------

QBlockHitCounts:
    dc.b    $0F, 5, $0A, $0A, 4, $1E, 5, $10, $11, $20, $21, $30, $31    ; ...
    even 


QBlockList:
    dc.l    QBlocks1                                                     ; level 1
    dc.l    QBlocks2                                                     ; level 2
    dc.l    QBlocks3                                                     ; level 3
    dc.l    QBlocks4                                                     ; level 4
    dc.l    QBlocks5                                                     ; level 5
    dc.l    QBlocks6                                                     ; level 6
    dc.l    QBlocks7                                                     ; level 7
    dc.l    QBlocks8                                                     ; level 8

    ; qblock data replaced as init code now searchs for the valid blocks at 
    ; a checkpoint rather than using these bits of data
;QBlocks:
;    dc.l    QBlocks1                                                     ; ...
;    dc.b    0, 3, 9, $10, $13, $16, $1B, $21, $24, 0
;    dc.l    QBlocks2                                                     ; level 2
;    dc.b    0, 4, $0A, $0F, $14, $18, $1C, $23, $2A, 0
;    dc.l    QBlocks3                                                     ; level 3
;    dc.b    0, 3, 7, $0E, $14, $1B, $22, $27, $2A, 0
;    dc.l    QBlocks4                                                     ; level 4
;    dc.b    0, 4, $0A, $10, $16, $1D, $21, $27, $2E, 0
;    dc.l    QBlocks5                                                     ; level 5
;    dc.b    0, 6, $0C, $12, $1A, $1F, $25, $2D, $34, 0
;    dc.l    QBlocks6                                                     ; level 6
;    dc.b    0, 6, $0C, $12, $1A, $20, $27, $2C, $30, $32
;    dc.l    QBlocks7                                                     ; level 7
;    dc.b    0, 5, $0B, $11, $18, $1C, $22, $26, $2C, $2D
;    dc.l    QBlocks8                                                     ; level 8
;    dc.b    0, 3, 9, $10, $17, $1C, $20, $26, $2B, 0

; qblock data (3 bytes)
;
; +0 = qblock type ( bit 7 = hidden? )
; +1 = qblock level position
; +2 = qblock x position
; +3 = qblock subtype (added by me)
QBlocks1: 
    dc.b    $31, $04, $44, $00  
    dc.b    $31, $0E, $94, $00
    dc.b    $31, $10, $94, $00
    dc.b    $12, $18, $E4, $00
    dc.b    $32, $20, $74, $00
    dc.b    $11, $20, $C4, $00
    dc.b    $11, $24, $C4, $00
    dc.b    $31, $28, $34, $00
    dc.b    $11, $28, $C4, $00
    dc.b    $9B, $30, $01, $00
    dc.b    $9C, $30, $F8, $00
    dc.b    $31, $38, $54, $00
    dc.b    $31, $3C, $54, $00
    dc.b    $11, $40, $54, $00
    dc.b    $33, $42, $B4, $00
    dc.b    $11, $44, $54, $00
    dc.b    $15, $50, $14, $00
    dc.b    $31, $56, $D4, $00
    dc.b    $13, $5E, $64, $00
    dc.b    $10, $6C, $E4, $00
    dc.b    $31, $72, $54, $00
    dc.b    $31, $72, $B4, $00
    dc.b    $31, $86, $34, $00
    dc.b    $97, $88, $01, $00
    dc.b    $98, $88, $F8, $00
    dc.b    $15, $88, $E4, $00
    dc.b    $32, $8A, $64, $00
    dc.b    $97, $90, $01, $00
    dc.b    $98, $90, $F8, $00
    dc.b    $11, $98, $84, $00
    dc.b    $11, $9E, $84, $00
    dc.b    $13, $9E, $D4, $00
    dc.b    $31, $A4, $84, $00
    dc.b    $12, $AC, $34, $00
    
    dc.b    $16, $B4, $14, $02                                           ; shop

    dc.b    $9B, $BC, $01, $00
    dc.b    $9C, $BC, $F8, $00
    dc.b    -1,-1,-1,-1
QBlocks2:
    dc.b    $11, $08, $A4, $00                                           ; ...
    dc.b    $12, $0A, $34, $00
    dc.b    $11, $0E, $A4, $00
    dc.b    $11, $14, $A4, $00
    dc.b    $34, $20, $74, $00
    dc.b    $34, $20, $84, $00
    dc.b    $34, $20, $94, $00
    dc.b    $34, $20, $A4, $00
    dc.b    $97, $28, $01, $00
    dc.b    $98, $28, $F8, $00
    dc.b    $31, $38, $A4, $00
    dc.b    $11, $3A, $94, $00
    dc.b    $31, $3C, $84, $00
    dc.b    $11, $3E, $74, $00
    dc.b    $13, $44, $B4, $00
    dc.b    $31, $4E, $54, $00
    dc.b    $31, $50, $74, $00
    dc.b    $31, $52, $94, $00
    dc.b    $31, $54, $B4, $00
    dc.b    $12, $5A, $44, $00
        
    dc.b    $16, $68, $04, $02                                           ; shop

    dc.b    $11, $6A, $64, $00
    dc.b    $11, $70, $64, $00
    dc.b    $15, $70, $E4, $00
    dc.b    $11, $76, $64, $00
    dc.b    $14, $7A, $94, $00
    dc.b    $31, $84, $44, $00

    dc.b    $16, $86, $f4, $01                                           ; gradius

    dc.b    $33, $88, $C4, $00
    dc.b    $11, $8C, $94, $00
    dc.b    $12, $92, $34, $00
    dc.b    $97, $94, $01, $00
    dc.b    $98, $94, $F8, $00
    dc.b    $11, $9C, $54, $00
    dc.b    $31, $9C, $84, $00
    dc.b    $11, $9C, $B4, $00
    dc.b    $14, $A6, $64, $00
    dc.b    $14, $A8, $64, $00
    dc.b    $31, $B2, $44, $00
    dc.b    $31, $B2, $B4, $00
    dc.b    $31, $B6, $74, $00
    dc.b    $31, $B6, $94, $00
    dc.b    $15, $BC, $14, $00
    dc.b    $14, $BE, $44, $00
    dc.b    -1,-1,-1,-1
QBlocks3: 
    dc.b    $31, $06, $34, $00    
    dc.b    $31, $0A, $54, $00
    dc.b    $31, $0E, $74, $00
    dc.b    $12, $24, $B4, $00
    dc.b    $36, $26, $6C, $00

    dc.b    $16, $2a, $04, $02                                           ; shop

    dc.b    $33, $2A, $44, $00
    dc.b    $31, $2A, $D4, $00
    dc.b    $9B, $34, $01, $00
    dc.b    $9C, $34, $F8, $00
    dc.b    $31, $38, $A4, $00
    dc.b    $31, $3C, $84, $00
    dc.b    $11, $40, $64, $00
    dc.b    $10, $42, $D4, $00
    dc.b    $31, $44, $44, $00
    dc.b    $31, $52, $44, $00
    dc.b    $31, $52, $B4, $00
    dc.b    $11, $54, $64, $00
    dc.b    $11, $54, $94, $00
    dc.b    $14, $5A, $44, $00
    dc.b    $14, $5A, $B4, $00
    dc.b    $16, $62, $4C, $00
    dc.b    $11, $6A, $44, $00
    dc.b    $11, $6A, $C4, $00
    dc.b    $31, $72, $54, $00
    dc.b    $31, $72, $A4, $00
    dc.b    $31, $74, $74, $00
    dc.b    $31, $74, $84, $00
    dc.b    $99, $80, $01, $00
    dc.b    $9A, $80, $F8, $00
    dc.b    $15, $86, $14, $00
    dc.b    $11, $88, $B4, $00
    dc.b    $31, $8A, $44, $00
    dc.b    $31, $8E, $44, $00
    dc.b    $13, $8E, $F4, $00
    dc.b    $10, $9C, $14, $00
    dc.b    $12, $9C, $E4, $00
    dc.b    $9B, $A4, $01, $00
    dc.b    $9C, $A4, $F8, $00
    dc.b    $16, $A6, $CC, $00
    dc.b    $34, $AA, $54, $00
    dc.b    $11, $B6, $44, $00
    dc.b    $11, $B6, $64, $00
    dc.b    -1,-1,-1,-1
QBlocks4:
    dc.b    $31, $06, $54, $00                                           ; ...
    dc.b    $31, $0A, $D4, $00
    dc.b    $31, $0C, $84, $00

    dc.b    $16, $16, $04, $02                                           ; shop

    dc.b    $31, $16, $74, $00
    dc.b    $11, $20, $84, $00
    dc.b    $11, $22, $74, $00
    dc.b    $11, $24, $84, $00
    dc.b    $97, $28, $01, $00
    dc.b    $98, $28, $F8, $00
    dc.b    $12, $2E, $C4, $00
    dc.b    $32, $30, $14, $00
    dc.b    $31, $36, $44, $00
    dc.b    $34, $38, $C4, $00
    dc.b    $16, $3A, $AC, $00
    dc.b    $13, $3E, $34, $00
    dc.b    $15, $3E, $E4, $00
    dc.b    $14, $54, $44, $00
    dc.b    $14, $54, $54, $00
    dc.b    $14, $54, $64, $00
    dc.b    $14, $54, $94, $00
    dc.b    $14, $54, $A4, $00
    dc.b    $14, $54, $B4, $00
    dc.b    $11, $6A, $74, $00
    dc.b    $11, $6A, $84, $00
    dc.b    $11, $6E, $74, $00
    dc.b    $11, $6E, $84, $00
    dc.b    $16, $72, $4C, $00
    dc.b    $11, $76, $74, $00
    dc.b    $11, $76, $84, $00
    dc.b    $34, $82, $C4, $00
    dc.b    $10, $84, $14, $00
    dc.b    $16, $86, $CC, $00
    dc.b    $34, $8A, $54, $00
    dc.b    $31, $90, $C4, $00

    dc.b    $16, $90, $f4, $01                                           ; gradius

    dc.b    $16, $92, $4C, $00
    dc.b    $31, $96, $74, $00
    dc.b    $13, $96, $D4, $00
    dc.b    $31, $9E, $44, $00
    dc.b    $12, $A2, $84, $00
    dc.b    $99, $B0, $01, $00
    dc.b    $9A, $B0, $F8, $00
    dc.b    $16, $B2, $4C, $00
    dc.b    $31, $B6, $24, $00
    dc.b    $31, $B6, $B4, $00
    dc.b    $31, $B8, $C4, $00
    dc.b    $16, $BA, $CC, $00
    dc.b    -1,-1,-1,-1
QBlocks5:
    dc.b    $34, $02, $64, $00                                           ; ...
    dc.b    $31, $0C, $D4, $00
    dc.b    $13, $0E, $44, $00
    dc.b    $31, $12, $24, $00
    dc.b    $31, $12, $94, $00
    dc.b    $12, $12, $E4, $00
    dc.b    $31, $18, $D4, $00
    dc.b    $31, $1E, $64, $00
    dc.b    $31, $22, $64, $00
    dc.b    $31, $26, $84, $00
    dc.b    $31, $2A, $84, $00
    dc.b    $13, $2E, $B4, $00
    
    dc.b    $16, $3a, $f4, $02                                           ; shop

    dc.b    $31, $3A, $64, $00
    dc.b    $11, $3A, $94, $00
    dc.b    $31, $40, $74, $00
    dc.b    $11, $40, $84, $00
    dc.b    $9B, $40, $01, $00
    dc.b    $9C, $40, $F8, $00
    dc.b    $12, $48, $74, $00
    dc.b    $31, $48, $84, $00
    dc.b    $11, $54, $24, $00
    dc.b    $11, $56, $C4, $00
    dc.b    $11, $58, $24, $00
    dc.b    $34, $5A, $74, $00
    dc.b    $11, $5A, $C4, $00
    dc.b    $34, $5C, $84, $00
    dc.b    $31, $6A, $84, $00
    dc.b    $9B, $70, $01, $00
    dc.b    $9C, $70, $F8, $00
    dc.b    $11, $72, $D4, $00
    dc.b    $11, $76, $24, $00
    dc.b    $12, $78, $14, $00
    dc.b    $34, $7E, $54, $00
    dc.b    $34, $82, $74, $00
    dc.b    $34, $88, $84, $00
    dc.b    $13, $8A, $D4, $00
    dc.b    $10, $8E, $14, $00
    dc.b    $12, $96, $14, $00
    dc.b    $99, $98, $01, $00
    dc.b    $9A, $98, $F8, $00
    dc.b    $31, $9C, $A4, $00
    dc.b    $31, $9E, $A4, $00
    dc.b    $31, $A0, $A4, $00
    dc.b    $14, $A6, $74, $00
    dc.b    $14, $A6, $84, $00
    dc.b    $13, $AE, $E4, $00
    dc.b    $12, $AE, $F4, $00
    dc.b    $31, $B6, $44, $00

    dc.b    $9B, $BC, $01, $00
    dc.b    $9C, $BC, $F8, $00
    dc.b    $34, $BC, $74, $00
    dc.b    $31, $BE, $84, $00
    dc.b    -1,-1,-1,-1


QBlocks6:
    dc.b    $11, $04, $84, $00                                           ; ...
    dc.b    $14, $08, $74, $00
    dc.b    $16, $0A, $4C, $00
    dc.b    $16, $0A, $AC, $00
    dc.b    $11, $10, $34, $00
    dc.b    $11, $12, $C4, $00
    dc.b    $97, $18, $01, $00
    dc.b    $98, $18, $F8, $00
    dc.b    $12, $1C, $A4, $00
    dc.b    $11, $22, $44, $00
    dc.b    $11, $26, $34, $00
    dc.b    $11, $28, $34, $00
    dc.b    $11, $32, $54, $00
    dc.b    $13, $34, $64, $00
    dc.b    $11, $36, $74, $00
    dc.b    $11, $38, $84, $00
    dc.b    $14, $3A, $94, $00
    dc.b    $16, $42, $4C, $00

    dc.b    $16, $48, $f4, $01                                           ; gradius

    dc.b    $12, $48, $E4, $00
    dc.b    $14, $50, $64, $00
    dc.b    $14, $50, $74, $00
    dc.b    $14, $50, $84, $00
    dc.b    $14, $50, $94, $00
    dc.b    $13, $54, $24, $00
    dc.b    $11, $5C, $74, $00
    dc.b    $11, $5C, $D4, $00
    dc.b    $16, $62, $CC, $00
    dc.b    $11, $68, $34, $00
    dc.b    $11, $68, $74, $00
    dc.b    $12, $6A, $94, $00
    dc.b    $16, $6E, $6C, $00

    dc.b    $16, $72, $04, $02                                           ; shop

    dc.b    $10, $72, $F4, $00
    dc.b    $11, $7E, $84, $00
    dc.b    $11, $82, $74, $00
    dc.b    $11, $84, $C4, $00
    dc.b    $11, $86, $84, $00
    dc.b    $11, $88, $C4, $00
    dc.b    $12, $8A, $74, $00
    dc.b    $14, $8E, $84, $00
    dc.b    $16, $96, $AC, $00
    dc.b    $13, $9A, $14, $00
    dc.b    $97, $9C, $01, $00
    dc.b    $98, $9C, $F8, $00
    dc.b    $16, $9E, $4C, $00
    dc.b    $14, $B0, $24, $00
    dc.b    $14, $B0, $34, $00
    dc.b    $16, $B6, $CC, $00
    dc.b    $14, $BE, $C4, $00
    dc.b    $11, $C0, $34, $00
    dc.b    $11, $C0, $94, $00
    dc.b    -1,-1,-1,-1

QBlocks7:
    dc.b    $11, $08, $84, $00                                           ; ...
    dc.b    $16, $0E, $4C, $00
    dc.b    $97, $14, $01, $00
    dc.b    $98, $14, $F8, $00
    dc.b    $16, $16, $8C, $00
    dc.b    $12, $1A, $24, $00
    dc.b    $11, $1C, $34, $00
    dc.b    $12, $24, $E4, $00
    dc.b    $16, $26, $AC, $00

    dc.b    $16, $2a, $2c, $02                                           ; shop

    dc.b    $16, $2A, $AC, $00
    dc.b    $14, $2E, $34, $00
    dc.b    $11, $34, $84, $00
    dc.b    $13, $36, $24, $00
    dc.b    $11, $36, $84, $00
    dc.b    $16, $3E, $CC, $00
    dc.b    $10, $42, $24, $00
    dc.b    $16, $46, $2C, $00
    dc.b    $11, $50, $94, $00
    dc.b    $14, $52, $94, $00
    dc.b    $9B, $54, $01, $00
    dc.b    $9C, $54, $F8, $00
    dc.b    $16, $56, $CC, $00
    dc.b    $16, $5A, $CC, $00
    dc.b    $16, $5E, $CC, $00
    dc.b    $31, $66, $A4, $00
    dc.b    $13, $68, $B4, $00
    dc.b    $16, $72, $4C, $00
    dc.b    $16, $76, $4C, $00
    dc.b    $9B, $84, $01, $00
    dc.b    $9C, $84, $F8, $00
    dc.b    $16, $86, $4C, $00
    dc.b    $16, $86, $AC, $00
    dc.b    $16, $8E, $6C, $00
    dc.b    $16, $8E, $8C, $00
    dc.b    $11, $96, $C4, $00
    dc.b    $12, $98, $44, $00
    dc.b    $16, $9E, $8C, $00
    dc.b    $16, $A6, $6C, $00
    dc.b    $16, $AA, $6C, $00
    dc.b    $11, $B0, $C4, $00
    dc.b    $97, $B0, $01, $00
    dc.b    $98, $B0, $F8, $00
    dc.b    $16, $B2, $AC, $00
    dc.b    $10, $B6, $64, $00
    dc.b    $31, $C0, $44, $00
    dc.b    -1,-1,-1,-1
QBlocks8:
    dc.b    $16, $04, $f4, $02                                           ; shop

    dc.b    $11, $08, $B4, $00                                           ; ...
    dc.b    $11, $0E, $44, $00
    dc.b    $11, $0E, $94, $00
    dc.b    $13, $18, $44, $00
    dc.b    $12, $18, $D4, $00
    dc.b    $14, $20, $B4, $00
    dc.b    $14, $24, $54, $00
    dc.b    $11, $2C, $84, $00
    dc.b    $14, $2E, $84, $00
    dc.b    $11, $36, $A4, $00
    dc.b    $11, $38, $54, $00
    dc.b    $11, $3E, $A4, $00
    dc.b    $12, $3E, $C4, $00
    dc.b    $11, $40, $54, $00
    dc.b    $11, $42, $A4, $00
    dc.b    $11, $44, $54, $00
    dc.b    $12, $50, $E4, $00
    dc.b    $14, $54, $84, $00
    dc.b    $11, $5A, $14, $00
    dc.b    $13, $5C, $14, $00
    dc.b    $11, $5C, $54, $00
    dc.b    $14, $5C, $A4, $00
    dc.b    $11, $5E, $A4, $00
    
    dc.b    $16, $6c, $04, $01                                           ; gradius

    dc.b    $14, $6E, $44, $00
    dc.b    $11, $70, $64, $00
    dc.b    $11, $70, $C4, $00
    dc.b    $14, $72, $74, $00
    dc.b    $12, $74, $74, $00
    dc.b    $11, $80, $74, $00
    dc.b    $12, $82, $24, $00
    dc.b    $11, $82, $74, $00
    dc.b    $13, $86, $C4, $00
    dc.b    $12, $90, $14, $00
    dc.b    $14, $98, $54, $00
    dc.b    $11, $98, $84, $00
    dc.b    $14, $9C, $54, $00
    dc.b    $11, $A0, $54, $00
    dc.b    $14, $A4, $A4, $00
    dc.b    $14, $AE, $94, $00
    dc.b    $14, $AE, $A4, $00
    dc.b    $11, $B4, $44, $00
    dc.b    $11, $B8, $A4, $00
    dc.b    $14, $BC, $64, $00
    dc.b    -1,-1,-1,-1
    even