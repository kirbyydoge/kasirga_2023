from PIL import Image
import numpy as np
from array import *

def convolution_filter(gray_img, kernel):
    # temporary operation
    # gray_img = cv2.resize(gray_img, (10, 10))

    kernel_size = len(kernel)

    row = gray_img.shape[0] - kernel_size + 1
    col = gray_img.shape[1] - kernel_size + 1

    result = np.zeros(shape=(row, col))

    for i in range(row):
        for j in range(col):
            current = gray_img[i:i+kernel_size, j:j+kernel_size]
            multiplication = sum(sum(current * kernel))
            result[i, j] = multiplication

    return result


im = Image.open("salo.png").convert('L')
#im = im.resize((320, 240))
p = np.pad(np.array(im), [(1, 1), (1, 1)], mode='constant')

g = [[1/16, 2/16, 1/16], [2/16, 4/16, 2/16], [1/16, 2/16, 1/16]]
x = [[1, 0, -1], [2, 0, -2], [1, 0, -1]]
y = [[1, 2, 1], [0, 0, 0], [-1, -2, -1]]
b = [[0, 0, 0], [0, 1, 0], [0, 0, 0]]
l = [[-1, -1, -1], [-1, 8, -1], [-1, -1, -1]]

filtered = convolution_filter(p, g)
filtered = np.pad(np.array(filtered), [(1, 1), (1, 1)], mode='constant')
for i in range(240):
    for j in range(320):
        if filtered[i][j]<0:
            filtered[i][j]=0
        elif filtered[i][j]>255:
            filtered[i][j]=255
        else:
            filtered[i][j]=int(filtered[i][j])

filtered = convolution_filter(filtered, l)
filtered = np.pad(np.array(filtered), [(1, 1), (1, 1)], mode='constant')
for i in range(240):
    for j in range(320):
        if filtered[i][j]<0:
            filtered[i][j]=0
        elif filtered[i][j]>255:
            filtered[i][j]=255
        else:
            filtered[i][j]=int(filtered[i][j])

filtered = convolution_filter(filtered, b)

f = open("kiyas1.txt","w")

for i in range(240):
    for j in range(320):
        if (filtered[i][j]+p[i][j]) <0:
            f.write("{}\n".format(0))
            filtered[i][j]=0
        elif (filtered[i][j]+p[i][j]) >255:
            f.write("{}\n".format(255))
            filtered[i][j]=255
        else :
            f.write("{}\n".format(int(filtered[i][j])))
            filtered[i][j]=int(filtered[i][j]+p[i][j])
f.close()
res = Image.fromarray(filtered)
print(filtered[1])
res.show()