with open("sonuc.txt", "r") as f:
    lines = f.readlines()
    lines = [line.strip() for line in lines]
    lines = ["0" + line if len(line) == 1 else line for line in lines]

with open("sonuc_1.txt", "w") as f:
    for i in range(0, len(lines), 3):
        merged = lines[i+2] + lines[i+1] + lines[i]
        f.write(merged + "\n")



