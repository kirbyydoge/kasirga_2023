import numpy as np
from scipy.signal import medfilt2d
from PIL import Image

# Verilen dosyayı okuyarak hexadecimal kodlu pikselleri bir diziye aktarma
with open('../cevrilmis.txt', 'r') as f:
    hex_pixels = f.read().split()

# Hexadecimal kodlu pikselleri bytearray'a dönüştürme ve resim boyutuna dönüştürme
pixels = bytearray.fromhex(''.join(hex_pixels))
img = np.array(pixels).reshape(240, 320)

# Zero-padding
img = np.pad(img, ((1,1),(1,1)), mode='constant')

# Medyan filtresi uygulama
filtered_img = medfilt2d(img, kernel_size=3)

# Sonucu görselleştirme
im = Image.fromarray(filtered_img.astype(np.uint8))
im.show()
im.save("../images_islenmis/salt_paper_grv3.jpg")
# Sonucu dosyaya yazma
with open('../salt_pepper_noise.txt', 'w') as f:
    for row in filtered_img[1:-1,1:-1].flatten():
        f.write(str(row) + '\n')

