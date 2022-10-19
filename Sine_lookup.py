from math import ceil, sin, pi
import sys

rows = int(input("Please input number of rows:"))
width = int(input("Please input width of columns"))

fmt_width = str(ceil(width/4))  #width in hex 
fmt_string = "{:0" + fmt_width + "X}  // {:03}: {:.4f}"
step = (pi/2)/rows

for i in range(rows):
    x = step* i
    res = sin(x)
    res_scaled = round((2**width) * res)
    if res_scaled == 2**width:  # maximum value uses too many bits
        res_scaled -= 1;        # accompanying Verilog module handles this
    print(fmt_string.format(res_scaled, i, res))