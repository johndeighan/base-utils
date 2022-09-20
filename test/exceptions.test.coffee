# exceptions.test.coffee

import test from 'ava'

import {
	haltOnError, logErrors, toTAML, LOG, DEBUG, assert, croak,
	} from '@jdeighan/exceptions'

# ---------------------------------------------------------------------------

test 'pass', (t) => t.pass()
test 'taml', (t) => t.is(toTAML([1,2]), "---\n- 1\n- 2\n")
test 'assert', (t) => t.is(assert(2+2 == 4, "garbage"), true)
logErrors false
test 'unassert', (t) => t.throws( () -> assert(2+2==5, "garbage") )
