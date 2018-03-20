This is a experimental patch/hack that adds "first class citizen" support for arrays to Lua 5.4-work1. The goal of the patch is to not be a production ready solution -- there are surely several bugs with the implementation. For example, the Lua C API and metatables have not been tested at all. It should be merely treated as a proof of concept that could be used to evaluate the general feasibility of arrays in Lua.

Arrays are implemented as a subtype of tables. In fact, the implementation reuses the table data structures inside Lua VM. Internally an array is a table with only integer keys starting at index 1 and all key-values are stored in the array part of the table data structure.

An array does not suffer from the problem with holes, a well known issue with Lua tables and the '#' length operator, because an array always has an explicit size. Insertions to an array potentially enlarges the array, so that if a new key is outside the bounds of the array, the array is resized to make it fit. To shrink an array, the code has to be explicit about it by using the table.resize() or table.remove() functions. An array can be considered to be a dense table (as opposed to sparse regular Lua tables). 

Elements of an array are always stored sequentially in memory, so value retrieval and setting happen in constant time, provided that the array is sufficiently large to fit the new keys. Similarly '#' length operator is always O(1). This has positive performance implications (especially when scatter reading or writing to an array) compared to regular tables (see benchmarks).

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

-- caveat: syntactic sugar for function call syntax f{...} -> f({...}) does not have
-- an equivalent sugar for arrays because the grammar would be ambiguous
local a = fun[1] 	-- indexing table 'fun' (never a function call)

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

-- table.pack() is not needed for a version of Lua with arrays, as nils and array size can be stored in an array naturally
-- tables a and b would be equivalent:
local a = pack(1, 2, 3)
local b = [1, 2, 3]

-- table.unpack() works with arrays as you'd expect:
table.unpack([1, nil, 3]) --> 1, nil, 3
~~~~
