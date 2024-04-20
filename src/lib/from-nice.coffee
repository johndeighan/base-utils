# from-nice.coffee

import {
	dbgEnter, dbgReturn, dbg,
	} from '@jdeighan/base-utils/debug'
import {parse} from '@jdeighan/base-utils/object'
import {pparse} from '@jdeighan/base-utils/peggy'

# ---------------------------------------------------------------------------

export fromNICE = (block) =>

	dbgEnter 'fromNICE', block
	result = pparse(parse, block)
	dbgReturn 'fromNICE', result
	return result
