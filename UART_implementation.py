import serial
import struct
import time
import sys
#-------------------------------------------------------------------------------

ClockTicks = 0x00
Buttons    = 0x01
LEDs       = 0x02
#-------------------------------------------------------------------------------

def Write(s, Address, Data):
    s.write(struct.pack('<BBBBBI', 0x55, 0x01, 0xAA, 0x05, Address, Data))
#-------------------------------------------------------------------------------

def Read(s, Address):
    s.write(struct.pack('<BBBBB', 0x55, 0x00, 0xAA, 0x01, Address))
    return struct.unpack_from('<I', s.read(9), offset=5)[0]
#-------------------------------------------------------------------------------
#character = struct.pack('<B',0x61)

with serial.Serial(port='COM6', baudrate=115200) as s:
    s.write(struct.pack('<B',0x62))
    s.write(struct.pack('<B',0x42))
    s.write(struct.pack('<B',0x62))
    s.write(struct.pack('<B',0x42))
    print(s.read())
    print(s.read())
    print(s.read())
    print(s.read())
   



#print(struct.pack('<BB',0x61,0x41))
#-------------------------------------------------------------------------------