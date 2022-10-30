# stack.test.coffee

import test from 'ava'

import {pass, undef} from '@jdeighan/exceptions/utils'
import {CallStack} from '@jdeighan/exceptions/stack'
import {LOG, utReset, utGetLog} from '@jdeighan/exceptions/log'
import {debug} from '@jdeighan/exceptions/debug'

# ---------------------------------------------------------------------------

test "line 10", (t) =>
	stack = new CallStack()
	t.is stack.getLevel(), 0

test "line 14", (t) =>
	stack = new CallStack()
	t.is stack.isLogging(), false

# ---------------------------------------------------------------------------

test "line 20", (t) =>
	stack = new CallStack()
	stack.enter 'callme', [1, 'abc'], true
	t.is stack.getLevel(), 1

test "line 25", (t) =>
	stack = new CallStack()
	stack.enter 'callme', [1, 'abc'], true
	t.is stack.isLogging(), true

# ---------------------------------------------------------------------------

test "line 32", (t) =>
	stack = new CallStack()
	stack.enter 'sub', [], false
	t.is stack.getLevel(), 0

test "line 37", (t) =>
	stack = new CallStack()
	stack.enter 'sub', [], true
	t.is stack.getLevel(), 1

test "line 42", (t) =>
	stack = new CallStack()
	stack.enter 'sub', [], false
	t.is stack.isLogging(), false

# ---------------------------------------------------------------------------

test "line 49", (t) =>
	stack = new CallStack()
	stack.enter 'callme', [1, 'abc'], true
	stack.enter 'sub', [], false
	stack.returnFrom 'sub'
	t.is stack.getLevel(), 1

test "line 56", (t) =>
	stack = new CallStack()
	stack.enter 'callme', [1, 'abc'], true
	stack.enter 'sub', [], false
	stack.returnFrom 'sub'
	t.is stack.isLogging(), true

# ---------------------------------------------------------------------------

(() ->

	main = () ->
		A()
		return

	A = () ->
		debug "enter A()"
		for x from B()
			LOG x
			C()
		debug "return from A()"
		return

	B = () ->
		debug "enter B()"

		LOG 13
		for n in [5,6]
			debug "yield from B()", n
			yield n
			debug "continue B()"

		C()
		debug "return from B()"
		return

	C = () ->
		debug "enter C()"
		LOG "here"
		debug "return from C()"
		return

	test "line 90", (t) =>
		utReset()
		main()
		t.is utGetLog(), """
			13
			5
			here
			6
			here
			here
			"""
	)()

