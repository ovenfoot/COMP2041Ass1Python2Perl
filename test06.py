#!/usr/bin/python

testarray = [11,5,10,12,13,4]

x = testarray.pop()
print x

testarray.append(18)
x = testarray.pop()
print x

print testarray[2]

testarray = sorted(testarray)

print testarray[0]

testarray = sorted([11,5,10,12,13,4])
print testarray[0]