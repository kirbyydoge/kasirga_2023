from fxpmath import Fxp
import math

M = 8
ONLY_DISTINCT = False

lookup = {}

# for i in range(8):
#     for j in range(8):
#         x = Fxp(math.cos((math.pi * (2*i + 1) * j) / (2 * M)), True, 32, 16)
#         key = x.bin(frac_dot=False)
#         if not ONLY_DISTINCT:
#             print(key, end=" ")
#             print("{:03b}{:03b}".format(i, j), end=" ")
#         if key not in lookup:
#             lookup[key] = f"IDCT_COS_VAL{len(lookup)}"
#             if ONLY_DISTINCT:
#                 print(key, end=" ")
#                 print(f"{i} {j}", end=" ")
#                 print(lookup[key])
#         if not ONLY_DISTINCT:
#             print(lookup[key])

print(Fxp(math.sqrt(1/8), True, 32, 16).bin())
print(Fxp(math.sqrt(2/8), True, 32, 16).bin())
                    
