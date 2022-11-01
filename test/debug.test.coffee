# debug.test.coffee

import test from 'ava'

import {
	undef, pass, arrayToBlock, isNumber, isArray, spaces,
	} from '@jdeighan/exceptions/utils'
import {toTAML} from '@jdeighan/exceptions/taml'
import {
	haltOnError, assert, croak,
	} from '@jdeighan/exceptions'
import {getPrefix} from '@jdeighan/exceptions/prefix'
import {utReset, LOG, utGetLog} from '@jdeighan/exceptions/log'
import {
	setDebugging, resetDebugging, setCustomDebugLogger,
	debug, getType, dumpDebugLoggers,
	} from '@jdeighan/exceptions/debug'

# ---------------------------------------------------------------------------

test "line 20", (t) =>
	setDebugging "myfunc"
	t.deepEqual(
		getType("something"),
		["string", undef])
	resetDebugging()

test "line 27", (t) =>
	setDebugging "myfunc"
	t.deepEqual(
		getType("enter myfunc"),
		["enter", "myfunc"])
	resetDebugging()

test "line 34", (t) =>
	setDebugging "myfunc"
	t.deepEqual(
		getType("return from X"),
		["returnFrom", 'X'])
	resetDebugging()

# ---------------------------------------------------------------------------

double = (x) =>
	debug "enter double", x
	assert isNumber(x), "not a number"
	debug "inside double"
	result = 2 * x
	debug "return from double", result
	return result

quadruple = (x) =>
	debug "enter quadruple", x
	debug "inside quadruple"
	result = 2 * double(x)
	debug "return from quadruple", result
	return result

# ---------------------------------------------------------------------------

test "line 60", (t) =>

	utReset()
	result = quadruple(3)
	t.is result, 12

# ---------------------------------------------------------------------------

test "line 68", (t) =>

	utReset()
	setDebugging 'double'
	result = quadruple(3)
	resetDebugging()
	t.is result, 12

# ---------------------------------------------------------------------------

test "line 78", (t) =>

	utReset()
	setDebugging 'double'
	result = quadruple(3)
	resetDebugging()
	t.is utGetLog(), """
		enter double
		│   arg[0] = 3
		│   inside double
		└─> return from double
		    ret[0] = 6
		"""

# ---------------------------------------------------------------------------

test "line 94", (t) =>

	utReset()
	setDebugging 'double quadruple'
	result = quadruple(3)
	resetDebugging()
	t.is result, 12
	t.is utGetLog(), """
		enter quadruple
		│   arg[0] = 3
		│   inside quadruple
		│   enter double
		│   │   arg[0] = 3
		│   │   inside double
		│   └─> return from double
		│       ret[0] = 6
		└─> return from quadruple
		    ret[0] = 12
		"""

# ---------------------------------------------------------------------------

test "line 116", (t) =>

	utReset()
	setDebugging 'double', 'quadruple'
	result = quadruple(3)
	resetDebugging()
	t.is result, 12
	t.is utGetLog(), """
		enter quadruple
		│   arg[0] = 3
		│   inside quadruple
		│   enter double
		│   │   arg[0] = 3
		│   │   inside double
		│   └─> return from double
		│       ret[0] = 6
		└─> return from quadruple
		    ret[0] = 12
		"""

# ---------------------------------------------------------------------------

class Class1
	constructor: () ->
		@lStrings = []
	add: (str) ->
		debug "enter Class1.add", str
		@lStrings.push str
		debug "return from Class1.add"
		return

class Class2
	constructor: () ->
		@lStrings = []
	add: (str) ->
		debug "enter Class2.add", str
		@lStrings.push str
		debug "return from Class2.add"
		return

# ---------------------------------------------------------------------------

test "line 158", (t) =>

	utReset()
	setDebugging 'Class1.add Class2.add'
	new Class1().add('abc')
	new Class2().add('def')
	resetDebugging()

	t.is utGetLog(), """
		enter Class1.add
		│   arg[0] = 'abc'
		└─> return from Class1.add
		enter Class2.add
		│   arg[0] = 'def'
		└─> return from Class2.add
		"""

# ---------------------------------------------------------------------------

test "line 177", (t) =>

	utReset()
	setDebugging 'Class2.add'
	new Class1().add('abc')
	new Class2().add('def')
	resetDebugging()

	t.is utGetLog(), """
		enter Class2.add
		│   arg[0] = 'def'
		└─> return from Class2.add
		"""

# ---------------------------------------------------------------------------

test "line 193", (t) =>

	utReset()
	setDebugging 'double quadruple'
	result = double(quadruple(3))
	resetDebugging()
	t.is result, 24
	t.is utGetLog(), """
		enter quadruple
		│   arg[0] = 3
		│   inside quadruple
		│   enter double
		│   │   arg[0] = 3
		│   │   inside double
		│   └─> return from double
		│       ret[0] = 6
		└─> return from quadruple
		    ret[0] = 12
		enter double
		│   arg[0] = 12
		│   inside double
		└─> return from double
		    ret[0] = 24
		"""

# ---------------------------------------------------------------------------
# Test using generators

allNumbers = (lItems) ->

	debug "enter allNumbers"
	for item in lItems
		if isNumber(item)
			debug "yield allNumbers", item
			yield item
			debug "resume allNumbers"
		else if isArray(item)
			debug "yield allNumbers", item
			yield from allNumbers(item)
			debug "resume allNumbers"
	debug "return from allNumbers"
	return

test "line 236", (t) =>
	lItems = ['a', 2, ['b', 3], 5]
	total = 0
	for i from allNumbers(lItems)
		total += i
	t.is total, 10

# ---------------------------------------------------------------------------
# Test custom loggers

test "line 246", (t) =>

	utReset()
	setDebugging 'double quadruple'

	# --- on debug('enter <func>'), just log the function name
	setCustomDebugLogger 'enter',
		(funcName, lObjects, level) ->
			LOG getPrefix(level, 'plain') + funcName
			return true

	# --- on debug('return from <func>'), don't log anything at all
	setCustomDebugLogger 'returnFrom',
		(funcName, lObjects, level) ->
			return true

	result = double(quadruple(3))
	t.is result, 24
	t.is utGetLog(), """
		quadruple
		│   inside quadruple
		│   double
		│   │   inside double
		double
		│   inside double
		"""

# ---------------------------------------------------------------------------

(() ->

	lOutput = undef
	output = (str) -> lOutput.push str

	main = () ->
		A()
		return

	A = () ->
		debug "enter A()"
		C()
		for x from B()
			output x
			C()
		debug "return from A()"
		return

	B = () ->
		debug "enter B()"
		output 13
		debug "yield B()", 5
		yield 5
		debug "resume B()"
		C()
		debug "yield B"
		yield from D()
		debug "resume B"
		debug "return from B()"
		return

	C = () ->
		debug "enter C()"
		output 'here'
		debug "here"
		debug "x", 9
		debug "return from C()"
		return

	D = () ->
		debug "enter D()"
		debug "yield D()", 1
		yield 1
		debug "resume D()"
		debug "yield D()", 2
		yield 2
		debug "resume D()"
		debug "return from D()"
		return

	test "line 69", (t) =>
		lOutput = []
		utReset()
		main()
		t.is arrayToBlock(lOutput), """
			here
			13
			5
			here
			here
			1
			here
			2
			here
			"""
		t.is utGetLog(), undef

	# --- Try with various settings of setDebugging()

	test "line 88", (t) =>
		lOutput = []
		utReset()
		resetDebugging()
		setDebugging "C"
		main()

		# --- C should be called 5 times

		t.is utGetLog(), """
			enter C
			│   here
			│   x = 9
			└─> return from C
			enter C
			│   here
			│   x = 9
			└─> return from C
			enter C
			│   here
			│   x = 9
			└─> return from C
			enter C
			│   here
			│   x = 9
			└─> return from C
			enter C
			│   here
			│   x = 9
			└─> return from C
		"""

	test "line 109", (t) =>
		lOutput = []
		utReset()
		resetDebugging()
		setDebugging "D"
		main()

		# --- D should be called once, yielding twice

		t.is utGetLog(), """
			enter D
			│   yield D
			│   │   arg[0] = 1
			│   yield D
			│   │   arg[0] = 2
			└─> return from D
		"""

	test "line 126", (t) =>
		lOutput = []
		utReset()
		resetDebugging()
		setDebugging "C D"
		main()

		# --- D should be called once, yielding twice

		t.is utGetLog(), """
			enter C
			│   here
			│   x = 9
			└─> return from C
			enter C
			│   here
			│   x = 9
			└─> return from C
			enter C
			│   here
			│   x = 9
			└─> return from C
			enter D
			│   yield D
			│   │   arg[0] = 1
			│   enter C
			│   │   here
			│   │   x = 9
			│   └─> return from C
			│   yield D
			│   │   arg[0] = 2
			│   enter C
			│   │   here
			│   │   x = 9
			│   └─> return from C
			└─> return from D
		"""

	test "line 153", (t) =>
		lOutput = []
		utReset()
		resetDebugging()
		setDebugging "A B C D"
		main()

		# --- debug all

		t.is utGetLog(), """
			enter A
			│   enter C
			│   │   here
			│   │   x = 9
			│   └─> return from C
			│   enter B
			│   │   yield B
			│   │   │   arg[0] = 5
			│   │   enter C
			│   │   │   here
			│   │   │   x = 9
			│   │   └─> return from C
			│   │   resume B
			│   │   enter C
			│   │   │   here
			│   │   │   x = 9
			│   │   └─> return from C
			│   │   yield B
			│   │   enter D
			│   │   │   yield D
			│   │   │   │   arg[0] = 1
			│   │   │   enter C
			│   │   │   │   here
			│   │   │   │   x = 9
			│   │   │   └─> return from C
			│   │   │   resume D
			│   │   │   yield D
			│   │   │   │   arg[0] = 2
			│   │   │   enter C
			│   │   │   │   here
			│   │   │   │   x = 9
			│   │   │   └─> return from C
			│   │   │   resume D
			│   │   └─> return from D
			│   │   resume B
			│   └─> return from B
			└─> return from A
		"""

	)()
