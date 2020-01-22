import sys,os,math
import struct


LL_Z = 64
LL_X = 64
sizeX = 320
sizeY = 256
z_obs = 1.6

rzutuj2d = lambda x,y,z: (x*(z_obs)/(z+1+z_obs),y*(z_obs)/(z+1+z_obs))

tab_dxdy={}
tab_XPYP={}
for z in range(0,LL_Z):
    tab_XPYP[z] = rzutuj2d(0.5/LL_X*2-1,0.953,(z+0.5)/LL_Z*2-1)  #poczatek kolejnej linii
    tab_dxdy[z] = rzutuj2d(2.0/LL_X,0.5,((z+0.5)/LL_Z*2-1)) #wektor - o ile przesuwac sie o x (dx) i jak wysoki jest slup(dy*LL)

makeXY = lambda (x,y): (int(round((x+1)*sizeX/2)),int(round(y*sizeY)))

sizes_Y={}
tab_dy = {}

tab_xz = {}     #tab_xz[(x,z)] = x'
for z in range(0,LL_Z):
    xp,yp = tab_XPYP[z]
    dx,dy = tab_dxdy[z]
    xa,ya = makeXY((xp,yp))
    sizes_Y[z] = int(yp*sizeY/2+sizeY/2-sizeY/8+0.5)
    tab_dy[z] = dy
    for x in range(0,LL_X):
        xa,ya = makeXY((xp,yp))
        tab_xz[(x,z)] = xa
        xp+=dx

#lens = [0 ,4 ,14 ,24 ,40 ,50 ,66 ,82 ,104 ,114 ,130 ,146 ,168 ,184 ,206 ,228 ,252]
lens2 = {}

len_count = 0


myCode1 = "\x4c\x98\x00\x0f"+"\xd0\x5b"+"\xd2\x5b"+"\xd4\x5b"+"\xd6\x5b"+"\xd4\xdd"
myCode2 = "\x4e\xd2"
myCode  = myCode1+myCode2
#            f.write("\x4c\x98\x00\x0f")     #movem  (a0)+,d0-d3
#            f.write("\xd0\x5b")             #add.w  (a3)+,d0
#            f.write("\xd2\x5b")             #add.w  (a3)+,d1
#            f.write("\xd4\x5b")             #add.w  (a3)+,d2
#            f.write("\xd6\x5b")             #add.w  (a3)+,d3
#            f.write("\xd4\xdd")             #add.w  (a5)+,a2
#            f.write("\x4e\xd2")             #jmp    (a2)



def writeMask(f,mask,xx,LEN_TOTAL,LEN_THIS,num,czyExpand=0):
    global len_count
    global lens2

    lens2[mask] = len_count
    if mask!=0b1011:
        xa = tab_xz[xx*4+0,z]
        if mask & 8:
            f.write("\x08\xf1\x00"+chr(7-xa%8)+chr(0*16)+chr(xa/8))
        xa = tab_xz[xx*4+1,z]
        if mask & 4:
            f.write("\x08\xf1\x00"+chr(7-xa%8)+chr(1*16)+chr(xa/8))
        xa = tab_xz[xx*4+2,z]
        if mask & 2:
            f.write("\x08\xf1\x00"+chr(7-xa%8)+chr(2*16)+chr(xa/8))
        xa = tab_xz[xx*4+3,z]
        if mask & 1:
            f.write("\x08\xf1\x00"+chr(7-xa%8)+chr(3*16)+chr(xa/8))
    else:   #mask = 1011
        xa = tab_xz[xx*4+3,z]
        if mask & 1:
            f.write("\x08\xf1\x00"+chr(7-xa%8)+chr(3*16)+chr(xa/8))
        xa = tab_xz[xx*4+2,z]
        if mask & 2:
            f.write("\x08\xf1\x00"+chr(7-xa%8)+chr(2*16)+chr(xa/8))
        xa = tab_xz[xx*4+1,z]
        if mask & 4:
            f.write("\x08\xf1\x00"+chr(7-xa%8)+chr(1*16)+chr(xa/8))
        xa = tab_xz[xx*4+0,z]
        if mask & 8:
            f.write("\x08\xf1\x00"+chr(7-xa%8)+chr(0*16)+chr(xa/8))
    if czyExpand: f.write(myCode)
    if mask!=15 and mask!=0 and (not czyExpand):
        f.write("\x60\x00")     #$bra xyz
        where = LEN_TOTAL+num*12-len_count-LEN_THIS+2
        f.write(chr(0)+chr(where))
        f.write("\x4e\x71"*6)

    if mask!=15 and mask!=0:
        len_count += LEN_THIS

#    print len_count
for z in range(0,LL_Z):
    f = open("c:\\users\\pejdys\\desktop\\harddrive\\sources\\1scp\\4bit\\lines_bsets_4bit_%02d_v2.bin"%z,"wb")
    f.write(myCode)
    for xx in range(0,LL_Z/4):
#code_size = 138 = 16 bajtow rozbiegowki + 122 rzeczywistego kodu!
        if xx==LL_Z/4-1:
 #           f.write(myCode)
            len_count = 0
            lens2 = {}
            writeMask(f,0b1011,xx,22+16+22+22+16+24,22,5)
            writeMask(f,0b1001,xx,22+16+22+22+16+24,16,4)
            writeMask(f,0b1110,xx,22+16+22+22+16+24,22,3)
            writeMask(f,0b1101,xx,22+16+22+22+16+24,22,2)
            writeMask(f,0b1100,xx,22+16+22+22+16+24,16,1)
            writeMask(f,0b1111,xx,22+16+22+22+16+24,24,0)
            lens2[0b1010] = lens2[0b1011]+6
            lens2[0b1000] = lens2[0b1011]+12
            lens2[0b0110] = lens2[0b1110]+6
            lens2[0b0010] = lens2[0b1110]+12
            lens2[0b0101] = lens2[0b1101]+6
            lens2[0b0100] = lens2[0b1100]+6
            lens2[0b0111] = lens2[0b1111]+6
            lens2[0b0011] = lens2[0b1111]+12
            lens2[0b0001] = lens2[0b1111]+18
            lens2[0] = 22+16+22+22+16+24
        else:
#            f.write(myCode)
            len_count = 0
            lens2 = {}
            writeMask(f,0b1011,xx,22+16+22+22+16+24,22,5,1)
            writeMask(f,0b1001,xx,22+16+22+22+16+24,16,4,1)
            writeMask(f,0b1110,xx,22+16+22+22+16+24,22,3,1)
            writeMask(f,0b1101,xx,22+16+22+22+16+24,22,2,1)
            writeMask(f,0b1100,xx,22+16+22+22+16+24,16,1,1)
            writeMask(f,0b1111,xx,22+16+22+22+16+24,24,0,1)
            lens2[0b1010] = lens2[0b1011]+6
            lens2[0b1000] = lens2[0b1011]+12
            lens2[0b0110] = lens2[0b1110]+6
            lens2[0b0010] = lens2[0b1110]+12
            lens2[0b0101] = lens2[0b1101]+6
            lens2[0b0100] = lens2[0b1100]+6
            lens2[0b0111] = lens2[0b1111]+6
            lens2[0b0011] = lens2[0b1111]+12
            lens2[0b0001] = lens2[0b1111]+18
            lens2[0] = 22+16+22+22+16+24
    f.close()

f = open("c:\\users\\pejdys\\desktop\\harddrive\\sources\\1scp\\sintabs.bin","wb")
g = open("c:\\users\\pejdys\\desktop\\harddrive\\sources\\1scp\\sintabs.s","wt")
g.write("AddrsSins:\n")
ssizes = "yAddSizes:\tdc.w\t"
prev_y=0
for z in range(0,LL_Z):
    zpom = z
    g.write("\tdc.l\tSinTab+%d\n"%(zpom*(256+LL_X)*2))
    act_y = 40*sizes_Y[zpom]-40*90
    g.write("\tdc.w\t%d\t;%d\n"%(act_y-prev_y,sizes_Y[zpom]))
    prev_y=act_y
#    g.write("\tdc.l\tgenBits%03d\n"%zpom)
    ssizes = ssizes+"-%d,"%(40*int(round(tab_dy[z]*48)))
    for i in range(0,256+LL_X):
        war = 40*int(round((sizeY/2.0)*tab_dy[z]*math.sin(2*math.pi*i/256.0)))
        f.write(struct.pack(">h",war))
g.write(ssizes+"0\n")
f.close()
g.close()

lens2[0b1011]+=0
lens2[0b1001] =(3)*6+16
lens2[0b1110] =(3+2)*6+2*16
lens2[0b1101] =(3+2+3)*6+3*16
lens2[0b1100] =(3+2+3+3)*6+4*16
lens2[0b1111] =(3+2+3+3+2)*6+5*16
lens2[0b1010] = lens2[0b1011]+6
lens2[0b1000] = lens2[0b1011]+12
lens2[0b0110] = lens2[0b1110]+6
lens2[0b0010] = lens2[0b1110]+12
lens2[0b0101] = lens2[0b1101]+6
lens2[0b0100] = lens2[0b1100]+6
lens2[0b0111] = lens2[0b1111]+6
lens2[0b0011] = lens2[0b1111]+12
lens2[0b0001] = lens2[0b1111]+18
lens2[0] = 22+16+22+22+16+24+6*16-5*4-16

ss = ""
for i in range(0,16):
    ss+=("%d=%02x,"%(i,0xb2+lens2[i]))
print ss
ss = ""
for i in range(0,16):
    ss+=("%d,"%(lens2[i]))
print ss
