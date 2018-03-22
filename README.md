This is a experimental patch for Lua 5.4-work1 that adds first class support for arrays. The goal of the patch is to not be a production ready solution -- there are surely several bugs with the implementation. For example, the Lua C API and metatables have not been tested at all. It should be merely treated as a proof of concept that could be used to evaluate the general feasibility of arrays in Lua.

Arrays are implemented as a subtype of tables. In fact, the implementation reuses the table data structures inside Lua VM. Internally an array is a table with only integer keys starting at index 1 and all key-values are stored in the array part of the table data structure.

An array does not suffer from the problem with holes, a well known issue with Lua tables and the '#' length operator, because an array always has an explicit size. Insertions to an array potentially enlarges the array, so that if a new key is outside the bounds of the array, the array is resized to fit the new element. To shrink an array, the code has to be explicit about it by using the table.resize() or table.remove() functions. An array can be considered to be a dense table (as opposed to sparse regular Lua tables). 

Elements of an array are always stored sequentially in memory, so value retrieval and setting happen in constant time, provided that the array access is within the bounds of the array. The '#' length operator for arrays is O(1). Together these have positive performance implications compared to regular tables.

The implementation has been carefully designed to not negatively affect the performance of regular Lua tables (see benchmarks and implementation notes at the end).

~~~~
-- arrays are constructed using [...] syntax
local a = [1, 2, 3, [4, 5]]

-- an array can contain nils without problems
local a = [1, nil, 2, 3, nil]
print(#a) --> 5

-- caveat: array indices can only be positive (non-zero) integers
local a = []
a[-1] = 1 	--> error: invalid array index
a.foo = 1 	--> error: invalid array index

-- caveat: array are dense by nature and array constructors don't support named or sparse elements
-- use tables if you need them
local a = [1, [3] = true]	--> syntax error
local a = [1, b = true]		--> syntax error

-- arrays grow to fit new keys automatically
local a = []
a[10] = true
print(#a) --> 10

-- table.insert() works on arrays as well as regular tables
local a = [1, 2]
table.insert(a, 3) --> a = [1, 2, 3]

-- setting a value to nil never resizes an array
local a = [1,2,3]
print(#a) --> 3
a[3] = nil
print(#a) --> 3

-- table.resize() can be used to explicitly resize an array
local a = []
table.resize(a, 10)
print(#a) --> 10

-- table.remove() also resizes the array
local a = [1, 2, 3]
table.remove(a, 1)	--> a = [2, 3]

-- table.pack() is not needed for a version of Lua with arrays, as nils  
-- can be stored naturally in an array
local a = table.pack(1, 2, 3)	-- not needed	
local a = [1, nil, 3]			-- use this instead

-- table.unpack() works with arrays as you'd expect
table.unpack([1, nil, 3]) --> 1, nil, 3

-- there is no difference between pairs() and ipairs(); both iterate all integer keys of an array in numeric order
for i,v in ipairs([1,nil,3,nil]) do print(i, v) end
--> (1 1) (2 nil) (3 3) (4 nil)

-- syntactic sugar for function call syntax f{...} -> f({...}) does not have
-- an equivalent for arrays because the grammar would be ambiguous
local a = fun[1] 	-- indexing table 'fun'
local a = fun([1])	-- call function 'fun' with array as an argument
~~~~

# Benchmarks

A number of benchmarks stressing table and array operations were run on unmodified and patched version of Lua 5.4. The benchmarks were repeated 4 times and the best result was chosen in each case out of these 4 runs. See the following table. In the "Unmodified Tables" column are the results for unmodified Lua 5.4-work1. The "Patched Tables" column shows the results of the benchmarks for patched Lua but still using regular tables. The "Patches Arrays" column shows the results for the benchmarks when using arrays.

The benchmarks show that there is no noticeable performance difference between the unmodified and patched version of Lua when using tables. The small differences in execution times vary from run to run because of varying system load, base address randomization of the Lua executable and other factors. The first two columns show that the addition of an array subtype for tables does not negatively impact the performance of regular tables. When using arrays, "Push" and "Length" benchmarks show significant performance increases, and "Insert", "Scatter-Write" and "Scatter-read" are also clearly faster. The major performance increase of "Push" and "Length" is mainly due to the O(1) implementation of the '#' operator.

~~~~
Benchmark        Unmodified    Patched   Patched
                 Tables        Tables    Arrays

Insert           0.352s        0.359s    0.319s
Write            0.470s        0.478s    0.456s
Read             0.429s        0.423s    0.420s
Push             2.268s        2.323s    0.419s
Scatter-write    0.217s        0.203s    0.180s
Scatter-read     0.200s        0.208s    0.170s
Length           1.999s        1.969s    0.124s
~~~~

## About the benchmarks

The benchmarks were run on macOS 10.13.3 with a Intel Core i7 CPU running at 2.3 GHz and with 8 GB 1600 MHz DDR3 RAM. For benchmarking Lua API checks were disabled and the code was compiled with the same version of the C compiler using the same options (-O2). If you want to repeat the benchmarks, the unmodified Lua sources can be found in this repository in the "unmodified" branch.

Insert: Starting with an empty table, this does a large number of table/array insertions to sequential indices. The point of this benchmark is to test the efficiency of growing the table/array data structure.

Write/read: These benchmarks stress setting and getting existing indices of a table/array.

Push: Does a large number of inserts using the "t[#t+1] = value" Lua idiom.

Scatter-write/scatter-read: Does a large number of random accesses to a table/array.

Length: Tests the performance of the '#' operator.

The code for benchmarks can be found in tests/benchmark1.lua.

# Summary and conclusions

The main contributions of this work are:
* The addition of a new high performance array subtype for tables, which does not negatively affect the performance of regular tables (within measurement precision).
* The arrays don't suffer from the issue with holes (also see Opinions below how the hole issue can be resolved in the future for regular tables).
* "[...]" syntax for arrays.
* Arrays have been implemented in a way that is fully backwards compatible, meaning that old Lua programs can be run without modification with the patched Lua interpreter.

The work shows that Lua could benefit from an array subtype for tables.

# Opinions

From a purely theoretical point of view, the inclusion of a new subtype adds some weight to the language, but from a more pragmatic view, the increased performance and fixing the hole issue overweights the theoretical issue. Moving forward, if arrays would be adopted to mainstream Lua, the '#' operator could be deprecated for tables and eventually made an array only feature. Of course, the '#' could still be implemented using a metatable for tables if needed. This would be the final nail in coffin for the hole issue.

With the addition of arrays another small wart in the language, the 'n' field of the table returned by table.pack(), could be eliminated by changing table.pack() to return an array. Since the array has a well defined length, the 'n' field would not be required. This would however break backwards compatibility, so this could be an opt-in feature at first.

In addition to the other benefits, in my opinion the inclusion of an array type would clarify the intent of Lua code, because the code explicitly uses the "[..]" syntax when creating an array.

# Implementation details

The implementation adds two new fields to the Table structure: "truearray" and "sizeused". True array is a single boolean that does not increase the memory consumption of Table struct, because of C struct packing and alignment rules. "Sizeused" is used to track the used size of the array as reported by '#', and it adds 4 or 8 bytes (depending whether Lua is compiled as a 32 or 64-bit application) to the size of the struct, but this does not seem to affect the CPU cache hit ratio or slow down the interpreter.

The implementation has been carefully designed to not increase the size of the main VM loop, which could negatively affect performance. Particularly no new opcodes have been added to the VM. Incrementing "sizeused" when setting array elements is implemented without branching and CPU cache usage has also been taken into account.
