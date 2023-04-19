a = open("sonuc_decimal.txt","r")
b = open("histogram_esitleme.txt","r")

for i in range(320*240):
    k=a.readline()
    l=b.readline()
    if k != l:
        print(i)
        print("k: {}l: {}".format(k,l))
    
a.close()
b.close()