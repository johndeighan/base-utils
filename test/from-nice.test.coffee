# from-nice.test.coffee

import {undef} from '@jdeighan/base-utils'
import {
	UnitTester, equal, like, notequal,
	truthy, falsy, fails, succeeds,
	} from '@jdeighan/base-utils/utest'
import * as lib from '@jdeighan/base-utils/from-nice'
Object.assign(global, lib)

# ---------------------------------------------------------------------------
# --- test fromNICE()

(() =>
	# --- transform value using fromNICE() automatically
	u = new UnitTester()
	u.transformValue = (str) => return fromNICE(str)

	u.equal """
		fileName: primitive-value
		type: coffee
		author: John Deighan
		include: pll-parser
		""", {
		fileName: 'primitive-value'
		type: 'coffee'
		author: 'John Deighan'
		include: 'pll-parser'
		}
	)()
