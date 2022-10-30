# stack.coffee

import {strict as assert} from 'node:assert'

import {
	undef, defined, OL, deepCopy, isArray, isBoolean,
	isEmpty, nonEmpty,
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

	constructor: () ->

		@lStack = []

	# ........................................................................

	reset: () ->

		if internalDebugging
			console.log "RESET STACK"
		@lStack = []
		return

	# ........................................................................

	indent: () ->
		# --- Only used in debugging the stack

		return getPrefix(@lStack.length)

	# ........................................................................

	enter: (funcName, lArgs, isLogged) ->

		assert isArray(lArgs),      "bad lArgs"
		assert isBoolean(isLogged), "bad isLogged"

		if internalDebugging
			console.log @indent() + "[--> ENTER #{funcName}]"

		@lStack.push {
			funcName
			lArgs: deepCopy(lArgs)
			isLogged
			}
		return

	# ........................................................................
	# --- if stack is empty, log the error, but continue

	returnFrom: (funcName) ->

		if @lStack.length == 0
			LOG "ERROR: returnFrom('#{funcName}') but stack is empty"
			return
		if (@TOS().funcName != funcName)
			LOG "ERROR: returnFrom('#{funcName}') but TOS is #{@TOS().funcName}"
			return
		{funcName, isLogged} = @lStack.pop()
		if internalDebugging
			console.log @indent() + "[<-- RETURN FROM #{funcName}]"

		return

	# ........................................................................

	yield: (funcName, lArgs=[], isLogged) ->

		assert isArray(lArgs),      "bad lArgs"
		assert isBoolean(isLogged), "bad isLogged"

		if internalDebugging
			console.log @indent() + "[--> YIELD #{funcName}]"

		@lStack.push {
			funcName
			lArgs: deepCopy(lArgs)
			isLogged
			}
		return

	# ........................................................................
	# --- if stack is empty, log the error, but continue

	continue: (funcName) ->

		if (@lStack.length == 0)
			LOG "ERROR: continue('#{funcName}') but stack is empty"
			return
		if (@TOS().funcName != funcName)
			LOG "ERROR: continue('#{funcName}') but TOS is #{@TOS().funcName}"
			return
		{funcName, isLogged} = @lStack.pop()
		if internalDebugging
			console.log @indent() + "[<-- CONTINUE #{funcName}]"

		return

	# ........................................................................

	isLogging: () ->

		if (@lStack.length == 0)
			return false
		else
			return @TOS().isLogged

	# ........................................................................

	getLevel: () ->

		level = 0
		for item in @lStack
			if item.isLogged
				level += 1
		return level

	# ........................................................................

	curFunc: () ->

		if (@lStack.length == 0)
			return 'main'
		else
			return @TOS().funcName

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

		lLines = ['CALL STACK']
		if @lStack.length == 0
			lLines.push "   <EMPTY>"
		else
			for item, i in @lStack
				lLines.push "   " + @callStr(i, item)
		return lLines.join("\n")

	# ........................................................................

	callStr: (i, item) ->

		sym = if item.isLogged then '*' else '-'
		str = "#{i}: #{sym}#{item.funcName}"
		for arg in item.lArgs
			str += " #{OL(arg)}"
		return str

	# ........................................................................

	sdump: (label='CALL STACK') ->

		lFuncNames = []
		for item in @lStack
			if item.isLogged
				lFuncNames.push '*' + item.funcName
			else
				lFuncNames.push item.funcName
		if @lStack.length == 0
			return "#{label} <EMPTY>"
		else
			return "#{label} #{lFuncNames.join(' ')}"
