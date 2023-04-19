import numpy as np
from scipy import ndimage

# bw.txt dosyasından verileri okuyoruz
with open('bw.txt', 'r') as f:
    data = f.read()

# Verileri 1D numpy dizisine dönüştürüyoruz
data = np.fromstring(data, sep=' ')

# Verileri 2D numpy dizisine dönüştürüyoruz
data = data.reshape((240, 320))

# Zeropadding işlemi
data_padded = np.pad(data, pad_width=1, mode='constant', constant_values=0)

# Erosion işlemi
selem = np.array([[1, 1, 1], [1, 1, 1], [1, 1, 1]])
eroded = ndimage.grey_erosion(data_padded, footprint=selem)

# Erozyon sonucunu dosyaya yazdırma
eroded = eroded[1:-1, 1:-1]  # padding'i kaldır
eroded = eroded.reshape((240*320))  # 1D diziyi elde et
with open('erosion.txt', 'w') as f:
    for i in range(240):
        for j in range(320):
            f.write(str(int(eroded[i*320+j])) + '\n')
