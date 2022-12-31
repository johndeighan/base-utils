# debug.test.coffee

import test from 'ava'

import {
	assert, croak,
	} from '@jdeighan/base-utils/exceptions'
import {
	undef, defined, notdefined,
	} from '@jdeighan/base-utils'
import {
	LOG, LOGVALUE, LOGSTRING, clearAllLogs, getMyLog,
	} from '@jdeighan/base-utils/log'
import {CallStack} from '@jdeighan/base-utils/stack'
import {
	callStack, setDebugging, debugDebug,
	getType, dumpDebugLoggers,
	dbgEnter, dbgReturn, dbgYield, dbgResume, dbg,
	clearDebugLog, getDebugLog, stdLogString,
	} from '@jdeighan/base-utils/debug'

# ---------------------------------------------------------------------------

test "line 24", (t) =>
	clearDebugLog()
	stdLogString 2, """
		---
		- abc
		- def
		"""
	t.is getDebugLog(), """
		│   │   ---
		│   │   - abc
		│   │   - def
		"""

# ---------------------------------------------------------------------------
# --- Define some functions to use in testing

main = () ->

	dbgEnter 'main'
	for i in [13, 15]
		func1 i
		LOG i+1
	dbgReturn 'main'
	return

func1 = (i) ->
	dbgEnter 'func1', i
	func2(i)
	dbgReturn 'func1'
	return

func2 = (i) ->
	dbgEnter 'func2', i
	LOG 2*i
	dbgReturn 'func2'
	return

callGen = () ->
	dbgEnter 'callGen'
	for i from gen()
		dbg "GOT #{i}"
		LOG i
	dbgReturn 'callGen'
	return

gen = () ->
	dbgEnter 'gen'

	dbgYield 'gen', 1
	yield 1
	dbgResume 'gen'

	dbgYield 'gen', 2
	yield 2
	dbgResume 'gen'

	dbgReturn 'gen'
	return

# ---------------------------------------------------------------------------

hTestNumbers = {}

TEST = (lineNum, options, func, expectedDbg, expectedLog) ->

	# --- Make sure test numbers are unique
	while (hTestNumbers[lineNum])
		lineNum += 1000
	hTestNumbers[lineNum] = true

	if defined(options)
		setDebugging options
	else
		setDebugging false

	callStack.logCalls true
	clearAllLogs()

	func()

	dbgStr = getDebugLog()
	logStr = getMyLog()

	test "line #{lineNum}-DEBUG", (t) =>
		t.is dbgStr, expectedDbg
	if defined(expectedLog)
		test "line #{lineNum}-LOG", (t) =>
			t.is logStr, expectedLog
	test "line #{lineNum}-final", (t) =>
		t.truthy callStack.isEmpty()
	return

# ---------------------------------------------------------------------------

(() ->

	TEST 107, undef, main, undef, """
		26
		14
		30
		16
		"""
	)()

# ---------------------------------------------------------------------------

(() ->

	TEST 119, 'main', main, """
		enter main
		└─> return from main
		""", """
		26
		14
		30
		16
		"""
	)()

# ---------------------------------------------------------------------------

(() ->

	TEST 134, 'main func2', main, """
		enter main
		│   enter func2 13
		│   └─> return from func2
		│   enter func2 15
		│   └─> return from func2
		└─> return from main
		""", """
		26
		14
		30
		16
		"""
	)()

# ---------------------------------------------------------------------------

(() ->

	TEST 153, 'func2', main, """
		enter func2 13
		└─> return from func2
		enter func2 15
		└─> return from func2
		""", """
		26
		14
		30
		16
		"""
	)()

# ---------------------------------------------------------------------------

(() ->

	TEST 170, true, callGen, """
		enter callGen
		│   enter gen
		│   ├<─ yield 1
		│   GOT 1
		│   ├─> resume
		│   ├<─ yield 2
		│   GOT 2
		│   ├─> resume
		│   └─> return from gen
		└─> return from callGen
		""", """
		1
		2
		"""
	)()

# ---------------------------------------------------------------------------

(() ->

	callGen = () ->
		dbgEnter 'func'
		dbgReturn 'func'
		LOG 'abc'

	TEST 193, 'func', callGen, """
		enter func
		└─> return from func
		""", """
		abc
		"""
	)()

# ---------------------------------------------------------------------------

(() ->

	callGen = () ->
		dbgEnter 'obj.func'
		dbgReturn 'obj.func'
		LOG 'abc'

	TEST 193, 'obj.func', callGen, """
		enter obj.func
		└─> return from obj.func
		""", """
		abc
		"""
	)()

# ---------------------------------------------------------------------------

(() ->

	callGen = () ->
		dbgEnter 'obj.func'
		dbgReturn 'obj.func'
		LOG 'abc'

	TEST 193, 'func', callGen, """
		enter obj.func
		└─> return from obj.func
		""", """
		abc
		"""
	)()

# ---------------------------------------------------------------------------

(() ->

	callGen = () ->
		dbgEnter 'Getter.get'
		dbgEnter 'Fetcher.fetch'
		dbgReturn 'Fetcher.fetch', {
			str: 'abcdef abcdef abcdef abcdef abcdef'
			node: 'abcdef abcdef abcdef abcdef abcdef'
			lineNum: 15
			}
		dbgReturn 'Getter.get', {
			str: 'abcdef abcdef abcdef abcdef abcdef'
			node: 'abcdef abcdef abcdef abcdef abcdef'
			lineNum: 15
			}
		LOG 'abc'

	TEST 193, 'get fetch', callGen, """
		enter Getter.get
		│   enter Fetcher.fetch
		│   └─> return from Fetcher.fetch
		│       val =
		│       ---
		│       lineNum: 15
		│       node: abcdef˳abcdef˳abcdef˳abcdef˳abcdef
		│       str: abcdef˳abcdef˳abcdef˳abcdef˳abcdef
		└─> return from Getter.get
		    val =
		    ---
		    lineNum: 15
		    node: abcdef˳abcdef˳abcdef˳abcdef˳abcdef
		    str: abcdef˳abcdef˳abcdef˳abcdef˳abcdef
		""", """
		abc
		"""
	)()

# ---------------------------------------------------------------------------

(() ->
	MAIN = () ->
		dbgEnter 'MAIN'
		FUNC1()
		FUNC2()
		dbgReturn 'MAIN'
		return

	FUNC1 = () ->
		dbgEnter 'FUNC1'
		LOG 'Hello'
		dbgReturn 'FUNC1'
		return

	FUNC2 = () ->
		dbgEnter 'FUNC2'
		LOG 'Hi'
		dbgReturn 'FUNC2'
		return

	TEST 297, 'MAIN+', MAIN, """
		enter MAIN
		│   enter FUNC1
		│   └─> return from FUNC1
		│   enter FUNC2
		│   └─> return from FUNC2
		└─> return from MAIN
		""", """
		Hello
		Hi
		"""

	)()

# ---------------------------------------------------------------------------
