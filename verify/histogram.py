from PIL import Image
import numpy as np
import argparse

p = np.zeros(320 * 240, dtype=np.int32)

f = open('cevrilmis.txt', 'r')
# f = open('cevrilmis.txt', 'r')

for i, pixel in enumerate(f):
    p[i] = int(pixel, 16)
    #p[i] = 0 if p[i] < 200 else p[i]

p = p.reshape((240, 320))



k = np.zeros(256)


for i in range(240):
    for j in range(320):
        if p[i][j]<0:
            k[0]=k[0]+1
        elif p[i][j]>255:
            k[255]=k[255]+1
        else :
            k[int(p[i][j])]=k[int(p[i][j])]+1

c = open("histogram.txt","w")
for i in range(256):
    #print("{}\n".format(k[0]))
    c.writelines("{}\n".format(int(k[i])))

    
c.close()

im = Image.fromarray(p)
im.show()