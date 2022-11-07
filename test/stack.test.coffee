# stack.test.coffee

import test from 'ava'

import {pass, undef} from '@jdeighan/base-utils/utils'
import {LOG, utReset, utGetLog} from '@jdeighan/base-utils/log'
import {CallStack} from '@jdeighan/base-utils/stack'

# ---------------------------------------------------------------------------

test "line 12", (t) =>
	stack = new CallStack()
	t.is stack.getIndentLevel(), 0

test "line 16", (t) =>
	stack = new CallStack()
	t.is stack.isLogging(), false

# ---------------------------------------------------------------------------

test "line 22", (t) =>
	stack = new CallStack()
	stack.enter 'callme', [1, 'abc'], true
	t.is stack.getIndentLevel(), 1

test "line 27", (t) =>
	stack = new CallStack()
	stack.enter 'callme', [1, 'abc'], true
	t.is stack.isLogging(), true

# ---------------------------------------------------------------------------

test "line 34", (t) =>
	stack = new CallStack()
	stack.enter 'sub', [], false
	t.is stack.getIndentLevel(), 0

test "line 39", (t) =>
	stack = new CallStack()
	stack.enter 'sub', [], true
	t.is stack.getIndentLevel(), 1

test "line 44", (t) =>
	stack = new CallStack()
	stack.enter 'sub', [], false
	t.is stack.isLogging(), false

# ---------------------------------------------------------------------------

test "line 51", (t) =>
	stack = new CallStack()
	stack.enter 'callme', [1, 'abc'], true
	stack.enter 'sub', [], false
	stack.returnFrom 'sub'
	t.is stack.getIndentLevel(), 1

test "line 58", (t) =>
	stack = new CallStack()
	stack.enter 'callme', [1, 'abc'], true
	stack.enter 'sub', [], false
	stack.returnFrom 'sub'
	t.is stack.isLogging(), true

# ---------------------------------------------------------------------------

(() ->

	# --- Simulate calling main() with these functions in effect

	coffeeCode = """
		main = () ->
			A()
			return

		A = () ->
			dbgEnter "A"
			C()
			for x from B()
				LOG x
				C()
			dbgReturn "A"
			return

		B = () ->
			dbgEnter "B"
			LOG 13
			dbgYield "B", 5
			yield 5
			dbgResume "B"
			C()
			yield from E()
			dbgReturn "B"
			return

		C = () ->
			dbgEnter "C"
			LOG 'here'
			dbgReturn "C"
			return

		D = () ->
			dbgEnter "D"
			dbgYield "D", 1
			yield 1
			dbgResume "D"
			dbgYield "D", 2
			yield 2
			dbgResume "D"
			dbgReturn "D"
			return
		"""

	# --- Simulate executing main() and check state at each step:

	test "line 227", (t) =>
		utReset()

		stack = new CallStack()

		t.is stack.size(), 0
		t.is stack.currentFunc(), 'main'

		# --- dbgEnter "A"
		stack.enter('A')

		t.is stack.size(), 1
		t.is stack.currentFunc(), 'A'

		# --- dbgEnter "C"
		stack.enter('C')

		t.is stack.size(), 2
		t.is stack.currentFunc(), 'C'

		# --- dbgReturn "C"
		stack.returnFrom('C')

		t.is stack.size(), 1
		t.is stack.currentFunc(), 'A'

		# --- dbgEnter "B"
		stack.enter('B')

		t.is stack.size(), 2
		t.is stack.currentFunc(), 'B'

		# --- dbgYield "B", 5
		stack.yield('B', [5])

		t.is stack.size(), 2
		t.is stack.currentFunc(), 'A'

		# --- dbgEnter "C"
		stack.enter('C')

		t.is stack.size(), 3
		t.is stack.currentFunc(), 'C'

		# --- dbgReturn "C"
		stack.returnFrom('C')

		t.is stack.size(), 2
		t.is stack.currentFunc(), 'A'

		# --- dbgResume "B"
		stack.resume('B')

		t.is stack.size(), 2
		t.is stack.currentFunc(), 'B'

		# --- dbgEnter "C"
		stack.enter('C')

		t.is stack.size(), 3
		t.is stack.currentFunc(), 'C'

		# --- dbgReturn "C"
		stack.returnFrom('C')

		t.is stack.size(), 2
		t.is stack.currentFunc(), 'B'

		# --- dbgYield "B"
		stack.yield('B')

		t.is stack.size(), 2
		t.is stack.currentFunc(), 'A'

		# --- dbgEnter "D"
		stack.enter('D')

		t.is stack.size(), 3
		t.is stack.currentFunc(), 'D'

		# --- dbgYield "D", 1
		stack.yield('D', [1])

		t.is stack.size(), 3
		t.is stack.currentFunc(), 'A'

		# --- dbgResume "D"
		stack.resume('D')

		t.is stack.size(), 3
		t.is stack.currentFunc(), 'D'

		# --- dbgYield "D", 2
		stack.yield('D', [2])

		t.is stack.size(), 3
		t.is stack.currentFunc(), 'A'

		# --- dbgResume "D"
		stack.resume('D')

		t.is stack.size(), 3
		t.is stack.currentFunc(), 'D'

		# --- dbgReturn "D"
		stack.returnFrom('D')

		t.is stack.size(), 2
		t.is stack.currentFunc(), 'A'

		# --- dbgEnter "C"
		stack.enter('C')

		t.is stack.size(), 3
		t.is stack.currentFunc(), 'C'

		# --- dbgReturn "C"
		stack.returnFrom('C')

		t.is stack.size(), 2
		t.is stack.currentFunc(), 'A'

		# --- dbgResume "B"
		stack.resume('B')

		t.is stack.size(), 2
		t.is stack.currentFunc(), 'B'

		# --- dbgReturn "B"
		stack.returnFrom('B')

		t.is stack.size(), 1
		t.is stack.currentFunc(), 'A'

		# --- dbgReturn "A"
		stack.returnFrom('A')

		t.is stack.size(), 0
		t.is stack.currentFunc(), 'main'

	)()
