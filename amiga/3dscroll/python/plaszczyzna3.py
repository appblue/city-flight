import sys,os,math
import struct


LL_Z = 64
LL_X = 64
sizeX = 320
sizeY = 256
z_obs = 1.3

rzutuj2d = lambda x,y,z: (x*(z_obs)/(z+1+z_obs),y*(z_obs)/(z+1+z_obs))

tab_dxdy={}
tab_XPYP={}
for z in range(0,LL_Z):
    tab_XPYP[z] = rzutuj2d(0.5/LL_X*2-1,0.253,(z+0.5)/LL_Z*2-1)  #poczatek kolejnej linii
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

f = open("c:\\users\\pejdys\\desktop\\harddrive\\sources\\1scp\\lines_bsets.s","wt")
for z in range(0,LL_Z):
    xp,yp = tab_XPYP[z]
    dx,dy = tab_dxdy[z]
    f.write("genBits%03d:\n"%z)
    xa,ya = makeXY((xp,yp))
    sizes_Y[z] = int(yp*sizeY/2+sizeY/2-sizeY/8+0.5)
    tab_dy[z] = dy
    for x in range(0,LL_X):
        if x%7==0 and x!=63: f.write("\tmovem.w\t(a0)+,d0-d6\n")
        if x==63:f.write("\tmove.w\t(a0)+,d0\n")
        if x%16==0: f.write("\tmove.w\t(a5)+,d7\n")
        f.write("\tadd.w\t(a3)+,d%d\n"%(x%7));
        f.write("\tadd.w\td7,d7\n")
        f.write("\tdc.l $64000008\n")

        xa,ya = makeXY((xp,yp))
        xa = tab_xz[(x,z)]
        f.write("\tbset\t#%d,%d(a1,d%d.w)\t\t;%d\n"%(7-xa%8,xa/8,x%7,xa))
        xp+=dx
    f.write("\trts\n\n")
f.close()

f = open("c:\\users\\pejdys\\desktop\\harddrive\\sources\\1scp\\lines_bsets_4bit.s","wt")
g = open("c:\\users\\pejdys\\desktop\\harddrive\\sources\\1scp\\lines_bsets_4bit.bin","wb")
for z in range(0,LL_Z):
    for xx in range(0,LL_Z/4):
        for mask in range(0,16):
            code_size = 0
            f.write("genBits%03d_%02d_%02d:\n"%(z,xx,mask))
#            f.write("\tmovem.w\t(a0)+,d0-d3\n")
#            f.write("\tadd.w\t(a3)+,d0\n")
            xa = tab_xz[xx*4+0,z]
            if mask & 8:
                f.write("\tbset\t#%d,%d(a1,d0.w)\t\t;%d\n"%(7-xa%8,xa/8,xa))
                g.write("\x08\xf1\x00"+chr(7-xa%8)+chr(0*16)+chr(xa/8))
                code_size+=6
#            f.write("\tadd.w\t(a3)+,d1\n")
            xa = tab_xz[xx*4+1,z]
            if mask & 4:
                f.write("\tbset\t#%d,%d(a1,d1.w)\t\t;%d\n"%(7-xa%8,xa/8,xa))
                g.write("\x08\xf1\x00"+chr(7-xa%8)+chr(1*16)+chr(xa/8))
                code_size+=6
#            f.write("\tadd.w\t(a3)+,d2\n")
            xa = tab_xz[xx*4+2,z]
            if mask & 2:
                f.write("\tbset\t#%d,%d(a1,d2.w)\t\t;%d\n"%(7-xa%8,xa/8,xa))
                g.write("\x08\xf1\x00"+chr(7-xa%8)+chr(2*16)+chr(xa/8))
                code_size+=6
#            f.write("\tadd.w\t(a3)+,d3\n")
            xa = tab_xz[xx*4+3,z]
            if mask & 1:
                f.write("\tbset\t#%d,%d(a1,d3.w)\t\t;%d\n"%(7-xa%8,xa/8,xa))
                g.write("\x08\xf1\x00"+chr(7-xa%8)+chr(3*16)+chr(xa/8))
                code_size+=6
            f.write("\trts\n")
            g.write("\x4e\x75")
            code_size+=2
#            print code_size,","

f.close()
g.close()
f = open("c:\\users\\pejdys\\desktop\\harddrive\\sources\\1scp\\sintabs.bin","wb")
g = open("c:\\users\\pejdys\\desktop\\harddrive\\sources\\1scp\\sintabs.s","wt")
g.write("AddrsSins:\n")
ssizes = "yAddSizes:\tdc.w\t"
for z in range(0,LL_Z):
    zpom = z
    g.write("\tdc.l\tSinTab+%d\n"%(zpom*(256+LL_X)*2))
    g.write("\tdc.w\t%d\t;%d\n"%(40*sizes_Y[zpom],sizes_Y[zpom]))
#    g.write("\tdc.l\tgenBits%03d\n"%zpom)
    ssizes = ssizes+"-%d,"%(40*int(round(tab_dy[z]*48)))
    for i in range(0,256+LL_X):
        war = 40*int(round((sizeY/2.0)*tab_dy[z]*math.sin(2*math.pi*i/256.0)))
        f.write(struct.pack(">h",war))
g.write(ssizes+"0\n")
f.close()
g.close()
