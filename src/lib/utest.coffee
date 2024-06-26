# utest.coffee

import test from 'ava'

import {
	undef, defined, pass, OL, jsType, rtrim,
	isString, isInteger, isRegExp, nonEmpty, isClass, isFunction,
	toArray, fileExt,
	} from '@jdeighan/base-utils'
import {
	assert, croak, exReset, exGetLog,
	} from '@jdeighan/base-utils/exceptions'
import {isFile, parsePath} from '@jdeighan/base-utils/ll-fs'
import {mapLineNum} from '@jdeighan/base-utils/source-map'
import {getMyOutsideCaller} from '@jdeighan/base-utils/v8-stack'

# ---------------------------------------------------------------------------
# --- Available tests w/num required params
#        equal 2
#        truthy 1
#        falsy 1
#        includes 2
#        matches 2
#        like 2
#        fails 1 (a function)
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
	# --- returns, e.g. "line 42"

	getTestName: () =>

		# --- We need to figure out the line number of the caller
		{filePath, line, column} = getMyOutsideCaller()
		if @debug
			console.log "getTestName()"
			console.log "   filePath = '#{filePath}'"
			console.log "   line = #{line}, col = #{column}"

		assert isInteger(line), "getMyOutsideCaller() line = #{OL(line)}"
		assert (fileExt(filePath) == '.js') || (fileExt(filePath) == '.coffee'),
			"caller not a JS or Coffee file: #{OL(filePath)}"

# 		# --- Attempt to use source map to get true line number
# 		mapFile = "#{filePath}.map"
# 		if isFile(mapFile)
# 			try
# 				mline = mapLineNum filePath, line, column, {debug: @debug}
# 				if @debug
# 					console.log "   mapped to #{mline}"
# 				assert isInteger(mline), "not an integer: #{mline}"
# 				line = mline
# 			catch err
# 				pass()
		while @hFound[line]
			line += 1000
		@hFound[line] = true

		return "line #{line}"

	# ........................................................................

	transformValue: (val) ->

		return val

	# ........................................................................

	transformExpected: (expected) ->

		return expected

	# ..........................................................
	# ..........................................................

	equal: (val, expected) ->

		val = @transformValue(val)
		expected = @transformExpected(expected)
		test @getTestName(), (t) =>
			t.deepEqual(val, expected)
		return

	# ..........................................................

	like: (val, expected) ->

		val = @transformValue(val)
		expected = @transformExpected(expected)
		if isString(val) && isString(expected)
			val = rtrim(val).replaceAll("\r", "")
			expected = rtrim(expected).replaceAll("\r", "")
			test @getTestName(), (t) =>
				t.deepEqual(val, expected)
		else
			test @getTestName(), (t) =>
				t.like(val, expected)
		return

	# ..........................................................

	samelines: (val, expected) ->

		val = @transformValue(val)
		expected = @transformExpected(expected)
		assert isString(val), "not a string: #{OL(val)}"
		assert isString(expected), "not a string: #{OL(expected)}"

		lValLines = toArray(val).filter((line) => return nonEmpty(line)).sort()
		lExpLines = toArray(expected).filter((line) => return nonEmpty(line)).sort()

		test @getTestName(), (t) =>
			t.deepEqual(lValLines, lExpLines)
		return

	# ..........................................................

	notequal: (val, expected) ->

		val = @transformValue(val)
		expected = @transformExpected(expected)
		test @getTestName(), (t) =>
			t.notDeepEqual(val, expected)
		return

	# ..........................................................

	truthy: (bool) ->

		test @getTestName(), (t) =>
			t.truthy(bool)
		return

	# ..........................................................

	falsy: (bool) ->

		test @getTestName(), (t) =>
			t.falsy(bool)
		return

	# ..........................................................

	includes: (val, expected) ->

		val = @transformValue(val)
		expected = @transformExpected(expected)
		switch jsType(val)[0]
			when 'string'
				test @getTestName(), (t) =>
					t.truthy(val.includes(expected))
			when 'array'
				test @getTestName(), (t) =>
					t.truthy(val.includes(expected))
			else
				croak "Bad arg to includes: #{OL(val)}"
		return

	# ..........................................................

	matches: (val, regexp) ->

		assert isString(val), "Not a string: #{OL(val)}"

		# --- convert strings to regular expressions
		if isString(regexp)
			regexp = new RegExp(regexp)
		assert isRegExp(regexp), "Not a string or regexp: #{OL(regexp)}"
		test @getTestName(), (t) =>
			t.truthy(defined(val.match(regexp)))
		return

	# ..........................................................

	fails: (func) ->

		assert (typeof func == 'function'), "function expected"
		try
			exReset()   # suppress logging of errors
			func()
			failed = false
		catch err
			failed = true
		log = exGetLog()   # we really don't care about log

		test @getTestName(), (t) => t.truthy(failed)
		return

	# ..........................................................

	throws: (func, errClass) ->

		assert (typeof func == 'function'), "Not a function: #{OL(func)}"
		assert isClass(errClass) || isFunction(errClass),
			"Not a class or function: #{OL(errClass)}"
		errObj = undef
		try
			exReset()   # suppress logging of errors
			func()
			failed = false
		catch err
			errObj = err
			failed = true
		log = exGetLog()   # we really don't care about log

		test @getTestName(), (t) =>
			t.truthy(failed && errObj instanceof errClass)
		return

	# ..........................................................

	succeeds: (func) ->

		assert (typeof func == 'function'), "function expected"
		try
			func()
			ok = true
		catch err
			console.error err
			ok = false

		test @getTestName(), (t) => t.truthy(ok)
		return

# ---------------------------------------------------------------------------

export u = new UnitTester()
export transformValue = (func) => u.transformValue = func
export transformExpected = (func) => u.transformExpected = func
export equal = (arg1, arg2) => return u.equal(arg1, arg2)
export like = (arg1, arg2) => return u.like(arg1, arg2)
export samelines = (arg1, arg2) => return u.samelines(arg1, arg2)
export notequal = (arg1, arg2) => return u.notequal(arg1, arg2)
export truthy = (arg) => return u.truthy(arg)
export falsy = (arg) => return u.falsy(arg)
export includes = (arg1, arg2) => return u.includes(arg1, arg2)
export matches = (str, regexp) => return u.matches(str, regexp)
export succeeds = (func) => return u.succeeds(func)
export fails = (func) => return u.fails(func)
export throws = (func, errClass) => return u.throws(func, errClass)
