;----------------------------------------------------------------------------
;
; shared routines
;
;----------------------------------------------------------------------------

    include    "common.asm"

;----------------------------------------------------------------------------
;
; set data pointers
;
; a0 = data chunk
; a1 = destination pointers
;
;----------------------------------------------------------------------------

SetDataPointers:
    moveq      #0,d0
    move.w     (a0)+,d7
    subq.w     #1,d7           ; count of data items
.loop
    move.w     (a0)+,d0        ; length of this chunk
    move.l     a0,(a1)+        ; store this pointer
    add.l      d0,a0           ; move to next items
    dbra       d7,.loop
    rts