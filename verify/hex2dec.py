import os

# Dosyaların yollarını tanımla
sonuc_file_path = "sonuc.txt"
eq_file_path = "sonuc_decimal.txt"

#sonuc_file_path = "cevrilmis.txt"
#eq_file_path = "cevrilmis_dec.txt"

# sonuc.txt dosyasındaki alt alta yazılan hexadecimal sayıları eq_verilog.txt dosyasına decimal olarak alt alta yazan fonksiyon
def hex_to_dec():
    # Dosyaların var olup olmadığını kontrol et
    if not os.path.isfile(sonuc_file_path):
        print(f"{sonuc_file_path} dosyası bulunamadı!")
        return
    if os.path.isfile(eq_file_path):
        print(f"{eq_file_path} dosyası zaten var, üzerine yazılacak!")
        
    # Dosyaları aç ve oku
    with open(sonuc_file_path, "r") as sonuc_file:
        sonuc_hex = sonuc_file.read().splitlines()

    # Hexadecimal sayıları decimal'e çevir
    sonuc_dec = [int(hex_num, 16) for hex_num in sonuc_hex]

    # Decimal sayıları eq_verilog.txt dosyasına yaz
    with open(eq_file_path, "w") as eq_file:
        eq_file.write('\n'.join(str(dec_num) for dec_num in sonuc_dec))
    
    print(f"{sonuc_file_path} dosyasındaki hexadecimal sayılar {eq_file_path} dosyasına yazıldı.")


# hex_to_dec() fonksiyonunu çağırarak işlemi başlat
hex_to_dec()
