from math import sqrt,sin,cos

obc_x = 319
obc_y = 255

sizeX = 320
sizeY = 256

z_obs = 6.3
rzutuj2d = lambda p,v,s: (sizeX/2.0*(1+s*((p[0]+v[0])*(z_obs)/(p[2]+v[2]+z_obs))),sizeY/2.0*(1+s*((p[1]+v[1])*(z_obs)/(p[2]+v[2]+z_obs))))
skalar = lambda p0,p1,p2 : (p2[0] - p0[0])*(p1[1]-p0[1]) - (p1[0] - p0[0])*(p2[1]-p0[1])

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

def odl(p1,p2):
    x = p1[0]-p2[0]
    y = p1[1]-p2[1]
    a = sqrt(x*x+y*y)
    return a

def triarea(p1,p2,p3):
    a = odl(p1,p2)+0.00
    b = odl(p2,p3)+0.00
    c = odl(p3,p1)+0.00
    s = (a+b+c)/2.0
#    print p1,p2,p3,a,b,c,s
    return sqrt(0.001+s*(s-a)*(s-b)*(s-c))

def pointInQuad(p1,a,b,c,d):

    pole1 = triarea(p1,a,b) + triarea(p1,b,c) + triarea(p1,c,d) + triarea(p1,d,a)
    pole2 = triarea(a,b,c) + triarea(a,c,d)
#    print "Q:",pole1,pole2
    return abs(pole1 - pole2)<0.1

def pointInPol(p1,P):

#    a = P[0]
#    b = P[1]
#    c = P[2]
#    d = P[3]

#    pole1 = triarea(p1,a,b) + triarea(p1,b,c) + triarea(p1,c,d) + triarea(p1,d,a)
#    pole2 = triarea(a,b,c) + triarea(a,c,d)

    pole1 = sum (map (lambda a:triarea(p1,a[0],a[1]),[(P[i],P[(i+1)%len(P)]) for i in range(0,len(P))]))
    pole2 = sum (map (lambda a:triarea(P[0],a[0],a[1]),[(P[i],P[(i+1)%len(P)]) for i in range(1,len(P)-1)]))

    return abs(pole1 - pole2)<0.1


def line_quad(draw,p1,p2,a,b,c,d):

#    a=P[0]
#    b=P[1]
#    c=P[2]
#    d=P[3]

#    a1 = pointInQuad(p1,a,b,c,d)
#    a2 = pointInQuad(p2,a,b,c,d)
    a1 = pointInPol(p1,(a,b,c,d))
    a2 = pointInPol(p2,(a,b,c,d))
#    print "-"

    if (a1 and a2): return []

    L1 = (p1,p2)
    L2 = (a,b)
    L3 = (b,c)
    L4 = (c,d)
    L5 = (d,a)

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



def line_Pol(draw,p1,p2,P):

    a1 = pointInPol(p1,P)
    a2 = pointInPol(p2,P)

    if (a1 and a2): return []

    sp = set()
#    R = {}
    for i in range(0,len(P)):
        R = intersection2((p1,p2),(P[i],P[(i+1)%len(P)]))
        if R: sp.add(R)

#    R1 = intersection2(L1,L2)
#    R2 = intersection2(L1,L3)
#    R3 = intersection2(L1,L4)
#    R4 = intersection2(L1,L5)

#    if R1: sp.add(R1)
#    if R2: sp.add(R2)
#    if R3: sp.add(R3)
#    if R4: sp.add(R4)

    if len(sp)>=3:
        print p1,p2,sp

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


#print pointInPol((10,10),((5,5),(5,20),(20,20),(20,5)))
#print line_Pol("ala",(10,10),(100,100),((5,5),(5,20),(20,20),(20,5)))


