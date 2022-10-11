# stack.test.coffee

import test from 'ava'

import {
	pass, undef, isNumber, arrayToBlock,
	} from '@jdeighan/exceptions/utils'
import {
	debugStack, CallStack,
	} from '@jdeighan/exceptions/stack'

# ---------------------------------------------------------------------------

stack = undef

test "line 16", (t) =>
	stack = new CallStack()
	t.is stack.getLevel(), 0
test "line 19", (t) =>
	t.is stack.isLogging(), false

# .............................................................

test "line 24", (t) =>
	stack.enter 'callme', [1, 'abc'], true
	t.is stack.getLevel(), 1
test "line 27", (t) =>
	t.is stack.isLogging(), true

# .............................................................

test "line 32", (t) =>
	stack.enter 'sub', [], false
	t.is stack.getLevel(), 1
test "line 35", (t) =>
	t.is stack.isLogging(), false

# .............................................................

test "line 40", (t) =>
	stack.returnFrom 'sub'
	t.is stack.getLevel(), 1
test "line 43", (t) =>
	t.is stack.isLogging(), true
