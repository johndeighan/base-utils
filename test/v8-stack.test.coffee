# v8-stack.test.coffee

import test from 'ava'

import {
	assert, croak,
	} from '@jdeighan/base-utils/exceptions'
import {undef} from '@jdeighan/base-utils'
import {fromTAML} from '@jdeighan/base-utils/taml'
import {LOG, LOGVALUE} from '@jdeighan/base-utils/log'
import {
	getMyDirectCaller, getMyOutsideCaller,
	getV8Stack, debugV8Stack, shorten,
	} from '@jdeighan/base-utils/v8-stack'
import {getCallers} from './v8-module.js'

# ---------------------------------------------------------------------------

test "line 21", (t) =>
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

	hExpected = fromTAML """
		---
		type: function
		funcName: main
		source: C:/Users/johnd/base-utils/test/v8-stack.test.js
		hFile:
			base: v8-stack.test.js
			dir: C:/Users/johnd/base-utils/test
			ext: .js
			name: v8-stack.test
			root: /
		"""

	test "line 60", (t) =>
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
		lCallers1 = getCallers()

	func2 = () ->
		lCallers2 = getCallers()
		return

	test "line 83", (t) =>
		main()
		t.like lCallers1[0], {
			type: 'function'
			funcName: 'secondFunc'
			source: 'C:/Users/johnd/base-utils/test/v8-module.js'
			hFile: {
				base: 'v8-module.js'
				lineNum: 17
				colNum: 10
				}
			}
		t.like lCallers1[1], {
			type: 'function'
			funcName: 'func1'
			source: 'C:/Users/johnd/base-utils/test/v8-stack.test.js'
			hFile: {
				base: 'v8-stack.test.js'
				lineNum: 83
				colNum: 24
				}
			}
		t.like lCallers2[0], {
			type: 'function'
			funcName: 'secondFunc'
			source: 'C:/Users/johnd/base-utils/test/v8-module.js'
			hFile: {
				base: 'v8-module.js'
				lineNum: 17
				colNum: 10
				}
			}
		t.like lCallers2[1], {
			type: 'function'
			funcName: 'func2'
			source: 'C:/Users/johnd/base-utils/test/v8-stack.test.js'
			hFile: {
				base: 'v8-stack.test.js'
				lineNum: 86
				colNum: 17
				}
			}
	)()
