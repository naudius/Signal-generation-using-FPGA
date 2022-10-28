from math import ceil, sin, pi
import sys

rows = 1024
width = 10

fmt_width = str(ceil(width/4))  #width in hex 
fmt_string = "{}  //{:03}: {:.4f}: {:04}"
step = (pi)/rows

for i in range(rows):
    x = step*i-pi/2
    res =round(512+512*sin(x))
    if (res==1024):
        res = 1023
    Dn = format(res,"010b")
    rev_Dn = ''.join(reversed(Dn))
    #print(rev_Dn)
    print(fmt_string.format(rev_Dn, i, x, res))