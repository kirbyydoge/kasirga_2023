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


im = Image.open("mario.jpg").convert('L')
#im = im.resize((320, 240))
p = np.pad(np.array(im), [(1, 1), (1, 1)], mode='constant')
k = [[-1, 0, 1], [-2, 0, 2], [-1, 0, 1]]

filtered = convolution_filter(p, k)
res = Image.fromarray(filtered)

f = open("kiyas1.txt","w")

for i in range(240):
    for j in range(320):
        if filtered[i][j]<0:
            f.write("{}\n".format(0))
        elif filtered[i][j]>255:
            f.write("{}\n".format(255))
        else :
            f.write("{}\n".format(int(filtered[i][j])))
f.close()
print(filtered[1])
res.show()