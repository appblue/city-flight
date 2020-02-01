import struct
import pygame
import math

PTS = 3000

size_x = 100
size_y = 100


def genSquare():
    r = []
    d = int(math.sqrt(PTS))+1
    for i in range(0,d):
        for j in range(0,d):
           x = int (size_x * i / d)
           y = int (size_y * j / d)
           r.append( (x,y) )
    return r

square = genSquare()

pygame.init()
screen = pygame.display.set_mode((400, 300))
done = False


def show(t):
    for x,y in t:
        screen.set_at((x, y), (255,255,255))

show(square)

while not done:
        for event in pygame.event.get():
                if event.type == pygame.QUIT:
                        done = True
        
        pygame.display.flip()

pygame.quit()
