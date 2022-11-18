# debug.test.coffee

import test from 'ava'

import {
	haltOnError, assert, croak,
	} from '@jdeighan/base-utils/exceptions'
import {
	undef, pass, arrayToBlock, isNumber, isArray, spaces,
	} from '@jdeighan/base-utils/utils'
import {toTAML} from '@jdeighan/base-utils/taml'
import {getPrefix} from '@jdeighan/base-utils/prefix'
import {
	LOG, LOGVALUE, utReset, utGetLog,
	} from '@jdeighan/base-utils/log'
import {
	setDebugging, getType, dumpDebugLoggers,
	dbgEnter, dbgReturn, dbgReturnVal,
	dbgYield, dbgYieldFrom, dbgResume, dbg,
	dbgReset, dbgGetLog,
	} from '@jdeighan/base-utils/debug'

haltOnError false

# ---------------------------------------------------------------------------

test "line 27", (t) =>
	setDebugging "myfunc"
	t.deepEqual(
		getType("something"),
		["string", undef])

test "line 33", (t) =>
	setDebugging "myfunc"
	t.deepEqual(
		getType("enter myfunc"),
		["enter", "myfunc"])

test "line 39", (t) =>
	setDebugging "myfunc"
	t.deepEqual(
		getType("return from X"),
		["returnFrom", 'X'])

# ---------------------------------------------------------------------------

double = (x) =>
	dbgEnter "double", x
	assert isNumber(x), "not a number"
	dbg "inside double"
	result = 2 * x
	dbgReturnVal "double", result
	return result

quadruple = (x) =>
	dbgEnter "quadruple", x
	dbg "inside quadruple"
	result = 2 * double(x)
	dbgReturnVal "quadruple", result
	return result

# ---------------------------------------------------------------------------

test "line 64", (t) =>

	utReset()
	result = quadruple(3)
	t.is result, 12

# ---------------------------------------------------------------------------

test "line 72", (t) =>

	utReset()
	setDebugging 'double'
	result = quadruple(3)
	t.is result, 12

# ---------------------------------------------------------------------------

test "line 81", (t) =>

	utReset()
	setDebugging 'double'
	result = quadruple(3)
	t.is utGetLog(), """
		enter double 3
		│   inside double
		└─> return 6 from double
		"""

# ---------------------------------------------------------------------------

test "line 94", (t) =>

	utReset()
	setDebugging 'double quadruple'
	result = quadruple(3)
	t.is result, 12
	t.is utGetLog(), """
		enter quadruple 3
		│   inside quadruple
		│   enter double 3
		│   │   inside double
		│   └─> return 6 from double
		└─> return 12 from quadruple
		"""

# ---------------------------------------------------------------------------

test "line 111", (t) =>

	utReset()
	setDebugging 'double', 'quadruple'
	result = quadruple(3)
	t.is result, 12
	t.is utGetLog(), """
		enter quadruple 3
		│   inside quadruple
		│   enter double 3
		│   │   inside double
		│   └─> return 6 from double
		└─> return 12 from quadruple
		"""

# ---------------------------------------------------------------------------

class Class1
	constructor: () ->
		@lStrings = []
	add: (str) ->
		dbgEnter "Class1.add", str
		@lStrings.push str
		dbgReturn "Class1.add"
		return

class Class2
	constructor: () ->
		@lStrings = []
	add: (str) ->
		dbgEnter "Class2.add", str
		@lStrings.push str
		dbgReturn "Class2.add"
		return

# ---------------------------------------------------------------------------

test "line 148", (t) =>

	utReset()
	setDebugging 'Class1.add Class2.add'
	new Class1().add('abc')
	new Class2().add('def')

	t.is utGetLog(), """
		enter Class1.add 'abc'
		└─> return from Class1.add
		enter Class2.add 'def'
		└─> return from Class2.add
		"""

# ---------------------------------------------------------------------------

test "line 164", (t) =>

	utReset()
	setDebugging 'Class2.add'
	new Class1().add('abc')
	new Class2().add('def')

	t.is utGetLog(), """
		enter Class2.add 'def'
		└─> return from Class2.add
		"""

# ---------------------------------------------------------------------------

test "line 178", (t) =>

	utReset()
	setDebugging 'double quadruple'
	result = double(quadruple(3))
	t.is result, 24
	t.is utGetLog(), """
		enter quadruple 3
		│   inside quadruple
		│   enter double 3
		│   │   inside double
		│   └─> return 6 from double
		└─> return 12 from quadruple
		enter double 12
		│   inside double
		└─> return 24 from double
		"""

# ---------------------------------------------------------------------------
# Test using generators

allNumbers = (lItems) ->

	dbgEnter "allNumbers"
	for item in lItems
		if isNumber(item)
			dbgYield "allNumbers", item
			yield item
			dbgResume "allNumbers"
		else if isArray(item)
			dbgYieldFrom "allNumbers"
			yield from allNumbers(item)
			dbgResume "allNumbers"
	dbgReturn "allNumbers"
	return

test "line 214", (t) =>
	lItems = ['a', 2, ['b', 3], 5]
	total = 0
	for i from allNumbers(lItems)
		total += i
	t.is total, 10

# ---------------------------------------------------------------------------
# Test custom loggers

test "line 224", (t) =>

	utReset()
	setDebugging 'double quadruple', {

		# --- on dbgEnter('<func>'), just log the function name
		enter: (funcName, lObjects, level) ->
			LOG getPrefix(level, 'plain') + funcName
			return true

		# --- on dbgReturn('<func>'), don't log anything at all
		returnFrom: (funcName, level) ->
			return true

		# --- on dbgReturnVal('<func>', <val>), don't log anything at all
		returnVal: (funcName, val, level) ->
			return true

		}

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
		dbgEnter "A"
		C()
		for x from B()
			output x
			C()
		dbgReturn "A"
		return

	B = () ->
		dbgEnter "B"
		output 13
		dbgYield "B", 5
		yield 5
		dbgResume "B"
		C()
		dbgYieldFrom "B"
		yield from D()
		dbgResume "B"
		dbgReturn "B"
		return

	C = () ->
		dbgEnter "C"
		output 'here'
		dbg "here"
		dbg "x", 9
		dbgReturn "C"
		return

	D = () ->
		dbgEnter "D"
		dbgYield "D", 1
		yield 1
		dbgResume "D"
		dbgYield "D", 2
		yield 2
		dbgResume "D"
		dbgReturn "D"
		return

	test "line 307", (t) =>
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

	test "line 326", (t) =>
		lOutput = []
		utReset()
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

	test "line 357", (t) =>
		lOutput = []
		utReset()
		setDebugging "D"
		main()

		# --- D should be called once, yielding twice

		t.is utGetLog(), """
			enter D
			├── yield 1
			├── yield 2
			└─> return from D
		"""

	test "line 372", (t) =>
		lOutput = []
		utReset()
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
			├── yield 1
			│   enter C
			│   │   here
			│   │   x = 9
			│   └─> return from C
			├── yield 2
			│   enter C
			│   │   here
			│   │   x = 9
			│   └─> return from C
			└─> return from D
		"""

	test "line 407", (t) =>
		lOutput = []
		utReset()
		setDebugging true
		main()

		# --- debug all

		t.is utGetLog(), """
			enter A
			│   enter C
			│   │   here
			│   │   x = 9
			│   └─> return from C
			│   enter B
			│   ├── yield 5
			│   │   enter C
			│   │   │   here
			│   │   │   x = 9
			│   │   └─> return from C
			│   │   enter C
			│   │   │   here
			│   │   │   x = 9
			│   │   └─> return from C
			│   ├── yieldFrom
			│   │   enter D
			│   │   ├── yield 1
			│   │   │   enter C
			│   │   │   │   here
			│   │   │   │   x = 9
			│   │   │   └─> return from C
			│   │   ├── yield 2
			│   │   │   enter C
			│   │   │   │   here
			│   │   │   │   x = 9
			│   │   │   └─> return from C
			│   │   └─> return from D
			│   └─> return from B
			└─> return from A
		"""

	)()

# ---------------------------------------------------------------------------
# --- We want to separate debug and normal logging

(() ->
	utReset()   # sets a custom logger for calls to LOG, LOGVALUE
	dbgReset()  # sets a custom logger for calls to debug functions

	main = () ->
		dbgEnter 'main'
		LOG 'in main()'
		A()
		dbgReturn 'main'
		return

	A = () ->
		dbgEnter 'A'
		LOG 'in A()'
		dbgReturn 'A'
		return

	hCustomLoggers = {
		enter: (funcName, lVals, level) ->
			LOG "ENTERING #{funcName}"
		}

	setDebugging 'A', hCustomLoggers

	main()

	dbgOutput = dbgGetLog()
	logOutput = utGetLog()

	test "line 489", (t) =>
		t.is logOutput, """
			in main()
			in A()
			"""
	test "line 494", (t) =>
		t.is dbgOutput, """
		   ENTERING A
		   └─> return from A
			"""
	)()
