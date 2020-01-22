from PIL import Image,ImageFont,ImageDraw
#import math
#import random
from math import pi

from gfx2d3d import obetnij,line_quad,line_Pol,rzutuj2d,rotate,skalar
from gfx2d3d import sizeX,sizeY

maxFrames = 256

twopoints = lambda x,y:tuple(list(x)+list(y))

b2 = lambda x: chr(int(x)/256)+chr(int(x)%256)


boxes=[]

def draw_next_box(draw,Pol):
    ret = []
    global boxes
    lines = [(Pol[i],Pol[(i+1)%len(Pol)]) for i in range(0,len(Pol))]
    for polygon in boxes:
        lines = sum([line_Pol(draw,line[0],line[1],polygon) for line in lines],[])
#        lines2 = []
#        for line in lines:
#            lines2+= line_Pol(draw,line[0],line[1],polygon)
#        lines = lines2

    ret += lines
#    for line in lines:
#        ret+=[line]

    boxes+=[Pol]
    return ret

def myfun(frame,f):

    global boxes
    boxes = []

    img = Image.new( 'RGB', (sizeX,sizeY), "black") # create a new black image
    pixels = img.load() # create the pixel map
    draw = ImageDraw.Draw(img)

    linie = []

    P11 = (-1.2,-1,-1.2)
    P12 = (1.2,-1,-1.2)
    P13 = (1.2,-1,1.2)
    P14 = (-1.2,-1,1.2)

    P15 = (0,-2,0)

    P1 = (-1,-1,-1)
    P2 = (1,-1,-1)
    P3 = (1,1,-1)
    P4 = (-1,1,-1)

    P5 = (-1,-1,1)
    P6 = (1,-1,1)
    P7 = (1,1,1)
    P8 = (-1,1,1)


    f1 = (P4,P3,P2,P1)
    f2 = (P1,P2,P6,P5)
    f3 = (P2,P3,P7,P6)
    f4 = (P3,P4,P8,P7)
    f5 = (P4,P1,P5,P8)
    f6 = (P7,P8,P5,P6)

    f21 = (P14,P13,P12,P11)
    f22 = (P11,P12,P15)
    f23 = (P12,P13,P15)
    f24 = (P13,P14,P15)
    f25 = (P14,P11,P15)

    bb1 = (f22,f23,f24,f25,f1,f2,f3,f4,f5,f6,f21)

    linie = []

#    al=2.2*pi*frame/maxFrames
#    be=3.5*pi*frame/maxFrames
#    ga=1.8*pi*frame/maxFrames
    al=0
    be=0
    ga=0
    s=1

    def doDomek(v,linie,al,be,ga,s):
        if v[2]>-3.0 and v[2]<42:
            for face in bb1:
                Points2d = [rzutuj2d(rotate(point,al,be,ga),v,s) for point in face]
                if skalar(Points2d[0],Points2d[1],Points2d[2])>0:
                    linie += draw_next_box(draw,tuple(Points2d))

    mmm=20
    if frame>=maxFrames/2 : yadd = -0.5
    else: yadd = -0.5+(maxFrames/2-frame)*5.0/maxFrames
#    print yadd,1+5.0*frame/maxFrames
    for i in range(0,mmm):
        v = (-2,yadd,-3+i*6-20.0*frame/maxFrames)
        doDomek(v,linie,al,be,ga,s)
        v = (+2,yadd,-3+i*6-20.0*frame/maxFrames)
        doDomek(v,linie,al,be,ga,s)


    al=2.2*pi*frame/maxFrames
    be=3.5*pi*frame/maxFrames
    ga=1.8*pi*frame/maxFrames
    v=(0,1,10)
    s=0.4
    doDomek(v,linie,al,be,ga,s)


    count = 0
    for lin in linie:
        lintr=obetnij(lin)
        if lintr:
            count+=1
            x1 = lintr[0][0]
            y1 = lintr[0][1]
            x2 = lintr[1][0]
            y2 = lintr[1][1]
            if y2>y1:
                yp = y2
                xp = x2
                x2 = x1
                y2 = y1
                x1 = xp
                y1 = yp
            y1 = y1-y2
            y2 = int(y2)*40
            f.write(b2(x1)+b2(y1)+b2(x2)+b2(y2))
        if lintr: draw.line(twopoints(lintr[0],lintr[1]))

    f.write(chr(255)*8)


    draw.text((10,sizeY-20), "lines:%d"%(count), font=ImageFont.truetype("cour.ttf", 10))

    img.save("C:\\users\\pejdys\\desktop\\2\\%03d.bmp"%frame,"BMP")

    return


f = open("c:\\users\\pejdys\\desktop\\harddrive\\sources\\2scp\\wsp.bin","wb")
for i in range(0,maxFrames):
    myfun(i,f)
f.close()

lin = ((-10,-10),(420,200))
print lin
print obetnij(lin)
