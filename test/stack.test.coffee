# stack.test.coffee

import test from 'ava'

import {haltOnError} from '@jdeighan/base-utils/exceptions'
import {pass, undef, OL} from '@jdeighan/base-utils/utils'
import {
	LOG, LOGVALUE, utReset, utGetLog,
	} from '@jdeighan/base-utils/log'
import {
	CallStack, throwOnError, debugStack,
	} from '@jdeighan/base-utils/stack'

haltOnError false
throwOnError true

# ---------------------------------------------------------------------------

(() ->
	stack = new CallStack()

	test "line 20", (t) =>
		t.is stack.level, 0
		t.is stack.logLevel, 0
		t.is stack.isLogging(), false
		t.is stack.currentFunc(), undef
		t.is stack.TOS(), undef
		t.is stack.isActive('dummy'), false

	test "line 28", (t) =>
		stack.enter 'A'

		t.is stack.level, 1
		t.is stack.logLevel, 0
		t.is stack.isLogging(), false
		t.is stack.currentFunc(), 'A'
		t.is stack.isActive('dummy'), false
		t.is stack.isActive('A'), true

	test "line 38", (t) =>
		stack.enter 'B', [], true

		t.is stack.level, 2
		t.is stack.logLevel, 1
		t.is stack.isLogging(), true
		t.is stack.currentFunc(), 'B'
		t.is stack.isActive('dummy'), false
		t.is stack.isActive('A'), true
		t.is stack.isActive('B'), true

	test "line 49", (t) =>
		stack.returnFrom 'B'

		t.is stack.level, 1
		t.is stack.logLevel, 0
		t.is stack.isLogging(), false
		t.is stack.currentFunc(), 'A'
		t.is stack.isActive('dummy'), false
		t.is stack.isActive('A'), true
		t.is stack.isActive('B'), false

	test "line 60", (t) =>
		stack.enter 'B', [], true

		t.is stack.level, 2
		t.is stack.logLevel, 1
		t.is stack.isLogging(), true
		t.is stack.currentFunc(), 'B'
		t.is stack.isActive('dummy'), false
		t.is stack.isActive('A'), true
		t.is stack.isActive('B'), true

	test "line 71", (t) =>
		stack.yield 'A', 1

		t.is stack.level, 2
		t.is stack.logLevel, 1
		t.is stack.isLogging(), false
		t.is stack.currentFunc(), 'A'
		t.is stack.isActive('dummy'), false
		t.is stack.isActive('A'), true
		t.is stack.isActive('B'), true

	test "line 82", (t) =>
		stack.resume 'B'

		t.is stack.level, 2
		t.is stack.logLevel, 1
		t.is stack.isLogging(), true
		t.is stack.currentFunc(), 'B'
		t.is stack.isActive('dummy'), false
		t.is stack.isActive('A'), true
		t.is stack.isActive('B'), true

	test "line 93", (t) =>
		stack.yieldFrom 'C'
		stack.enter 'C', [], true

		t.is stack.level, 3
		t.is stack.logLevel, 2
		t.is stack.isLogging(), true
		t.is stack.currentFunc(), 'C'
		t.is stack.isActive('dummy'), false
		t.is stack.isActive('A'), true
		t.is stack.isActive('B'), true
		t.is stack.isActive('C'), true
	)()

# ---------------------------------------------------------------------------

(() ->
	utReset()
	prev = debugStack true

	stack = new CallStack()

	stack.enter 'A'
	stack.enter 'B', [], true
	stack.returnFrom 'B'
	stack.enter 'B', [], true
	stack.yield 'B', 1
	stack.resume 'B'
	stack.yield 'B', 2
	stack.resume 'B'
	stack.returnFrom 'B'
	stack.enter 'C', [], true

	theLog = utGetLog()

	test "line 126", (t) =>
		t.is theLog, """
			RESET STACK => <undef>
			ENTER A => A
				ENTER B => B
					RETURN FROM B => A
				ENTER B => B
					YIELD 1 - in B => A
					RESUME B => B
					YIELD 2 - in B => A
					RESUME B => B
					RETURN FROM B => A
				ENTER C => C
			"""
	debugStack prev
	)()

# ---------------------------------------------------------------------------

(() ->

	# --- What we're simulating

	A = () ->
		dbgEnter 'A'
		for i in B()
			LOG i
		dbgReturn 'A'

	B = () ->
		dbgEnter 'B'
		dbgYieldFrom 'B'
		yield from C()
		dbgResume 'B'
		dbgReturn 'B'

	C = () ->
		dbgEnter 'C'
		dbgYield 'C', 42
		yield 42
		dbgResume 'C'
		dbgYield 'C', 99
		yield 99
		dbgResume 'C'
		dbgReturn 'C'

	utReset()
	prev = debugStack true

	stack = new CallStack()

	stack.enter 'A'
	stack.enter 'B'
	stack.yieldFrom 'B'
	stack.enter 'C'
	stack.yield 'C', 42
	stack.resume 'C'
	stack.yield 'C', 99
	stack.resume 'C'
	stack.returnFrom 'C'
	stack.resume 'B'
	stack.returnFrom 'B'
	stack.returnFrom 'A'

	theLog = utGetLog()

	test "line 196", (t) =>
		t.is theLog, """
			RESET STACK => <undef>
			ENTER A => A
				ENTER B => B
					YIELD FROM - in B => A
					ENTER C => C
						YIELD 42 - in C => A
						RESUME C => C
						YIELD 99 - in C => A
						RESUME C => C
						RETURN FROM C => A
					RESUME B => B
					RETURN FROM B => A
				RETURN FROM A => <undef>
			"""
	debugStack prev
	)()

# ---------------------------------------------------------------------------

(() ->
	utReset()
	prev = debugStack true

	stack = new CallStack()

	stack.enter 'A'
	stack.enter 'B', [], true
	stack.returnFrom 'B'
	stack.enter 'B', [], true
	stack.yield 'B', 1
	stack.resume 'B'
	stack.yieldFrom 'B'
	stack.enter 'C', [], true

	theLog = utGetLog()

	test "line 96", (t) =>
		t.is theLog, """
			RESET STACK => <undef>
			ENTER A => A
				ENTER B => B
					RETURN FROM B => A
				ENTER B => B
					YIELD 1 - in B => A
					RESUME B => B
					YIELD FROM - in B => A
					ENTER C => C
			"""
	debugStack prev
	)()
