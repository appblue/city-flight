;*********************************************************
;*        STANDART BY DR.DF0  OF  ... ATD ...            *
;*             4 BITPLANY  I  SPRITE'Y                   *
;*********************************************************
Planesize=40*256

Start:
	move.l	#begin,$80.w
	trap	#0
	move.l	#0,d0
	rts

;*********************************************************
;*                   INICJALIZACJA                       *
;*********************************************************
Begin:
	lea	$dff000,a6
	move.w	$1c(a6),wart1
	move.w	$1e(a6),wart2
	move.w	$02(a6),wart3
	or.w	#$c000,wart1
	or.w	#$8000,wart2
	or.w	#$8000,wart3
	move.w	#$7fff,$9a(a6)
	move.w	#$7fff,$9c(a6)
	move.w	#$7fff,$96(a6)
	Bsr.w	Wymiana
	Bsr.w	Init
	move.l	#Copper,$80(a6)
	tst.w	$88(a6)
	move.l	$6c.w,old
	move.l	#Inter,$6c.w
	move.w	#$c020,$9a(a6)
	move.w	#%1000001111000000,$96(a6)

	movem.l	d0-d7/a0-a6,-(sp)
	Bsr.w	MyRoutine
	movem.l	(sp)+,d0-d7/a0-a6
	
	jsr	wblit
	move.w	#$7fff,$9a(a6)
	move.w	#$7fff,$9c(a6)
	move.w	#$7fff,$96(a6)
	move.l	Old,$6c.w
	move.l	4.w,a6
	move.l	#name,a1
	clr.l	d0
	jsr	-408(a6)
	lea	$dff000,a6
	move.l	d0,a5
	move.l	38(a5),$80(a6)
	tst.w	$88(a6)
	move.w	wart1,$9a(a6)
	move.w	wart2,$9c(a6)
	move.w	wart3,$96(a6)
	rte

;*********************************************************
;*                     PRZERWANIA                        *
;*********************************************************
;	x,y,c
oneChr: macro
	move.b	#\3,d0
	lea	Zeros+(\1)*2+(\2)*64*4,a0
	lea	yAddSizes+2*(\2+8),a2
	jsr	putCh
	endm

Init:

	oneChr	0*8,50,'A'
	oneChr	1*8,50,'m'
	oneChr	2*8,50,'i'
	oneChr	3*8,50,'g'
	oneChr	4*8,50,'a'
	oneChr	5*8,50,' '
	oneChr	6*8,50,'i'
	oneChr	7*8,50,'s'

	oneChr	0*8,28,'A'
	oneChr	1*8,28,'m'
	oneChr	2*8,28,'i'
	oneChr	3*8,28,'g'
	oneChr	4*8,28,'a'
	oneChr	5*8,28,' '
	oneChr	6*8,28,'i'
	oneChr	7*8,28,'s'

	oneChr	19+0*8,20,'T'
	oneChr	19+1*8,20,'H'
	oneChr	19+2*8,20,'E'

	oneChr	16+0*8,12,'b'
	oneChr	16+1*8,12,'e'
	oneChr	16+2*8,12,'S'
	oneChr	16+3*8,12,'T'


	rts



;d0 ->char,a0 -> where
;uses a1,d1
putCh:	ext.w	d0
	add.w	d0,d0
	add.w	d0,d0
	add.w	d0,d0
	lea	Font-32*8,a1
	add.w	d0,a1
	moveq	#7,d7
.l1:	move.b	(a1)+,d0
	move.l	a2,a3
	moveq	#7,d6
.l2:	move.w	-(a3),d1
	add.b	d0,d0
	bcs	.l3
	moveq	#0,d1
.l3:	move.w	d1,(a0)
	add.w	#64*2,a0
	move.w	d1,(a0)
	sub.w	#64*2-2,a0
	dbf	d6,.l2

	add.w	#-64*4-16,a0

	dbf	d7,.l1
	rts



Inter:
	movem.l	d0-d7/a0-a6,-(sp)
	lea	$dff000,a6
	and.w	#$20,$1e(a6)
	beq.s	out
	move.w	#$20,$9c(a6)

Out:
	movem.l	(sp)+,d0-d7/a0-a6
	rte

;*********************************************************
;*                      PETLA GLOWNA                     *
;*********************************************************
MyRoutine:
.wait:
	stop	#$2000

	jsr	Wymiana
	jsr	ClsBlit
	jsr	doMy
	
	move.w	#$f00,$dff180


	btst	#6,$bfe001
	bne.w	.wait
	rts

;*********************************************************
;*                    WYMIANA EKRANOW                    *
;*********************************************************
Wymiana:
	move.l	ClsAdr,d0
	move.l	PlaneAdre,d1
	move.l	DrawAdr,d2
	move.l	d1,ClsAdr
	move.l	d2,PlaneAdre
	move.l	d0,DrawAdr
;	move.l	PlaneAdre,ClsAdr
;	move.l	DrawAdr,PlaneAdre
;	move.l	d0,DrawAdr
	lea	Planes,a0
	moveq	#3,d1
Loop:
	move.w	d0,6(a0)
	swap	d0
	move.w	d0,2(a0)
	swap	d0
	add.l	#8,a0
	add.l	#40,d0
;	dbf	d1,loop
	rts


przesZeros:
	dc.l	2

frameNr:
	dc.w	0

doMy:
	move.b	frameNr,d0
	jsr	printNr
	move.b	frameNr,d0
	add.b	#1,d0
	move.b	d0,frameNr
	sub.b	#1,d0
	bne	.ddd
	move.l	#zaslanianie,(zaslAdr)
.ddd

;	move.l	#Font+('A'-32)*8,a0
;	move.l	DrawAdr,a1
;	move.w	#2-1,d0
;.l1:	move.w	#8-1,d1
;.l2:	move.b	(a0)+,d2
;	move.b	d2,(a1)
;	add.w	#40,a1
;	dbf	d1,.l2
;	sub.w	#40*8,a1
;	add.w	#1,a1
;	dbf	d0,.l1
;
;	move.l	#Font+('A'-32)*8,a0
;	move.l	DrawAdr,a1
;	add.w	#40*(256-8),a1
;	move.w	#2-1,d0
;.l3:	move.w	#8-1,d1
;.l4:	move.b	(a0)+,d2
;	move.b	d2,(a1)
;	add.w	#40,a1
;	dbf	d1,.l4
;	sub.w	#40*8,a1
;	add.w	#1,a1
;	dbf	d0,.l3
;

ileOp = 12

doMy2:
	move.w	whereX,d0
	move.w	d0,whereX_cp

	move.w	#63-ileOp,d0
	lea	AddrsSins,a4
	lea	zeros,a3
	add.w	przesZeros,a3
	move.l	zaslAdr,a5
;	move.l	#zaslanianie,a5
.l1:
	move.l	(a4)+,a0		;sinTab
	move.l	drawAdr,a1
	add.l	(a4)+,a1
	move.l	(a4)+,a2		;genBits
	move.w	d0,-(sp)

	add.w	WhereX,a0
	jsr	(a2)
	move.w	whereX,d0
	add.w	#6,d0
	and.w	#511,d0
	move.w	d0,whereX
	move.w	(sp)+,d0
	add.w	#64*2,a3
	dbf	d0,.l1

	rept	ileOp
	add.l	#8,a5
	endr

	move.l	a5,zaslAdr

	move.w	whereX_cp,d0
	add.w	#-4,d0
	and.w	#511,d0
	move	d0,whereX

	move.w	przesZeros,d0
	addq.w	#2,d0
	and.w	#2*64-1,d0
	move.w	d0,przesZeros

	rts

ttt
	bcc	.d1
	bset	#0,123(a0,d0.w)
.d1:

zaslAdr:dc.l	0
zeros:	blk.w	64*64*2*2,0

	include "sintabs.s"


whereX:	dc.w	0
whereX_cp:	dc.w	0

	include "lines_bsets.s"

printNr:
	move.w	d0,-(sp)
	lsr.b	#4,d0
	and.b	#15,d0
	ext.w	d0
	lea	tabDig,a0
	move.b	(a0,d0.w),d0
	move.l	DrawAdr,a0
	add.l	#40*240,a0
	lea	Font-32*8,a1
	ext.w	d0
	add.w	d0,d0
	add.w	d0,d0
	add.w	d0,d0
	add.w	d0,a1
	rept	8
	move.b	(a1)+,(a0)
	add.w	#40,a0
	endr
	move.w	(sp)+,d0
	and.b	#15,d0
	ext.w	d0
	lea	tabDig,a0
	move.b	(a0,d0.w),d0
	move.l	DrawAdr,a0
	add.l	#40*240+1,a0
	lea	Font-32*8,a1
	ext.w	d0
	add.w	d0,d0
	add.w	d0,d0
	add.w	d0,d0
	add.w	d0,a1
	rept	8
	move.b	(a1)+,(a0)
	add.w	#40,a0
	endr
	rts

tabDig:
	dc.b	"0123456789ABCDEF"

;*********************************************************
;*               CZEKAJ AZ BLITER GOTOWY                 *
;*********************************************************
Wblit:
	btst	#6,2(a6)
	bne.s	wblit
	rts

ClsBlit:
	bsr.w	wblit
	move.l	ClsAdr,$dff054
	move.l	#-1,$dff044
	move.l	#$01000000,$dff040
	move.w	#0,$dff066
	move.w	#128*40,$dff058 
	rts
	
	
Cls:
	move.l	ClsAdr(pc),a0
	moveq	#0,d0
	moveq	#0,d1
	moveq	#0,d2
	moveq	#0,d3
	moveq	#0,d4
	moveq	#0,d5
	moveq	#0,d6
	moveq	#0,d7

	move.w	#32,d7
.loop:	rept 10
	movem.l	d0-d3,(a0)
	movem.l	d0-d6,12(a0)
	lea	40(a0),a0
	endr
	dbf	d7,.loop
	rts

;*********************************************************
;*                    ZMIENNE I STALE                    *
;*********************************************************

Name:		dc.b	'graphics.library',0
	even
Wart1:		dc.w	0
Wart2:		dc.w	0
Wart3:		dc.w	0
Old:		dc.l	0
PlaneAdre:	dc.l	Screen1
ClsAdr:		dc.l	Screen1+PlaneSize
DrawAdr:	dc.l	Screen1+2*PlaneSize

;*Spectrum font 8x8
;* chars 32-127
Font:	
	dc.b	$00,$00,$00,$00,$00,$00,$00,$00
	dc.b	$00,$10,$10,$10,$10,$00,$10,$00
	dc.b	$00,$24,$24,$00,$00,$00,$00,$00
	dc.b	$00,$24,$7e,$24,$24,$7e,$24,$00
	dc.b	$00,$08,$3e,$28,$3e,$0a,$3e,$08
	dc.b	$00,$62,$64,$08,$10,$26,$46,$00
	dc.b	$00,$10,$28,$10,$2a,$44,$3a,$00
	dc.b	$00,$08,$10,$00,$00,$00,$00,$00
	dc.b	$04,$08,$08,$08,$08,$08,$04,$00
	dc.b	$00,$20,$10,$10,$10,$10,$20,$00
	dc.b	$00,$00,$14,$08,$3e,$08,$14,$00
	dc.b	$00,$00,$08,$08,$3e,$08,$08,$00
	dc.b	$00,$00,$00,$00,$00,$08,$08,$10
	dc.b	$00,$00,$00,$00,$3e,$00,$00,$00
	dc.b	$00,$00,$00,$00,$00,$18,$18,$00
	dc.b	$00,$00,$02,$04,$08,$10,$20,$00
	dc.b	$00,$3c,$46,$4a,$52,$62,$3c,$00
	dc.b	$00,$18,$28,$08,$08,$08,$3e,$00
	dc.b	$00,$3c,$42,$02,$3c,$40,$7e,$00
	dc.b	$00,$3c,$42,$0c,$02,$42,$3c,$00
	dc.b	$00,$08,$18,$28,$48,$7e,$08,$00
	dc.b	$00,$7e,$40,$7c,$02,$42,$3c,$00
	dc.b	$00,$3c,$40,$7c,$42,$42,$3c,$00
	dc.b	$00,$7e,$02,$04,$08,$10,$10,$00
	dc.b	$00,$3c,$42,$3c,$42,$42,$3c,$00
	dc.b	$00,$3c,$42,$42,$3e,$02,$3c,$00
	dc.b	$00,$00,$10,$00,$00,$00,$10,$00
	dc.b	$00,$00,$10,$00,$00,$10,$10,$20
	dc.b	$00,$00,$04,$08,$10,$08,$04,$00
	dc.b	$00,$00,$00,$3e,$00,$3e,$00,$00
	dc.b	$00,$00,$10,$08,$04,$08,$10,$00
	dc.b	$00,$3c,$42,$04,$08,$00,$08,$00
	dc.b	$00,$3c,$4a,$56,$5e,$40,$3c,$00
	dc.b	$00,$3c,$42,$42,$7e,$42,$42,$00
	dc.b	$00,$7c,$42,$7c,$42,$42,$7c,$00
	dc.b	$00,$3c,$42,$40,$40,$42,$3c,$00
	dc.b	$00,$78,$44,$42,$42,$44,$78,$00
	dc.b	$00,$7e,$40,$7c,$40,$40,$7e,$00
	dc.b	$00,$7e,$40,$7c,$40,$40,$40,$00
	dc.b	$00,$3c,$42,$40,$4e,$42,$3c,$00
	dc.b	$00,$42,$42,$7e,$42,$42,$42,$00
	dc.b	$00,$3e,$08,$08,$08,$08,$3e,$00
	dc.b	$00,$02,$02,$02,$42,$42,$3c,$00
	dc.b	$00,$44,$48,$70,$48,$44,$42,$00
	dc.b	$00,$40,$40,$40,$40,$40,$7e,$00
	dc.b	$00,$42,$66,$5a,$42,$42,$42,$00
	dc.b	$00,$42,$62,$52,$4a,$46,$42,$00
	dc.b	$00,$3c,$42,$42,$42,$42,$3c,$00
	dc.b	$00,$7c,$42,$42,$7c,$40,$40,$00
	dc.b	$00,$3c,$42,$42,$52,$4a,$3c,$00
	dc.b	$00,$7c,$42,$42,$7c,$44,$42,$00
	dc.b	$00,$3c,$40,$3c,$02,$42,$3c,$00
	dc.b	$00,$fe,$10,$10,$10,$10,$10,$00
	dc.b	$00,$42,$42,$42,$42,$42,$3c,$00
	dc.b	$00,$42,$42,$42,$42,$24,$18,$00
	dc.b	$00,$42,$42,$42,$42,$5a,$24,$00
	dc.b	$00,$42,$24,$18,$18,$24,$42,$00
	dc.b	$00,$82,$44,$28,$10,$10,$10,$00
	dc.b	$00,$7e,$04,$08,$10,$20,$7e,$00
	dc.b	$00,$0e,$08,$08,$08,$08,$0e,$00
	dc.b	$00,$00,$40,$20,$10,$08,$04,$00
	dc.b	$00,$70,$10,$10,$10,$10,$70,$00
	dc.b	$00,$10,$38,$54,$10,$10,$10,$00
	dc.b	$00,$00,$00,$00,$00,$00,$00,$ff
	dc.b	$00,$1c,$22,$78,$20,$20,$7e,$00
	dc.b	$00,$00,$38,$04,$3c,$44,$3c,$00
	dc.b	$00,$20,$20,$3c,$22,$22,$3c,$00
	dc.b	$00,$00,$1c,$20,$20,$20,$1c,$00
	dc.b	$00,$04,$04,$3c,$44,$44,$3c,$00
	dc.b	$00,$00,$38,$44,$78,$40,$3c,$00
	dc.b	$00,$0c,$10,$18,$10,$10,$10,$00
	dc.b	$00,$00,$3c,$44,$44,$3c,$04,$38
	dc.b	$00,$40,$40,$78,$44,$44,$44,$00
	dc.b	$00,$10,$00,$30,$10,$10,$38,$00
	dc.b	$00,$04,$00,$04,$04,$04,$24,$18
	dc.b	$00,$20,$28,$30,$30,$28,$24,$00
	dc.b	$00,$10,$10,$10,$10,$10,$0c,$00
	dc.b	$00,$00,$68,$54,$54,$54,$54,$00
	dc.b	$00,$00,$78,$44,$44,$44,$44,$00
	dc.b	$00,$00,$38,$44,$44,$44,$38,$00
	dc.b	$00,$00,$78,$44,$44,$78,$40,$40
	dc.b	$00,$00,$3c,$44,$44,$3c,$04,$06
	dc.b	$00,$00,$1c,$20,$20,$20,$20,$00
	dc.b	$00,$00,$38,$40,$38,$04,$78,$00
	dc.b	$00,$10,$38,$10,$10,$10,$0c,$00
	dc.b	$00,$00,$44,$44,$44,$44,$38,$00
	dc.b	$00,$00,$44,$44,$28,$28,$10,$00
	dc.b	$00,$00,$44,$54,$54,$54,$28,$00
	dc.b	$00,$00,$44,$28,$10,$28,$44,$00
	dc.b	$00,$00,$44,$44,$44,$3c,$04,$38
	dc.b	$00,$00,$7c,$08,$10,$20,$7c,$00
	dc.b	$00,$0e,$08,$30,$08,$08,$0e,$00
	dc.b	$00,$08,$08,$08,$08,$08,$08,$00
	dc.b	$00,$70,$10,$0c,$10,$10,$70,$00
	dc.b	$00,$14,$28,$00,$00,$00,$00,$00 
;*********************************************************
;*                    SINUS TABLES                       *
;*********************************************************
zaslanianie:
	incbin	"zasl.bin"

zaslanianieF:
	blk.b	64*64/8,-1

SinTab:
	incbin	"sintabs.bin"

CosTab = SinTab+64*2
	DC.W	$0028,$0050,$00A0,$00C8,$0118,$0168,$0190,$01E0,$0208,$0258
	DC.W	$0280,$02D0,$02F8,$0348,$0370,$03C0,$03E8,$0438,$0460,$0488
	DC.W	$04D8,$0500,$0550,$0578,$05A0,$05C8,$0618,$0640,$0668,$0690
	DC.W	$06E0,$0708,$0730,$0758,$0780,$07A8,$07D0,$07F8,$0820,$0848
	DC.W	$0870,$0870,$0898,$08C0,$08E8,$0910,$0910,$0938,$0938,$0960
	DC.W	$0988,$0988,$0988,$09B0,$09B0,$09D8,$09D8,$09D8,$09D8,$0A00
	DC.W	$0A00,$0A00,$0A00,$0A00,$0A00,$0A00,$0A00,$0A00,$0A00,$09D8
	DC.W	$09D8,$09D8,$09D8,$09B0,$09B0,$0988,$0988,$0988,$0960,$0938
	DC.W	$0938,$0910,$0910,$08E8,$08C0,$0898,$0870,$0870,$0848,$0820
	DC.W	$07F8,$07D0,$07A8,$0780,$0758,$0730,$0708,$06E0,$0690,$0668
	DC.W	$0640,$0618,$05C8,$05A0,$0578,$0550,$0500,$04D8,$0488,$0460
	DC.W	$0438,$03E8,$03C0,$0370,$0348,$02F8,$02D0,$0280,$0258,$0208
	DC.W	$01E0,$0190,$0168,$0118,$00C8,$00A0,$0050,$0028,$FFD8,$FFB0
	DC.W	$FF60,$FF38,$FEE8,$FE98,$FE70,$FE20,$FDF8,$FDA8,$FD80,$FD30
	DC.W	$FD08,$FCB8,$FC90,$FC40,$FC18,$FBC8,$FBA0,$FB78,$FB28,$FB00
	DC.W	$FAB0,$FA88,$FA60,$FA38,$F9E8,$F9C0,$F998,$F970,$F920,$F8F8
	DC.W	$F8D0,$F8A8,$F880,$F858,$F830,$F808,$F7E0,$F7B8,$F790,$F790
	DC.W	$F768,$F740,$F718,$F6F0,$F6F0,$F6C8,$F6C8,$F6A0,$F678,$F678
	DC.W	$F678,$F650,$F650,$F628,$F628,$F628,$F628,$F600,$F600,$F600
	DC.W	$F600,$F600,$F600,$F600,$F600,$F600,$F600,$F628,$F628,$F628
	DC.W	$F628,$F650,$F650,$F678,$F678,$F678,$F6A0,$F6C8,$F6C8,$F6F0
	DC.W	$F6F0,$F718,$F740,$F768,$F790,$F790,$F7B8,$F7E0,$F808,$F830
	DC.W	$F858,$F880,$F8A8,$F8D0,$F8F8,$F920,$F970,$F998,$F9C0,$F9E8
	DC.W	$FA38,$FA60,$FA88,$FAB0,$FB00,$FB28,$FB78,$FBA0,$FBC8,$FC18
	DC.W	$FC40,$FC90,$FCB8,$FD08,$FD30,$FD80,$FDA8,$FDF8,$FE20,$FE70
	DC.W	$FE98,$FEE8,$FF38,$FF60,$FFB0,$FFD8

	DC.W	$0028,$0050,$00A0,$00C8,$0118,$0168,$0190,$01E0,$0208,$0258
	DC.W	$0280,$02D0,$02F8,$0348,$0370,$03C0,$03E8,$0438,$0460,$0488
	DC.W	$04D8,$0500,$0550,$0578,$05A0,$05C8,$0618,$0640,$0668,$0690
	DC.W	$06E0,$0708,$0730,$0758,$0780,$07A8,$07D0,$07F8,$0820,$0848
	DC.W	$0870,$0870,$0898,$08C0,$08E8,$0910,$0910,$0938,$0938,$0960
	DC.W	$0988,$0988,$0988,$09B0,$09B0,$09D8,$09D8,$09D8,$09D8,$0A00
	DC.W	$0A00,$0A00,$0A00,$0A00,$0A00,$0A00,$0A00,$0A00,$0A00,$09D8
	DC.W	$09D8,$09D8,$09D8,$09B0,$09B0,$0988,$0988,$0988,$0960,$0938
	DC.W	$0938,$0910,$0910,$08E8,$08C0,$0898,$0870,$0870,$0848,$0820
	DC.W	$07F8,$07D0,$07A8,$0780,$0758,$0730,$0708,$06E0,$0690,$0668
	DC.W	$0640,$0618,$05C8,$05A0,$0578,$0550,$0500,$04D8,$0488,$0460
	DC.W	$0438,$03E8,$03C0,$0370,$0348,$02F8,$02D0,$0280,$0258,$0208
	DC.W	$01E0,$0190,$0168,$0118,$00C8,$00A0,$0050,$0028,$FFD8,$FFB0
	DC.W	$FF60,$FF38,$FEE8,$FE98,$FE70,$FE20,$FDF8,$FDA8,$FD80,$FD30
	DC.W	$FD08,$FCB8,$FC90,$FC40,$FC18,$FBC8,$FBA0,$FB78,$FB28,$FB00
	DC.W	$FAB0,$FA88,$FA60,$FA38,$F9E8,$F9C0,$F998,$F970,$F920,$F8F8
	DC.W	$F8D0,$F8A8,$F880,$F858,$F830,$F808,$F7E0,$F7B8,$F790,$F790
	DC.W	$F768,$F740,$F718,$F6F0,$F6F0,$F6C8,$F6C8,$F6A0,$F678,$F678
	DC.W	$F678,$F650,$F650,$F628,$F628,$F628,$F628,$F600,$F600,$F600
	DC.W	$F600,$F600,$F600,$F600,$F600,$F600,$F600,$F628,$F628,$F628
	DC.W	$F628,$F650,$F650,$F678,$F678,$F678,$F6A0,$F6C8,$F6C8,$F6F0
	DC.W	$F6F0,$F718,$F740,$F768,$F790,$F790,$F7B8,$F7E0,$F808,$F830
	DC.W	$F858,$F880,$F8A8,$F8D0,$F8F8,$F920,$F970,$F998,$F9C0,$F9E8
	DC.W	$FA38,$FA60,$FA88,$FAB0,$FB00,$FB28,$FB78,$FBA0,$FBC8,$FC18
	DC.W	$FC40,$FC90,$FCB8,$FD08,$FD30,$FD80,$FDA8,$FDF8,$FE20,$FE70
	DC.W	$FE98,$FEE8,$FF38,$FF60,$FFB0,$FFD8

;*********************************************************
;*                    PROGRAM COPPERA                    *
;*********************************************************
Copper:
Planes:	dc.w	$e0,0,$e2,0,$e4,0,$e6,0
	dc.w	$e8,0,$ea,0,$ec,0,$ee,0

	dc.w	$0180,$0000,$0182,$0fff,$0184,$000c,$0186,$0c00
	dc.w	$0188,$0400,$018a,$0800,$018c,$0008,$018e,$0008
	dc.w	$0190,$0fff,$0192,$0fff,$0194,$0fff,$0196,$0fff
	dc.w	$0198,$0fff,$019a,$0fff,$019c,$0fff,$019e,$0fff

	dc.w	$ffe1,$fffe
	dc.w	$3401,$fffe
	dc.w	$8e,$2081,$90,$20c1,$92,$38,$94,$d0
	dc.w	$100,%0001001000000000,$102,0,$104,0
	dc.w	$108,0,$10a,0
	
	dc.w	$ffff,$fffe

;*********************************************************
;*                        EKRAN                          *
;*********************************************************
Screen1:
	blk.b	3*Planesize,0

	include "lines_bsets_4bit.s"

end:
