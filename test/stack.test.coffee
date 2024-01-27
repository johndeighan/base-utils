# stack.test.coffee

import {
	assert, croak,
	} from '@jdeighan/base-utils/exceptions'
import {
	undef, defined, notdefined, words,
	} from '@jdeighan/base-utils'
import {
	clearAllLogs, echoLogsByDefault,
	} from '@jdeighan/base-utils/log'
import {CallStack, getStackLog} from '@jdeighan/base-utils/stack'
import {utest} from '@jdeighan/base-utils/utest'

echoLogsByDefault false

# ---------------------------------------------------------------------------

TEST = (stack, curFunc, strActive, strNonActive, logging, level=undef, logLevel=undef) =>
	if defined(curFunc)
		utest.equal stack.curFuncName, curFunc
	else
		utest.equal stack.curFuncName, '_MAIN_'
	if defined(strActive)
		for name in words(strActive)
			utest.truthy stack.isActive(name)
	if defined(strNonActive)
		for name in words(strNonActive)
			utest.falsy stack.isActive(name)
	if logging
		utest.truthy stack.isLogging()
	else
		utest.falsy stack.isLogging()
	if defined(level)
		utest.equal stack.level, level
	if defined(logLevel)
		utest.equal stack.logLevel, logLevel
	return

# ---------------------------------------------------------------------------

clearAllLogs()
stack = new CallStack()
stack.logCalls true

stack.enter 'func'
# ---           cur    active  !active  isLogging
TEST stack, 'func', "func", "func2", false

stack.returnFrom 'func'
utest.truthy stack.isEmpty()

utest.equal getStackLog(), """
	ENTER 'func'
	RETURN FROM 'func'
	"""

# ---------------------------------------------------------------------------

utest.throws () ->
	suppressExceptionLogging true
	clearAllLogs()
	stack = new CallStack()
	stack.logCalls true
	stack.enter 'func'
	stack.returnFrom 'func2'   # should throw an error

# ---------------------------------------------------------------------------

clearAllLogs()
stack = new CallStack()
stack.logCalls true

stack.enter 'func', [], true
# ---           cur    active  !active  isLogging
TEST stack, 'func', "func", "func2", true

stack.returnFrom 'func'
# ---          cur     active  !active        isLogging
#              -----   ------  --------       ---------
TEST stack, undef,  undef,  'func func2',  false
utest.truthy stack.isEmpty()

utest.equal getStackLog(), """
	ENTER 'func'
	RETURN FROM 'func'
	"""

# ---------------------------------------------------------------------------

clearAllLogs()
stack = new CallStack()
stack.logCalls true

stack.enter 'func', [], true

# ---          cur     active  !active    isLogging
#              -----   ------  --------   ---------
TEST stack, 'func', 'func',  'func2',  true

stack.enter 'func2'

# ---          cur      active        !active   isLogging
#              -----    ------        --------  ---------
TEST stack, 'func2', 'func func2', undef,    false

stack.returnFrom 'func2'

# ---          cur     active  !active    isLogging
#              -----   ------  --------   ---------
TEST stack, 'func', 'func',  'func2',  true

stack.returnFrom 'func'

# ---          cur     active  !active      isLogging
#              -----   ------  --------     ---------
TEST stack, undef, undef,  'func func2', false

utest.equal getStackLog(), """
	ENTER 'func'
		ENTER 'func2'
		RETURN FROM 'func2'
	RETURN FROM 'func'
	"""
utest.truthy stack.isEmpty()

# ---------------------------------------------------------------------------
# --- Test yield / resume

clearAllLogs()
stack = new CallStack()
stack.logCalls true

# ---          cur     active  !active       isLogging
#              -----   ------  --------      ---------
TEST stack, undef, undef,   'func gen', false, 0, 0

stack.enter 'func', [], true

# ---          cur     active  !active   isLogging
#              -----   ------  --------  ---------
TEST stack, 'func', 'func',  'gen', true, 1, 1

stack.enter 'gen', [], false

# ---          cur     active        !active   isLogging
#              -----   ------        --------  ---------
TEST stack, 'gen', 'func gen',  undef, false, 2, 1

stack.yield 'gen', 13

# ---          cur     active    !active   isLogging
#              -----   ------    --------  ---------
TEST stack, 'func', 'func',  'gen',   true, 1, 1

stack.resume 'gen'

# ---          cur     active    !active   isLogging
#              -----   ------    --------  ---------
TEST stack, 'gen', 'func gen',  undef,   false, 2, 1

stack.returnFrom 'gen'

# ---          cur     active    !active   isLogging
#              -----   ------    --------  ---------
TEST stack, 'func', 'func',  'gen',   true, 1, 1

stack.returnFrom 'func'

# ---          cur     active  !active       isLogging
#              -----   ------  --------      ---------
TEST stack, undef, undef,   'func gen', false, 0, 0

utest.truthy stack.isEmpty()

# ---------------------------------------------------------------------------
# --- Test multiple generators

clearAllLogs()
stack = new CallStack()
stack.logCalls true

# ---          cur     active  !active       isLogging
#              -----   ------  --------      ---------
TEST stack, undef, undef,   'func gen', false, 0, 0

stack.enter 'func', [], true

# ---          cur     active  !active   isLogging
#              -----   ------  --------  ---------
TEST stack, 'func', 'func',  'gen', true, 1, 1

stack.enter 'gen', [], false

# ---          cur     active        !active   isLogging
#              -----   ------        --------  ---------
TEST stack, 'gen', 'func gen',  undef, false, 2, 1

stack.yield 'gen', 13

# ---          cur     active    !active   isLogging
#              -----   ------    --------  ---------
TEST stack, 'func', 'func',  'gen',   true, 1, 1

stack.resume 'gen'

# ---          cur     active    !active   isLogging
#              -----   ------    --------  ---------
TEST stack, 'gen', 'func gen',  undef,   false, 2, 1

stack.returnFrom 'gen'

# ---          cur     active    !active   isLogging
#              -----   ------    --------  ---------
TEST stack, 'func', 'func',  'gen',   true, 1, 1

stack.returnFrom 'func'

# ---          cur     active  !active       isLogging
#              -----   ------  --------      ---------
TEST stack, undef, undef,   'func gen', false, 0, 0

utest.truthy stack.isEmpty()

# ---------------------------------------------------------------------------
# test stack log

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

utest.equal getStackLog(), """
	RESET STACK
	ENTER 'func1' 13
		ENTER 'func2' 'abc',{"mean":42}
		YIELD FROM 'func2' 99
		RESUME 'func2'
		RETURN FROM 'func2' 'def'
	RETURN FROM 'func1'
	"""
