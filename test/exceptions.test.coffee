# exceptions.test.coffee

import {
	assert, croak, suppressExceptionLogging,
	} from '@jdeighan/base-utils/exceptions'
import {throws, succeeds} from '@jdeighan/base-utils/utest'

# ---------------------------------------------------------------------------

throws () ->
	suppressExceptionLogging true
	croak("BAD")

throws () ->
	suppressExceptionLogging true
	assert(2+2 != 4, 'EXCEPTION')

succeeds () ->
	assert(2+2 == 4)
