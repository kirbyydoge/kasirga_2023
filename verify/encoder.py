import numpy as np
import math
import matplotlib.pyplot as plt
import matplotlib.image as mpimg
from PIL import Image
import random
from fxpmath import Fxp

Q_TABLE = np.array([
    [16,  11,  10,  16,  24,  40,  51,  61],
    [12,  12,  14,  10,  26,  58,  60,  55],
    [14,  13,  16,  24,  40,  57,  69,  56],
    [14,  17,  22,  29,  51,  87,  80,  62],
    [18,  22,  37,  56,  68,  109, 103, 77],
    [24,  35,  55,  64,  81,  104, 113, 92],
    [49,  64,  78,  87,  103, 121, 120, 101],
    [72,  92,  95,  98,  112, 100, 103, 99]
], np.int32)

IMG_SIZE = [240, 320]

def idct_full_err(img, err):
    res = np.ones(IMG_SIZE, np.float32)
    for row in range(IMG_SIZE[0] // 8):
        for col in range(IMG_SIZE[1] // 8):
            idct_block_err(res, img, row, col, err)
    return res

def idct_block_err(res, img, row, col, err):
    for m in range(8):
        for n in range(8):
            val = idct_single_err(img, row, col, m, n, err)
            res[row * 8 + m][col * 8 + n] = val

def rand_err(err):
    return 1 + random.random() * err * 2 - err

BITS = 0
def quant(num, bits=BITS):
    # frac = num % 1.00
    # qfrac = float(round(frac / (1 / (2 ** bits)))) / (2 ** bits)
    # return  num - frac + qfrac
    return Fxp(num, True, 18, 3)

def idct_single_err(img, row, col, m, n, err):
    M = 8
    N = 8
    total_sum = 0
    for p in range(8):
        for q in range(8):
            alpha_p = (1 / math.sqrt(M)) if p == 0 else (math.sqrt(2 / M))
            alpha_q = (1 / math.sqrt(N)) if q == 0 else (math.sqrt(2 / N))
            total_sum +=    quant(quant(alpha_p, err) * quant(alpha_q, err), err) * quant(img[row * 8 + p][col * 8 + q], err) *\
                            quant(quant(math.cos((math.pi * (2 * m + 1) * p) / (2 * M)), err)            *\
                            quant(math.cos((math.pi * (2 * n + 1) * q) / (2 * N)), err), err)
    return total_sum           
  

def idct_full(img):
    res = np.ones(IMG_SIZE, np.float32)
    for row in range(IMG_SIZE[0] // 8):
        for col in range(IMG_SIZE[1] // 8):
            idct_block(res, img, row, col)
    return res

def idct_block(res, img, row, col):
    for m in range(8):
        for n in range(8):
            val = idct_single(img, row, col, m, n)
            res[row * 8 + m][col * 8 + n] = val

def idct_single(img, row, col, m, n):
    M = 8
    N = 8
    total_sum = 0
    for p in range(8):
        for q in range(8):
            alpha_p = (1 / math.sqrt(M)) if p == 0 else (math.sqrt(2 / M))
            alpha_q = (1 / math.sqrt(N)) if q == 0 else (math.sqrt(2 / N))
            total_sum +=    alpha_p * alpha_q * img[row * 8 + p][col * 8 + q]   * \
                            math.cos((math.pi * (2 * m + 1) * p) / (2 * M))     * \
                            math.cos((math.pi * (2 * n + 1) * q) / (2 * N))
    return total_sum

def dct_full(img):
    res = np.zeros(IMG_SIZE, np.float32)
    for row in range(IMG_SIZE[0] // 8):
        for col in range(IMG_SIZE[1] // 8):
            dct_block(res, img, row, col)
    return res

def dct_block(res, img, row, col):
    for p in range(8):
        for q in range(8):
            val = dct_single(img, row, col, p, q)
            res[row * 8 + p][col * 8 + q] = val
 
def dct_single(img, row, col, p, q):
    M = 8
    N = 8
    total_sum = 0
    for m in range(8):
        for n in range(8):
            total_sum +=    img[row * 8 + m][col * 8 + n]                   * \
                            math.cos((math.pi * (2 * m + 1) * p) / (2 * M)) * \
                            math.cos((math.pi * (2 * n + 1) * q) / (2 * N))
    alfa_p = (1 / math.sqrt(M)) if p == 0 else (math.sqrt(2 / M))
    alfa_q = (1 / math.sqrt(N)) if q == 0 else (math.sqrt(2 / N))
    total_sum = total_sum * alfa_p
    total_sum = total_sum * alfa_q
    return total_sum

def quantize_full(img, q_table):
    res = np.zeros(IMG_SIZE)
    for row in range(IMG_SIZE[0] // 8):
        for col in range(IMG_SIZE[1] // 8):
            quantize_block(res, img, q_table, row, col)
    return res

def quantize_block(dest, src, q_table, row, col):
    for i in range(8):
        for j in range(8):
            pixel_y = 8 * row + i
            pixel_x = 8 * col + j
            dest[pixel_y][pixel_x] = round(float(src[pixel_y][pixel_x]) / q_table[i][j])

def dequantize_full(img, q_table):
    res = np.zeros(IMG_SIZE)
    for row in range(IMG_SIZE[0] // 8):
        for col in range(IMG_SIZE[1] // 8):
            dequantize_block(res, img, q_table, row, col)
    return res

def dequantize_block(dest, src, q_table, row, col):
    for i in range(8):
        for j in range(8):
            pixel_y = 8 * row + i
            pixel_x = 8 * col + j
            dest[pixel_y][pixel_x] = src[pixel_y][pixel_x] * q_table[i][j]

f = plt.figure()

orig = np.array(Image.open('mario.jpg').convert('L'))

dct_img = dct_full(orig)
q_img = quantize_full(dct_img, Q_TABLE)
dq_img = dequantize_full(q_img, Q_TABLE)
# idct_img = idct_full(dq_img)
print("Idct ERR")
q3_img = idct_full_err(dq_img, 3)

ax = f.add_subplot(1, 2, 1)
plt.tick_params(left = False, bottom = False, labelleft = False, labelbottom = False)
plt.imshow(orig, cmap='gray', vmin = 0, vmax = 255)
ax.set_title("Orijinal Gorsel")

ax = f.add_subplot(1, 2, 2)
plt.tick_params(left = False, bottom = False, labelleft = False, labelbottom = False)
plt.imshow(q3_img, cmap='gray', vmin = 0, vmax = 255)
ax.set_title("Q15.3 IDCT Sonucu")

plt.show(block=True)