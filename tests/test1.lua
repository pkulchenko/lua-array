print("creating new array")
x = table.newarray(1, 2, 3, "foo")

print("getting array size")
print(#x)

print("getting array values")
print("x[1] = ", x[1])
print("x[4] = ", x[4])
print("x.foo = ", x.foo)
y = 1
print("x[y] = ", x[y])

print("setting array value")
x[1] = 2
x[y] = 3
print("x[y] = ", x[y])

x.foo = 3
print("x[1] = ", x[1])
