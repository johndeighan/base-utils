# v8-stack.test.coffee

import test from 'ava'

import {assert, croak} from '@jdeighan/base-utils/exceptions'
import {undef} from '@jdeighan/base-utils'
import {fromTAML} from '@jdeighan/base-utils/taml'
import {LOG, LOGVALUE} from '@jdeighan/base-utils/log'
import {
	getMyDirectCaller, getMyOutsideCaller,
	getV8Stack, debugV8Stack, shorten,
	} from '@jdeighan/base-utils/v8-stack'
import {getBoth} from './v8-module.js'

# ---------------------------------------------------------------------------

test "line 17", (t) =>
	orgStr = "(file:///C:/Users/johnd/base-utils/src/v8-stack.js)"
	replace = "file:///C:/Users/johnd"
	expStr = "(file:///ROOT/base-utils/src/v8-stack.js)"
	t.is shorten(orgStr, replace), expStr

# ---------------------------------------------------------------------------

(() ->
	hCaller = undef

	main = () ->
		func1()
		func2()

	func1 = () ->
		return

	func2 = () ->
		hCaller = getMyDirectCaller()
		return

	# ------------------------------------------------------------------------

	hExpected = {
		type: 'function'
		funcName: 'main'
		source: 'C:/Users/johnd/base-utils/test/v8-stack.test.js'
		}

	test "line 48", (t) =>
		main()

		t.like hCaller, hExpected
	)()

# ---------------------------------------------------------------------------

(() ->
	lCallers1 = undef
	lCallers2 = undef

	main = () ->
		func1()
		func2()

	func1 = () ->
		lCallers1 = getBoth()

	func2 = () ->
		lCallers2 = getBoth()
		return

	test "line 70", (t) =>
		main()
		t.like lCallers1[0], {
			type: 'function'
			funcName: 'secondFunc'
			source: 'C:/Users/johnd/base-utils/test/v8-module.js'
			}
		t.like lCallers1[1], {
			type: 'function'
			funcName: 'func1'
			source: 'C:/Users/johnd/base-utils/test/v8-stack.test.js'
			}
		t.like lCallers2[0], {
			type: 'function'
			funcName: 'secondFunc'
			source: 'C:/Users/johnd/base-utils/test/v8-module.js'
			}
		t.like lCallers2[1], {
			type: 'function'
			funcName: 'func2'
			source: 'C:/Users/johnd/base-utils/test/v8-stack.test.js'
			}
	)()
