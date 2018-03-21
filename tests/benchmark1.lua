function printf(...)
	print(string.format(...))
end

function run_benchmarks(table_ctor)
	local t = table_ctor()
	local t2 = table_ctor()
	local t3 = table_ctor()
	
	-- insert
	local start = os.clock()
	for i=1,10000000 do
		t[i] = i
	end
	printf("Insert        %fs", os.clock() - start)

	-- write
	local start = os.clock()
	for i=1,10000000 do
		t[i] = i
	end
	printf("Write         %fs", os.clock() - start)

	-- read
	local start = os.clock()
	local x
	for i=1,10000000 do
		x = t[i]
	end
	printf("Read          %fs", os.clock() - start)

	-- push back
	local start = os.clock()
	for i=1,10000000 do
		t2[#t2+1] = i
	end
	printf("Push          %fs", os.clock() - start)

	-- init random number for scatter read/write benchmarks
	math.randomseed(12345)
	for i=1,10000000 do
		local j = math.random(1, #t)
		t[i],t[j] = t[j],t[i]
	end

	-- scatter write
	local start = os.clock()
	for i=1,10000000 do
		local pos = t[i]
		t3[pos] = i
	end
	printf("Scatter-write %fs", os.clock() - start)

	-- scatter read
	local start = os.clock()
	math.randomseed(12345)
	local x
	for i=1,10000000 do
		local pos = t[i]
		x = t3[pos]
	end
	printf("Scatter-read  %fs", os.clock() - start)
end

print("Running benchmarks using tables:")
run_benchmarks(function() return {} end)

print("")
collectgarbage()
collectgarbage()

if table.reserve then
	print("Running benchmarks using arrays:")
	run_benchmarks(function() return [] end)
else
	print("No arrays available; array benchmarks skipped!")
end
