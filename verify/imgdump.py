from PIL import Image
import numpy as np
import argparse

parser = argparse.ArgumentParser(description = "herhangi bir gorseli 300x300 boyutunda gri tonlamali gosterimindeki veriye cevirir")

parser.add_argument('--gorsel_path', help="cevrilecek dosya")

args = parser.parse_args()

im = Image.open(args.gorsel_path).convert('L')
#im = im.resize((320, 240))
p = np.array(im)

print(p)
print(p.shape)

output = ""

for row in p:
    for col in row:
        output += f"{col:02x}\n"



f = open('cevrilmis.txt', 'w')
f.write(output)