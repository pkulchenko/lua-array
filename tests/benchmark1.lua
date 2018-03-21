repeat_count = 5	-- how many times to repeat tests

function printf(...)
	print(string.format(...))
end

function print_results(results)
	local tests = { "Insert", "Write", "Read", "Push", "Scatter-write", "Scatter-read" }
	for i=1,#results do
		printf("%-16s %fs", tests[i], results[i])
	end
end

function run_benchmarks(table_ctor)
	local t = table_ctor()
	local t2 = table_ctor()
	local t3 = table_ctor()

	-- accumulated results
	local acc = {}

	for cnt=1,repeat_count do
		io.write(string.format("\r%d%%", (cnt-1) * 100 / repeat_count))
		io.flush()
		collectgarbage()
		collectgarbage()

		local results = {}

		-- insert
		local start = os.clock()
		for i=1,10000000 do
			t[i] = i
		end
		results[1] = os.clock() - start

		-- write
		local start = os.clock()
		for i=1,10000000 do
			t[i] = i
		end
		results[2] = os.clock() - start

		-- read
		local start = os.clock()
		local x
		for i=1,10000000 do
			x = t[i]
		end
		results[3] = os.clock() - start

		-- push back
		local start = os.clock()
		for i=1,10000000/2 do
			t2[#t2+1] = i
		end
		results[4] = os.clock() - start

		-- init random number for scatter read/write benchmarks
		math.randomseed(12345)
		for i=1,10000000 do
			local j = math.random(1, #t)
			t[i],t[j] = t[j],t[i]
		end

		-- scatter write
		local start = os.clock()
		for i=1,10000000/2 do
			local pos = t[i]
			t3[pos] = i
		end
		results[5] = os.clock() - start

		-- scatter read
		local start = os.clock()
		math.randomseed(12345)
		local x
		for i=1,10000000 do
			local pos = t[i]
			x = t3[pos]
		end
		results[6] = os.clock() - start

		-- accumulate
		for i=1,#results do
			acc[i] = (acc[i] or 0.0) + results[i]
		end
	end

	io.write("\r")

	-- normalize results
	for i=1,#acc do
		acc[i] = acc[i] / repeat_count
	end

	print_results(acc)
end

print("Running benchmarks using tables...")
run_benchmarks(function() return {} end)

print("")

if table.resize then
	print("Running benchmarks using arrays...")
	local newarray = load("return function() return [] end")()
	run_benchmarks(newarray)
else
	print("No arrays available; array benchmarks skipped!")
end
