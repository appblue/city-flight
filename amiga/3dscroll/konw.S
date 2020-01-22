copyOneLine:	macro
	lea	oneline(pc),a2
	move.l	(a0)+,d1
	move.l	(a0)+,d2
	move.l	d1,(a2)+
	move.l	d2,(a2)+
	sub.w	#8,a0
	endm


start:
	lea	zasl+(64/8)*256*64-(64/8),a0
	lea	zasl+64*(64/4)*2*256-(64/4)*2,a1
	lea	przesTab,a3
	move.w	#256-1,d7
	moveq	#0,d0
.lf:
	move.w	#64-1,d6
.ll:
	moveq	#0,d4			;prev_val
	copyOneLine
	bsr.w	transformOneLine1
;	bsr.w	transformOneLine2
	
	suba.w	#64/8,a0
	suba.w	#(64/4)*2,a1

	dbra	d6,.ll

	dbra	d7,.lf
	rts


transformOneLine1:
	move.l	a0,-(a7)
	move.l	a1,-(a7)
	moveq	#0,d5
	lea	oneLine(pc),a2

	rept	8

	move.b	(a2),d0
	lsr.b	#4,d0
	move.w	d0,d1
	move.b	(a3,d1.w),d1
	add.w	d5,d1
	sub.w	d1,d4		;delta z prev_val
	neg.w	d4
	move.w	d4,(a1)+
	move.w	d1,d4
	add.w	#182+16,d5

	move.b	(a2)+,d0
	and.b	#$0f,d0
	move.w	d0,d1
	move.b	(a3,d1.w),d1
	add.w	d5,d1
	sub.w	d1,d4
	neg.w	d4
	move.w	d4,(a1)+
	move.w	d1,d4
	add.w	#182+16,d5
	endr

	move.l	(a7)+,a1
	move.l	(a7)+,a0
	rts

oneline:
	blk.b	64/8

zasl:
	incbin	zasl1.bin
	blk.b	2*64*64*256/4-64*64*256/8
endzasl:

zasl3:
	incbin	zasl3.bin

przesTab:
	dc.b	182,176,74,170,136,102,68,164
	dc.b	 12, 34, 6,  0,130, 96,62,158
