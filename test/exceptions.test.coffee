# exceptions.test.coffee

import * as lib from '@jdeighan/base-utils/exceptions'
Object.assign(global, lib)
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
