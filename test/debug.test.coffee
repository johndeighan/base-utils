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
	setDebugging, resetDebugging, setCustomDebugLogger, debug, getType,
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
		getType("enter myfunc()"),
		["enter", "myfunc"])
	resetDebugging()

test "line 34", (t) =>
	setDebugging "myfunc"
	t.deepEqual(
		getType("enter obj.method()"),
		["enter", "obj.method"])
	resetDebugging()

test "line 41", (t) =>
	setDebugging "myfunc"
	t.deepEqual(
		getType("return from myfunc()"),
		["return", "myfunc"])
	resetDebugging()

test "line 48", (t) =>
	setDebugging "myfunc"
	t.deepEqual(
		getType("return 42 from myobj.mymethod()"),
		["return", "myobj.mymethod"])
	resetDebugging()

# ---------------------------------------------------------------------------

double = (x) =>
	debug "enter double()", x
	assert isNumber(x), "not a number"
	debug "inside double()"
	result = 2 * x
	debug "return from double()", result
	return result

quadruple = (x) =>
	debug "enter quadruple()", x
	debug "inside quadruple()"
	result = 2 * double(x)
	debug "return from quadruple()", result
	return result

# ---------------------------------------------------------------------------

test "line 74", (t) =>

	utReset()
	result = quadruple(3)
	t.is result, 12

# ---------------------------------------------------------------------------

test "line 82", (t) =>

	utReset()
	setDebugging 'double'
	result = quadruple(3)
	resetDebugging()
	t.is result, 12

# ---------------------------------------------------------------------------

test "line 92", (t) =>

	utReset()
	setDebugging 'double'
	result = quadruple(3)
	resetDebugging()
	t.is utGetLog(), """
		enter double()
		│   arg[0] = 3
		│   inside double()
		└─> return from double()
		    ret[0] = 6
		"""

# ---------------------------------------------------------------------------

test "line 108", (t) =>

	utReset()
	setDebugging 'double quadruple'
	result = quadruple(3)
	resetDebugging()
	t.is result, 12
	t.is utGetLog(), """
		enter quadruple()
		│   arg[0] = 3
		│   inside quadruple()
		│   enter double()
		│   │   arg[0] = 3
		│   │   inside double()
		│   └─> return from double()
		│       ret[0] = 6
		└─> return from quadruple()
		    ret[0] = 12
		"""

# ---------------------------------------------------------------------------

test "line 130", (t) =>

	utReset()
	setDebugging 'double', 'quadruple'
	result = quadruple(3)
	resetDebugging()
	t.is result, 12
	t.is utGetLog(), """
		enter quadruple()
		│   arg[0] = 3
		│   inside quadruple()
		│   enter double()
		│   │   arg[0] = 3
		│   │   inside double()
		│   └─> return from double()
		│       ret[0] = 6
		└─> return from quadruple()
		    ret[0] = 12
		"""

# ---------------------------------------------------------------------------

class Class1
	constructor: () ->
		@lStrings = []
	add: (str) ->
		debug "enter Class1.add()", str
		@lStrings.push str
		debug "return from Class1.add()"
		return

class Class2
	constructor: () ->
		@lStrings = []
	add: (str) ->
		debug "enter Class2.add()", str
		@lStrings.push str
		debug "return from Class2.add()"
		return

# ---------------------------------------------------------------------------

test "line 172", (t) =>

	utReset()
	setDebugging 'Class1.add Class2.add'
	new Class1().add('abc')
	new Class2().add('def')
	resetDebugging()

	t.is utGetLog(), """
		enter Class1.add()
		│   arg[0] = 'abc'
		└─> return from Class1.add()
		enter Class2.add()
		│   arg[0] = 'def'
		└─> return from Class2.add()
		"""

# ---------------------------------------------------------------------------

test "line 191", (t) =>

	utReset()
	setDebugging 'Class2.add'
	new Class1().add('abc')
	new Class2().add('def')
	resetDebugging()

	t.is utGetLog(), """
		enter Class2.add()
		│   arg[0] = 'def'
		└─> return from Class2.add()
		"""

# ---------------------------------------------------------------------------

test "line 207", (t) =>

	utReset()
	setDebugging 'double quadruple'
	result = double(quadruple(3))
	resetDebugging()
	t.is result, 24
	t.is utGetLog(), """
		enter quadruple()
		│   arg[0] = 3
		│   inside quadruple()
		│   enter double()
		│   │   arg[0] = 3
		│   │   inside double()
		│   └─> return from double()
		│       ret[0] = 6
		└─> return from quadruple()
		    ret[0] = 12
		enter double()
		│   arg[0] = 12
		│   inside double()
		└─> return from double()
		    ret[0] = 24
		"""

# ---------------------------------------------------------------------------
# Test using generators

allNumbers = (lItems) ->

	debug "enter allNumbers()"
	for item in lItems
		if isNumber(item)
			debug "yield allNumbers()"
			yield item
			debug "continue allNumbers()"
		else if isArray(item)
			debug "yield allNumbers()"
			yield from allNumbers(item)
			debug "continue allNumbers()"
	debug "return from allNumbers()"
	return

test "line 250", (t) =>
	lItems = ['a', 2, ['b', 3], 5]
	total = 0
	for i from allNumbers(lItems)
		total += i
	t.is total, 10

# ---------------------------------------------------------------------------
# Test custom loggers

test "line 260", (t) =>

	utReset()
	setDebugging 'double quadruple'

	setCustomDebugLogger 'enter', (label, lObjects, level, funcName) ->
		LOG getPrefix(level, 'plain') + funcName
		return true

	setCustomDebugLogger 'return', (label, lObjects, level, funcName) ->
		return true

	result = double(quadruple(3))
	resetDebugging()
	t.is result, 24
	t.is utGetLog(), """
		quadruple
		│   inside quadruple()
		│   double
		│   │   inside double()
		double
		│   inside double()
		"""
