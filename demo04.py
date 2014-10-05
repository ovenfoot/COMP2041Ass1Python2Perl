#writen by andrewt@cse.unsw.edu.au for ASS1 testing COM2041

#!/usr/bin/python
import sys
x = 1
while x < 10:
    y = 1
    while y <= x:
        sys.stdout.write("*")
        y = y + 1
    print
    x = x + 1
