with open("../cevrilmis.txt", "r") as f:
    pixels = []
    for line in f:
        line = line.strip()  # Boşluk karakterlerini kaldırır
        for i in range(0, len(line), 2):
            pixels.append(int(line[i:i+2], 16))

bw_pixels = [0 if p < 128 else 255 for p in pixels]

with open("bw.txt", "w") as f:
    for p in bw_pixels:
        f.write(str(p) + "\n")

