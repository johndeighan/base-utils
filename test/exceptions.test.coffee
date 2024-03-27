# exceptions.test.coffee

import * as lib from '@jdeighan/base-utils/exceptions'
Object.assign(global, lib)
import {fails, succeeds} from '@jdeighan/base-utils/utest'

# ---------------------------------------------------------------------------

fails () ->
	suppressExceptionLogging true
	croak("BAD")

fails () ->
	suppressExceptionLogging true
	assert(2+2 != 4, 'EXCEPTION')

succeeds () ->
	assert(2+2 == 4)
