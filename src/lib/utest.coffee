# utest.coffee

import test from 'ava'

import {
	undef, defined, pass, isInteger, OL, LOG,
	} from '@jdeighan/base-utils'
import {
	assert, croak, exReset, exGetLog,
	} from '@jdeighan/base-utils/exceptions'
import {isFile, parsePath, fileExt} from '@jdeighan/base-utils/ll-fs'
import {mapLineNum} from '@jdeighan/base-utils/source-map'
import {getMyOutsideCaller} from '@jdeighan/base-utils/v8-stack'

# ---------------------------------------------------------------------------
# --- Available tests w/num required params
#        equal 2
#        truthy 1
#        falsy 1
#        like 2
#        throws 1 (a function)
#        succeeds 1 (a function)
# ---------------------------------------------------------------------------

export class UnitTester

	constructor: () ->

		@debug = false
		@hFound = {}   # used line numbers

	# ........................................................................

	doDebug: () =>

		@debug = true
		return

	# ........................................................................

	getLineNum: () =>

		# --- We need to figure out the line number of the caller
		{filePath, line, column} = getMyOutsideCaller()
		if @debug
			LOG "getLineNum()"
			LOG "   filePath = '#{filePath}'"
			LOG "   line = #{line}, col = #{column}"

		assert isInteger(line), "getMyOutsideCaller() line = #{OL(line)}"
		assert (fileExt(filePath) == '.js'),
			"caller not a JS file: #{OL(filePath)}"

		# --- Attempt to use source map to get true line number
		mapFile = "#{filePath}.map"
		if isFile(mapFile)
			try
				mline = mapLineNum filePath, line, column, {debug: @debug}
				if @debug
					LOG "   mapped to #{mline}"
				assert isInteger(mline), "not an integer: #{mline}"
				line = mline
			catch err
				pass()
		while @hFound[line]
			line += 1000
		@hFound[line] = true
		return line

	# ........................................................................

	transformValue: (val) ->

		return val

	# ........................................................................

	transformExpected: (expected) ->

		return expected

	# ..........................................................
	# ..........................................................

	equal: (val, expected) ->

		lineNum = @getLineNum()
		test "line #{lineNum}", (t) =>
			t.deepEqual(@transformValue(val), @transformExpected(expected))

	# ..........................................................

	like: (val, expected) ->

		lineNum = @getLineNum()
		test "line #{lineNum}", (t) =>
			t.like(@transformValue(val), @transformExpected(expected))

	# ..........................................................

	notequal: (val, expected) ->

		lineNum = @getLineNum()
		test "line #{lineNum}", (t) =>
			t.notDeepEqual(@transformValue(val), @transformExpected(expected))

	# ..........................................................

	truthy: (bool) ->

		lineNum = @getLineNum()
		test "line #{lineNum}", (t) =>
			t.truthy(@transformValue(bool))

	# ..........................................................

	falsy: (bool) ->

		lineNum = @getLineNum()
		test "line #{lineNum}", (t) =>
			t.falsy(@transformValue(bool))

	# ..........................................................

	throws: (func) ->

		lineNum = @getLineNum()
		assert (typeof func == 'function'), "function expected"
		try
			exReset()   # suppress logging of errors
			func()
			ok = true
		catch err
			ok = false
		log = exGetLog()   # we really don't care about log

		test "line #{lineNum}", (t) => t.falsy(ok)

	# ..........................................................

	succeeds: (func) ->

		lineNum = @getLineNum()
		assert (typeof func == 'function'), "function expected"
		try
			func()
			ok = true
		catch err
			console.error err
			ok = false

		test "line #{lineNum}", (t) => t.truthy(ok)

# ---------------------------------------------------------------------------

export u = new UnitTester()
export transformValue = (func) => u.transformValue = func
export transformExpected = (func) => u.transformExpected = func
export equal = (arg1, arg2) => return u.equal(arg1, arg2)
export like = (arg1, arg2) => return u.like(arg1, arg2)
export notequal = (arg1, arg2) => return u.notequal(arg1, arg2)
export truthy = (arg) => return u.truthy(arg)
export falsy = (arg) => return u.falsy(arg)
export throws = (func) => return u.throws(func)
export succeeds = (func) => return u.succeeds(func)
