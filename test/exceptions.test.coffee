# exceptions.test.coffee

import {
	assert, croak, suppressExceptionLogging,
	} from '@jdeighan/base-utils/exceptions'
import {utest} from '@jdeighan/base-utils/utest'

# ---------------------------------------------------------------------------

utest.throws () ->
	suppressExceptionLogging true
	croak("BAD")

utest.throws () ->
	suppressExceptionLogging true
	assert(2+2 != 4, 'EXCEPTION')

utest.succeeds () ->
	assert(2+2 == 4)
