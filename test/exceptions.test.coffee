# exceptions.test.coffee

import test from 'ava'

import {
	haltOnError, logErrors, LOG, DEBUG, error, assert, croak,
	normalize, super_normalize,
	} from '@jdeighan/exceptions'

# ---------------------------------------------------------------------------

test 'foo', (t) => t.pass()

block = """
	abc\tdef
	\tabc     def
	"""

norm = normalize(block)
snorm = super_normalize(block)

test 'normalize', (t) => t.is(norm, "abc def\nabc def")
test 'super_normalize', (t) => t.is(snorm, "abc def abc def")
