Z_OBS = 2.0
Y_OBS = 0
Z_MOVE = 1

def rzutuj3d(x,y,z):
    print x,Z_OBS,z,Z_MOVE
    return (x*Z_OBS / (Z_OBS+z+Z_MOVE), y*Z_OBS+Y_OBS*(z+Z_MOVE) / (Z_OBS+z+Z_MOVE))

def gen_points(frame):

    Z_MOVE = frame+1
    print 1*Z_OBS / (Z_OBS+1+Z_MOVE)

    A = (1,1,1)
    print rzutuj3d(1,1,1)
    
    return


for i in range(0,50):
    gen_points(i)
