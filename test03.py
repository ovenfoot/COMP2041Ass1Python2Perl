#!/usr/bin/python
x = 0
y = 0
while (x<10):
   while (y < 10):
      y = y+1
      print y
      if (y%2 ==0):
         print "even"
      else:
         print "odd"
   x = x + 1
   y = 0

