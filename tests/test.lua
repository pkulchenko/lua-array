local errors = false

function assert(cond)
	if not cond then
		local line = debug.getinfo(2).currentline
		print("test failed at line " .. line)
		errors = true
	end
end

-- test array constructor
do
	local a = [1, 2, 3]
	assert(a[1] == 1)
	assert(a[2] == 2)
	assert(a[3] == 3)
	assert(#a == 3)
end

-- test nested array constructor
do
	local a = [1, 2, 3, [4, 5]]
	assert(a[1] == 1)
	assert(a[2] == 2)
	assert(a[3] == 3)
	assert(a[4][1] == 4)
	assert(a[4][2] == 5)
	assert(#a == 4)
end

-- test array write
do
	local a = [1, 2, 3]
	a[1] = -1
	assert(a[1] == -1)
	assert(#a == 3)
end

-- test array extend
do
	local a = [1, 2, 3]
	a[5] = 5
	assert(a[5] == 5)
	assert(#a == 5)
end

-- test array extend 2
do
	local a = []
	for i=5,15 do
		a[i] = i
		assert(a[i] == i)
		assert(#a == i)
	end
end

-- test setting element to nil (should not affect array size)
do
	local a = [1, 2, 3]
	a[3] = nil
	assert(a[3] == nil)
	assert(#a == 3)
end

-- test array with holes
do
	local a = [1, nil, 3]
	assert(a[1] == 1)
	assert(a[2] == nil)
	assert(a[3] == 3)
	assert(#a == 3)
	a[1] = nil
	assert(#a == 3)
end

-- test filling hole in array
do
	local a = [1, nil, 3]
	a[2] = 2
	assert(a[2] == 2)
	assert(#a == 3)
end

-- test filling hole in array 2
do
	local a = [1, nil, 3]
	local i = 2
	a[i] = 2
	assert(a[2] == 2)
	assert(#a == 3)
end

-- test array reserve (array growing)
do
	local a = [1, 2, 3]
	table.reserve(a, 1000)
	assert(#a == 1000)
	a[1] = 4
	a[10] = 10
	a[11] = 11
	assert(#a == 1000)
end

-- test array reserve (array not growing)
do
	local a = [1, 2, 3, 4, 5]
	table.reserve(a, 3)
	assert(#a == 5)
end

-- test non-const integer
do
	local a = []
	local y = 3
	a[y] = 66
	assert(a[3] == 66)
	assert(#a == 3)
end

-- test table.insert()
do
	local a = [1, 2, 3]
	table.insert(a, 1, "new")
	assert(a[1] == "new")
	assert(a[2] == 1)
	assert(a[3] == 2)
	assert(a[4] == 3)
	assert(#a == 4)
end

-- test table.remove()
do
	local a = [1, 2, 3]
	print("#a before = ", #a)
	table.remove(a, 1)
	assert(a[1] == 2)
	assert(a[2] == 3)
	print("#a after = ", #a)
	assert(#a == 2)
end

if not errors then
	print("All tests passed!")
end
