with open("eq_verilog.txt", "r") as f:
    total = sum(map(int, f.readlines()))

print(total)
