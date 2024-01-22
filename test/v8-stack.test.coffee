# v8-stack.test.coffee

import test from 'ava'

import {assert, croak} from '@jdeighan/base-utils/exceptions'
import {undef, defined} from '@jdeighan/base-utils'
import {fromTAML} from '@jdeighan/base-utils/taml'
import {LOG, LOGVALUE} from '@jdeighan/base-utils/log'
import {
	getMyDirectCaller, getMyOutsideCaller,
	getV8Stack, debugV8Stack, getV8StackStr,
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

	test "line 33", (t) =>
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

	test "line 60", (t) =>
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

# ---------------------------------------------------------------------------

(() =>
	func1 = () =>
		return await func2()

	func2 = () =>
		stackStr = await getV8StackStr()
		return stackStr

	test "line 94", (t) => t.is(await func1(), """
		function at v8-stack.js:62:19
		function at v8-stack.test.js:106:23
		function at v8-stack.test.js:102:19
		script at v8-stack.test.js:110:24
		""")
	)()

# ---------------------------------------------------------------------------

(() =>
	func1 = () =>
		func2()
		return await getV8StackStr('debug')

	func2 = () =>
		x = 2 * 2
		return x

	test "line 113", (t) => t.is(await func1(), """
		function at v8-stack.js:62:19
		function at v8-stack.test.js:122:19
		script at v8-stack.test.js:130:24
		""")
	)()
