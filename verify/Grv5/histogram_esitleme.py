import numpy as np

# Dosyadan histogram değerlerini oku
with open('../histogram.txt', 'r') as f:
    hist = np.array([int(line) for line in f])

@np.vectorize
def my_round(number, ndigits=None):
    if ndigits is None:
        return int(number + 0.5)
    factor = 10 ** ndigits
    return int(number * factor + 0.5) / factor

# Histogram eşitleme fonksiyonunu hesapla
cdf = np.cumsum(hist)
cdf_min = cdf.min()
pdf = (cdf - cdf_min) / (cdf.max() - cdf_min)
print(cdf[101])
print((cdf - cdf_min)[101])
print((cdf.max() - cdf_min))
print(pdf[101])
print((pdf*255)[101])
eq_func = my_round(255 * pdf).astype(int)

# eq_func array'ini alt alta yazdir
with open('../histogram_esitleme_degerleri.txt', 'w') as f:
    for i in range(len(eq_func)):
        f.write(str(eq_func[i]) + '\n')

# Dosyadan piksel verilerini oku
with open('../cevrilmis.txt', 'r') as f:
    hex_pixels = f.read().splitlines()

# Hexadecimal pikselleri decimal olarak dönüştür
dec_pixels = np.array([int(p, 16) for p in hex_pixels], dtype=int)

# Yeni piksel değerlerini hesapla ve dosyaya yaz
with open('../histogram_esitleme.txt', 'w') as f:
    for pixel in dec_pixels:
        yeni_pixel = eq_func[pixel]
        f.write('{}\n'.format(yeni_pixel))

from PIL import Image

# Dosyadan piksel verilerini oku
with open('../histogram_esitleme.txt', 'r') as f:
    pixel_values = [int(line) for line in f]

# Görüntüyü oluştur
img = Image.new('L', (320, 240))
img.putdata(pixel_values)

# Görüntüyü göster
img.show()