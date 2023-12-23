# v8-stack-str.coffee

import test from 'ava'

import {undef, defined} from '@jdeighan/base-utils'
import {getV8Stack, getV8StackStr} from '@jdeighan/base-utils/v8-stack'

# ---------------------------------------------------------------------------

(() =>
	func1 = () =>
		return await func2()

	func2 = () =>
		stackStr = await getV8StackStr()
		return stackStr

	test "line 19", (t) => t.is(await func1(), """
		function at v8-stack.js:70:19
		function at v8-stack-str.test.js:22:23
		function at v8-stack-str.test.js:18:19
		script at v8-stack-str.test.js:26:24
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

	test "line 38", (t) => t.is(await func1(), """
		function at v8-stack.js:70:19
		function at v8-stack-str.test.js:38:19
		script at v8-stack-str.test.js:46:24
		""")
	)()
