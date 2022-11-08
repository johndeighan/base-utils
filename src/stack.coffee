# stack.coffee

import {strict as assert} from 'node:assert'

import {
	undef, defined, notdefined, OL, deepCopy, warn, oneof, spaces,
	isString, isArray, isBoolean, isEmpty, nonEmpty,
	} from '@jdeighan/base-utils/utils'
import {LOG} from '@jdeighan/base-utils/log'
import {getPrefix} from '@jdeighan/base-utils/prefix'

internalDebugging = false

# ---------------------------------------------------------------------------

export debugStack = (flag=true) ->

	internalDebugging = flag
	return

# ---------------------------------------------------------------------------

export class CallStack

	constructor: () ->

		# --- Items on stack have keys:
		#        funcName
		#        lArgs
		#        doLog
		#        isYielded
		@lStack = []

	# ........................................................................

	dbg: (str) ->

		console.log @indent() + str
		return

	# ........................................................................

	reset: () ->

		@lStack = []
		if internalDebugging
			@dbg "RESET STACK"
		return

	# ........................................................................

	indent: () ->
		# --- Only used in debugging the stack

		return getPrefix(@lStack.length)

	# ........................................................................

	stackAssert: (cond, msg) ->
		# --- We don't really want to throw exceptions here

		if !cond
			warn "#{msg}\n#{@dump()}"
		return

	# ........................................................................
	# ........................................................................

	enter: (funcName, lArgs=[], doLog=false) ->

		assert isArray(lArgs), "not an array"
		if internalDebugging
			nArgs = lArgs.length
			if (nArgs == 0)
				@dbg "[--> ENTER #{OL(funcName)}]"
			else
				@dbg "[--> ENTER #{OL(funcName)} #{nArgs} args]"

		@lStack.push {
			funcName
			lArgs: deepCopy(lArgs)
			doLog
			isYielded: false
			}
		return

	# ........................................................................
	# --- if stack is empty, log the error, but continue

	returnFrom: (funcName, lVals=[]) ->

		assert isString(funcName), "not a string"
		str = OL(funcName)
		assert isArray(lVals), "not an array"
		rec = @currentFuncRec()
		@stackAssert (funcName == rec.funcName),
			"returnFrom(#{str}) but current func is #{OL(rec.funcName)}"
		@stackAssert ! @TOS.isYielded,
			"returnFrom(#{str}) but #{OL(@TOS().funcName)} at TOS is yielded"
		if internalDebugging
			nVals = lVals.length
			if (nVals == 0)
				@dbg "[<-- RETURN FROM #{str}]"
			else
				@dbg "[<-- RETURN FROM #{str} #{nVals} vals]"
		@lStack.pop()
		return

	# ........................................................................

	yield: (funcName, lVals=[]) ->

		assert isString(funcName), "not a string"
		str = OL(funcName)
		assert isArray(lVals), "not an array"
		if internalDebugging
			nVals = lVals.length
			if (nVals == 0)
				@dbg "[--> YIELD]"
			else
				@dbg "[--> YIELD #{str} #{nVals} vals]"

		rec = @currentFuncRec()
		@stackAssert (funcName == rec.funcName),
			"yield #{str}, but current func is #{rec.funcName}"
		rec.isYielded = true
		return

	# ........................................................................
	# --- if stack is empty, log the error, but continue

	resume: (funcName) ->

		rec = @TOS()
		@stackAssert (rec.isYielded),
			"resume('#{funcName}') but #{funcName} is not yielded"
		rec.isYielded = false

		if internalDebugging
			@dbg "[<-- RESUME #{funcName}]"
		return

	# ........................................................................
	# ........................................................................

	isLogging: () ->

		rec = @currentFuncRec()
		if defined(rec)
			return rec.doLog
		else
			return false

	# ........................................................................

	getIndentLevel: () ->

		level = 0
		for item in @lStack
			if item.doLog
				level += 1
		return level

	# ........................................................................

	currentFunc: () ->

		rec = @currentFuncRec()
		if defined(rec)
			return rec.funcName
		else
			return 'main'

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

	size: () ->

		return @lStack.length

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
