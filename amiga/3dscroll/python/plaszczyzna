from PIL import Image
import math
import random

sizeX = 160
sizeY = 100
step = 0.0315*1

img = Image.new( 'RGB', (sizeX,sizeY), "black") # create a new black image
pixels = img.load() # create the pixel map

def frange(x, y, jump):
  if jump>0:
    while x < y:
        yield x
        x += jump
  else:
    while x > y:
        yield x
        x += jump



tab_min_max={}

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
#        print x,tab_p[x]

    return


put_pixels=[]
all_pixels = 0

def put_pixel(x,y,cR):
    global all_pixels
    all_pixels+=1
    y1,y2 = tab_min_max[x]
    if y>=y1 and y<=y2: return 0
    pixels[x,y] = (cR,cR,cR)
    put_pixels.append((x,y))
    return 1


def do_magic(A,B):
    x1 = A[0]
    x2 = B[0]
    y1 = A[1]
    y2 = B[1]
    delta = 1
    if x1>x2: delta=-1
    x = x1
    while x!=x2:
            y = int(y2 - round((y2-y1)*(x2-x)/float((x2-x1))))
            yield x,y
            x+=delta
    yield x2,y2



def do_rectangle(A,B,C,D):
    x = list(do_magic(A,B))
    x+= list(do_magic(B,C))
    x+= list(do_magic(C,D))
    x+= list(do_magic(D,A))
#    for a,b in x:
#        print a,b
#        put_pixel(a,b,255)
#    update_min_max(x)
    return x

def update_min_max_lines(prevl,currl):
    x = []
    for i in range(0,len(currl)-1):
        A = (prevl[i][0],prevl[i][1])
        B = (prevl[i+1][0],prevl[i+1][1])
        C = (currl[i+1][0],currl[i+1][1])
        D = (currl[i][0],currl[i][1])
        x+=do_rectangle(A,B,C,D)
    update_min_max(x)

def plot(xx,yy,zz):             #x,y,z <- [-1,+1]

    zMove = 1.41
    zD = 1

    xx = xx*(zMove-zD)/(zz+zMove)
    yy = yy*(zMove-zD)/(zz+zMove)

    x = int( (1+xx)*sizeX/2 )
    y = int( (1+yy)*sizeY/2 )

    if x>=sizeX or y>=sizeY: return

    cR = int((255-64)*(1-zz)/2+64)
#    cR=255
    cG = cR
    cB = cR

    return x,y,cR

rand_fact = random.randint(0,100)/100.0
rand_fact_z = 0

amigo = lambda x,y: math.sin(y+x+math.pi/2)*math.sin(rand_fact+2*(x+0.7)*x+2*y)
#amigo = lambda x,y: math.sin(y+x+math.pi/2)*math.sin(rand_fact+2*(x+0.7)*x+2*y*y)

def generate_line(z):
    one_line = []
    for i in frange(-1,1,step):
#        one_line.append(plot(i,math.sin(rand_fact+2*(i+0.7)*i+2*z*z),z))
        one_line.append(plot(i,amigo(i,z+rand_fact_z),z))
    return one_line



def encode(tab_addrs):
    lenE = 0
    for i in range(1,len(tab_addrs)):
        odl = tab_addrs[i][0]-tab_addrs[i-1][0]
        if odl <=4 : lenE += 5
        else : lenE+=8
    print "Len (oryginal/encoded):",len(tab_addrs),lenE/8



def one_frame(przes,rand_z,num):
    global rand_fact
    global rand_fact_z
    global pixels
    global img
    global tab_min_max
    global put_pixels
    global all_pixels

    put_pixels=[]
    all_pixels = 0
    img = Image.new( 'RGB', (sizeX,sizeY), "black") # create a new black image
    pixels = img.load() # create the pixel map
    rand_fact = przes
    rand_fact_z = rand_z

    tab_points = []
    for i in range(0,sizeX):
        tab_min_max[i] = (sizeY,0)  #min,max

    for z in frange(-1+step*(3-num%3)/5,1,step):
        tab_points.append(generate_line(z))


    for x,y,col in tab_points[0]:
        put_pixel(x,y,col)

    prev_line = tab_points[0]

    for lines in tab_points[1:]:
        S = ''
        for x,y,col in lines:
            S+=str(put_pixel(x,y,col))
        print S
        update_min_max_lines(prev_line,lines)
        prev_line = lines

    print len(put_pixels),all_pixels
    tab_addr = sorted([(40*y+x/8,x%8) for x,y in put_pixels],key=lambda x:x[0])
    encode(tab_addr)

#    img.save("C:\\users\\pejdys\\%03d.bmp" % num,"BMP")


for i in range(0,1):
    rr = 2*math.pi*i/50
#    rr = 11
    rr_z = 2*math.pi*i/50
#    rr_z = 123
    one_frame(rr,rr_z,i)

print len(put_pixels)
print all_pixels

"""
A = (10,10)
B = (50,20)
C = (80,70)
D = (20,50)
do_rectangle(A,B,C,D)

A = (20+10,20+10)
B = (20+50,25+20)
C = (20+80,20+70)
D = (20+20,25+50)
do_rectangle(A,B,C,D)


tab_addr = []
for x,y in put_pixels: tab_addr.append((40*y+x,x%8))

tab_addrS = set([a for a,b in tab_addr])
tab_addr = list(tab_addrS)
print len(tab_addr)

tab_addr.sort()
for i in range(0,10):
    print tab_addr[i]


f=open("C:\users\\pejdys\\d.bin","wb")
ile_w = 0
for i in range(0,len(tab_addr)-1):
    bbb = tab_addr[i+1]-tab_addr[i]
    bbb = bbb%256
#    print bbb
    f.write(chr(bbb))
    ile_w +=1
f.close()
print ile_w


img.save("C:\\users\\pejdys\\1.bmp","BMP")



"""
