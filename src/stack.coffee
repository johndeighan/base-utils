# stack.coffee

import {strict as assert} from 'node:assert'

import {
	undef, defined, notdefined, OL, deepCopy, warn, oneof, spaces,
	isString, isArray, isBoolean, isEmpty, nonEmpty,
	} from '@jdeighan/exceptions/utils'
import {LOG} from '@jdeighan/exceptions/log'
import {getPrefix} from '@jdeighan/exceptions/prefix'

internalDebugging = false

# ---------------------------------------------------------------------------

export debugStack = (flag=true) ->

	internalDebugging = flag
	return

# ---------------------------------------------------------------------------

export class CallStack

	constructor: (debugFlag=false) ->

		# --- Items on stack have keys:
		#        funcName
		#        lArgs
		#        doLog
		#        isYielded
		debugStack(debugFlag)
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

	stackErr: (cond, msg) ->
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
				@dbg "[--> ENTER #{funcName}]"
			else
				@dbg "[--> ENTER #{funcName} #{nArgs} args]"

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

		assert isArray(lVals), "not an array"
		rec = @currentFuncRec()
		@stackErr (funcName == rec.funcName),
			"returnFrom('#{funcName}') but current func is #{rec.funcName}"
		@stackErr ! @TOS.isYielded,
			"returnFrom('#{funcName}') but #{@TOS().funcName} at TOS is yielded"
		if internalDebugging
			nVals = @lVals.length
			if (nVals == 0)
				@dbg "[<-- RETURN FROM #{funcName}]"
			else
				@dbg "[<-- RETURN FROM #{funcName} #{nVals} vals]"
		@lStack.pop()
		return

	# ........................................................................

	yield: (funcName, lVals=[]) ->

		assert isString(funcName), "not a string"
		assert isArray(lVals), "not an array"
		if internalDebugging
			nVals = @lVals.length
			if (nVals == 0)
				@dbg "[--> YIELD]"
			else
				@dbg "[--> YIELD #{funcName} #{nVals} vals]"

		rec = @currentFuncRec()
		@stackErr (funcName == rec.funcName),
			"yield #{funcName}, but current func is #{rec.funcName}"
		rec.isYielded = true
		return

	# ........................................................................
	# --- if stack is empty, log the error, but continue

	resume: (funcName) ->

		rec = @TOS()
		@stackErr (rec.isYielded),
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
