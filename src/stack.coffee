# stack.coffee

import {assert, croak} from '@jdeighan/base-utils/exceptions'
import {
	undef, defined, notdefined, OL, deepCopy, warn, oneof,
	isString, isArray, isBoolean, isEmpty, nonEmpty, isFunctionName,
	spaces, tabs,
	} from '@jdeighan/base-utils/utils'
import {LOG} from '@jdeighan/base-utils/log'

internalDebugging = false
doThrowOnError = false

# ---------------------------------------------------------------------------

export throwOnError = (flag=true) ->

	save = doThrowOnError
	doThrowOnError = flag
	return save

# ---------------------------------------------------------------------------

export debugStack = (flag=true) ->

	save = internalDebugging
	internalDebugging = !!flag
	return save

# ---------------------------------------------------------------------------

export class CallStack

	constructor: () ->

		# --- Items on stack have keys:
		#        funcName
		#        lArgs
		#        caller
		#        doLog
		#        isYielded
		@reset()

	# ........................................................................

	reset: () ->

		@lStack = []
		@level = 0
		@logLevel = 0
		if internalDebugging
			@dbg "RESET STACK"
		return

	# ........................................................................
	# ........................................................................

	enter: (funcName, lArgs=[], doLog=false) ->

		assert isFunctionName(funcName), "not a function name"
		assert isArray(lArgs), "not an array"
		@lStack.push {
			funcName
			lArgs: deepCopy(lArgs)
			caller: @currentFuncRec()
			doLog
			isYielded: false
			}
		if internalDebugging
			nArgs = lArgs.length
			if (nArgs == 0)
				@dbg "ENTER #{funcName}"
			else
				@dbg "ENTER #{funcName} #{nArgs} args"
		@incLevel(doLog)
		return

	# ........................................................................

	returnFrom: (funcName) ->

		assert isString(funcName), "not a string"

		rec = @currentFuncRec()
		@stackAssert (funcName == rec.funcName),
			"returnFrom #{funcName} but current func is #{rec.funcName}"
		@stackAssert ! @TOS.isYielded,
			"returnFrom #{funcName} but #{@TOS().funcName} at TOS is yielded"
		@lStack.pop()
		if internalDebugging
			@dbg "RETURN FROM #{funcName}"
		@decLevel(rec.doLog)
		return

	# ........................................................................

	returnVal: (funcName, val) ->

		assert isString(funcName), "not a string"

		rec = @currentFuncRec()
		@stackAssert (funcName == rec.funcName),
			"returnFrom #{funcName} but current func is #{rec.funcName}"
		@stackAssert ! @TOS.isYielded,
			"returnFrom #{funcName} but #{@TOS().funcName} at TOS is yielded"
		@lStack.pop()
		if internalDebugging
			@dbg "RETURN FROM #{funcName} #{OL(val)}"
		@decLevel(rec.doLog)
		return

	# ........................................................................

	yield: (lArgs...) ->

		assert (lArgs.length == 2), "Bad # args: #{lArgs.length}"
		[funcName, val] = lArgs
		rec = @currentFuncRec()
		rec.isYielded = true
		if internalDebugging
			@dbg "YIELD #{OL(val)} - in #{funcName}"
		return

	# ........................................................................

	yieldFrom: (funcName) ->

		rec = @currentFuncRec()
		rec.isYielded = true
		if internalDebugging
			@dbg "YIELD FROM - in #{funcName}"
		return

	# ........................................................................

	resume: (funcName) ->

		rec = @TOS()
		assert (rec.funcName == funcName),
				"resume #{funcName} but TOS is #{rec.funcName}"
		@stackAssert (rec.isYielded),
			"resume('#{funcName}') but #{funcName} is not yielded"
		rec.isYielded = false

		if internalDebugging
			@dbg "RESUME #{funcName}"
		return

	# ........................................................................
	# ........................................................................

	dbg: (str) ->

		curFunc = @currentFunc() || '<undef>'
		LOG "#{tabs(@level)}#{str} => #{curFunc}"
		return

	# ........................................................................

	incLevel: (doLog) ->

		@level += 1
		if doLog
			@logLevel += 1
		return

	# ........................................................................

	decLevel: (doLog) ->

		@level -= 1
		if doLog
			@logLevel -= 1
		return

	# ........................................................................

	stackAssert: (cond, msg) ->
		# --- We don't really want to throw exceptions here

		if !cond
			if doThrowOnError
				croak "#{msg}\n#{@dump()}"
			else
				warn "#{msg}\n#{@dump()}"
		return

	# ........................................................................

	isLogging: () ->

		rec = @currentFuncRec()
		if defined(rec)
			return rec.doLog
		else
			return false

	# ........................................................................

	currentFunc: () ->

		rec = @currentFuncRec()
		if defined(rec)
			return rec.funcName
		else
			return undef

	# ........................................................................

	currentFuncRec: () ->

		return @lStack.findLast((rec) -> ! rec.isYielded)

	# ........................................................................

	TOS: () ->

		if (@lStack.length == 0)
			return undef
		else
			return @lStack[@lStack.length - 1]

	# ........................................................................

	isActive: (funcName) ->

		for h in @lStack
			if (h.funcName == funcName)
				return true
		return false

	# ........................................................................

	dump: () ->

		lLines = ['-- CALL STACK --']
		if @lStack.length == 0
			lLines.push "\t<EMPTY>"
		else
			pos = @lStack.length
			while (pos > 0)
				pos -= 1
				lLines.push "\t" + @callStr(@lStack[pos])
		return lLines.join("\n")

	# ........................................................................

	callStr: (item) ->

		sym = if item.doLog then 'L' else '-'
		if item.isYielded
			return "#{sym} #{item.funcName}*"
		else
			return "#{sym} #{item.funcName}"
