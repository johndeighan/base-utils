# debug.test.coffee

import test from 'ava'

import {
	undef, pass, arrayToBlock, isNumber,
	} from '@jdeighan/exceptions/utils'
import {toTAML} from '@jdeighan/exceptions/taml'
import {
	haltOnError, assert, croak,
	} from '@jdeighan/exceptions'
import {utReset, LOG, utGetLog} from '@jdeighan/exceptions/log'
import {
	setDebugging, resetDebugging, debug, getType,
	} from '@jdeighan/exceptions/debug'

# ---------------------------------------------------------------------------

# --- Until setDebugging() is called with a nonEmpty string,
#     all debugging is turned off

test "line 22", (t) => t.deepEqual(
	getType("something"),
	[undef, undef, undef])


test "line 27", (t) =>
	setDebugging "myfunc"
	t.deepEqual(
		getType("something"),
		["string", undef, undef])
	resetDebugging()

test "line 34", (t) =>
	setDebugging "myfunc"
	t.deepEqual(
		getType("enter myfunc"),
		["enter", "myfunc", undef])
	resetDebugging()

test "line 41", (t) =>
	setDebugging "myfunc"
	t.deepEqual(
		getType("enter obj.method()"),
		["enter", "method", "obj"])
	resetDebugging()

test "line 48", (t) =>
	setDebugging "myfunc"
	t.deepEqual(
		getType("return from myfunc"),
		["return", "myfunc", undef])
	resetDebugging()

test "line 55", (t) =>
	setDebugging "myfunc"
	t.deepEqual(
		getType("return 42 from myobj.mymethod"),
		["return", "mymethod", "myobj"])
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

test "line 79", (t) =>

	utReset()
	result = quadruple(3)
	t.is result, 12

test "line 85", (t) =>

	utReset()
	setDebugging 'double'
	result = quadruple(3)
	resetDebugging()
	t.is result, 12

test "line 93", (t) =>

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

test "line 106", (t) =>

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

test "line 124", (t) =>

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

test "line 166", (t) =>

	utReset()
	setDebugging 'add'
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

test "line 183", (t) =>

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
