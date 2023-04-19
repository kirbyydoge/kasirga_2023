from PIL import Image, ImageOps


# Dosyayı oku ve pikselleri ayır
with open('../cevrilmis.txt', 'r') as f:
    pixels = f.read().split('\n')

# Dosya boyutunu ve piksel sayısını belirle
width, height = 320, 240
n_pixels = width * height

# Pikselleri bir NumPy dizisine dönüştür
import numpy as np
pixel_array = np.zeros(n_pixels, dtype=np.uint8)
for i, pixel in enumerate(pixels):
    if pixel == '':
        continue
    pixel_array[i] = int(pixel, 16)

# Görüntüyü bir NumPy dizisine dönüştür
image_array = pixel_array.reshape((height, width))

# Görüntüyü PIL Image nesnesine dönüştür
image = Image.fromarray(image_array)

# Histogram eşitleme uygula
image_equalized = ImageOps.equalize(image)

# Yeni görüntüyü NumPy dizisine dönüştür
new_image_array = np.array(image_equalized)

# Yeni görüntüyü tek boyutlu NumPy dizisine dönüştür
new_pixel_array = new_image_array.flatten()

# Yeni pikselleri hex formatında bir dosyaya yaz
with open('../histogram_esitleme.txt', 'w') as f:
    for pixel in new_pixel_array:
        #f.write(hex(pixel)[2:].zfill(2).lower() + '\n')
        f.write(str(pixel) + '\n')
with open('../histogram_esitleme.txt', 'w') as f:
    for pixel in new_pixel_array:
        #f.write(hex(pixel)[2:].zfill(2).lower() + '\n')
        f.write(str(pixel) + '\n')
from PIL import Image
img = Image.new('L', (320, 240))
img.putdata(new_pixel_array)
img.show()