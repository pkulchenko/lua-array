local a = table.newarray(1,2,3)
assert(#a == 3)

a[1] = -1
assert(a[1] == -1)
assert(#a == 3)

a[5] = 5
assert(#a == 5)

a[5] = nil
assert(#a == 5)

do
	local a = table.newarray()
	for i=5,15 do
		a[i] = i
		assert(#a == i)
	end
end
