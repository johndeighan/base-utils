# debug.test.coffee

import test from 'ava'

import {
	assert, croak, haltOnError,
	} from '@jdeighan/base-utils/exceptions'
import {
	undef, defined, notdefined,
	} from '@jdeighan/base-utils/utils'
import {
	LOG, LOGVALUE, LOGSTRING, clearAllLogs, getMyLog,
	} from '@jdeighan/base-utils/log'
import {CallStack} from '@jdeighan/base-utils/stack'
import {
	setCallStack, callStack, setDebugging, debugDebug,
	getType, dumpDebugLoggers,
	dbgEnter, dbgReturn, dbgYield, dbgResume, dbg,
	getDebugLog,
	} from '@jdeighan/base-utils/debug'

haltOnError false

# ---------------------------------------------------------------------------
# --- Define some functions to use in testing

main = () ->

	dbgEnter 'main'
	for i in [13, 15]
		func i
		LOG i+1
	dbgReturn 'main'
	return

func = (i) ->
	dbgEnter 'func', i
	func2(i)
	dbgReturn 'func'
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

	setCallStack('debugCalls')
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
		│   ├── yield 1
		│   GOT 1
		│   ├── yield 2
		│   GOT 2
		│   └─> return from gen
		└─> return from callGen
		""", """
		1
		2
		"""
	)()
