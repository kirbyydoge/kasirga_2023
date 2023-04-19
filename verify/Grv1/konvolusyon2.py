from PIL import Image
import numpy as np

# Txt dosyasından pixelleri oku ve hexadecimal değerleri decimal değerlere dönüştür
with open('filtered_resim1.txt') as f:
    content = f.readlines()

pixels = []
for line in content:
    row = []
    hex_values = line.strip().split()
    for hex_val in hex_values:
        decimal_val = int(hex_val)
        row.append(decimal_val)
    pixels.append(row)

# Matrise dönüştür
img = np.array(pixels)

# Matrisin boyutunu (320, 240) olarak ayarla
img = img.reshape(240, 320)

# Matrisin etrafını sıfırlarla çerçevele
img_padded = np.pad(img, ((1, 1), (1, 1)), mode='constant')

# 3x3'lük bir filtre uygula

# sobel_Y
filter = np.array([[1, 2, 1], [0, 0, 0], [-1, -2, -1]], dtype=np.float32)



filtered_pixels = np.zeros_like(img_padded, dtype=np.int64)
for i in range(1, img_padded.shape[0] - 1):
    for j in range(1, img_padded.shape[1] - 1):
        filtered_pixels[i, j] = np.sum(img_padded[i-1:i+2, j-1:j+2] * filter)

# Sonuç matrisindeki elemanları istenilen şekilde düzenle ve txt dosyasına kaydet
a=0
with open('../edge_detection.txt', 'w') as f:
    for row in filtered_pixels[1:-1, 1:-1]:
        # 255'ten büyük olan değerleri 255'e eşitle
        row[row > 255] = 255
        # Negatif değerleri 0'a eşitle
        row[row < 0] = 0
        for val in row:
            # Her bir piksel değeri yeni bir satıra yazılır
            f.write(str(int(round(val))) + '\n')

# Filtrelenmiş pixelleri görüntü olarak göster
filtered_img = Image.fromarray(filtered_pixels[1:-1, 1:-1].astype(np.uint8))
filtered_img.show()

# Orjinal pixelleri görüntü olarak göster
img = Image.fromarray(img.astype(np.uint8))
img.show()

