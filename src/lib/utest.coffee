# utest.coffee

import test from 'ava'
import {isInteger} from '@jdeighan/base-utils'
import {assert} from '@jdeighan/base-utils/exceptions'

# ---------------------------------------------------------------------------

class SimpleUnitTester

	constructor: () ->

		@hFound = {}   # used line numbers

	# ..........................................................

	getLineNum: (lineNum) ->

		assert isInteger(lineNum), "#{lineNum} is not an integer"
		# --- patch lineNum to avoid duplicates
		while @hFound[lineNum]
			lineNum += 1000
		@hFound[lineNum] = true
		return lineNum

	# ..........................................................

	truthy: (lineNum, bool) ->

		lineNum = @getLineNum(lineNum)
		test "line #{lineNum}", (t) => t.truthy(bool)

	# ..........................................................

	falsy: (lineNum, bool) ->

		lineNum = @getLineNum(lineNum)
		test "line #{lineNum}", (t) => t.falsy(bool)

	# ..........................................................

	equal: (lineNum, val1, val2) ->

		lineNum = @getLineNum(lineNum)
		test "line #{lineNum}", (t) => t.deepEqual(val1, val2)

	# ..........................................................

	like: (lineNum, val1, val2) ->

		lineNum = @getLineNum(lineNum)
		test "line #{lineNum}", (t) => t.like(val1, val2)

	# ..........................................................

	throws: (lineNum, func) ->

		lineNum = @getLineNum(lineNum)
		if (typeof func != 'function')
			throw new Error("SimpleUnitTester.fails(): function expected")
		try
			func()
			ok = true
		catch err
			ok = false

		test "line #{lineNum}", (t) => t.falsy(ok)

	fails: (lineNum, func) ->

		return @throws(lineNum, func)

	# ..........................................................

	succeeds: (lineNum, func) ->

		lineNum = @getLineNum(lineNum)
		if (typeof func != 'function')
			throw new Error("SimpleUnitTester.fails(): function expected")
		try
			func()
			ok = true
		catch err
			ok = false

		test "line #{lineNum}", (t) => t.truthy(ok)

export utest = new SimpleUnitTester()
