# debug.coffee

import {strict as assert} from 'node:assert'

import {
	undef, defined, notdefined, OL, isString, isFunction,
	isEmpty, nonEmpty, words,
	} from '@jdeighan/exceptions/utils'
import {toTAML} from '@jdeighan/exceptions/taml'
import {getPrefix} from '@jdeighan/exceptions/prefix'
import {LOG, LOGVALUE} from '@jdeighan/exceptions/log'
import {CallStack} from '@jdeighan/exceptions/stack'

callStack = new CallStack()
lFuncList = undef           # array of {funcName, objName, plus}
internalDebugging = false   # set true on setDebugging('debug')

customLogEnter = undef
customLogReturn = undef
customLogValue = undef
customLogString = undef

# ---------------------------------------------------------------------------

export setCustomDebugLogger = (type, func) ->

	assert isFunction(func), "Not a function"
	switch type
		when 'enter'
			customLogEnter = func
		when 'return'
			customLogReturn = func
		when 'value'
			customLogValue = func
		when 'string'
			customLogString = func
		else
			throw new error("Unknown type: #{OL(type)}")
	return

# ---------------------------------------------------------------------------

export resetDebugging = () ->

	callStack.reset()
	lFuncList = undef
	internalDebugging = false
	customLogEnter = undef
	customLogReturn = undef
	customLogValue = undef
	customLogString = undef
	return

# ---------------------------------------------------------------------------

export setDebugging = (funcNameStr) ->

	callStack.reset()
	if isEmpty(funcNameStr)
		resetDebugging()
	else
		assert isString(funcNameStr), "not a string: #{OL(funcNameStr)}"
		lFuncList = getFuncList(funcNameStr)
		if internalDebugging
			console.log 'lFuncList:'
			console.log toTAML(lFuncList)
	return

# ---------------------------------------------------------------------------

export getFuncList = (str) ->

	lFuncList = []
	for word in words(str)
		if (word == 'debug')
			internalDebugging = true
		if lMatches = word.match(///^
				([A-Za-z_][A-Za-z0-9_]*)
				(?:
					\.
					([A-Za-z_][A-Za-z0-9_]*)
					)?
				(\+)?
				$///)
			[_, ident1, ident2, plus] = lMatches
			if ident2
				lFuncList.push {
					funcName: ident2
					objName: ident1
					plus: (plus == '+')
					}
			else
				lFuncList.push {
					funcName: ident1
					objName: undef
					plus: (plus == '+')
					}
		else
			throw new Error("getFuncList: bad word : #{OL(word)}")
	return lFuncList

# ---------------------------------------------------------------------------

export debug = (label, lObjects...) ->

	assert isString(label), "1st arg #{OL(label)} should be a string"

	if internalDebugging
		console.log "call debug('#{label}')"

	[type, funcName, objName] = getType(label, lObjects)
	if internalDebugging
		console.log "   - type = #{OL(type)}, func = #{OL(funcName)}, obj = #{OL(objName)}"

	switch type
		when 'enter','return'
			assert nonEmpty(funcName), "enter without funcName"
			doLog = funcMatch(funcName, objName)
		when 'value','string'
			assert isEmpty(funcName), "string with funcName"
			doLog = funcMatch(callStack.curFunc()...)
		else
			doLog = false   # debugging is turned off, i.e. lFuncList == undef

	if internalDebugging
		console.log "   - doLog = #{OL(doLog)}"

	level = callStack.getLevel()
	handled = false
	switch type
		when 'enter'
			if doLog
				if defined(customLogEnter)
					handled = customLogEnter label, lObjects, level, funcName, objName
				if ! handled
					logEnter label, lObjects, level
			callStack.enter funcName, objName, lObjects, doLog

		when 'return'
			if doLog
				if defined(customLogReturn)
					handled = customLogReturn label, lObjects, level, funcName, objName
				if ! handled
					logReturn label, lObjects, level

			callStack.returnFrom funcName, objName

		when 'value'
			if doLog
				if defined(customLogValue)
					handled = customLogValue label, lObjects[0], level
				if ! handled
					logValue label, lObjects[0], level

		when 'string'
			if doLog
				if defined(customLogString)
					handled = customLogString label, level
				if ! handled
					logString label, level

	return true   # allow use in boolean expressions

# ---------------------------------------------------------------------------

export logEnter = (label, lObjects, level) ->

	labelPre = getPrefix(level, 'plain')
	idPre = getPrefix(level+1, 'plain')
	itemPre = getPrefix(level+2, 'dotLast2Vbars')
	LOG label, labelPre
	for obj,i in lObjects
		LOGVALUE "arg[#{i}]", obj, idPre, itemPre
	return

# ---------------------------------------------------------------------------

export logReturn = (label, lObjects, level) ->

	labelPre = getPrefix(level, 'withArrow')
	idPre = getPrefix(level, 'noLastVbar')
	itemPre = getPrefix(level, 'noLast2Vbars')
	LOG label, labelPre
	for obj,i in lObjects
		LOGVALUE "ret[#{i}]", obj, idPre, itemPre
	return

# ---------------------------------------------------------------------------

export logValue = (label, obj, level) ->

	labelPre = getPrefix(level, 'plain')
	LOGVALUE label, obj, labelPre
	return

# ---------------------------------------------------------------------------

export logString = (label, level) ->

	labelPre = getPrefix(level, 'plain')
	LOG label, labelPre
	return

# ---------------------------------------------------------------------------

export getType = (label, lObjects=[]) ->

	# --- If lFuncList is undef, all debugging is turned off
	if notdefined(lFuncList)
		return [undef, undef, undef]

	if lMatches = label.match(///^
			\s*
			( enter | (?: return .+ from ) )
			\s+
			([A-Za-z_][A-Za-z0-9_]*)
			(?:
				\.
				([A-Za-z_][A-Za-z0-9_]*)
				)?
			///)
		[_, type, ident1, ident2] = lMatches

		if ident2
			objName  = ident1
			funcName = ident2
		else
			objName = undef
			funcName = ident1

		if (type == 'enter')
			return ['enter', funcName, objName]
		else
			return ['return', funcName, objName]
	else if (lObjects.length == 1)
		return ['value', undef, undef]
	else if (lObjects.length == 0)
		return ['string', undef, undef]
	else
		throw new Error("More than 1 object not allowed")

# ---------------------------------------------------------------------------

export funcMatch = (funcName, objName) ->

	if internalDebugging
		console.log "funcMatch(#{OL(funcName)}, #{OL(objName)})"

	for h in lFuncList
		if defined(h.objName)
			if (funcName == h.funcName) && (objName == h.objName)
				return true
		else
			if (h.funcName == funcName)
				return true
		if h.plus && callStack.isActive(h.funcName, h.objName)
			return true
	return false

# ---------------------------------------------------------------------------
