import numpy as np
from PIL import Image

# Daha az satir lazimsa bunu ayarla
NUM_LINES = -1

lines = []
with open("view.txt", "r", encoding="utf-16") as f:
    for line in f:
        lines.append(line)

if NUM_LINES < 0:
    NUM_LINES = len(lines)//320
lines = lines[:NUM_LINES*320]
img = np.array([x.strip() for x in lines], np.uint8)
Image.fromarray(img.reshape(NUM_LINES, 320)).show()
Image.fromarray(img.reshape(NUM_LINES, 320)).save("./fpga_images_islenmis/median1_salt_paper.png")