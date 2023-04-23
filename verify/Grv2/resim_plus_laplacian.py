with open('../cevrilmis.txt', 'r') as f:
    hex_data = f.read().split()

pixels = [int(pixel, 16) for pixel in hex_data]

with open('filtered_resim1.txt', 'r') as f:
    dec_data = f.read().split()

pixels2 = [int(pixel) for pixel in dec_data]

new_pixels = []
for i in range(len(pixels)):
    new_pixel = pixels[i] + pixels2[i]
    if new_pixel > 255:
        new_pixel = 255
    elif new_pixel < 0:
        new_pixel = 0
    new_pixels.append(new_pixel)

with open('../edge_enhancement.txt', 'w') as f:
    for i in range(len(new_pixels)):
        #if i==422:
        #    f.write(str(new_pixels[i]) +"***\n")
        #else:
        f.write(str(new_pixels[i]) + '\n')

from PIL import Image
img = Image.new('L', (320, 240))
img.putdata(new_pixels)
img.show()
img.save("../images_islenmis/edge_enhancement_grv2.jpg")
