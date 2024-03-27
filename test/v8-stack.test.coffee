# v8-stack.test.coffee

import {assert, croak} from '@jdeighan/base-utils/exceptions'
import {
	undef, defined, notdefined,
	} from '@jdeighan/base-utils'
import {fromTAML} from '@jdeighan/base-utils/taml'
import {LOG, LOGVALUE} from '@jdeighan/base-utils/log'
import * as lib from '@jdeighan/base-utils/v8-stack'
Object.assign(global, lib)
import {getBoth} from './v8-module.js'
import {
	UnitTester,
	equal, like, notequal, succeeds, fails, truthy, falsy,
	} from '@jdeighan/base-utils/utest'

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
	like stack1, [
		{
			functionName: 'func1'
			}
		]
	like stack2, [
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
	like caller1, {
		functionName: 'main'
		fileName: 'v8-stack.test.js'
		}
	like caller2, {
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

	like hCaller, {
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
	like lCallers1[0], {
		type: 'function'
		functionName: 'secondFunc'
		fileName: 'v8-module.js'
		}
	like lCallers1[1], {
		type: 'function'
		functionName: 'func1'
		fileName: 'v8-stack.test.js'
		}
	like lCallers2[0], {
		type: 'function'
		functionName: 'secondFunc'
		fileName: 'v8-module.js'
		}
	like lCallers2[1], {
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

	equal await func1(), """
		function at v8-stack.test.js:151:23
		function at v8-stack.test.js:148:19
		script at v8-stack.test.js:165:23
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

	equal await func1(), """
		function at v8-stack.test.js:167:19
		script at v8-stack.test.js:182:23
		"""
	)()
