����                                        OpenLibrary = -30-522
AllocMem    = -30-168
FreeMem     = -30-180
;graphics base

StartList   = 38

Execbase    = 4
Planesize   = 40*256
Chip        = 2
Clear       = Chip+$10000

;************* Pre-program *********

Start:	move.l	#begin,$80.w
	trap	#0
	moveq	#0,d0
	rts

begin:	lea	$dff000,a6
	move.w	$1c(a6),wartosc
	move.w	$02(a6),wartosc2
	move.w	$1e(a6),wartosc3
	ori.w	#$c000,wartosc
	ori.w	#$8000,wartosc2
	ori.w	#$8000,wartosc3
SpLo:	move.l	4(a6),d0
	and.l	#$1ff00,d0
	cmpi.l	#$13700,d0
	bne.s	SpLo

	move.w	#$7fff,$9a(a6)
	move.w	#$7fff,$96(a6)
	move.w	#$7fff,$9c(a6)
	move.l	$6c.w,old

	move.l	#screen1,planeadr
	move.l	#screen3,clsadr
	move.l	#screen2,midleadr
	move.w	#$8400,$dff096
	bsr.w	init
	
	move.l	planeadr,d0
	move.w	d0,pl1l
	swap	d0
	move.w	d0,pl1h
	swap 	d0

	add.l	#40,d0	
	move.w	d0,pl2l
	swap	d0
	move.w	d0,pl2h
	swap 	d0

	add.l	#40,d0	
	move.w	d0,pl3l
	swap	d0
	move.w	d0,pl3h

	move.w #$3081,$dff08e
	move.w #$30c1,$dff090
	move.w #$0038,$dff092
	move.w #$00d0,$dff094
	move.w #%0011001000000000,$dff100
	clr.w  $dff102
	clr.w  $dff104
	move.w	#80,$dff108
	move.w	#80,$dff10a

	move.l	#new,$6c.w
	move.l	a7,stack

	move.l	#CLadr,$dff080
	clr.w 	$dff088

	move.w	#%1000001111000000,$96(a6)
	move.w	#$c020,$9a(a6)

	bsr.w	brylka

uno:	move.l	stack(pc),a7
	lea	$dff000,a6
	bsr.w	WaitBlit
	move.l	old(pc),$6c.w
	move.w	#$7fff,$9a(a6)
	move.w	#$7fff,$96(a6)
	move.w	#$7fff,$9c(a6)
	move.w	wartosc3(pc),$9c(a6)
	move.w	wartosc2(pc),$96(a6)
	move.w	wartosc(pc),$9a(a6)
	lea	GRname(pc),a1
	moveq	#0,d0
	move.l	$4.w,a6
	jsr	OpenLibrary(a6)
	move.l	d0,a6
	lea	$dff000,a5
	move.l	startlist(a6),$dff080
	move.w	d0,$dff088
	rte

;*****Main program*****

init:
	move.w	#$0,$dff180
	move.w	#$fff,$dff182
	move.w	#$f00,$dff184
	move.w	#$fff,$dff186
	move.w	#$f00,$dff188
	move.w	#$fff,$dff18a
	move.w	#$800,$dff18c
	move.w	#$fff,$dff18e
	move.w	#24000,obserw
	move.w	#00,alfa
	move.w	#00,beta
	move.w	#00,gama
	lea	Pomoc1(pc),a0
	moveq	#0,d0
	move.w	#120,d1
	move.l	#250,d2
Abba2:	move.w	d0,(a0)+
	add.w	d1,d0
	dbf	d2,Abba2
	move.l	#0,count
	move.l	Wsk_Sin(pc),a0
	move.w	(a0),Wsp_y
	bsr.w	roots
	rts

;Variables

planeadr:	dc.l	0
clsadr:		dc.l	0
midleadr:	dc.l	0
newfigur:	dc.l	0
obserw:		dc.l	0
flaga:		dc.l	0
counter:	dc.l	0
progadr:	dc.l	0
count:		dc.l	0
alfa:		dc.w	0
beta:		dc.w	0
gama:		dc.w	0
wymfg:		dc.l	0
wartosc:	dc.l	0
wartosc2:	dc.l	0
wartosc3:	dc.l	0
stack:		dc.l	0
Wsp_y:		dc.w	0
Wsp_ay:		dc.w	0
Wsk_Sin:	dc.l	Sin2+32
;Constants
	
Grname: dc.b "graphics.library",0
	even

;**************** NARESZCIE ***************
new:
	btst	#6,$bfe001
	beq.w	uno
	movem.l	d0-d7/a0-a6,-(sp)
	andi.w	#$20,$dff01e
	beq.w	out
	move.w	#$20,$dff09c

	add.b	#1,count

out:
	movem.l	(sp)+,d0-d7/a0-a6
	rte
old:
	dc.l 0
;*********************COPPER PROGRAM************************

CLadr:
	dc.w	$e0
pl1h:	dc.w	0,$e2
pl1l:	dc.w	0,$e4
pl2h:	dc.w	0,$e6
pl2l:	dc.w	0,$e8
pl3h:	dc.w	0,$ea
pl3l:	dc.w	0,$ec
	dc.w	0


	dc.w	$ffff,$fffe

;*************** Pozostale dane ****************

brylka:
	cmp.b	#1,count
	bne.s	brylka
	move.l	#0,count

	move.l	Wsk_Sin(pc),a0
	tst.w	(a0)
	bpl.s	.ll
	lea	Sin2(pc),a0
.ll:	move.w	(a0)+,d0
	move.l	a0,Wsk_Sin
	move.w	d0,Wsp_y
;	move.w	#$ff0,$dff180
	bsr.w	show
	bsr.w	filling
;	move.w	#$a,$dff180
	move.w	#$400,$dff096
	bsr.w	cls2
	bsr.w	wymiana
;	move.w	#$f0,$dff180
	bsr.w	roots

;	move.w	#0,$dff180

	add.w	#4,gama
	cmp.w	#720,gama
	bne.s	uto2
	move.w	#0,gama
uto2:
	add.w	#4,beta
	cmp.w	#720,beta
	bne.s	uot1
	move.w	#0,beta
uot1:
	add.w	#6,alfa
	cmp.w	#720,alfa
	bne.w	out1
	move.w	#0,alfa
out1:	
	bra.w	brylka
	

wymiana:
	move.l	clsadr,d0
	move.l	planeadr,clsadr
	move.l	midleadr,planeadr
	move.l	midleadr,d1
	move.l	d0,midleadr
	move.l	d1,d0
	move.w	d0,pl1l
	swap	d0
	move.w	d0,pl1h
	swap 	d0
	add.l	#40,d0	
	move.w	d0,pl2l
	swap	d0
	move.w	d0,pl2h
	swap 	d0
	add.l	#40,d0	
	move.w	d0,pl3l
	swap	d0
	move.w	d0,pl3h
	rts

;*************************************************************
;*                     3D-ROTATIONS                          *
;*               CODED BY DR.DF0 OF .. ATD ..                *
;*                   ON  4 JULY 1992                         *
;*************************************************************
roots:
	move.w	#300,Wsp_ay
	lea	sinus(pc),a0
	lea	cosin(pc),a1
	move.l	#punkty3D,a2
	move.l	#punkty2D,a4

rloop:
	movem.l	(a2)+,d0-d2
	cmp.w	#$7fff,d0	
	beq.w	exit_p

;around x
;	move.w	alfa(pc),d7
;	move.w	(a0,d7.w),d6
;	move.w	(a1,d7.w),d7
;	move.w	d2,d3
;	muls	d6,d3
;	muls	d7,d2
;	move.w	d1,d4
;	muls	d6,d4
;	muls	d7,d1
;	add.l	d1,d1
;	swap	d1
;	add.l	d2,d2
;	swap	d2
;	add.l	d3,d3
;	swap	d3
;	add.l	d4,d4
;	swap	d4
;	add.w	d4,d2
;	sub.w	d3,d1	

;around y	
	move.w	beta(pc),d7
	move.w	(a0,d7.w),d6
	move.w	(a1,d7.w),d7
	move.w	d2,d3
	muls	d6,d3
	muls	d7,d2
	move.w	d0,d4
	muls	d6,d4
	muls	d7,d0
	add.l	d0,d0
	swap	d0
	add.l	d2,d2
	swap	d2
	add.l	d3,d3
	swap	d3
	add.l	d4,d4
	swap	d4
	add.w	d3,d0
	sub.w	d4,d2	

;around z
;	move.w	gama(pc),d7
;	move.w	(a0,d7.w),d6
;	move.w	(a1,d7.w),d7
;	move.w	d0,d3
;	muls	d6,d3
;	muls	d7,d0
;	move.w	d1,d4
;	muls	d6,d4
;	muls	d7,d1
;	add.l	d0,d0
;	swap	d0
;	add.l	d1,d1
;	swap	d1
;	add.l	d3,d3
;	swap	d3
;	add.l	d4,d4
;	swap	d4
;	add.w	d3,d1
;	sub.w	d4,d0


	add.w	Wsp_y(pc),d1
	cmp.w	#10000,d1
	ble.s	.al1
	move.w	#10000,d1
.al1:
	add.w	Obserw(pc),d2
	ext.l	d1
	ext.l	d0
	lsl.l	#8,d0
	lsl.l	#8,d1
	divs	d2,d0
	divs	d2,d1
	add.w	#150,d0
	add.w	#55,d1

	move.w	d0,(a4)+
	move.w	d1,(a4)+

	cmp.w	Wsp_ay,d1
	bge.s	.lll
	move.w	d1,Wsp_Ay
.lll
	bra rloop
exit_p:
	rts

;     SINUS AND COSINUS TABLES

sinus:
	dc.w	$0000,$0242,$0484,$06C6,$0907,$0B48,$0D87,$0FC6
	dc.w	$1203,$143F,$1679,$18B2,$1AE8,$1D1D,$1F4F,$217E
	dc.w	$23AB,$25D5,$27FC,$2A20,$2C41,$2E5D,$3077,$328C
	dc.w	$349D,$36AB,$38B3,$3AB8,$3CB7,$3EB2,$40A8,$4298
	dc.w	$4483,$4669,$4849,$4A24,$4BF8,$4DC7,$4F8F,$5151
	dc.w	$530C,$54C1,$566F,$5816,$59B6,$5B4F,$5CE1,$5E6B
	dc.w	$5FEE,$6169,$62DC,$6448,$65AB,$6706,$6859,$69A4
	dc.w	$6AE6,$6C20,$6D51,$6E7A,$6F9A,$70B0,$71BE,$72C3
	dc.w	$73BE,$74B1,$759A,$7679,$774F,$781C,$78DF,$7998
	dc.w	$7A48,$7AEE,$7B8A,$7C1D,$7CA5,$7D24,$7D98,$7E02
	dc.w	$7E63,$7EB9,$7F05,$7F48,$7F80,$7FAD,$7FD1,$7FEA
	dc.w	$7FFA,$7fff
cosin:
	dc.w	$7FFF,$7FF9,$7FEA,$7FD1,$7FAE,$7F81,$7F4A,$7F09
	dc.w	$7EBE,$7E69,$7E0A,$7DA1,$7D2E,$7CB2,$7C2C,$7B9C
	dc.w	$7B02,$7A5F,$79B2,$78FB,$783B,$7772,$769F,$75C3
	dc.w	$74DE,$73F0,$72F8,$71F8,$70EE,$6FDC,$6EC1,$6D9D
	dc.w	$6C70,$6B3C,$69FE,$68B9,$676B,$6615,$64B7,$6351
	dc.w	$61E3,$606E,$5EF1,$5D6D,$5BE1,$5A4F,$58B5,$5714
	dc.w	$556C,$53BE,$5209,$504D,$4E8C,$4CC4,$4AF6,$4922
	dc.w	$4749,$456A,$4385,$419B,$3FAC,$3DB8,$3BBF,$39C2
	dc.w	$37C0,$35BA,$33AF,$31A0,$2F8E,$2D78,$2B5E,$2940
	dc.w	$2720,$24FC,$22D6,$20AD,$1E81,$1C53,$1A23,$17F0
	dc.w	$15BC,$1386,$114F,$0F16,$0CDC,$0AA1,$0865,$0628
	dc.w	$03EB,$01AE,$FF71,$FD34,$FAF7,$F8BA,$F67E,$F442
	dc.w	$F208,$EFCE,$ED96,$EB5F,$E92A,$E6F7,$E4C5,$E296
	dc.w	$E069,$DE3E,$DC17,$D9F2,$D7D0,$D5B1,$D395,$D17D
	dc.w	$CF69,$CD58,$CB4B,$C943,$C73F,$C53F,$C344,$C14D
	dc.w	$BF5C,$BD6F,$BB88,$B9A6,$B7CA,$B5F4,$B423,$B258
	dc.w	$B093,$AED4,$AD1C,$AB6B,$A9BF,$A81B,$A67E,$A4E7
	dc.w	$A358,$A1D0,$A04F,$9ED6,$9D65,$9BFB,$9A99,$993F
	dc.w	$97ED,$96A4,$9562,$9429,$92F8,$91D0,$90B1,$8F9A
	dc.w	$8E8C,$8D87,$8C8B,$8B98,$8AAE,$89CE,$88F6,$8828
	dc.w	$8763,$86A8,$85F7,$854E,$84B0,$841B,$8390,$830F
	dc.w	$8297,$8229,$81C5,$816B,$811B,$80D5,$8099,$8067
	dc.w	$803F,$8021,$800D,$8003,$8003,$800D,$8021,$803F
	dc.w	$8067,$8099,$80D5,$811B,$816B,$81C5,$8229,$8297
	dc.w	$830E,$8390,$841B,$84B0,$854E,$85F6,$86A8,$8763
	dc.w	$8828,$88F6,$89CD,$8AAE,$8B98,$8C8B,$8D87,$8E8C
	dc.w	$8F9A,$90B1,$91D0,$92F8,$9429,$9562,$96A3,$97ED
	dc.w	$993F,$9A99,$9BFB,$9D64,$9ED6,$A04F,$A1D0,$A358
	dc.w	$A4E7,$A67D,$A81B,$A9BF,$AB6A,$AD1C,$AED4,$B092
	dc.w	$B257,$B422,$B5F3,$B7CA,$B9A6,$BB88,$BD6F,$BF5B
	dc.w	$C14D,$C343,$C53E,$C73E,$C942,$CB4B,$CD57,$CF68
	dc.w	$D17C,$D395,$D5B0,$D7CF,$D9F1,$DC16,$DE3E,$E068
	dc.w	$E295,$E4C4,$E6F6,$E929,$EB5E,$ED95,$EFCD,$F207
	dc.w	$F441,$F67D,$F8B9,$FAF6,$FD33,$FF71,$01AD,$03EA
	dc.w	$0627,$0864,$0AA0,$0CDB,$0F15,$114E,$1385,$15BB
	dc.w	$17F0,$1A22,$1C52,$1E80,$20AC,$22D5,$24FC,$271F
	dc.w	$2940,$2B5D,$2D77,$2F8D,$31A0,$33AE,$35B9,$37BF
	dc.w	$39C1,$3BBF,$3DB8,$3FAC,$419B,$4384,$4569,$4748
	dc.w	$4921,$4AF5,$4CC3,$4E8B,$504D,$5208,$53BD,$556C
	dc.w	$5713,$58B4,$5A4E,$5BE1,$5D6D,$5EF1,$606E,$61E3
	dc.w	$6351,$64B6,$6614,$676A,$68B8,$69FE,$6B3B,$6C70
	dc.w	$6D9C,$6EC0,$6FDB,$70EE,$71F7,$72F8,$73EF,$74DE
	dc.w	$75C3,$769F,$7772,$783B,$78FB,$79B2,$7A5F,$7B02
	dc.w	$7B9C,$7C2C,$7CB2,$7D2E,$7DA1,$7E0A,$7E69,$7EBE
	dc.w	$7F09,$7F4A,$7F81,$7FAE,$7FD1,$7FEA,$7FF9,$7FFF

Sin2:
	DC.W	$1064,$11E9,$1369,$14E0,$164A,$17A3,$18E9,$1A18,$1B2E,$1C27
	DC.W	$1D01,$1DBB,$1E52,$1EC5,$1F12,$1F3A,$1F3C,$1F17,$1ECD,$1E5D
	DC.W	$1DC9,$1D13,$1C3B,$1B45,$1A32,$1905,$17C1,$1669,$1501,$138B
	DC.W	$120C,$1087,$0EFF,$0D79,$0BF9,$0A81,$0916,$07BB,$0673,$0542
	DC.W	$042A,$032E,$0251,$0195,$00FA,$0084,$0033,$0008,$0003,$0024
	DC.W	$006B,$00D7,$0168,$021B,$02F0,$03E4,$04F4,$061F,$0761,$08B7
	DC.W	$0A1F,$0B93,$0D12,$0E97

	dc.w	-1

show:
	lea	$dff000,a6
	bsr.w	waitblit
	move.l	#-1,$dff044
	move.l	#$ffff8000,$dff072
	move.w	#120,$dff060
	move.w	#120,$dff066
	move.l	#linie3D,a0
	move.l	#punkty2D,a1
	lea	Pomoc1(pc),a4
sh_1:
	move.w	(a0)+,Modula
	bmi.w	exit_p

	movem.w	(a0),d0-d2
	movem.w	(a1,d2.w),d4-d5
	movem.w	(a1,d1.w),d2-d3
	movem.w	(a1,d0.w),d0-d1
	sub.w	d2,d4
	sub.w	d3,d5
	sub.w	d0,d2
	sub.w	d1,d3
	muls	d2,d5
	muls	d3,d4
	sub.l	d5,d4
	ble.s	visible	
	add.w	#80,Modula
visible:	
	cmp.w	#120,modula
	beq.w	no_vis

	move.w	(a0)+,d0
	movem.w	(a1,d0.w),d0-d1
	move.w	(a0),d2
	movem.w	(a1,d2.w),d2-d3
	bsr.w	draw
	
	move.w	(a0)+,d0
	movem.w	(a1,d0.w),d0-d1
	move.w	(a0),d2
	movem.w	(a1,d2.w),d2-d3
	bsr.w	draw

	move.w	(a0)+,d0
	movem.w	(a1,d0.w),d0-d1
	move.w	-6(a0),d2
	movem.w	(a1,d2.w),d2-d3
	bsr.w	draw

	bra.w	sh_1
no_vis:
	addq.l	#6,a0
	bra.w	sh_1


pomoc1:
	blk.l	400,0

;****************************************************************
;*			    BLITER GOTOWY			*
;****************************************************************
waitblit:
	btst	#6,$dff002
	bne.s	waitblit
	rts

;****************************************************************
;*			    WYPELNIANIE				*
;****************************************************************
Filling:
	move.l	midleadr(pc),a0
	move.w	Wsp_ay(pc),d0
	mulu	#120,d0
	lea	(a0,d0.l),a0
	add.l	#120*111-16,a0
	bsr.w	waitblit
	move.l	a0,$dff050
	move.l	a0,$dff054
	move.w	#26,$dff064
	move.w	#26,$dff066
	move.l	#$09f0000a,$dff040
	move.l	#-1,$dff044
	move.w	#3*110*64+7,$dff058

	rts

;****************************************************************
;*			     CLS EKRANU				*
;****************************************************************
Exit:	rts

cls2:
	move.l	clsadr,a0
	move.w	Wsp_ay,d0
	mulu	#120,d0
	lea	10(a0,d0.l),a0
	lea	-120*9(a0),a0
	move.l	#$0,d0
	move.l	d0,d1
	move.l	d0,d2
	move.l	d0,d3
	move.l	d0,d4
	move.l	d0,d5
	move.l	#17,d7
cl1:
	movem.l	d0-d3,(a0)
	movem.l	d0-d3,40(a0)
	movem.l	d0-d3,80(a0)
	movem.l	d0-d3,120(a0)
	movem.l	d0-d3,160(a0)
	movem.l	d0-d3,200(a0)
	movem.l	d0-d3,240(a0)
	movem.l	d0-d3,280(a0)
	movem.l	d0-d3,320(a0)
	movem.l	d0-d3,360(a0)
	movem.l	d0-d3,400(a0)
	movem.l	d0-d3,440(a0)
	movem.l	d0-d3,480(a0)
	movem.l	d0-d3,520(a0)
	movem.l	d0-d3,560(a0)
	movem.l	d0-d3,600(a0)
	movem.l	d0-d3,640(a0)
	movem.l	d0-d3,680(a0)
	movem.l	d0-d3,720(a0)
	movem.l	d0-d3,760(a0)
	lea	800(a0),a0

	dbf	d7,cl1
	rts
;****************************************************************
;*			 WYRZUCANIE LINI			*
;****************************************************************
Modula:	dc.w	0
Draw:
	move.l	midleadr(pc),a2
	add.w	Modula,a2
				;d0,d1-x,y poczatku linii
				;d2,d3-x,y konca linii
	moveq	#15,d4
	cmp.w	d1,d3
	beq.w	exit_p
	ble.s	moon
	exg	d0,d2
	exg	d1,d3
moon:	and.w	d2,d4
	move.w	d4,d5
	not.b	d5
	sub.w	d3,d1
	ext.l	d3
	add.w	d3,d3
	move.w	(a4,d3.w),d3
	sub.w	d2,d0
	blt.s	tron
	cmp.w	d0,d1
	bge.s	prince
	moveq	#$11,d7
	bra.s	speedy
prince:	moveq	#1,d7
	exg	d1,d0
	bra.s	speedy
tron:	neg.w	d0
	cmp.w	d0,d1
	bge.s	only
	moveq	#$15,d7
	bra.s	speedy
only:	moveq	#$9,d7
	exg	d1,d0
speedy: add.w   d1,d1
	lsr.w	#3,d2
;	ext.l	d2
	add.w	d2,d3
	add.w	d3,a2
	move.w	d1,d2
	swap	d4
	lsr.l	#4,d4
	or.w	#$0b6a,d4
	swap	d7
	move.w	d4,d7
	swap	d7
	move.w	d0,d6
	addq.w	#1,d6
	lsl.w	#6,d6
	addq.w	#2,d6
	sub.w	d0,d2
	or.w	#2,d7
	bge.s	wblit2
	ori.b	#$40,d7
wblit2:	btst	#14,$dff002
	bne.s	wblit2
	move.w	d1,$dff062	;D1=2*SDELTA DO BLTBMOD
	move.w	d2,d1		;D2=2*SDELTA DO D1
	sub.w	d0,d1		;D1-D0=2*SDELTA-2*LDELTA
	move.w	d1,$dff064	;D1=2*SDELTA-2*LDELTA=BLTAMOD
	move.l	d7,$dff040
	move.l	a2,$dff048
	move.l	a2,$dff054
	move.w	d2,$dff052
	bchg	d5,(a2)
	move.w	d6,$dff058
	rts
	
	
punkty3D:

	dc.l	0,0,4000
	dc.l	-4000,-1500,2000
	dc.l	-4000,1500,2000
	dc.l	-1500,4000,2000
	dc.l	1500,4000,2000
	dc.l	4000,1500,2000
	dc.l	4000,-1500,2000
	dc.l	1500,-4000,2000
	dc.l	-1500,-4000,2000

	dc.l	0,0,-4000
	dc.l	-4000,-1500,-2000
	dc.l	-4000,1500,-2000
	dc.l	-1500,4000,-2000
	dc.l	1500,4000,-2000
	dc.l	4000,1500,-2000
	dc.l	4000,-1500,-2000
	dc.l	1500,-4000,-2000
	dc.l	-1500,-4000,-2000

	dc.l	-4000,0,0
	dc.l	-2750,2750,0
	dc.l	0,4000,0
	dc.l	2750,2750,0
	dc.l	4000,0,0
	dc.l	2750,-2750,0
	dc.l	0,-4000,0
	dc.l	-2750,-2750,0
	
	dc.l	$7fff

linie3D:
	dc.w	0,2*4,0,1*4
	dc.w	40,3*4,0,2*4
	dc.w	0,4*4,0,3*4
	dc.w	40,5*4,0,4*4
	dc.w	0,6*4,0,5*4
	dc.w	40,7*4,0,6*4
	dc.w	0,8*4,0,7*4
	dc.w	40,1*4,0,8*4

	dc.w	0,11*4,10*4,9*4
	dc.w	40,12*4,11*4,9*4
	dc.w	0,13*4,12*4,9*4
	dc.w	40,14*4,13*4,9*4
	dc.w	0,15*4,14*4,9*4
	dc.w	40,16*4,15*4,9*4
	dc.w	0,17*4,16*4,9*4
	dc.w	40,10*4,17*4,9*4

	dc.w	40,2*4,1*4,18*4
	dc.w	40,11*4,18*4,10*4
	dc.w	0,1*4,10*4,18*4
	dc.w	0,2*4,18*4,11*4

	dc.w	0,3*4,2*4,19*4
	dc.w	0,12*4,19*4,11*4
	dc.w	40,2*4,11*4,19*4
	dc.w	40,3*4,19*4,12*4

	dc.w	40,4*4,3*4,20*4
	dc.w	40,13*4,20*4,12*4
	dc.w	0,3*4,12*4,20*4
	dc.w	0,4*4,20*4,13*4

	dc.w	0,5*4,4*4,21*4
	dc.w	0,14*4,21*4,13*4
	dc.w	40,4*4,13*4,21*4
	dc.w	40,5*4,21*4,14*4
	
	dc.w	40,6*4,5*4,22*4
	dc.w	40,15*4,22*4,14*4
	dc.w	0,5*4,14*4,22*4
	dc.w	0,6*4,22*4,15*4

	dc.w	0,7*4,6*4,23*4
	dc.w	0,16*4,23*4,15*4
	dc.w	40,6*4,15*4,23*4
	dc.w	40,7*4,23*4,16*4

	dc.w	40,8*4,7*4,24*4
	dc.w	40,17*4,24*4,16*4
	dc.w	0,7*4,16*4,24*4
	dc.w	0,8*4,24*4,17*4

	dc.w	0,1*4,8*4,25*4
	dc.w	0,10*4,25*4,17*4
	dc.w	40,8*4,17*4,25*4
	dc.w	40,1*4,25*4,10*4
	
	dc.w	$ffff



punktypo:
	blk.l	100,0

punkty2D:
	blk.l	100,0

	even
screen1:
	blk.b	3*planesize,0

	even
screen2:
	blk.b	3*planesize,0

screen3:
	blk.b	3*planesize,0
