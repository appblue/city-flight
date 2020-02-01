;*********************************************************
;*        STANDART BY DR.DF0  OF  ... ATD ...            *
;*             4 BITPLANY  I  SPRITE'Y                   *
;*********************************************************
Planesize=40*256

MAX_PTS	= 15000

Wblit:	macro
	btst	#6,2(a6)
	bne.s	*-6
	endm



Start:
	move.l	#begin,$80.w
	trap	#0
	moveq	#0,d0
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

;	jsr	mt_init

	move.l	#Copper,$80(a6)
	tst.w	$88(a6)
	move.l	$6c.w,old
	move.l	#Inter,$6c.w
	move.w	#$c020,$9a(a6)
	move.w	#%1000001111000000,$96(a6)

	movem.l	d0-d7/a0-a6,-(sp)
	Bsr.w	MyRoutine
	movem.l	(sp)+,d0-d7/a0-a6

	wblit
;	jsr	mt_end
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

addp:	macro
	add.b	\1,\1
	bcc.s	.n\@
	move.w	d0,(a0)+
	move.w	d1,(a0)+
	addq.w	#1,d5
.n\@:	addq.w	#1,d0
	endm

init:
	lea	pts_src,a0
	lea	data_src,a1
	lea	num_pts_src,a2
	bsr	init_plane2XY1
	lea	pts_dst,a0
	lea	data_dst,a1
	lea	num_pts_dst,a2
	bsr	init_plane2XY2


	lea	pts_src,a0
	lea	pts_dst,a1
	move.w	num_pts_src,d7
	subq.w	#1,d7
	bsr.w	init_code


	move.w	#40,d0		;init
	moveq	#1,d1
	jsr	c_l1
	jsr	c_l1
	jsr	c_l1
	jsr	c_l1
	jsr	c_l1
;	jsr	c_l1



	rts

opcode_or:	or.w	#$0800,123(a0)
		bset	#3,123(a0)
opcode_rts:	rts
opcode_addd0:	add.w	d0,$12345678
opcode_subd0:	sub.w	d0,$12345678

opcode_ror:	ror.w	#1,$12345678
opcode_rol:	rol.w	#1,$12345678
opcode_bpl:	bcc.s	.d
		add.w	d1,$12345678
.d:
opcode_addd1:	add.w	d1,$12345678
opcode_subd1:	sub.w	d1,$12345678

;**************************
tst_y:	macro
	btst	#\1,d1
	beq.s	.a\@
	move.l	\2*4(a3),a4
	move.w	d2,(a4)+
	move.l	a2,(a4)+
	move.l	a4,\2*4(a3)
	
.a\@:
	endm
tst_x:	macro
	btst	#\1,d0
	beq.s	.a\@
	move.l	\2*4(a3),a4
	move.w	d2,(a4)+
	subq.l	#2,a2
	move.l	a2,(a4)+
	addq.l	#2,a2
	move.w	opcode_bpl(pc),(a4)+
	move.w	d3,(a4)+
	move.l	a2,(a4)+
	move.l	a4,\2*4(a3)
.a\@:
	endm


put_do:	macro
	move.l	\1(a3),a0
	move.w	d0,(a0)
	endm
;**************************
;a0 = source pts
;a1 = dst pts
;d7 = num_pts
init_code:
	lea	code,a2		;a2 = code to be generated
	lea	code_addrs_gen,a3
	lea	.tab_pom(pc),a5
.l:	move.w	(a0),d0
	move.w	2(a0),d1
	mulu	#40,d1
	move.w	d0,d2
	asr.w	#4,d2
	add.w	d2,d1
	add.w	d2,d1
	and.w	#15,d0
	add.w	d0,d0
	move.w	opcode_or(pc),(a2)+
	move.w	(a5,d0.w),(a2)+			;$8000 or... or $0001
	move.w	d1,(a2)
	move.w	(a1)+,d0
	move.w	(a1)+,d1
	sub.w	(a0)+,d0	;dx
	move.w	opcode_rol(pc),d2
	move.w	opcode_subd1(pc),d3
	bpl.s	.dalx
	neg.w	d0
	move.w	opcode_ror(pc),d2
	move.w	opcode_addd1(pc),d3
.dalx:
	tst_x	0,7
	tst_x	1,6
	tst_x	2,5
	tst_x	3,4
	tst_x	4,3
	tst_x	5,2
	tst_x	6,1
	tst_x	7,0



	move.w	opcode_addd0(pc),d2
	sub.w	(a0)+,d1	;dy
	bpl.s	.daly
	neg.w	d1
	move.w	opcode_subd0(pc),d2
.daly:

	tst_y	0,7
	tst_y	1,6
	tst_y	2,5
	tst_y	3,4
	tst_y	4,3
	tst_y	5,2
	tst_y	6,1
	tst_y	7,0

	addq.l	#2,a2
	dbf	d7,.l

	move.w	opcode_rts(pc),d0
	move.w	d0,(a2)
	put_do	4*0	;rts at the end of each list
	put_do	4*1
	put_do	4*2
	put_do	4*3
	put_do	4*4
	put_do	4*5
	put_do	4*6
	put_do	4*7
	rts
.tab_pom:
	dc.w	$8000,$4000,$2000,$1000,$800,$400,$200,$100
	dc.w	$80,$40,$20,$10,$8,$4,$2,$1


init_plane2XY1:
	move.w	#10,(a0)+
	move.w	#100,(a0)+
	move.w	#1,(a2)
	rts
	move.w	#100-1,d7
	move.w	#10,d0
	move.w	#100,d1
.l:	move.w	d0,(a0)+
	move.w	d1,(a0)+
	addq.w	#1,d0
	add.w	#1,(a2)
	dbf	d7,.l
	rts
init_plane2XY2:
	move.w	#200,(a0)+
	move.w	#100,(a0)+
	move.w	#1,(a2)
	rts
	move.w	#100-1,d7
	move.w	#10,d0
	move.w	#150,d1
.l:	move.w	d0,(a0)+
	move.w	d1,(a0)+
	subq.w	#1,d1
	addq.w	#1,d0
	add.w	#1,(a2)
	dbf	d7,.l
	rts
;**************************
;**************************
;a0 = filled with x,y from
;a1 = bplane addr
;a2 = num_pts
init_plane2XY:

	moveq	#0,d5		;Num_pts
;	lea	pts,a0
;	lea	data,a1
	move.w	#255-1,d7
	moveq	#0,d1		;Y
.ly:	move.w	#40/4-1,d6
	moveq	#0,d0		;X
.lx:
	move.l	(a1)+,d2
	beq.w	.skip4bytes

	;some nonzero :-)

	subq.l	#4,a1

	move.b	(a1)+,d2
	beq.w	.skip0
	rept	8
	addp	d2
	endr
	subq.w	#8,d0
.skip0:	addq.w	#8,d0
	move.b	(a1)+,d2
	beq.w	.skip1
	rept	8
	addp	d2
	endr
	subq.w	#8,d0
.skip1:	addq.w	#8,d0
	move.b	(a1)+,d2
	beq.w	.skip2
	rept	8
	addp	d2
	endr
	subq.w	#8,d0
.skip2:	addq.w	#8,d0
	move.b	(a1)+,d2
	beq.w	.skip3
	rept	8
	addp	d2
	endr
	subq.w	#8,d0
.skip3:	addq.w	#8,d0


	cmp.w	#MAX_PTS,d5
	bpl.s	.exit


	bra.s	.cont


.skip4bytes:
	add.w	#32,d0

.cont:
	dbf	d6,.lx
	addq.w	#1,d1		;Y = Y+1
	dbf	d7,.ly
.exit:	move.w	d5,(a2)
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
	lea	$dff000,a6
	stop	#$2000
;	jsr	mt_music
	jsr	ClsBlit
	jsr	doMy
	jsr	Wymiana

	move.w	#$268,$dff180

	btst	#6,$bfe001
	bne.w	.wait
	rts

;*********************************************************
;*                    WYMIANA EKRANOW                    *
;*********************************************************
PlaneAdre:	dc.l	Screen1
ClsAdr:		dc.l	Screen1+PlaneSize
DrawAdr:	dc.l	Screen1+2*PlaneSize

ClsBlit:
	lea	$dff000,a6
	wblit

	move.l	ClsAdr,$054(a6)
	move.l	#-1,$044(a6)
	move.l	#$01000000,$040(a6)
	move.w	#0,$066(a6)
	move.w	#(256)*20,$058(a6) 

	rts
	
Wymiana:
	lea	PlaneAdre(pc),a1
	move.l	(a1)+,d1
	move.l	(a1)+,d2
	move.l	(a1)+,d3
	move.l	d2,-(a1)
	move.l	d1,-(a1)
	move.l	d3,-(a1)

	lea	Planes+2,a0
	move.w	d3,4(a0)
	swap	d3
	move.w	d3,(a0)

	rts


frame_nr:
	dc.w	0

doMy:
	move.l	DrawAdr,a0
	jsr	code

	move.w	frame_nr(pc),d0
	addq.b	#1,d0
	bcs.w	.dal
	move.w	d0,frame_nr
	lea	tab_codes,a0
	add.w	d0,d0
	add.w	d0,d0
	move.l	(a0,d0),a0

	move.w	#40,d0		;init
	moveq	#1,d1

;	lea	c_l1,a0
;	jsr	(a0)

	rts
.dal:
	rts




	move.l	drawadr(pc),a0

	move.w	num_pts_src,d7
	lea	pts_src,a1

.lo:
	move.w	(a1)+,d0
	move.w	(a1)+,d1
;	bsr.w	plot
	dbf	d7,.lo

	move.w	num_pts_dst,d7
	lea	pts_dst,a1
	move.l	drawadr(pc),a0

.lo2:
	move.w	(a1)+,d0
	move.w	(a1)+,d1
;	bsr.w	plot
	dbf	d7,.lo2

	rts

	move.w	#5000,d7
.l:
	nop
	dbf	d7,.l
	rts
	

;a0 = srodek ekranu
;d0,d1 = xy
Plot:
	move.w	d0,d2
	asr.w	#3,d2
	not.w	d0
	muls	#40,d1
	add.w	d1,d2
	bset.b	d0,(a0,d2.w)
	rts



;*********************************************************
;*               CZEKAJ AZ BLITER GOTOWY                 *
;*********************************************************
	
;*********************************************************
;*                    ZMIENNE I STALE                    *
;*********************************************************

Name:		dc.b	'graphics.library',0
	even
Wart1:		dc.w	0
Wart2:		dc.w	0
Wart3:		dc.w	0
Old:		dc.l	0

num_pts_src:	dc.w	0
pts_src:	blk.l	max_pts+64,0
data_src:	incbin	frame200.dat

num_pts_dst:	dc.w	0
pts_dst:	blk.l	max_pts+64,0
data_dst:	incbin	frame100.dat

code:
	blk.b	6*max_pts + 100

code_addrs:
	dc.l	c_l0,c_l1,c_l2,c_l3
	dc.l	c_l4,c_l5,c_l6,c_l7

code_addrs_gen:
	dc.l	c_l0,c_l1,c_l2,c_l3
	dc.l	c_l4,c_l5,c_l6,c_l7

tab_codes:
	dc.l	c_l0,c_l1,c_l0,c_l2,c_l0,c_l1,c_l0,c_l3,c_l0,c_l1,c_l0,c_l2,c_l0,c_l1,c_l0,c_l4
	dc.l	c_l0,c_l1,c_l0,c_l2,c_l0,c_l1,c_l0,c_l3,c_l0,c_l1,c_l0,c_l2,c_l0,c_l1,c_l0,c_l5
	dc.l	c_l0,c_l1,c_l0,c_l2,c_l0,c_l1,c_l0,c_l3,c_l0,c_l1,c_l0,c_l2,c_l0,c_l1,c_l0,c_l4
	dc.l	c_l0,c_l1,c_l0,c_l2,c_l0,c_l1,c_l0,c_l3,c_l0,c_l1,c_l0,c_l2,c_l0,c_l1,c_l0,c_l6
	dc.l	c_l0,c_l1,c_l0,c_l2,c_l0,c_l1,c_l0,c_l3,c_l0,c_l1,c_l0,c_l2,c_l0,c_l1,c_l0,c_l4
	dc.l	c_l0,c_l1,c_l0,c_l2,c_l0,c_l1,c_l0,c_l3,c_l0,c_l1,c_l0,c_l2,c_l0,c_l1,c_l0,c_l5
	dc.l	c_l0,c_l1,c_l0,c_l2,c_l0,c_l1,c_l0,c_l3,c_l0,c_l1,c_l0,c_l2,c_l0,c_l1,c_l0,c_l4
	dc.l	c_l0,c_l1,c_l0,c_l2,c_l0,c_l1,c_l0,c_l3,c_l0,c_l1,c_l0,c_l2,c_l0,c_l1,c_l0,c_l7
	dc.l	c_l0,c_l1,c_l0,c_l2,c_l0,c_l1,c_l0,c_l3,c_l0,c_l1,c_l0,c_l2,c_l0,c_l1,c_l0,c_l4
	dc.l	c_l0,c_l1,c_l0,c_l2,c_l0,c_l1,c_l0,c_l3,c_l0,c_l1,c_l0,c_l2,c_l0,c_l1,c_l0,c_l5
	dc.l	c_l0,c_l1,c_l0,c_l2,c_l0,c_l1,c_l0,c_l3,c_l0,c_l1,c_l0,c_l2,c_l0,c_l1,c_l0,c_l4
	dc.l	c_l0,c_l1,c_l0,c_l2,c_l0,c_l1,c_l0,c_l3,c_l0,c_l1,c_l0,c_l2,c_l0,c_l1,c_l0,c_l6
	dc.l	c_l0,c_l1,c_l0,c_l2,c_l0,c_l1,c_l0,c_l3,c_l0,c_l1,c_l0,c_l2,c_l0,c_l1,c_l0,c_l4
	dc.l	c_l0,c_l1,c_l0,c_l2,c_l0,c_l1,c_l0,c_l3,c_l0,c_l1,c_l0,c_l2,c_l0,c_l1,c_l0,c_l5
	dc.l	c_l0,c_l1,c_l0,c_l2,c_l0,c_l1,c_l0,c_l3,c_l0,c_l1,c_l0,c_l2,c_l0,c_l1,c_l0,c_l4
	dc.l	c_l0,c_l1,c_l0,c_l2,c_l0,c_l1,c_l0,c_l3,c_l0,c_l1,c_l0,c_l2,c_l0,c_l1,c_l0
	dc.l	c_rts

c_rts:
	rts

c_l0:blk.b	20000
c_l1:blk.b	20000
c_l2:blk.b	20000
c_l3:blk.b	20000
c_l4:blk.b	20000
c_l5:blk.b	20000
c_l6:blk.b	20000
c_l7:blk.b	20000


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

