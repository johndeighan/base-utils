# v8-stack.test.coffee

import test from 'ava'

import {assert, croak} from '@jdeighan/base-utils/exceptions'
import {undef} from '@jdeighan/base-utils'
import {fromTAML} from '@jdeighan/base-utils/ll-taml'
import {LOG, LOGVALUE} from '@jdeighan/base-utils/log'
import {
	getMyDirectCaller, getMyOutsideCaller,
	getV8Stack, debugV8Stack,
	} from '@jdeighan/base-utils/v8-stack'
import {getBoth} from './v8-module.js'

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

	test "line 48", (t) =>
		main()

		t.like hCaller, {
			type: 'function'
			functionName: 'main'
			fileName: 'v8-stack.test.js'
			}
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
			functionName: 'secondFunc'
			fileName: 'v8-module.js'
			}
		t.like lCallers1[1], {
			type: 'function'
			functionName: 'func1'
			fileName: 'v8-stack.test.js'
			}
		t.like lCallers2[0], {
			type: 'function'
			functionName: 'secondFunc'
			fileName: 'v8-module.js'
			}
		t.like lCallers2[1], {
			type: 'function'
			functionName: 'func2'
			fileName: 'v8-stack.test.js'
			}
	)()
