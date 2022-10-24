# stack.test.coffee

import test from 'ava'

import {pass, undef} from '@jdeighan/exceptions/utils'
import {CallStack} from '@jdeighan/exceptions/stack'

# ---------------------------------------------------------------------------

test "line 10", (t) =>
	stack = new CallStack()
	t.is stack.getLevel(), 0

test "line 14", (t) =>
	stack = new CallStack()
	t.is stack.isLogging(), false

# .............................................................

test "line 20", (t) =>
	stack = new CallStack()
	stack.enter 'callme', undef, [1, 'abc'], true
	t.is stack.getLevel(), 1

test "line 25", (t) =>
	stack = new CallStack()
	stack.enter 'callme', undef, [1, 'abc'], true
	t.is stack.isLogging(), true

# .............................................................

test "line 32", (t) =>
	stack = new CallStack()
	stack.enter 'sub', undef, [], false
	t.is stack.getLevel(), 0

test "line 37", (t) =>
	stack = new CallStack()
	stack.enter 'sub', undef, [], true
	t.is stack.getLevel(), 1

test "line 42", (t) =>
	stack = new CallStack()
	stack.enter 'sub', undef, [], false
	t.is stack.isLogging(), false

# .............................................................

test "line 49", (t) =>
	stack = new CallStack()
	stack.enter 'callme', undef, [1, 'abc'], true
	stack.enter 'sub', undef, [], false
	stack.returnFrom 'sub', undef
	t.is stack.getLevel(), 1

test "line 56", (t) =>
	stack = new CallStack()
	stack.enter 'callme', undef, [1, 'abc'], true
	stack.enter 'sub', undef, [], false
	stack.returnFrom 'sub', undef
	t.is stack.isLogging(), true
