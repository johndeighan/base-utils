# exceptions.test.coffee

import test from 'ava'

import {
	suppressExceptionLogging, assert, croak,
	} from '@jdeighan/base-utils/exceptions'

# ---------------------------------------------------------------------------

test "line 12", (t) =>
	t.throws(() ->
		suppressExceptionLogging true
		croak("BAD")
		)
test "line 13", (t) =>
	t.throws(() ->
		suppressExceptionLogging true
		assert(2+2 != 4, 'EXCEPTION'))

test "line 14", (t) =>
	t.notThrows(() ->
		assert(2+2 == 4))
