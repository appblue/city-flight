from PIL import Image,ImageFont,ImageDraw
import math
import random
import struct

yAddSizes = [24,23,23,22,22,21,21,20,20,20,19,19,18,18,18,17,17,17,17,16,16,16,16,15,15,15,15,14,14,14,14,14,13,13,13,13,13,13,12,12,12,12,12,12,12,11,11,11,11,11,11,11,11,10,10,10,10,10,10,10,10,10,10,9,0]

Fonts = [		0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,
		0x00,0x10,0x10,0x10,0x10,0x00,0x10,0x00,
		0x00,0x24,0x24,0x00,0x00,0x00,0x00,0x00,
		0x00,0x24,0x7e,0x24,0x24,0x7e,0x24,0x00,
		0x00,0x08,0x3e,0x28,0x3e,0x0a,0x3e,0x08,
		0x00,0x62,0x64,0x08,0x10,0x26,0x46,0x00,
		0x00,0x10,0x28,0x10,0x2a,0x44,0x3a,0x00,
		0x00,0x08,0x10,0x00,0x00,0x00,0x00,0x00,
		0x04,0x08,0x08,0x08,0x08,0x08,0x04,0x00,
		0x00,0x20,0x10,0x10,0x10,0x10,0x20,0x00,
		0x00,0x00,0x14,0x08,0x3e,0x08,0x14,0x00,
		0x00,0x00,0x08,0x08,0x3e,0x08,0x08,0x00,
		0x00,0x00,0x00,0x00,0x00,0x08,0x08,0x10,
		0x00,0x00,0x00,0x00,0x3e,0x00,0x00,0x00,
		0x00,0x00,0x00,0x00,0x00,0x18,0x18,0x00,
		0x00,0x00,0x02,0x04,0x08,0x10,0x20,0x00,
		0x00,0x3c,0x46,0x4a,0x52,0x62,0x3c,0x00,
		0x00,0x18,0x28,0x08,0x08,0x08,0x3e,0x00,
		0x00,0x3c,0x42,0x02,0x3c,0x40,0x7e,0x00,
		0x00,0x3c,0x42,0x0c,0x02,0x42,0x3c,0x00,
		0x00,0x08,0x18,0x28,0x48,0x7e,0x08,0x00,
		0x00,0x7e,0x40,0x7c,0x02,0x42,0x3c,0x00,
		0x00,0x3c,0x40,0x7c,0x42,0x42,0x3c,0x00,
		0x00,0x7e,0x02,0x04,0x08,0x10,0x10,0x00,
		0x00,0x3c,0x42,0x3c,0x42,0x42,0x3c,0x00,
		0x00,0x3c,0x42,0x42,0x3e,0x02,0x3c,0x00,
		0x00,0x00,0x10,0x00,0x00,0x00,0x10,0x00,
		0x00,0x00,0x10,0x00,0x00,0x10,0x10,0x20,
		0x00,0x00,0x04,0x08,0x10,0x08,0x04,0x00,
		0x00,0x00,0x00,0x3e,0x00,0x3e,0x00,0x00,
		0x00,0x00,0x10,0x08,0x04,0x08,0x10,0x00,
		0x00,0x3c,0x42,0x04,0x08,0x00,0x08,0x00,
		0x00,0x3c,0x4a,0x56,0x5e,0x40,0x3c,0x00,
		0x00,0x3c,0x42,0x42,0x7e,0x42,0x42,0x00,
		0x00,0x7c,0x42,0x7c,0x42,0x42,0x7c,0x00,
		0x00,0x3c,0x42,0x40,0x40,0x42,0x3c,0x00,
		0x00,0x78,0x44,0x42,0x42,0x44,0x78,0x00,
		0x00,0x7e,0x40,0x7c,0x40,0x40,0x7e,0x00,
		0x00,0x7e,0x40,0x7c,0x40,0x40,0x40,0x00,
		0x00,0x3c,0x42,0x40,0x4e,0x42,0x3c,0x00,
		0x00,0x42,0x42,0x7e,0x42,0x42,0x42,0x00,
		0x00,0x3e,0x08,0x08,0x08,0x08,0x3e,0x00,
		0x00,0x02,0x02,0x02,0x42,0x42,0x3c,0x00,
		0x00,0x44,0x48,0x70,0x48,0x44,0x42,0x00,
		0x00,0x40,0x40,0x40,0x40,0x40,0x7e,0x00,
		0x00,0x42,0x66,0x5a,0x42,0x42,0x42,0x00,
		0x00,0x42,0x62,0x52,0x4a,0x46,0x42,0x00,
		0x00,0x3c,0x42,0x42,0x42,0x42,0x3c,0x00,
		0x00,0x7c,0x42,0x42,0x7c,0x40,0x40,0x00,
		0x00,0x3c,0x42,0x42,0x52,0x4a,0x3c,0x00,
		0x00,0x7c,0x42,0x42,0x7c,0x44,0x42,0x00,
		0x00,0x3c,0x40,0x3c,0x02,0x42,0x3c,0x00,
		0x00,0xfe,0x10,0x10,0x10,0x10,0x10,0x00,
		0x00,0x42,0x42,0x42,0x42,0x42,0x3c,0x00,
		0x00,0x42,0x42,0x42,0x42,0x24,0x18,0x00,
		0x00,0x42,0x42,0x42,0x42,0x5a,0x24,0x00,
		0x00,0x42,0x24,0x18,0x18,0x24,0x42,0x00,
		0x00,0x82,0x44,0x28,0x10,0x10,0x10,0x00,
		0x00,0x7e,0x04,0x08,0x10,0x20,0x7e,0x00,
		0x00,0x0e,0x08,0x08,0x08,0x08,0x0e,0x00,
		0x00,0x00,0x40,0x20,0x10,0x08,0x04,0x00,
		0x00,0x70,0x10,0x10,0x10,0x10,0x70,0x00,
		0x00,0x10,0x38,0x54,0x10,0x10,0x10,0x00,
		0x00,0x00,0x00,0x00,0x00,0x00,0x00,0xff,
		0x00,0x1c,0x22,0x78,0x20,0x20,0x7e,0x00,
		0x00,0x00,0x38,0x04,0x3c,0x44,0x3c,0x00,
		0x00,0x20,0x20,0x3c,0x22,0x22,0x3c,0x00,
		0x00,0x00,0x1c,0x20,0x20,0x20,0x1c,0x00,
		0x00,0x04,0x04,0x3c,0x44,0x44,0x3c,0x00,
		0x00,0x00,0x38,0x44,0x78,0x40,0x3c,0x00,
		0x00,0x0c,0x10,0x18,0x10,0x10,0x10,0x00,
		0x00,0x00,0x3c,0x44,0x44,0x3c,0x04,0x38,
		0x00,0x40,0x40,0x78,0x44,0x44,0x44,0x00,
		0x00,0x10,0x00,0x30,0x10,0x10,0x38,0x00,
		0x00,0x04,0x00,0x04,0x04,0x04,0x24,0x18,
		0x00,0x20,0x28,0x30,0x30,0x28,0x24,0x00,
		0x00,0x10,0x10,0x10,0x10,0x10,0x0c,0x00,
		0x00,0x00,0x68,0x54,0x54,0x54,0x54,0x00,
		0x00,0x00,0x78,0x44,0x44,0x44,0x44,0x00,
		0x00,0x00,0x38,0x44,0x44,0x44,0x38,0x00,
		0x00,0x00,0x78,0x44,0x44,0x78,0x40,0x40,
		0x00,0x00,0x3c,0x44,0x44,0x3c,0x04,0x06,
		0x00,0x00,0x1c,0x20,0x20,0x20,0x20,0x00,
		0x00,0x00,0x38,0x40,0x38,0x04,0x78,0x00,
		0x00,0x10,0x38,0x10,0x10,0x10,0x0c,0x00,
		0x00,0x00,0x44,0x44,0x44,0x44,0x38,0x00,
		0x00,0x00,0x44,0x44,0x28,0x28,0x10,0x00,
		0x00,0x00,0x44,0x54,0x54,0x54,0x28,0x00,
		0x00,0x00,0x44,0x28,0x10,0x28,0x44,0x00,
		0x00,0x00,0x44,0x44,0x44,0x3c,0x04,0x38,
		0x00,0x00,0x7c,0x08,0x10,0x20,0x7c,0x00,
		0x00,0x0e,0x08,0x30,0x08,0x08,0x0e,0x00,
		0x00,0x08,0x08,0x08,0x08,0x08,0x08,0x00,
		0x00,0x70,0x10,0x0c,0x10,0x10,0x70,0x00,
		0x00,0x14,0x28,0x00,0x00,0x00,0x00,0x00]


sizeX = 320
sizeY = 256
LL_X = 64
LL_Z = 64
MAX_FR=256
z_obs = 1.3

tab_min_max = {}

rzutuj2d = lambda x,y,z: (x*(z_obs)/(z+1+z_obs),y*(z_obs)/(z+1+z_obs))


tab_dxdy={}
tab_XPYP={}
for z in range(0,LL_Z):
    tab_XPYP[z] = rzutuj2d(0.5/LL_X*2-1,0.253,(z+0.5)/LL_Z*2-1)  #poczatek kolejnej linii
    tab_dxdy[z] = rzutuj2d(2.0/LL_X,0.5,((z+0.5)/LL_Z*2-1)) #wektor - o ile przesuwac sie o x (dx) i jak wysoki jest slup(dy*LL)
#    tab_XPYP[z] = rzutuj2d(0.5/LL_X*2-1,0.253,(z+0.5)/LL_Z*2-1)  #poczatek kolejnej linii
#    tab_dxdy[z] = rzutuj2d(2.0/LL_X,0.5,(z+0.5)/LL_Z*2-1) #wektor - o ile przesuwac sie o x (dx) i jak wysoki jest slup(dy*LL)


SIN_SIZE = 256
SinTab={}
for i in range(0,SIN_SIZE):
    rad = i*2*math.pi/SIN_SIZE
    SinTab[i]=math.sin(rad)

def plot(pixels,x,y,cR=255):
    y1,y2 = tab_min_max[x]
    if y>y1 and y<y2: return 0
    pixels[x,y] = (cR,cR,cR)
    return 1

def update_min_max(point_list):
    tab_p = {}
    for x,y in point_list:
        try:
            if tab_p[x][0]>y : tab_p[x][0] = y
            if tab_p[x][1]<y : tab_p[x][1] = y
        except KeyError:
            tab_p[x]=[y,y]

    for x in tab_p:
        yo1,yo2 = tab_min_max[x]
        yn1,yn2 = tab_p[x]
        if yn1<yo1: yo1 = yn1
        if yn2>yo2: yo2 = yn2
        tab_min_max[x] = (yo1,yo2)

    return


def line_points(A,B):
    ret_list = []
    x1 = A[0]
    x2 = B[0]
    y1 = A[1]
    y2 = B[1]
    delta = 1
    if x1>x2: delta=-1
    x = x1
    while x!=x2:
            y = int(y2 - round((y2-y1)*(x2-x)/float((x2-x1))))
            ret_list += [(x,y)]
            x+=delta
    ret_list +=[(x2,y2)]
    return ret_list


def put_to_screen(pixels,draw,tab_xz):
#zwraca bitmaske widoczny<->niewidoczny
    for i in range(0,sizeX): tab_min_max[i]=(sizeY,0)

    ret_bmask = []

#    for x,y,c in [tab_xz[(x,z)] for x in range(0,LL_X) for z in range(0,LL_Z)]:
#        plot(pixels,x,y,c)

    for x in range(0,LL_X): ret_bmask+=[plot(pixels,tab_xz[(x,0)][0],tab_xz[(x,0)][1],tab_xz[(x,0)][2])]
    for z in range(0,LL_Z-1):
        for x in range(0,LL_X): ret_bmask+=[plot(pixels,tab_xz[(x,z+1)][0],tab_xz[(x,z+1)][1],tab_xz[(x,z+1)][2])]
        (x1,y1,c1) = tab_xz[(0,z)]
        (x2,y2,c1) = tab_xz[(0,z+1)]
        points_xy = line_points((x1,y1),(x2,y2))
        (x1,y1,c1) = tab_xz[(LL_X-1,z)]
        (x2,y2,c1) = tab_xz[(LL_X-1,z+1)]
        points_xy+= line_points((x1,y1),(x2,y2))
        for x in range(0,LL_X-1):
            (x1,y1,c1) = tab_xz[(x,z)]
            (x2,y2,c1) = tab_xz[(x+1,z)]
            points_xy+= line_points((x1,y1),(x2,y2))
            (x1,y1,c1) = tab_xz[(x,z+1)]
            (x2,y2,c1) = tab_xz[(x+1,z+1)]
            points_xy+= line_points((x1,y1),(x2,y2))
        update_min_max(points_xy)
    return ret_bmask

tab_literki_xz={}
for x in range(0,256):
    for z in range(0,LL_Z):
        tab_literki_xz[(x,z)] = 0

def putNapis(nap,x,z):
    for l_ind in range(0,len(nap)):
        for i in range(0,8):
            for j in range(0,8):
                letter = nap[l_ind]
                if (1<<(7-i)) & Fonts[8*(ord(letter)-32)+j]:
                    tab_literki_xz[((x+i)+l_ind*8,z-j)]=-20
#       01234567890123456789012345678901
nap1 = "4096 dots.... 3D plane...       "
nap2 = "in 2015 'dot records' will not  "
nap3 = "   be broken................... "
nap4 = "They WILL BE......              "
nap5 = "    SMASHED BY NEW AGE CODING!!!"
putNapis(nap5,0,10)
putNapis(nap4,0,20)
putNapis(nap3,0,30)
putNapis(nap2,0,40)
putNapis(nap1,0,50)

yAddSizes = [-960,-920,-920,-880,-880,-840,-840,-800,-800,-800,-760,-760,-720,-720,-720,-680,-680,-680,-680,-640,-640,-640,-640,-600,-600,-600,-600,-560,-560,-560,-560,-560,-520,-520,-520,-520,-520,-520,-480,-480,-480,-480,-480,-480,-480,-440,-440,-440,-440,-440,-440,-440,-440,-400,-400,-400,-400,-400,-400,-400,-400,-400,-400,-360]

#for z in range(0,LL_Z):
#    print 48*tab_dxdy[z][1]

zmin = 25
zmax = 35
xmin = 25
xmax = 35
for x in range(xmin,xmax):
    for z in range(zmin,zmax):
        xp = 2.0*(x-xmin)/(xmax-xmin)-1
        zp = 2.0*(z-zmin)/(zmax-zmin)-1
#       tab_literki_xz[(x,z)] = 60


f = open("c:\\users\\pejdys\\desktop\\harddrive\\sources\\1scp\\scroll.bin","wb")
for z in range(0,LL_Z):
    for x in range(0,256):
        war = 40*int(tab_dxdy[z][1]*48*tab_literki_xz[(x,z)]/20.0)
        f.write(struct.pack(">h",war))
    for x in range(0,LL_X):
        war = 40*int(tab_dxdy[z][1]*48*tab_literki_xz[(x,z)]/20.0)
        f.write(struct.pack(">h",war))

f.close()

#asdasdsad()

def onemore_frame(frame):
#zwraca tablice [0..LL,0..LL]->(x,y,color)
    ret_tab = {}
    sinInd = SIN_SIZE*(MAX_FR-2*frame)/MAX_FR %SIN_SIZE
    print sinInd
    for z in range(0,LL_Z):
        (XP,YP) = tab_XPYP[z]           #rzutuj2d(0.5/LL*2-1,0.8,(z+0.5)/LL*2-1)
        (dx,dy) = tab_dxdy[z]           #rzutuj2d(2.0/LL,0.8,(z+0.5)/LL*2-1)
        sinIndX = sinInd
        for x in range(0,LL_X):
            XX = XP + x*dx
            YY = SinTab[sinIndX % SIN_SIZE] * dy/1
            XX = int(XX*sizeX/2+sizeX/2+0.5)
            YY = int(YP*sizeY/2+sizeY/2+0.5-sizeY/8)+int(YY*sizeY/2)
#            if frame==0 and x==0:
#                print dy
            ret_tab[(x,z)] = (XX,YY,50+(LL_Z-z)*200/LL_Z) #plot(pixels,XX,YY,50+(LL-z)*200/LL)
            sinIndX+=1
        sinInd +=3
    return ret_tab
"""
def update_pixel(tab_xz,x,y,delta):
    delta = -yAddSizes[y]
    (a,b,c) = tab_xz[(x,y)]
    tab_xz[(x,y)] = (a,b+delta,c)
def putLetter(tab_xz,x,y,c,przes_x):
    for i in range(0,8):
        for j in range(0,8):
            ccc = Fonts[8*(ord(c)-32)+j]
            if (ccc & (1<<(7-i))):
                update_pixel(tab_xz,(przes_x+x+i)%LL_X,y-j,-20)
"""
def update_tab(tab_xz,frame):
#    przes_x = MAX_FR-frame
    for x in range(0,LL_X):
        for z in range(0,LL_Z):
            (a,b,c) = tab_xz[(x,z)]
            tab_xz[(x,z)] = (a,b+tab_literki_xz[((x+frame)%256,z)],c)
    return

f = open("c:\\users\\pejdys\\desktop\\harddrive\\sources\\1scp\\zasl.bin","wb")
g = open("c:\\users\\pejdys\\desktop\\harddrive\\sources\\1scp\\zasl2.bin","wb")

przes = lambda x: [0,2,10,18,32,40,54,68,88,96,110,124,144,158,178,198][x]

for frame in range(0,MAX_FR):
    img = Image.new( 'RGB', (sizeX,sizeY), "black") # create a new black image
    pixels = img.load() # create the pixel map
    draw = ImageDraw.Draw(img)
    font = ImageFont.truetype("cour.ttf", 10)
    draw.text((10,sizeY-20), "dots:%d"%(LL_X*LL_Z), font=font)
    #draw.line((100,200, 150, 100))
    tab_xz = onemore_frame(frame)
    update_tab(tab_xz,frame)
    bmask = put_to_screen(pixels,draw,tab_xz)
    count=0
    
    for z in range(0,LL_Z):
        info=0
        for x in range(0,LL_X):
            info=info*2+bmask[z*LL_X+x]
            if (x+1)%8==0:
                f.write(chr(info))
                g.write(chr(przes(info/16)))
                g.write(chr(przes(info&15)))
                info = 0
                
#            ss+=str(bmask[z*LL_X+x])
            count+=bmask[z*LL_X+x]
#            col = bmask[z*LL_X+x]*200
#            pixels[x,LL_Z-1-z] = (col,0,col)
    draw.text((10,sizeY-10), "visible:%d"%(count), font=font)
    draw.text((10+20*8,sizeY-10), "frame:%d"%(frame), font=font)
    img.save("C:\\users\\pejdys\\%03d.bmp"%frame,"BMP")
f.close()
g.close()