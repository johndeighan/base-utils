# exceptions.test.coffee

import test from 'ava'

import {
	haltOnError, logErrors, LOG, DEBUG, error, assert, croak,
	} from '@jdeighan/exceptions'

# ---------------------------------------------------------------------------

test 'foo', (t) => t.pass()
