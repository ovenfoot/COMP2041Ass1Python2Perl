#!/usr/bin/python

x=2
x= x << 1
print x
x= x >> 1
print x
y = 4
y= y & x
print y&x
y=4
print y|x

z = x^y
print z

z = ~y
#print z

