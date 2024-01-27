# v8-stack.test.coffee

import {assert, croak} from '@jdeighan/base-utils/exceptions'
import {
	undef, defined, notdefined,
	} from '@jdeighan/base-utils'
import {fromTAML} from '@jdeighan/base-utils/taml'
import {LOG, LOGVALUE} from '@jdeighan/base-utils/log'
import {
	getMyDirectCaller, getMyOutsideCaller,
	getV8Stack, debugV8Stack, getV8StackStr,
	} from '@jdeighan/base-utils/v8-stack'
import {getBoth} from './v8-module.js'
import {utest} from '@jdeighan/base-utils/utest'

# ---------------------------------------------------------------------------

(() ->
	stack1 = undef
	stack2 = undef

	main = () ->
		func1()
		func2()

	func1 = () ->
		stack1 = getV8Stack()

	func2 = () ->
		stack2 = getV8Stack()
		return

	main()
	utest.like stack1, [
		{
			functionName: 'func1'
			}
		]
	utest.like stack2, [
		{
			functionName: 'func2'
			}
		]
	)()

# ---------------------------------------------------------------------------

(() ->
	caller1 = undef
	caller2 = undef

	main = () ->
		func1()
		func2()

	func1 = () ->
		caller1 = getMyDirectCaller()

	func2 = () ->
		caller2 = getMyDirectCaller()
		return

	main()
	utest.like caller1, {
		functionName: 'main'
		fileName: 'v8-stack.test.js'
		}
	utest.like caller2, {
		functionName: 'main'
		fileName: 'v8-stack.test.js'
		}
	)()

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

	main()

	utest.like hCaller, {
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

	main()
	utest.like lCallers1[0], {
		type: 'function'
		functionName: 'secondFunc'
		fileName: 'v8-module.js'
		}
	utest.like lCallers1[1], {
		type: 'function'
		functionName: 'func1'
		fileName: 'v8-stack.test.js'
		}
	utest.like lCallers2[0], {
		type: 'function'
		functionName: 'secondFunc'
		fileName: 'v8-module.js'
		}
	utest.like lCallers2[1], {
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

	utest.equal await func1(), """
		function at v8-stack.test.js:150:23
		function at v8-stack.test.js:147:19
		script at v8-stack.test.js:162:29
		"""

	)()

# ---------------------------------------------------------------------------

(() =>
	func1 = () =>
		func2()
		return await getV8StackStr('debug')

	func2 = () =>
		x = 2 * 2
		return x

	utest.equal await func1(), """
		function at v8-stack.test.js:166:19
		script at v8-stack.test.js:179:29
		"""
	)()
