with open("a.txt", "r") as file:
    words = file.read().split()

with open("b.txt", "w") as file:
    for index, word in enumerate(words):
        word = word[2:]
        file.write(f"   tablo[{index}] <= 16'h{word};\n")
