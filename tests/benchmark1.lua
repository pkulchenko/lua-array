local t = { 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16 }
local a = table.newarray(1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16)

local x
local start = os.clock()
for i=1,10000000 do
	x = t[1]
	x = t[2]
	x = t[3]
	x = t[4]
	x = t[5]
	x = t[6]
	x = t[7]
	x = t[8]
	x = t[9]
	x = t[10]
	x = t[11]
	x = t[12]
	x = t[13]
	x = t[14]
	x = t[15]
	x = t[16]
end
print("Table read: ", os.clock() - start)

local start = os.clock()
for i=1,10000000 do
	x = a[1]
	x = a[2]
	x = a[3]
	x = a[4]
	x = a[5]
	x = a[6]
	x = a[7]
	x = a[8]
	x = a[9]
	x = a[10]
	x = a[11]
	x = a[12]
	x = a[13]
	x = a[14]
	x = a[15]
	x = a[16]
end
print("Array read: ", os.clock() - start)

local x
local start = os.clock()
for i=1,10000000 do
	t[1] = 1
	t[2] = 1
	t[3] = 1
	t[4] = 1
	t[5] = 1
	t[6] = 1
	t[7] = 1
	t[8] = 1
	t[9] = 1
	t[10] = 1
	t[11] = 1
	t[12] = 1
	t[13] = 1
	t[14] = 1
	t[15] = 1
	t[16] = 1
end
print("Table write: ", os.clock() - start)

local start = os.clock()
for i=1,10000000 do
	a[1] = 1
	a[2] = 1
	a[3] = 1
	a[4] = 1
	a[5] = 1
	a[6] = 1
	a[7] = 1
	a[8] = 1
	a[9] = 1
	a[10] = 1
	a[11] = 1
	a[12] = 1
	a[13] = 1
	a[14] = 1
	a[15] = 1
	a[16] = 1
end
print("Array write: ", os.clock() - start)
