# stack.test.coffee

import test from 'ava'

import {
	assert, croak, haltOnError,
	} from '@jdeighan/base-utils/exceptions'
import {
	undef, defined, notdefined, words,
	} from '@jdeighan/base-utils/utils'
import {clearAllLogs} from '@jdeighan/base-utils/log'
import {CallStack, getStackLog} from '@jdeighan/base-utils/stack'

haltOnError false   # always set in unit tests

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

test "line 41", (t) =>
	clearAllLogs()
	stack = new CallStack('logCalls')

	stack.enter 'func'
	# ---           cur    active  !active  isLogging
	TEST t, stack, 'func', "func", "func2", false

	stack.returnFrom 'func'
	t.truthy stack.isEmpty()

	t.is getStackLog(), """
		RESET STACK
		ENTER 'func'
		RETURN FROM 'func'
		"""

# ---------------------------------------------------------------------------

test "line 59", (t) =>
	t.throws () ->
		suppressExceptionLogging true
		clearAllLogs()
		stack = new CallStack('logCalls')
		stack.enter 'func'
		stack.returnFrom 'func2'   # should throw an error

# ---------------------------------------------------------------------------

test "line 69", (t) =>
	clearAllLogs()
	stack = new CallStack('logCalls')

	stack.enter 'func', [], true
	# ---           cur    active  !active  isLogging
	TEST t, stack, 'func', "func", "func2", true

	stack.returnFrom 'func'
	# ---          cur     active  !active        isLogging
	#              -----   ------  --------       ---------
	TEST t, stack, undef,  undef,  'func func2',  false
	t.truthy stack.isEmpty()

	t.is getStackLog(), """
		RESET STACK
		ENTER 'func'
		RETURN FROM 'func'
		"""

# ---------------------------------------------------------------------------

test "line 92", (t) =>
	clearAllLogs()
	stack = new CallStack('logCalls')

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
		RESET STACK
		ENTER 'func'
			ENTER 'func2'
			RETURN FROM 'func2'
		RETURN FROM 'func'
		"""
	t.truthy stack.isEmpty()

# ---------------------------------------------------------------------------
# --- Test yield / resume

test "line 132", (t) =>
	clearAllLogs()
	stack = new CallStack('logCalls')

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
	stack = new CallStack('logCalls')

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
