# base-utils.test.coffee

import test from 'ava'

import {
	assert, croak, haltOnError, exReset, exGetLog,
	} from '@jdeighan/base-utils/exceptions'
import {
	undef, pass, isNumber, arrayToBlock,
	} from '@jdeighan/base-utils/utils'
import {
	setLogger, debugLogging, LOG, sep_dash, utReset, utGetLog,
	} from '@jdeighan/base-utils/log'
import {dbgReset, dbgGetLog} from '@jdeighan/base-utils/debug'

haltOnError false

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

test "line 33", (t) =>
	lLog = []
	LOG 'abc'
	LOG 'def'
	t.is getLog(), "abc\ndef"

test "line 39", (t) =>
	x = 5
	t.is(quadruple(x), 20)


test "line 44", (t) =>
	exReset()
	try
		result = quadruple('abc')
	t.is exGetLog(), """
		-------------------------
		JavaScript CALL STACK:
		   double
		   quadruple
		-------------------------
		ERROR: not a number (in double())
		"""

test "line 57", (t) =>
	lLog = []
	try
		croak "Bad Moon Rising"
	catch err
		LOG err.message
	t.is getLog(), "ERROR (croak): Bad Moon Rising"
