# debug.test.coffee

import {
	assert, croak,
	} from '@jdeighan/base-utils/exceptions'
import {
	undef, defined, notdefined, isFunction,
	} from '@jdeighan/base-utils'
import {
	LOG, LOGVALUE, LOGSTRING,
	clearAllLogs, getMyLogs, echoLogs,
	} from '@jdeighan/base-utils/log'
import {CallStack} from '@jdeighan/base-utils/stack'
import * as lib from '@jdeighan/base-utils/debug'
Object.assign(global, lib)
import {
	UnitTester, equal, notequal,
	like, truthy, falsy, fails, succeeds,
	} from '@jdeighan/base-utils/utest'

echoLogs false
setDebugging false, 'noecho'

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

callGen1 = () ->
	dbgEnter 'func'
	dbgReturn 'func'
	LOG 'abc'

callGen2 = () ->
	dbgEnter 'obj.func'
	dbgReturn 'obj.func'
	LOG 'abc'

callGen3 = () ->
	dbgEnter 'obj.func'
	dbgReturn 'obj.func'
	LOG 'abc'

callGen4 = () ->
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

clearDebugLog()
stdLogString 2, """
	---
	- abc
	- def
	"""
equal getDebugLog(), """
	│   │   ---
	│   │   - abc
	│   │   - def
	"""

# ---------------------------------------------------------------------------
# --- possible values for debugWhat:
#        false - no debug output
#        true - debug all calls
#        <string> - space separated names
#                   of functions/methods to debug

TEST = (debugWhat, func, expectedDbg, expectedLog) ->

	assert defined(debugWhat), "1st arg must be defined"
	setDebugging debugWhat, 'noecho'

	assert isFunction(func), "not a function"

	debugStack.logCalls true
	clearAllLogs()

	func()

	dbgStr = getDebugLog()
	logStr = getMyLogs()

	equal dbgStr, expectedDbg
	equal logStr, expectedLog
	truthy debugStack.isEmpty()
	return

# ---------------------------------------------------------------------------

(() ->
	TEST false, main, '', """
		26
		14
		30
		16
		"""
	)()

# ---------------------------------------------------------------------------

(() ->
	TEST 'main', main, """
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

	TEST 'main func2', main, """
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

	TEST 'func2', main, """
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
# --- PROBLEM

# (() ->
#
# 	TEST 'callGen get', callGen, """
# 		enter callGen
# 		│   enter gen
# 		│   ├<─ yield 1
# 		│   GOT 1
# 		│   ├─> resume
# 		│   ├<─ yield 2
# 		│   GOT 2
# 		│   ├─> resume
# 		│   └─> return from gen
# 		└─> return from callGen
# 		""", """
# 		1
# 		2
# 		"""
# 	)()

# ---------------------------------------------------------------------------

(() ->

	TEST true, callGen1, """
		enter func
		└─> return from func
		""", """
		abc
		"""
	)()

# ---------------------------------------------------------------------------

(() ->

	TEST 'obj.func', callGen2, """
		enter obj.func
		└─> return from obj.func
		""", """
		abc
		"""
	)()

# ---------------------------------------------------------------------------

(() ->

	TEST 'func', callGen3, """
		enter obj.func
		└─> return from obj.func
		""", """
		abc
		"""
	)()

# ---------------------------------------------------------------------------

(() ->

	TEST 'get fetch', callGen4, """
		enter Getter.get
		│   enter Fetcher.fetch
		│   └─> return from Fetcher.fetch
		│       val =
		│       lineNum: 15
		│       node: abcdef˳abcdef˳abcdef˳abcdef˳abcdef
		│       str: abcdef˳abcdef˳abcdef˳abcdef˳abcdef
		└─> return from Getter.get
		    val =
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

	TEST 'MAIN+', MAIN, """
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

(() =>
	str = 'abcde '.repeat(4)

	func = (arg) ->
		dbgEnter 'func', arg
		result = {a:str, b:str}
		dbgReturn 'func', result
		return result

	setDebugging 'func', 'noecho'

	debugStack.logCalls true
	clearAllLogs()

	func([str, str, str])

	dbgStr = getDebugLog()

	expectedDbg = """
		enter func
		│   arg[0] =
		│       - abcde˳abcde˳abcde˳abcde˳
		│       - abcde˳abcde˳abcde˳abcde˳
		│       - abcde˳abcde˳abcde˳abcde˳
		└─> return from func
		    val =
		    a: abcde˳abcde˳abcde˳abcde˳
		    b: abcde˳abcde˳abcde˳abcde˳
		"""

	equal dbgStr, expectedDbg
	truthy debugStack.isEmpty()
	)()

# ---------------------------------------------------------------------------
# --- test option 'shortvals'

(() =>
	str = 'abcde '.repeat(4)

	func = (arg) ->
		dbgEnter 'func', arg
		result = {a:str, b:str}
		dbgReturn 'func', result
		return result

	setDebugging 'func', 'noecho shortvals'

	debugStack.logCalls true
	clearAllLogs()

	func([str, str, str])

	dbgStr = getDebugLog()

	expectedDbg = """
		enter func ARRAY
		└─> return from func
		    val = HASH
		"""

	equal dbgStr, expectedDbg
	truthy debugStack.isEmpty()
	)()
