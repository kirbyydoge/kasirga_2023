from PIL import Image
import numpy as np
import argparse

parser = argparse.ArgumentParser(description = "herhangi bir gorseli 300x300 boyutunda gri tonlamali gosterimindeki veriye cevirir")

parser.add_argument('--gorsel', help="cevrilecek dosya")

args = parser.parse_args()

p = np.zeros(320 * 240, dtype=np.int32)

f = open('sonuc.txt', 'r')
#f = open('eq_verilog.txt', 'r')

for i, pixel in enumerate(f):
    p[i] = int(pixel,16)
    #p[i] = 0 if p[i] < 200 else p[i]

p = p.reshape((240, 320))

c = open("kiyas2.txt","w")

for i in range(240):
    for j in range(320):
        if p[i][j]<0:
            c.write("{}\n".format(0))
        elif p[i][j]>255:
            c.write("{}\n".format(255))
        else :
            c.write("{}\n".format(int(p[i][j])))
c.close()

im = Image.fromarray(p)
im.show()