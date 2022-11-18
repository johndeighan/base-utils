# exceptions.test.coffee

import test from 'ava'

import {
	suppressExceptionLogging, haltOnError, assert, croak,
	} from '@jdeighan/base-utils/exceptions'

haltOnError false
suppressExceptionLogging true

# ---------------------------------------------------------------------------

test "line 11", (t) => t.is(2+2, 4)
test "line 12", (t) => t.throws(() -> croak("BAD"))
test "line 13", (t) => t.throws(() -> assert(2+2 != 4, 'EXCEPTION'))
test "line 14", (t) => t.notThrows(() -> assert(2+2 == 4))
