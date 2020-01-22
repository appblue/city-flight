from PIL import Image,ImageFont,ImageDraw
import math
import random
from math import sin,cos,pi

sizeX = 320
sizeY = 256
maxFrames = 256

obc_x = 255
obc_y = 255

def line(p1, p2):
    A = (p1[1] - p2[1])
    B = (p2[0] - p1[0])
    C = (p1[0]*p2[1] - p2[0]*p1[1])
    return A, B, -C, min(p1[0],p2[0]), max(p1[0],p2[0])

def intersection(L1, L2):
    D  = L1[0] * L2[1] - L1[1] * L2[0]
    Dx = L1[2] * L2[1] - L1[1] * L2[2]
    Dy = L1[0] * L2[2] - L1[2] * L2[0]
    if D != 0:
        x = 1.0*Dx / D
        y = 1.0*Dy / D
 #       if x<L1[3] or x>L1[4]: return False
 #       if x<L2[3] or x>L2[4]: return False
 #   if 1:
        return round(x),round(y)
#    else:
        return False

def line2(p1, p2):
    A = (p1[1] - p2[1])
    B = (p2[0] - p1[0])
    C = (p1[0]*p2[1] - p2[0]*p1[1])
    return p1,p2
    return A, B, -C, min(p1[0],p2[0]), max(p1[0],p2[0])

def intersection2(l1,l2):
    #(L1X1,L1Y1,L1X2,L1Y2, L2X1,L2Y1,L2X2,L2Y2):
    L1X1 = l1[0][0]
    L1Y1 = l1[0][1]
    L1X2 = l1[1][0]
    L1Y2 = l1[1][1]
    L2X1 = l2[0][0]
    L2Y1 = l2[0][1]
    L2X2 = l2[1][0]
    L2Y2 = l2[1][1]
    d = (L2Y2 - L2Y1) * (L1X2 - L1X1) - (L2X2 - L2X1) * (L1Y2 - L1Y1);
    n_a = (L2X2 - L2X1) * (L1Y1 - L2Y1) - (L2Y2 - L2Y1) * (L1X1 - L2X1);
    n_b = (L1X2 - L1X1) * (L1Y1 - L2Y1) - (L1Y2 - L1Y1) * (L1X1 - L2X1);
    if d==0: return False
    ua = 1.0* n_a / d;
    ub = 1.0* n_b / d;
    if (ua >= 0 and ua <= 1 and ub >= 0 and ub <= 1):
        X = L1X1 + (ua * (L1X2 - L1X1))
        Y = L1Y1 + (ua * (L1Y2 - L1Y1))
        return X,Y
    else:
        return False
    
twopoints = lambda x,y:tuple(list(x)+list(y))

def odl(p1,p2):
    x = p1[0]-p2[0]
    y = p1[1]-p2[1]
    a = math.sqrt(x*x+y*y)
    return a

def triarea(p1,p2,p3):
    a = odl(p1,p2)+0.00
    b = odl(p2,p3)+0.00
    c = odl(p3,p1)+0.00
    s = (a+b+c)/2.0
#    print p1,p2,p3,a,b,c,s
    x = math.sqrt(0.001+s*(s-a)*(s-b)*(s-c))
    return x

def pointInQuad(p1,a,b,c,d):

    pole1 = triarea(p1,a,b) + triarea(p1,b,c) + triarea(p1,c,d) + triarea(p1,d,a)
    pole2 = triarea(a,b,c) + triarea(a,c,d)
    return abs(pole1 - pole2)<0.1

def line_quad(draw,p1,p2,a,b,c,d):

#    print p1,p2,a,b,c,d

#    draw.line(twopoints(a,b))
#    draw.line(twopoints(b,c))
#    draw.line(twopoints(c,d))
#    draw.line(twopoints(d,a))

    a1 = pointInQuad(p1,a,b,c,d)
    a2 = pointInQuad(p2,a,b,c,d)

    if (a1 and a2): return []

    L1 = line2(p1,p2)
    L2 = line2(a,b)
    L3 = line2(b,c)
    L4 = line2(c,d)
    L5 = line2(d,a)

    sp = set()

    R1 = intersection2(L1,L2)
    R2 = intersection2(L1,L3)
    R3 = intersection2(L1,L4)
    R4 = intersection2(L1,L5)

    if R1: sp.add(R1)
    if R2: sp.add(R2)
    if R3: sp.add(R3)
    if R4: sp.add(R4)

#    print sp


#    if len(sp)==3:
#        print p1,p2,R1,R2,R3,R4,sp

    if len(sp)==2:

        pp1 = sp.pop()
        pp2 = sp.pop()

        if odl(pp1,p1)<odl(pp2,p1):
#            draw.line(twopoints(p1,pp1))
#            draw.line(twopoints(pp2,p2))
            return [(p1,pp1),(pp2,p2)]
        else:
#            draw.line(twopoints(p1,pp2))
#            draw.line(twopoints(pp1,p2))
            return [(p1,pp2),(pp1,p2)]


    if len(sp)==1:
        pp = sp.pop()
        if a2:
#            draw.line(twopoints(p1,pp))
            return [(p1,pp)]
        else:
#            draw.line(twopoints(p2,pp))
            return [(p2,pp)]

    if len(sp)==0:
#        draw.line(twopoints(p1,p2))
        return [(p1,p2)]

    return []



def rotate(P,a,b,g):
    x = P[0]
    y = P[1]
    z = P[2]
    x2 = x*cos(g)*cos(b) - y*sin(g)*cos(b) - z* sin(b)
    y2 = x*(sin(g)*cos(a)-cos(g)*sin(b)*sin(a)) + y*(cos(g)*cos(a)+sin(g)*sin(b)*sin(a)) - z*cos(b)*sin(a)
    z2 = x*(sin(g)*sin(a)+cos(g)*sin(b)*cos(a)) + y*(cos(g)*sin(a)-sin(g)*sin(b)*cos(a)) + z*cos(b)*cos(a)
#        |     cG*cB               -sG*cB         -sB   |
#        | sG*cA-cG*sB*sA      cG*cA+sG*sB*sA    -cB*sA |
#        | sG*sA+cG*sB*cA      cG*sA-sG*sB*cA     cB*cA |
    return (x2,y2,z2)
boxes=[]

def draw_next_box(draw,a,b,c,d):
    ret = []
    global boxes
    lines = [(a,b),(b,c),(c,d),(d,a)]
    for i in boxes:
        lines2 = []
        for line in lines:
            lines2+= line_quad(draw,line[0],line[1],i[0],i[1],i[2],i[3])
        lines = lines2

    for line in lines:
        draw.line(twopoints(line[0],line[1]))
        ret+=[(line[0],line[1])]

    boxes+=[(a,b,c,d)]
    return ret


def kod(p):
    ret = 0
    if p[0]<0: ret|=1
    if p[0]>obc_x: ret|=2
    if p[1]<0: ret|=4
    if p[1]>obc_y: ret|=8
    return ret

def obetnij(lin):
    P1 = lin[0]
    P2 = lin[1]
    k1 = kod(P1)
    k2 = kod(P2)
    if k1==0 and k2 ==0: return lin
    if (k1&k2)!=0: return None
    if (k1==0):
        P = P1
        k = k1
        P1 = P2
        k1 = k2
        P2 = P
        k2 = k
    if k1&1:
        yn = P1[1]+(0-P1[0])*(P2[1]-P1[1])/(P2[0]-P1[0])
        xn = 0
        return obetnij(((xn,yn),P2))
    elif k1&2:
        yn = P1[1]+(obc_x-P1[0])*(P2[1]-P1[1])/(P2[0]-P1[0])
        xn = obc_x
        return obetnij(((xn,yn),P2))
    elif k1&4:
        xn = P1[0]+(0-P1[1])*(P2[0]-P1[0])/(P2[1]-P1[1])
        yn = 0
        return obetnij(((xn,yn),P2))
    elif k1&8:
        xn = P1[0]+(obc_y-P1[1])*(P2[0]-P1[0])/(P2[1]-P1[1])
        yn = obc_y
        return obetnij(((xn,yn),P2))
    a = kjsaldjsakldjsakldjsaklsa()
    return lin

def myfun(frame,f):

    global boxes
    boxes = []

    img = Image.new( 'RGB', (sizeX,sizeY), "black") # create a new black image
    pixels = img.load() # create the pixel map
    draw = ImageDraw.Draw(img)

    linie = []

    z_obs = 4.3

    rzutuj2d = lambda p,v,s: (100+100*s*((p[0]+v[0])*(z_obs)/(p[2]+v[2]+z_obs)),100+100*s*((p[1]+v[1])*(z_obs)/(p[2]+v[2]+z_obs)))


    fun = lambda x,y,fr: 0.4*sin(x+2*y*x + y*y-4*fr*pi/maxFrames)

    points={}

    v = (0,0,-3)
    s = 0.6

    DX = 11
    DZ = 11
    for x in range(0,DX):
        nextline={}
        for z in range(0,DZ):
            xx = (x-DX/2+0.5)*1.0/DX
            zz = (z-DZ/2+0.5)*1.0/DZ
            val = fun(1.9*xx,1.7*zz,frame)
#            print xx,zz,val
            nextline[z] = rzutuj2d((xx,val,zz),v,s)
        points[x] = nextline


    print "Frame:%d done(1/2)"%frame
    for z in range(0,DZ-1):
        for x in range(0,DX-1):
#            print points[x][z]
            p0 = points[x][z]
            p1 = points[x+1][z]
            p2 = points[x+1][z+1]
            p3 = points[x][z+1]
#            p0 = rzutuj2d(points[x][z],v,s)
#            p1 = rzutuj2d(points[x+1][z],v,s)
#            p2 = rzutuj2d(points[x+1][z+1],v,s)
#            p3 = rzutuj2d(points[x][z+1],v,s)
#            print p0
            linie += draw_next_box(draw,p0,p1,p2,p3)
    print "Frame:%d done(2/2)"%frame
#    for face in bb1:
#        z = (face[2][0] - face[0][0])*(face[1][1]-face[0][1]) - (face[1][0] - face[0][0])*(face[2][1]-face[0][1])
#
#        p0 = rzutuj2d(rotate(face[0],al,be,ga),v,s)
#        p1 = rzutuj2d(rotate(face[1],al,be,ga),v,s)
#        p2 = rzutuj2d(rotate(face[2],al,be,ga),v,s)
#        p3 = rzutuj2d(rotate(face[3],al,be,ga),v,s)
#        zz = (p2[0] - p0[0])*(p1[1]-p0[1]) - (p1[0] - p0[0])*(p2[1]-p0[1])
#        if zz>0:
#            linie += draw_next_box(draw,p0,p1,p2,p3)

    b2 = lambda x: chr((int(x)&65535)/256)+chr((int(x)&65535)%256)
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
#            f.write(b2(lintr[0][0]))
#            f.write(b2(lintr[0][1]))
#            f.write(b2(lintr[1][0]))
#            f.write(b2(lintr[1][1]))
    f.write(chr(255)*8)


    draw.text((10,sizeY-20), "lines:%d"%(count), font=ImageFont.truetype("cour.ttf", 10))
    draw.text((10,sizeY-10), "frame:%d"%(frame), font=ImageFont.truetype("cour.ttf", 10))

    img.save("C:\\users\\pejdys\\desktop\\2\\%03d.bmp"%frame,"BMP")

    return


f = open("c:\\users\\pejdys\\desktop\\harddrive\\sources\\2scp\\wsp.bin","wb")
for i in range(0,maxFrames):
    myfun(i,f)
f.close()

lin = ((-10,-10),(420,200))
print lin
print obetnij(lin)
