import serial
import argparse
import time
 
parser = argparse.ArgumentParser(description='')
parser.add_argument('--port' , '-v', default='COM8')
parser.add_argument('img')

args = parser.parse_args()

ser_port = args.port
im_path = args.img

encoded = ""
with open(im_path, "r", encoding="utf-8") as f:
    encoded = f.readlines()
encoded = "".join(line.lstrip().strip() for line in encoded)

if len(encoded) % 8 != 0:
    encoded += "0" * (8 - (len(encoded) % 8))

encoded_bytes = int(encoded, 2).to_bytes(len(encoded) // 8, byteorder='big')

ser = serial.Serial(ser_port, 9600, timeout=None, write_timeout=None)

for byte in encoded_bytes:
    ser.write(bytes([byte]))


for i in range(320*240):
    byte = ser.read(1)
    val = int.from_bytes(byte, 'little')
    print(val)