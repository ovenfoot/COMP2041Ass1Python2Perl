#written by andrewt@cse.unsw.edu as test for ass1 COMP2041
#!/usr/bin/python

n = 1
while n <= 10:
    total = 0
    j = 1
    while j <= n:
        i = 1
        while i <= j:
            total = total + i
            i = i + 1
        j = j + 1
    print total
    n = n + 1
