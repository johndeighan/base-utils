# exceptions.test.coffee

import test from 'ava'

import {
	pass, isNumber, arrayToBlock,
	} from '@jdeighan/exceptions/utils'
import {
	haltOnError, assert, croak,
	} from '@jdeighan/exceptions'
import {
	setLogger, debugLogging, LOG, sep_dash,
	} from '@jdeighan/exceptions/log'

# ---------------------------------------------------------------------------

double = (x) =>
	assert isNumber(x), "not a number"
	return 2 * x

quadruple = (x) =>
	return 2 * double(x)

# ---------------------------------------------------------------------------

# --- clear lLog before each test
lLog = []
setLogger (str) => lLog.push(str)
getLog = () => return arrayToBlock(lLog)

# ---------------------------------------------------------------------------

test "line 31", (t) =>
	lLog = []
	LOG 'abc'
	LOG 'def'
	t.is getLog(), "abc\ndef"

test "line 37", (t) =>
	x = 5
	t.is(quadruple(x), 20)


test "line 41", (t) =>
	lLog = []
	try
		result = quadruple('abc')
	t.is getLog(), """
		#{sep_dash}
		JavaScript CALL STACK:
		   double
		   quadruple
		#{sep_dash}
		ERROR: not a number (in double())
		"""

test "line 57", (t) =>
	lLog = []
	try
		croak "Bad Moon Rising"
	catch err
		LOG err.message
	t.is getLog(), "ERROR (croak): Bad Moon Rising"
