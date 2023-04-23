with open('../cevrilmis.txt', 'r') as f:
    hex_data = f.read().split()

pixels = [int(pixel, 16) for pixel in hex_data]

with open('erosion.txt', 'r') as f:
    dec_data = f.read().split()

pixels2 = [int(pixel) for pixel in dec_data]

new_pixels = []
for i in range(len(pixels)):
    if i==422:
        print(pixels[i] + pixels2[i])
    new_pixel = pixels[i] + pixels2[i]
    if new_pixel > 255:
        new_pixel = 255
    elif new_pixel < 0:
        new_pixel = 0
    new_pixels.append(new_pixel)

with open('../boundary_extraction.txt', 'w') as f:
    for i in range(len(new_pixels)):
        #if i==422:
        #    f.write(str(new_pixels[i]) +"***\n")
        #else:
        f.write(str(new_pixels[i]) + '\n')

from PIL import Image
img = Image.new('L', (320, 240))
img.putdata(new_pixels)
img.show()
img.save("../images_islenmis/boundry_extraction_grv6.jpg")
