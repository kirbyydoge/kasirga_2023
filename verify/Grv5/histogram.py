import numpy as np

# Dosyadan piksel verilerini oku
with open('../cevrilmis.txt', 'r') as f:
    hex_pixels = f.read().splitlines()

# Hexadecimal pikselleri decimal olarak dönüştür
dec_pixels = np.array([int(p, 16) for p in hex_pixels], dtype=int)

# Histogram tablosunu hesapla
hist = np.zeros(256, dtype=int)
for pixel in dec_pixels:
    hist[pixel] += 1

# Sonuçları dosyaya yaz
with open('../histogram.txt', 'w') as f:
    for i in range(256):
        f.write('{}\n'.format(hist[i]))
