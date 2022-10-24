# stack.coffee

import {strict as assert} from 'node:assert'

import {
	undef, defined, OL, deepCopy, isArray, isBoolean,
	isEmpty, nonEmpty,
	} from '@jdeighan/exceptions/utils'
import {LOG} from '@jdeighan/exceptions/log'
import {getPrefix} from '@jdeighan/exceptions/prefix'

doDebugStack = false

# ---------------------------------------------------------------------------

export debugStack = (flag=true) ->

	doDebugStack = flag
	return

# ---------------------------------------------------------------------------

export class CallStack

	constructor: () ->

		@lStack = []

	# ........................................................................

	reset: () ->

		if doDebugStack
			console.log "RESET STACK"
		@lStack = []
		return

	# ........................................................................

	indent: () ->
		# --- Only used in debugging the stack

		return getPrefix(@lStack.length)

	# ........................................................................

	enter: (funcName, objName, lArgs=[], isLogged) ->
		# --- funcName might be <object>.<method>

		assert isArray(lArgs),      "bad lArgs"
		assert isBoolean(isLogged), "bad isLogged"

		if doDebugStack
			console.log @indent() + "[--> ENTER #{funcName}]"

		if nonEmpty(objName)
			fullName = "#{objName}.#{funcName}"
		else
			fullName = funcName

		@lStack.push {
			fullName
			funcName
			objName
			isLogged
			lArgs: deepCopy(lArgs)
			}
		return

	# ........................................................................
	# --- if stack is empty, log the error, but continue

	returnFrom: (funcName, objName) ->

		if objName
			fullReturnName = "#{objName}.#{funcName}"
		else
			fullReturnName = funcName

		if @lStack.length == 0
			LOG "ERROR: returnFrom('#{fullReturnName}') but stack is empty"
			return
		{fullName, isLogged} = @lStack.pop()
		if doDebugStack
			console.log @indent() + "[<-- BACK #{fullReturnName}]"
		if (fullName != fullReturnName)
			LOG "ERROR: returnFrom('#{fullReturnName}') but TOS is #{fullName}"
			return

		return

	# ........................................................................

	isLogging: () ->

		if (@lStack.length == 0)
			return false
		else
			return @lStack[@lStack.length - 1].isLogged

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
			return ['main', undef]
		else
			h = @TOS()
			if defined(h)
				return [h.funcName, h.objName]
			else
				return [undef, undef]

	# ........................................................................

	TOS: () ->

		if (@lStack.length == 0)
			return undef
		else
			return @lStack[@lStack.length - 1]

	# ........................................................................

	isActive: (funcName, objName) ->

		for h in @lStack
			if (h.funcName == funcName) && (h.objName == objName)
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
		str = "#{i}: #{sym}#{item.fullName}"
		for arg in item.lArgs
			str += " #{OL(arg)}"
		return str

	# ........................................................................

	sdump: (label='CALL STACK') ->

		lFuncNames = []
		for item in @lStack
			if item.isLogged
				lFuncNames.push '*' + item.fullName
			else
				lFuncNames.push item.fullName
		if @lStack.length == 0
			return "#{label} <EMPTY>"
		else
			return "#{label} #{lFuncNames.join(' ')}"
