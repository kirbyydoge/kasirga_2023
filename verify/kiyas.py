a = open("kiyas1.txt","r")
b = open("kiyas2.txt","r")

for i in range(320*240):
    k=a.readline()
    l=b.readline()
    if k != l:
        print(i)
        print("k: {}l: {}".format(k,l))
    
a.close()
b.close()