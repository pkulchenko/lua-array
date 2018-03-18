a = table.newarray(1, nil, 3)
table.reserve(a, 1000)
print(#a)
a[1] = 4
a[10] = 6

local y = 1
a[y] = 66
print(#a)
print(a[1], a[2], a[3], a[4], a[10])