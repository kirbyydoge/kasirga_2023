from fxpmath import Fxp
import math

MN = 8
ONLY_DISTINCT = True

test_block = [0 for i in range(64)]
test_block[0] = Fxp(160, True, 18, 3)
test_block[1] = Fxp(11, True, 18, 3)
test_block[9] = Fxp(-48, True, 18, 3)
test_block[17] = Fxp(117, True, 18, 3)

res_block = [0 for i in range(64)]

def idct_single_err(img, m, n):
    M = 8
    N = 8
    total_sum = Fxp(0, True, 18, 3)
    print(f"**** BEGIN {m} {n} ****")
    for p in range(8):
        for q in range(8):
            print(f"**** STEP {p} {q} ****")
            alpha_p = Fxp((1 / math.sqrt(M)) if p == 0 else (math.sqrt(2 / M)), True, 18, 3, rounding="floor")
            alpha_q = Fxp((1 / math.sqrt(N)) if q == 0 else (math.sqrt(2 / N)), True, 18, 3, rounding="floor")
            cos_mp = Fxp(math.cos((math.pi * (2 * m + 1) * p) / (2 * M)), True, 18, 3, rounding="floor")
            cos_nq = Fxp(math.cos((math.pi * (2 * n + 1) * q) / (2 * N)), True, 18, 3, rounding="floor")
            matrix_val = Fxp(img[p * 8 + q], True, 18, 3, rounding="floor")
            alpmul = Fxp(None, True, 18, 3, rounding="floor")
            cosmul = Fxp(None, True, 18, 3, rounding="floor")
            cosalp = Fxp(None, True, 18, 3, rounding="floor")
            result = Fxp(None, True, 18, 3, rounding="floor")
            alpmul.equal(alpha_p * alpha_q)
            cosmul.equal(cos_mp * cos_nq)
            cosalp.equal(cosmul * alpmul)
            result.equal(cosalp * matrix_val)
            print(f"alpha_p     : {alpha_p.bin()}")
            print(f"alpha_q     : {alpha_q.bin()}")
            print(f"cos_mp      : {cos_mp.bin()}")
            print(f"cos_nq      : {cos_nq.bin()}")
            print(f"matrix_val  : {matrix_val.bin()} {hex(int(str(matrix_val.bin()), 2))}")
            print(f"alpmul      : {alpmul.bin()}")
            print(f"cosmul      : {cosmul.bin()}")
            print(f"cosalp      : {cosalp.bin()}")
            print(f"result      : {result.bin()}")
            total_sum.equal(total_sum + result)
    return total_sum        

for m in range(8):
    for n in range(8):
        res_block[m * 8 + n] = idct_single_err(test_block, m, n)
        
for m in range(8):
    for n in range(8):
        print(res_block[m * 8 + n].bin())
        