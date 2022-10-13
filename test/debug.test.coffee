# debug.test.coffee

import test from 'ava'

import {
	pass, arrayToBlock, isNumber,
	} from '@jdeighan/exceptions/utils'
import {toTAML} from '@jdeighan/exceptions/taml'
import {
	haltOnError, assert, croak,
	} from '@jdeighan/exceptions'
import {utReset, LOG, utGetLog} from '@jdeighan/exceptions/log'
import {
	debug, setDebugging, resetDebugging,
	} from '@jdeighan/exceptions/debug'

# ---------------------------------------------------------------------------

double = (x) =>
	debug "enter double()", x
	assert isNumber(x), "not a number"
	result = 2 * x
	debug "return from double()", result
	return result

quadruple = (x) =>
	debug "enter quadruple()", x
	result = 2 * double(x)
	debug "return from quadruple()", result
	return result

# ---------------------------------------------------------------------------

test 'line 33', (t) =>

	utReset()
	result = quadruple(3)
	t.is result, 12

test 'line 39', (t) =>

	utReset()
	setDebugging 'double'
	result = quadruple(3)
	resetDebugging()
	t.is result, 12
	t.is utGetLog(), """
		enter˳double()
		.˳˳˳arg[0]˳=˳3
		└─>˳return˳from˳double()
		˳˳˳˳ret[0]˳=˳6
		"""

test 'line 52', (t) =>

	utReset()
	setDebugging 'double quadruple'
	result = quadruple(3)
	resetDebugging()
	t.is result, 12
	t.is utGetLog(), """
		enter˳quadruple()
		.˳˳˳arg[0]˳=˳3
		˳˳˳˳enter˳double()
		│˳˳˳.˳˳˳arg[0]˳=˳3
		│˳˳˳└─>˳return˳from˳double()
		│˳˳˳˳˳˳˳ret[0]˳=˳6
		└─>˳return˳from˳quadruple()
		˳˳˳˳ret[0]˳=˳12
		"""

