# ll-v8-stack.test.coffee

import test from 'ava'

import {
	pass, undef, defined, notdefined, assert,
	} from '@jdeighan/base-utils/ll-utils'
import {
	getV8Stack, getMyOutsideCaller, getMyDirectCaller,
	} from '@jdeighan/base-utils/ll-v8-stack'

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

	test "line 30", (t) =>
		main()
		t.like stack1, [
			{
				functionName: 'func1'
				}
			]
		t.like stack2, [
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

	test "line 61", (t) =>
		main()
		t.like caller1, {
			functionName: 'main'
			fileName: 'll-v8-stack.test.js'
			}
		t.like caller2, {
			functionName: 'main'
			fileName: 'll-v8-stack.test.js'
			}
	)()
