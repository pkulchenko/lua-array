-- benchmark table
--local t = {}
--local t2 = {}

-- benchmark array
local t = table.newarray()
local t2 = table.newarray()

-- insert
local start = os.clock()
for i=1,10000000 do
	t[i] = i
end
print("Insert: ", os.clock() - start)

-- write
local start = os.clock()
for i=1,10000000 do
	t[i] = i
end
print("Write:  ", os.clock() - start)

-- read
local start = os.clock()
local x
for i=1,10000000 do
	x = t[i]
end
print("Read:   ", os.clock() - start)

-- push back
local start = os.clock()
for i=1,10000000 do
	t2[#t2+1] = i
end
print("Push:   ", os.clock() - start)
