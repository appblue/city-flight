;*********************************************************
;*        STANDART BY DR.DF0  OF  ... ATD ...            *
;*             4 BITPLANY  I  SPRITE'Y                   *
;*********************************************************
Planesize=40*256

STEP_FR = -2
STEP_Y  =  2


Wblit:	macro
	btst	#6,2(a6)
	bne.s	*-6
	endm



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
	jsr	mt_init
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
	jsr	mt_end
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

oneline:
	blk.b	64/8
przesTab:
	incbin	lens.bin
;	dc.w	  0,  8, 26, 48, 76, 98,126,154
;	dc.w	188,206,234,262,296,324,358,392
;	dc.w	432
;total_len = 432

copyOneLine:	macro
	move.l	(a0)+,d1
	move.l	(a0),d2
	move.l	d2,-(a2)
	move.l	d1,-(a2)
	subq.l	#4,a0
	endm


init:

transform_zasl:
	lea	zasl+(64/8)*256*64-(64/8),a0
	lea	zasl+64*(64/4)*2*256-(64/4)*2,a1
	lea	przesTab(pc),a3
	move.w	#256-1,d7
	moveq	#0,d0
;	move.w	#182+16,d3
	move.w	17*2(a3),d3		;move.w	#total_len,d3
	lea	oneline+8(pc),a2
.lf:
	move.w	#64-1,d6
.ll:
	move.w	d6,$dff180
	moveq	#0,d4			;prev_val
	moveq	#0,d5

	copyOneLine

	rept	8

	move.b	(a2),d0
	lsr.b	#4,d0
	and.w	#$0f,d0
	add.w	d0,d0
	move.w	(a3,d0.w),d1
	add.w	d5,d1
	sub.w	d4,d1		;delta z prev_val
	move.w	d1,(a1)+
	add.w	d1,d4
	add.w	d3,d5		;+182+16

	move.b	(a2)+,d0
	and.w	#$0f,d0		;nie trzeba, bo tablica * 16
	add.w	d0,d0
	move.w	(a3,d0.w),d1
	add.w	d5,d1
	sub.w	d4,d1
	move.w	d1,(a1)+
	add.w	d1,d4
	add.w	d3,d5
	endr

	suba.w	#64/8,a0
	suba.w	#(64/4)*2+2*8*2,a1

	dbra	d6,.ll

	dbra	d7,.lf


	lea	Obrazek+63*32,a0
	lea	Zeros,a1

	move.w	#63,d7
.l0:
	move.w	#31,d6
.l1:
	moveq	#0,d1
	rept	8
	add.b	d1,d1
	move.w	(a1)+,d0
	beq	*+6
	addq.w	#1,d1
	endr
	move.b	d1,(a0)+
	dbra	d6,.l1
	add.w	#64*2,a1
	sub.w	#32+32,a0

	dbra	d7,.l0



	jsr	Wymiana
	jsr	showNapis
	jsr	Wymiana
	jsr	showNapis
	jsr	Wymiana
	jsr	showNapis
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
	jsr	mt_music
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
	move.w	#(256-64)*20,$058(a6) 

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


one2line:	macro
	move.l	(a4)+,a0		;sinTab
;	move.l	d4,a1			;drawAdr -> w tablicy sin sa delty :-)
	add.w	(a4)+,a1		;w ktorej linii - przesuniecie dz
	add.w	d5,a0			;d5 = whereX
	addq.w	#(STEP_Y)*2,d5
	and.w	d6,d5			;d6=511 - okres sinu
;	swap	d5
;	swap	d6
	lea	.l\@(pc),a2
	add.w	(a5)+,a2
	jmp	(a2)

.l\@:	incbin	4bit/lines_bsets_4bit_\1_v3.bin

;	swap	d5
;	swap	d6
	add.w	#2*256,a3		;d7=2*256 nastepna linia z tablicy przesuniec

	endm

zaslAdr:	dc.l	0	;zaslanianie
whereX:		dc.w	0
przesZeros:	dc.w	0
frameNr:	dc.w	-1

doMy:
	lea	zaslAdr(pc),a0
	move.l	(a0)+,a5

	lea	AddrsSins,a4
	lea	zeros,a3
	move.w	(a0)+,d5		;whereX(pc),d5
	add.w	(a0)+,a3		;przesZeros(pc),a3

	addq.b	#1,(a0)			;framenr
	bne.b	.ddd
	lea	zaslanianie,a5	;(zaslAdr)
.ddd:

	move.l	DrawAdr(pc),a1
	move.w	#511,d6
;	move.w	#512,d7
	move.w	#8,d7


ll1	one2line	00
ll2	one2line	01
	one2line	02
	one2line	03
	one2line	04
	one2line	05
	one2line	06
	one2line	07
	one2line	08
	one2line	09


	one2line	10
	one2line	11
	one2line	12
	one2line	13
	one2line	14
	one2line	15
	one2line	16
	one2line	17
	one2line	18
	one2line	19

	one2line	20
	one2line	21
	one2line	22
	one2line	23
	one2line	24
	one2line	25
	one2line	26
	one2line	27
	one2line	28
	one2line	29

	one2line	30
	one2line	31
	one2line	32
	one2line	33
	one2line	34
	one2line	35
	one2line	36
	one2line	37
	one2line	38
	one2line	39

	one2line	40
	one2line	41
	one2line	42
	one2line	43
	one2line	44
	one2line	45
	one2line	46
	one2line	47
	one2line	48
	one2line	49

	one2line	50
	one2line	51
	one2line	52
	one2line	53
	one2line	54
	one2line	55
	one2line	56
	one2line	57
	one2line	58
	one2line	59

	one2line	60
	one2line	61
	one2line	62
	one2line	63


xyz:
	lea	zaslAdr,a0
	move.l	a5,(a0)+	;a5,zaslAdr

	move.w	(a0),d0		;whereX,d0
	add.w	#(STEP_FR)*2,d0
	and.w	d6,d0		;#511,d0
	move.w	d0,(a0)+	;d0,whereX

	move.w	(a0),d0		;przesZeros,d0
	addq.w	#2,d0
	and.w	d6,d0		;#511,d0
	move.w	d0,(a0)		;d0,przesZeros

;	rept 800
;	move.w	d0,(a0)
;	endr


	rts

showNapis:
	move.l	DrawAdr,a0
	add.w	#40*(256-64)+8/2,a0
	lea	obrazek,a1
	rept	64
	movem.l	(a1)+,d0-d7
	movem.l	d0-d7,(a0)
	add.w	#40,a0
	endr
	rts

obrazek:
	blk.b	32*64,$aa



ttt:
	movem.w	(a0)+,d0-d7
	add.w	(a3)+,d0
	add.w	(a3)+,d1
	add.w	(a3)+,d2
	add.w	(a3)+,d3
	bset	#3,(a1,d3.w)
	add.w	(a3)+,d4
	add.w	(a3)+,d5
	add.w	(a3)+,d6
	add.w	(a3)+,d7
	bset	#3,10(a1,d7.w)
	bset	#3,11(a1,d6.w)
	bset	#3,12(a1,d5.w)
	bset	#3,13(a1,d4.w)
	add.l	(a5)+,a2
	jmp	(a2)
	nop
	addq.w	#2,a5
	bra.w	*+4

	addq.w	#8,a0
	addq.w	#8,a3
	nop
	moveq	#0,d0
	addq.w	#8,a0

;*********************************************************
;*               CZEKAJ AZ BLITER GOTOWY                 *
;*********************************************************
	
Cls:
	move.l	ClsAdr,a0
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

;*********************************************************
;*                    SINUS TABLES                       *
;*********************************************************
zaslanianie:
zasl:
	incbin	zasl1.bin
	blk.b	2*64*64*256/4-64*64*256/8
endzasl:

;#zasl3:
;#	incbin	zasl3.bin
;zaslanianie:
;	incbin	"zasl3.bin"

	even

SinTab:
	incbin	"sintabs.bin"


zeros:
	incbin	"scroll.bin"
;	blk.w	(256+64)*64*2,0

	include "sintabs.s"



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


;bitmasks_4:
;	incbin	"lines_bsets_4bit.bin"
;	include "lines_bsets_4bit.s"



;­­­­­­­­­­­­­­­­­­­­­­­­­­­­­­­­­­­­­­­­
;­   NoisetrackerV2.0 FASTreplay V1.1   ­
;­  Uses lev6irq - takes 7 rasterlines  ­
;­ Do not disable Master irq in $dff09a ­
;­ Used regs: d0-d7/a0-a5/a7 |  =INTENA ­
;­   Mahoney & Kaktus - © E.A.S. 1990   ­
;­­­­­­­­­­­­­­­­­­­­­­­­­­­­­­­­­­­­­­­­


mt_init:lea	mt_data,a0
	lea	mt_mulu(pc),a1
	move.l	#mt_data+$c,d0
	moveq	#$1f,d1
	moveq	#$1e,d3
mt_lop4:move.l	d0,(a1)+
	add.l	d3,d0
	dbf	d1,mt_lop4

	lea	$3b8(a0),a1
	moveq	#$7f,d0
	moveq	#0,d1
	moveq	#0,d2
mt_lop2:move.b	(a1)+,d1
	cmp.b	d2,d1
	ble.s	mt_lop
	move.l	d1,d2
mt_lop:	dbf	d0,mt_lop2
	addq.w	#1,d2

	swap	d2
	lsr.l	#6,d2
	lea	4(a1,d2.l),a2
	lea	mt_samplestarts(pc),a1
	add.w	#$2a,a0
	moveq	#$1e,d0
mt_lop3:clr.l	(a2)
	move.l	a2,(a1)+
	moveq	#0,d1
	move.b	d1,2(a0)
	move.w	(a0),d1
	add.l	d1,d1
	add.l	d1,a2
	add.l	d3,a0
	dbf	d0,mt_lop3

	move.l	$78.w,mt_irq+2-mt_samplestarts-$7c(a1)
	or.b	#2,$bfe001
	move.b	#6,mt_spd+3-mt_samplestarts-$7c(a1)
	moveq	#0,d0
	move.b	d0,mt_song+3-mt_samplestarts-$7c(a1)
	move.b	d0,mt_cou+1-mt_samplestarts-$7c(a1)
	move.w	d0,mt_patt+2-mt_samplestarts-$7c(a1)
	lea	$dff000,a0
	move.w	d0,$a8(a0)
	move.w	d0,$b8(a0)
	move.w	d0,$c8(a0)
	move.w	d0,$d8(a0)
	move.w	#$f,$96(a0)
	rts

mt_end:	moveq	#0,d0
	lea	$dff000,a0
	move.b	d0,$bfde00
	move.b	#$7f,$bfdd00
	move.w	#$2000,$9c(a0)
	move.w	#$2000,$9a(a0)
	move.l	mt_irq+2(pc),$78.w
	move.w	d0,$a8(a0)
	move.w	d0,$b8(a0)
	move.w	d0,$c8(a0)
	move.w	d0,$d8(a0)
	move.w	#$f,$96(a0)
	rts

mt_nonew:
	lea	$dff0a0,a5
	jsr	mt_com(pc)
	lea	mt_voice2(pc),a4
	lea	$10(a5),a5
	jsr	mt_com(pc)
	lea	mt_voice3(pc),a4
	lea	$10(a5),a5
	jsr	mt_com(pc)
	lea	mt_voice4(pc),a4
	lea	$10(a5),a5
	jsr	mt_com(pc)
	tst.b	mt_brk+3-mt_voice4(a4)
	bne	mt_next
	rts

mt_music:
	move.w	#$fff,d4
	moveq	#$f,d5
	move.w	#$f0,d6
	moveq	#0,d7
	lea	mt_voice1(pc),a4
	addq.b	#1,mt_cou+1-mt_voice1(a4)
	lea	mt_data,a0
mt_cou:	moveq	#0,d0
mt_spd:	cmp.b	#6,d0
	blt.s	mt_nonew
	move.b	d7,mt_cou+1-mt_voice1(a4)
	move.w	d7,mt_dma+2-mt_voice1(a4)
	lea	mt_data,a0
	lea	$3b8(a0),a2
	lea	$43c(a0),a0

	moveq	#0,d1
	moveq	#0,d0
mt_song:move.b	#0,d0
	move.b	(a2,d0.w),d1
	swap	d1
	lsr.l	#6,d1
mt_patt:add.w	#0,d1
	lea	(a0,d1.l),a0
	lea	$dff0a0,a5
	lea	mt_samplestarts-4(pc),a1
	jsr	mt_playvoice(pc)
	lea	$10(a5),a5
	lea	mt_voice2(pc),a4
	jsr	mt_playvoice(pc)
	lea	$10(a5),a5
	lea	mt_voice3(pc),a4
	jsr	mt_playvoice(pc)
	lea	$10(a5),a5
	lea	mt_voice4(pc),a4
	jsr	mt_playvoice(pc)

mt_dma:	move.w	#0,d0
	beq.s	mt_nodma

	lea	$bfd000,a3
	move.b	#$7f,$d00(a3)
	move.w	#$2000,$dff09c
	move.w	#$a000,$dff09a
	move.l	#mt_irq1,$78.w
	move.b	d7,$e00(a3)
	move.b	#$ea,$400(a3)
	move.b	d7,$500(a3)
	or.w	#$8000,mt_dma+2-mt_voice4(a4)
	move.b	#$11,$e00(a3)
	move.b	#$81,$d00(a3)

mt_nodma:
	add.w	#$10,mt_patt+2-mt_voice4(a4)
	cmp.w	#$400,mt_patt+2-mt_voice4(a4)
	bne.s	mt_exit
mt_next:move.w	d7,mt_patt+2-mt_voice4(a4)
	move.b	d7,mt_brk+3-mt_voice4(a4)
	addq.b	#1,mt_song+3-mt_voice4(a4)
	move.b	-2(a2),d0
	cmp.b	mt_song+3(pc),d0
	bne.s	mt_exit
	move.b	-1(a2),mt_song+3-mt_voice4(a4)
mt_exit:
mt_brk:	move.b	#0,d0
	bne.s	mt_next
	rts

mt_irq1:tst.b	$bfdd00
	move.w	mt_dma+2(pc),$dff096
	move.l	#mt_irq2,$78.w
	move.w	#$2000,$dff09c
	rte

mt_irq2:tst.b	$bfdd00
	movem.l	a3/a4,-(a7)
	lea	mt_voice1(pc),a4
	lea	$dff000,a3
	move.l	$a(a4),$a0(a3)
	move.w	$e(a4),$a4(a3)
	move.w	$12(a4),$a8(a3)
	move.l	$28(a4),$b0(a3)
	move.w	$2c(a4),$b4(a3)
	move.w	$30(a4),$b8(a3)
	move.l	$46(a4),$c0(a3)
	move.w	$4a(a4),$c4(a3)
	move.w	$4e(a4),$c8(a3)
	move.l	$64(a4),$d0(a3)
	move.w	$68(a4),$d4(a3)
	move.w	$6c(a4),$d8(a3)
	movem.l	(a7)+,a3/a4
	move.b	#0,$bfde00
	move.b	#$7f,$bfdd00
mt_irq:	move.l	#0,$78.w
	move.w	#$2000,$dff09c
	move.w	#$2000,$dff09a
	rte

mt_playvoice:
	move.l	(a0)+,(a4)
	moveq	#0,d2
	move.b	2(a4),d2
	lsr.b	#4,d2
	move.b	(a4),d0
	and.b	d6,d0
	or.b	d0,d2
	beq	mt_oldinstr
	add.w	d2,d2
	add.w	d2,d2
	move.l	mt_mulu(pc,d2.w),a3
	move.l	(a1,d2.l),4(a4)
	move.w	(a3)+,8(a4)
	move.w	(a3)+,$12(a4)
	move.l	4(a4),d0
	move.w	(a3)+,d3
	beq	mt_noloop
	ext.l	d3
	add.w	d3,d3
	add.l	d3,d0
	move.l	d0,$a(a4)
	move.w	-2(a3),d0
	add.w	(a3),d0
	move.w	d0,8(a4)
	bra	mt_hejaSverige

mt_mulu:blk.l	$20,0

mt_setport:
	move.w	(a4),d2
	and.w	d4,d2
	move.w	d2,$16(a4)
	move.w	$10(a4),d0
	move.b	d7,$14(a4)
	cmp.w	d0,d2
	beq.s	mt_clrport
	bge.s	mt_com2
	move.b	#1,$14(a4)
	bra.s	mt_com2
mt_clrport:
	move.w	d7,$16(a4)
	rts

mt_noloop:
	move.l	d0,$a(a4)
mt_hejaSverige:
	move.w	(a3),$e(a4)

mt_oldinstr:
	move.w	(a4),d3
	and.w	d4,d3
	beq.s	mt_com2
	tst.w	8(a4)
	beq.s	mt_stopsound
	move.b	2(a4),d0
	and.b	d5,d0
	subq.b	#3,d0
	beq.s	mt_setport
	subq.b	#2,d0
	beq.s	mt_setport
	move.w	d3,$10(a4)
	move.w	$1c(a4),$dff096
	move.b	d7,$19(a4)
	move.l	4(a4),(a5)
	move.w	8(a4),4(a5)
	move.w	$10(a4),6(a5)
	move.w	$1c(a4),d0
	or.w	d0,mt_dma+2-[mt_samplestarts-4](a1)

mt_com2:move.b	2(a4),d0
	and.b	d5,d0
	beq.s	mt_rts2
	sub.b	d5,d0
	beq.s	mt_setspeed
	addq.b	#1,d0
	beq.s	mt_filter
	addq.b	#1,d0
	beq.s	mt_pattbreak
	addq.b	#1,d0
	beq.s	mt_setvol
	addq.b	#1,d0
	beq.s	mt_songjmp
mt_rts2:rts

mt_stopsound:
	move.w	$1c(a4),$dff096
	bra	mt_com2

mt_filter:
	move.b	3(a4),d0
	and.b	#1,d0
	add.b	d0,d0
	and.b	#$fd,$bfe001
	or.b	d0,$bfe001
	rts

mt_pattbreak:
	move.b	#1,mt_brk+3-[mt_samplestarts-4](a1)
	rts

mt_songjmp:
	move.b	3(a4),d0
	subq.b	#1,d0
	move.b	#1,mt_brk+3-[mt_samplestarts-4](a1)
	move.b	d0,mt_song+3-[mt_samplestarts-4](a1)
	rts

mt_setvol:
	moveq	#0,d0
	move.b	3(a4),d0
	cmp.b	#$40,d0
	bls.s	mt_sv2
	move.b	#$40,d0
mt_sv2:	move.b	d0,$13(a4)
	move.w	d0,8(a5)
	rts

mt_setspeed:
	move.b	3(a4),d0
	cmp.b	#$1f,d0
	bls.s	mt_sp2
	moveq	#$1f,d0
mt_sp2:	tst.w	d0
	bne.s	mt_sp3
	moveq	#1,d0
mt_sp3:	move.b	d0,mt_spd+3-[mt_samplestarts-4](a1)
	rts

mt_port:move.b	3(a4),d2
	beq.s	mt_port2
	move.b	d2,$15(a4)
	clr.b	3(a4)
mt_port2:
	moveq	#0,d0
	tst.w	$16(a4)
	beq.s	mt_rts
	move.b	$15(a4),d0
	tst.b	$14(a4)
	bne.s	mt_sub
	add.w	d0,$10(a4)
	move.w	$16(a4),d0
	cmp.w	$10(a4),d0
	bgt.s	mt_portok
	move.w	$16(a4),$10(a4)
	move.w	d7,$16(a4)
mt_portok:
	move.w	$10(a4),6(a5)
mt_rts:	rts

mt_sub:	sub.w	d0,$10(a4)
	move.w	$16(a4),d0
	cmp.w	$10(a4),d0
	blt.s	mt_portok
	move.w	$16(a4),$10(a4)
	move.w	d7,$16(a4)
	move.w	$10(a4),6(a5)
	rts

mt_vib:	move.b	$3(a4),d0
	beq.s	mt_vib2
	move.b	d0,$18(a4)

mt_vib2:move.b	$19(a4),d0
	move.w	d0,d2
	lsr.w	#2,d0
	and.w	#$1f,d0
	move.b	$18(a4),d1
	and.w	d5,d1
	asl.w	#5,d1
	add.w	d1,d0
	moveq	#0,d1
	move.b	mt_sin(pc,d0.w),d1

	tst.b	d2
	bmi.s	mt_vibsub
	move.w	$10(a4),d2
	add.w	d1,d2
	bra.s	mt_vib3
mt_vibsub:
	move.w	$10(a4),d2
	sub.w	d1,d2
mt_vib3:move.w	d2,6(a5)
	move.b	$18(a4),d0
	lsr.w	#2,d0
	and.w	#$3c,d0
	add.b	d0,$19(a4)
	rts

mt_sin:
	dc.l 0,0,0,0,0,0,0,0
	dc.l $00000000,$00000101,$01010101,$01010101,$01010101,$01010101
	dc.l $01000000,$00000000,$00000001,$01010202,$02030303,$03030303
	dc.l $03030303,$03030303,$02020201,$01010000,$00000101,$02020303
	dc.l $04040405,$05050505,$05050505,$05050404,$04030302,$02010100
	dc.l $00000102,$03030405,$05060607,$07070707,$07070707,$07070606
	dc.l $05050403,$03020100,$00000102,$03040506,$07070808,$09090909
	dc.l $09090909,$09080807,$07060504,$03020100,$00010203,$04050607
	dc.l $0809090a,$0b0b0b0b,$0b0b0b0b,$0b0a0909,$08070605,$04030201
	dc.l $00010204,$05060708,$090a0b0c,$0c0d0d0d,$0d0d0d0d,$0c0c0b0a
	dc.l $09080706,$05040201,$00010304,$0607080a,$0b0c0d0e,$0e0f0f0f
	dc.l $0f0f0f0f,$0e0e0d0c,$0b0a0807,$06040301,$00010305,$0608090b
	dc.l $0c0d0e0f,$10111111,$11111111,$100f0e0d,$0c0b0908,$06050301
	dc.l $00010305,$07090b0c,$0e0f1011,$12131313,$13131313,$1211100f
	dc.l $0e0c0b09,$07050301,$00020406,$080a0c0d,$0f101213,$14141515
	dc.l $15151514,$14131210,$0f0d0c0a,$08060402,$00020406,$090b0d0f
	dc.l $10121315,$16161717,$17171716,$16151312,$100f0d0b,$09060402
	dc.l $00020407,$090c0e10,$12141516,$17181919,$19191918,$17161514
	dc.l $12100e0c,$09070402,$00020508,$0a0d0f11,$13151719,$191a1b1b
	dc.l $1b1b1b1a,$19181715,$13110f0d,$0a080502,$00020508,$0b0e1012
	dc.l $1517181a,$1b1c1d1d,$1d1d1d1c,$1b1a1817,$1512100e,$0b080502

mt_arplist:
	dc.b 0,1,2,0,1,2,0,1,2,0,1,2,0,1,2,0,1,2,0,1,2,0,1,2,0,1,2,0,1,2,0,1

mt_arp:	moveq	#0,d0
	move.b	mt_cou+1(pc),d0
	move.b	mt_arplist(pc,d0.w),d0
	beq	mt_normper
	subq.b	#2,d0
	beq.s	mt_arp2
mt_arp1:move.b	3(a4),d0
	lsr.w	#4,d0
	bra.s	mt_arpdo
mt_arp2:move.b	3(a4),d0
	and.w	d5,d0
mt_arpdo:
	add.w	d0,d0
	move.w	$10(a4),d1
	lsr.w	#2,d1
	add.b	mt_arp3-$1c(pc,d1.w),d0
	lea	mt_periods(pc),a0
	move.w	(a0,d0.w),6(a5)
	rts

mt_arp3:
	dc.l $46004442,$0040003e,$003c0000,$3a003800,$00360034,$00003200
	dc.l $00300000,$2e000000,$2c00002a,$00000028,$00000026,$00000024
	dc.l $00000000,$22000000,$20000000,$00001e00,$0000001c,$00000000
	dc.l $001a0000,$00000018,$00000000,$00160000,$00000000,$14000000
	dc.l $00000012,$00000000,$00001000,$00000000,$00000e00,$00000000
	dc.l $0000000c,$00000000,$00000000,$0a000000,$00000000,$00080000
	dc.l $00000000,$00000000,$06000000,$00000000,$00000400,$00000000
	dc.l $00000000,$200,0,0,0

mt_normper:
	move.w	$10(a4),6(a5)
	rts

mt_com:	move.w	2(a4),d0
	and.w	d4,d0
	beq.s	mt_normper
	move.b	2(a4),d0
	and.b	d5,d0
	beq	mt_arp
	subq.b	#1,d0
	beq.s	mt_portup
	subq.b	#1,d0
	beq.s	mt_portdown
	subq.b	#1,d0
	beq	mt_port
	subq.b	#1,d0
	beq	mt_vib
	subq.b	#1,d0
	beq.s	mt_volport
	subq.b	#1,d0
	beq.s	mt_volvib
	move.w	$10(a4),6(a5)
	subq.b	#4,d0
	beq.s	mt_volslide
	rts

mt_portup:
	moveq	#0,d0
	move.b	3(a4),d0
	sub.w	d0,$10(a4)
	move.w	$10(a4),d0
	cmp.w	#$71,d0
	bpl.s	mt_portup2
	move.w	#$71,$10(a4)
mt_portup2:
	move.w	$10(a4),6(a5)
	rts

mt_portdown:
	moveq	#0,d0
	move.b	3(a4),d0
	add.w	d0,$10(a4)
	move.w	$10(a4),d0
	cmp.w	#$358,d0
	bmi.s	mt_portdown2
	move.w	#$358,$10(a4)
mt_portdown2:
	move.w	$10(a4),6(a5)
	rts

mt_volvib:
	bsr	mt_vib2
	bra.s	mt_volslide
mt_volport:
	bsr	mt_port2

mt_volslide:
	move.b	3(a4),d0
	move.w	d0,d1
	and.b	d5,d0
	beq.s	mt_vol3
	sub.b	d0,$13(a4)
	bpl.s	mt_vol2
	move.b	d7,$13(a4)
mt_vol2:move.w	$12(a4),8(a5)
	rts

mt_vol3:lsr.b	#4,d1
	add.b	d1,$13(a4)
	cmp.b	#$40,$13(a4)
	bmi.s	mt_vol2
	move.b	#$40,$13(a4)
	move.w	$12(a4),8(a5)
	rts

mt_periods:
	dc.w $358,$328,$2fa,$2d0,$2a6,$280,$25c,$23a,$21a,$1fc,$1e0,$1c5,$1ac
	dc.w $194,$17d,$168,$153,$140,$12e,$11d,$10d,$fe,$f0,$e2,$d6,$ca,$be
	dc.w $b4,$aa,$a0,$97,$8f,$87,$7f,$78,$71,0

mt_samplestarts:blk.l	$1f,0
mt_voice1:	blk.w	14,0
		dc.w	1
mt_voice2:	blk.w	14,0
		dc.w	2
mt_voice3:	blk.w	14,0
		dc.w	4
mt_voice4:	blk.w	14,0
		dc.w	8

mt_data:
	incbin "## dead brain ##.mod"
;	incbin "/modd/## te-x-mas 5 ##.mod"


end:
