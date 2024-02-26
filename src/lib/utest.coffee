# utest.coffee

import test from 'ava'

import {defined, isInteger} from '@jdeighan/base-utils'
import {
	assert, croak, exReset, exGetLog,
	} from '@jdeighan/base-utils/exceptions'
import {isFile, parsePath, fileExt} from '@jdeighan/base-utils/ll-fs'
import {mapLineNum} from '@jdeighan/base-utils/source-map'
import {getMyOutsideCaller} from '@jdeighan/base-utils/v8-stack'

# ---------------------------------------------------------------------------
# --- Available tests w/num required params (aside from line num)
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

	getParms: (lParms, nExpected) =>

		nParms = lParms.length
		if @debug
			console.log "getParms(): #{nParms} parameters"
		if (nParms == nExpected)
			if @debug
				console.log "   find correct line number"

			# --- We need to figure out the line number of the caller
			{filePath, line, column} = getMyOutsideCaller()
			if @debug
				console.log "   filePath = '#{filePath}'"
				console.log "   line = #{line}, col = #{column}"

			if ! isInteger(line)
				console.log "getMyOutsideCaller() returned non-integer"
				console.log {filePath, line, column}
			assert fileExt(filePath) == '.js', "caller not a JS file", "fileExt(filePath) == '.js'"

			# --- Attempt to use source map to get true line number
			mapFile = "#{filePath}.map"
			try
				assert isFile(mapFile), "Missing map file for #{filePath}", "isFile(mapFile)"
				mline = mapLineNum filePath, line, column, {debug: @debug}
				if @debug
					console.log "   mapped to #{mline}"
				assert isInteger(mline), "not an integer: #{mline}", "isInteger(mline)"
				return [@dedupLine(mline), lParms...]
			catch err
				return [@dedupLine(line), lParms...]
		else if (nParms = nExpected + 1)
			line = lParms[0]
			assert isInteger(line), "not an integer #{line}", "isInteger(line)"
			lParms[0] = @dedupLine(lParms[0])
			return lParms
		else
			croak "Bad parameters to utest function"

	# ..........................................................

	dedupLine: (line) ->

		assert isInteger(line), "#{line} is not an integer"
		# --- patch line to avoid duplicates
		while @hFound[line]
			line += 10000
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

	equal: (lParms...) ->

		[lineNum, val, expected] = @getParms lParms, 2
		test "line #{lineNum}", (t) =>
			t.deepEqual(@transformValue(val), @transformExpected(expected))

	# ..........................................................

	notequal: (lParms...) ->

		[lineNum, val, expected] = @getParms lParms, 2
		test "line #{lineNum}", (t) =>
			t.notDeepEqual(@transformValue(val), @transformExpected(expected))

	# ..........................................................

	truthy: (lParms...) ->

		[lineNum, bool] = @getParms lParms, 1
		test "line #{lineNum}", (t) =>
			t.truthy(@transformValue(bool))

	# ..........................................................

	falsy: (lParms...) ->

		[lineNum, bool] = @getParms lParms, 1
		test "line #{lineNum}", (t) =>
			t.falsy(@transformValue(bool))

	# ..........................................................

	like: (lParms...) ->

		[lineNum, val, expected] = @getParms lParms, 2
		test "line #{lineNum}", (t) =>
			t.like(@transformValue(val), @transformExpected(expected))

	# ..........................................................

	throws: (lParams...) ->

		[lineNum, func] = @getParms lParams, 1
		if (typeof func != 'function')
			throw new Error("function expected")
		try
			exReset()   # suppress logging of errors
			func()
			ok = true
		catch err
			ok = false
		log = exGetLog()   # we really don't care about log

		test "line #{lineNum}", (t) => t.falsy(ok)

	# ..........................................................

	succeeds: (lParams...) ->

		[lineNum, func] = @getParms lParams, 1
		if (typeof func != 'function')
			throw new Error("function expected")
		try
			func()
			ok = true
		catch err
			console.error err
			ok = false

		test "line #{lineNum}", (t) => t.truthy(ok)

export utest = new UnitTester()
export u = new UnitTester()

u_private = new UnitTester()
export equal = (arg1, arg2) => return u_private.equal(arg1, arg2)
export like = (arg1, arg2) => return u_private.like(arg1, arg2)
export notequal = (arg1, arg2) => return u_private.notequal(arg1, arg2)
export truthy = (arg) => return u_private.truthy(arg)
export falsy = (arg) => return u_private.falsy(arg)
export throws = (func) => return u_private.throws(func)
export succeeds = (func) => return u_private.succeeds(func)
