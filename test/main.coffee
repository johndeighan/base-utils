A = () ->
	for x from B()
		output x

B = () ->
	output 13
	yield 5
	yield from D()

D = () ->
	yield 1
	yield 2
