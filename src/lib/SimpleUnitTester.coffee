# SimpleUnitTester.coffee

import test from 'ava'

# ---------------------------------------------------------------------------

class SimpleUnitTester

	constructor: () ->
		@hFound = {}   # used line numbers

	# ..........................................................

	getLineNum: (lineNum) ->

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

export utest = new SimpleUnitTester()
