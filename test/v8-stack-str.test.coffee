# v8-stack-str.coffee

import test from 'ava'

import {undef, defined} from '@jdeighan/base-utils'
import {getV8Stack, getV8StackStr} from '@jdeighan/base-utils/v8-stack'
import {getStack, getCaller} from './templib.js'

# ---------------------------------------------------------------------------

(() =>
	func1 = () =>
		return await func2()

	func2 = () =>
		stackStr = await getV8StackStr()
		return stackStr

	test "line 19", (t) => t.is(await func1(), """
		function at v8-stack.js:73:19
		function at v8-stack-str.test.js:27:23
		function at v8-stack-str.test.js:23:19
		script at v8-stack-str.test.js:31:24
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
		function at v8-stack.js:73:19
		function at v8-stack-str.test.js:43:19
		script at v8-stack-str.test.js:51:24
		""")
	)()
