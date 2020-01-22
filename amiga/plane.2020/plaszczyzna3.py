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

f = open("zx.bin","wb")
for z in range(0,LL_Z):
    for x in range(0,LL_X):
        xx = tab_xz[x,z]
        f.write(chr(xx/256)+chr(xx%256))
f.close()

f = open("sintabs.bin","wb")
g = open("sintabs.s","wt")
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


"""
    jr (a2)
;0  add.w d7,a0
    add.w d7,a3
    add.w (a5)+,a2
    jmp   (a2)
;1  addq  #6,a0
    addq  #6,a3
    move.w (a0)+,d3
    add.w  (a3)+,d3
    bset   #xyz,(a1,d3.w)
;2

"""

bset = lambda x,reg,z: "\x08\xf1\x00"+chr(7-tab_xz[x*4+reg,z]%8)+chr(reg*16)+chr(tab_xz[x*4+reg,z]/8)
cmdaddjmp = "\xd4\xdd\x4e\xd2"

cmdadd8a0 = "\x50\x48"
cmdadd8a3 = "\x50\x4b"
cmdadd4a0 = "\x58\x48"
cmdadd4a3 = "\x58\x4b"
cmdadd6a0 = "\x5c\x48"
cmdadd6a3 = "\x5c\x4b"
cmdmovem  = "\x4c\x98\x00\x0f"
cmdmove0  = "\x30\x18"
cmdmove1  = "\x32\x18"
cmdmove2  = "\x34\x18"
cmdmove3  = "\x36\x18"
cmdaddd0  = "\xd0\x5b"
cmdaddd1  = "\xd2\x5b"
cmdaddd2  = "\xd4\x5b"
cmdaddd3  = "\xd6\x5b"
cmdaddd4  = "\xd8\x5b"
cmdaddd5  = "\xda\x5b"
cmdaddd6  = "\xdc\x5b"
cmdaddd7  = "\xde\x5b"

cmd0 = cmdadd8a0+cmdadd8a3   #add.w d7,a0 add.w d7.a3
cmd1 = cmdadd6a0+cmdadd6a3+cmdmove3+cmdaddd3
cmd2 = cmdadd4a0+cmdadd4a3+cmdmove2+cmdmove3+cmdaddd2+cmdaddd3  #"\x58\x48\x34\x18\x36\x18\x58\x4b\xd4\x5b\xd6\x5b"
cmd3 = cmdadd4a0+cmdadd4a3+cmdmove2+cmdmove3+cmdaddd2+cmdaddd3  #"\x58\x48\x34\x18\x36\x18\x58\x4b\xd4\x5b\xd6\x5b"
cmd4 = cmdmove0+cmdmove1+cmdadd4a0+cmdaddd0+cmdaddd1+cmdadd4a3
cmd8 = cmdmove0+cmdadd6a0+cmdaddd0+cmdadd6a3
cmd9 = cmdmove0+cmdadd4a0+cmdmove3+cmdaddd0+cmdadd4a3+cmdaddd3
cmd12= cmdmove0+cmdmove1+cmdadd4a0+cmdaddd0+cmdaddd1+cmdadd4a3
cmd15= "\x4c\x98\x00\x0f"+"\xd0\x5b"+"\xd2\x5b"+"\xd4\x5b"+"\xd6\x5b"
#            if mask & 1:
#                f.write("\x08\xf1\x00"+chr(7-xa%8)+chr(3*16)+chr(xa/8))
lens={}
lens[0] = 0


def endcmd(bmask,xx):
    if xx==14 and bmask == 16:
        abc=1
    if xx!=15: return cmdaddjmp
    aaa = "\x60\x00"     #$bra xyz
    where = lens[17]-lens[bmask+1]+2
    aaa += chr(where/256)+chr(where%256)
    return aaa    

for z in range(0,LL_Z):
    f = open("4bit\\lines_bsets_4bit_%02d_v3.bin"%z,"wb")
    for xx in range(0,LL_Z/4):

        for i in range(0,17):
            if i==0:
                cmd = cmd0
            elif i==1:
                cmd = cmd1
            elif i==2:
                cmd = cmd2
            elif i==3:
                cmd = cmd3
            elif i==4:
                cmd = cmd4
            elif i==8:
                cmd = cmd8
            elif i==9:
                cmd = cmd9
            elif i==16:
                cmd = "\x4c\x98\x00\xff"+cmdaddd0+cmdaddd1+cmdaddd3+cmdaddd3
                cmd+= bset(xx,3,z)+bset(xx,2,z)+bset(xx,1,z)+bset(xx,0,z)
                cmd+= cmdaddd4+cmdaddd5+cmdaddd6+cmdaddd7
#                cmd+= bset(xx,7,z)+bset(xx,6,z)+bset(xx,5,z)+bset(xx,4,z)
                cmd+=endcmd(i,xx)
            else:
                cmd = cmd15
            if i>=0 and i<=15:
                if i & 1: cmd +=bset(xx,3,z)
                if i & 2: cmd +=bset(xx,2,z)
                if i & 4: cmd +=bset(xx,1,z)
                if i & 8: cmd +=bset(xx,0,z)
                cmd+=endcmd(i,xx)
            f.write(cmd)
            lens[i+1] = lens[i]+len(cmd)
    f.close()

f = open("lens.bin","wb")
print "%d,"*18 % (tuple([lens[i] for i in range(0,18)]))
f.write(reduce(lambda x,y:x+y,map(lambda x:chr(x/256)+chr(x%256),[lens[i] for i in range(0,18)])))
f.close()
