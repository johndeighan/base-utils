# stack.test.coffee

import test from 'ava'

import {
	assert, croak,
	} from '@jdeighan/base-utils/exceptions'
import {
	undef, defined, notdefined, words,
	} from '@jdeighan/base-utils/utils'
import {clearAllLogs} from '@jdeighan/base-utils/log'
import {CallStack, getStackLog} from '@jdeighan/base-utils/stack'

# ---------------------------------------------------------------------------

TEST = (t, stack, curFunc, strActive, strNonActive, logging, level=undef, logLevel=undef) =>
	if defined(curFunc)
		t.is stack.curFuncName, curFunc
	else
		t.is stack.curFuncName, '_MAIN_'
	if defined(strActive)
		for name in words(strActive)
			t.truthy stack.isActive(name)
	if defined(strNonActive)
		for name in words(strNonActive)
			t.falsy stack.isActive(name)
	if logging
		t.truthy stack.isLogging()
	else
		t.falsy stack.isLogging()
	if defined(level)
		t.is stack.level, level
	if defined(logLevel)
		t.is stack.logLevel, logLevel
	return

# ---------------------------------------------------------------------------

test "line 39", (t) =>
	clearAllLogs()
	stack = new CallStack()
	stack.logCalls true

	stack.enter 'func'
	# ---           cur    active  !active  isLogging
	TEST t, stack, 'func', "func", "func2", false

	stack.returnFrom 'func'
	t.truthy stack.isEmpty()

	t.is getStackLog(), """
		ENTER 'func'
		RETURN FROM 'func'
		"""

# ---------------------------------------------------------------------------

test "line 58", (t) =>
	t.throws () ->
		suppressExceptionLogging true
		clearAllLogs()
		stack = new CallStack()
		stack.logCalls true
		stack.enter 'func'
		stack.returnFrom 'func2'   # should throw an error

# ---------------------------------------------------------------------------

test "line 69", (t) =>
	clearAllLogs()
	stack = new CallStack()
	stack.logCalls true

	stack.enter 'func', [], true
	# ---           cur    active  !active  isLogging
	TEST t, stack, 'func', "func", "func2", true

	stack.returnFrom 'func'
	# ---          cur     active  !active        isLogging
	#              -----   ------  --------       ---------
	TEST t, stack, undef,  undef,  'func func2',  false
	t.truthy stack.isEmpty()

	t.is getStackLog(), """
		ENTER 'func'
		RETURN FROM 'func'
		"""

# ---------------------------------------------------------------------------

test "line 91", (t) =>
	clearAllLogs()
	stack = new CallStack()
	stack.logCalls true

	stack.enter 'func', [], true

	# ---          cur     active  !active    isLogging
	#              -----   ------  --------   ---------
	TEST t, stack, 'func', 'func',  'func2',  true

	stack.enter 'func2'

	# ---          cur      active        !active   isLogging
	#              -----    ------        --------  ---------
	TEST t, stack, 'func2', 'func func2', undef,    false

	stack.returnFrom 'func2'

	# ---          cur     active  !active    isLogging
	#              -----   ------  --------   ---------
	TEST t, stack, 'func', 'func',  'func2',  true

	stack.returnFrom 'func'

	# ---          cur     active  !active      isLogging
	#              -----   ------  --------     ---------
	TEST t, stack, undef, undef,  'func func2', false

	t.is getStackLog(), """
		ENTER 'func'
			ENTER 'func2'
			RETURN FROM 'func2'
		RETURN FROM 'func'
		"""
	t.truthy stack.isEmpty()

# ---------------------------------------------------------------------------
# --- Test yield / resume

test "line 131", (t) =>
	clearAllLogs()
	stack = new CallStack()
	stack.logCalls true

	# ---          cur     active  !active       isLogging
	#              -----   ------  --------      ---------
	TEST t, stack, undef, undef,   'func gen', false, 0, 0

	stack.enter 'func', [], true

	# ---          cur     active  !active   isLogging
	#              -----   ------  --------  ---------
	TEST t, stack, 'func', 'func',  'gen', true, 1, 1

	stack.enter 'gen', [], false

	# ---          cur     active        !active   isLogging
	#              -----   ------        --------  ---------
	TEST t, stack, 'gen', 'func gen',  undef, false, 2, 1

	stack.yield 'gen', 13

	# ---          cur     active    !active   isLogging
	#              -----   ------    --------  ---------
	TEST t, stack, 'func', 'func',  'gen',   true, 1, 1

	stack.resume 'gen'

	# ---          cur     active    !active   isLogging
	#              -----   ------    --------  ---------
	TEST t, stack, 'gen', 'func gen',  undef,   false, 2, 1

	stack.returnFrom 'gen'

	# ---          cur     active    !active   isLogging
	#              -----   ------    --------  ---------
	TEST t, stack, 'func', 'func',  'gen',   true, 1, 1

	stack.returnFrom 'func'

	# ---          cur     active  !active       isLogging
	#              -----   ------  --------      ---------
	TEST t, stack, undef, undef,   'func gen', false, 0, 0

	t.truthy stack.isEmpty()

# ---------------------------------------------------------------------------
# --- Test multiple generators

test "line 181", (t) =>
	clearAllLogs()
	stack = new CallStack()
	stack.logCalls true

	# ---          cur     active  !active       isLogging
	#              -----   ------  --------      ---------
	TEST t, stack, undef, undef,   'func gen', false, 0, 0

	stack.enter 'func', [], true

	# ---          cur     active  !active   isLogging
	#              -----   ------  --------  ---------
	TEST t, stack, 'func', 'func',  'gen', true, 1, 1

	stack.enter 'gen', [], false

	# ---          cur     active        !active   isLogging
	#              -----   ------        --------  ---------
	TEST t, stack, 'gen', 'func gen',  undef, false, 2, 1

	stack.yield 'gen', 13

	# ---          cur     active    !active   isLogging
	#              -----   ------    --------  ---------
	TEST t, stack, 'func', 'func',  'gen',   true, 1, 1

	stack.resume 'gen'

	# ---          cur     active    !active   isLogging
	#              -----   ------    --------  ---------
	TEST t, stack, 'gen', 'func gen',  undef,   false, 2, 1

	stack.returnFrom 'gen'

	# ---          cur     active    !active   isLogging
	#              -----   ------    --------  ---------
	TEST t, stack, 'func', 'func',  'gen',   true, 1, 1

	stack.returnFrom 'func'

	# ---          cur     active  !active       isLogging
	#              -----   ------  --------      ---------
	TEST t, stack, undef, undef,   'func gen', false, 0, 0

	t.truthy stack.isEmpty()

# ---------------------------------------------------------------------------
# test stack log

test "line 231", (t) =>
	clearAllLogs()
	stack = new CallStack()
	stack.logCalls true

	stack.reset()
	stack.enter 'func1', [13]
	stack.enter 'func2', ['abc', {mean: 42}]
	stack.yield 'func2', 99
	stack.resume 'func2'
	stack.returnFrom 'func2', 'def'
	stack.returnFrom 'func1'

	t.is getStackLog(), """
		RESET STACK
		ENTER 'func1' 13
			ENTER 'func2' 'abc',{"mean":42}
			YIELD FROM 'func2' 99
			RESUME 'func2'
			RETURN FROM 'func2' 'def'
		RETURN FROM 'func1'
		"""
