# debug.coffee

import {strict as assert} from 'node:assert'

import {
	undef, defined, notdefined, OL, isString, isFunction,
	isEmpty, nonEmpty, words, inList,
	} from '@jdeighan/exceptions/utils'
import {toTAML} from '@jdeighan/exceptions/taml'
import {getPrefix} from '@jdeighan/exceptions/prefix'
import {LOG, LOGVALUE} from '@jdeighan/exceptions/log'
import {CallStack} from '@jdeighan/exceptions/stack'

callStack = new CallStack()
lFuncList = undef           # array of {funcName, plus}
internalDebugging = false   # set true on setDebugging('debug')

customLogEnter = undef
customLogReturn = undef
customLogYield = undef
customLogContinue = undef
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

export setDebugging = (lStrings...) ->

	callStack.reset()
	if isEmpty(lStrings)
		resetDebugging()
		return
	lFuncList = []
	for str in lStrings
		assert isString(str), "not a string: #{OL(str)}"
		lFuncList = lFuncList.concat(getFuncList(str))
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
		[fullName, modifier] = parseFunc(word)
		assert defined(fullName), "Bad debug object: #{OL(word)}"
		lFuncList.push {
			fullName
			plus: (modifier == '+')
			}
	return lFuncList

# ---------------------------------------------------------------------------

export debug = (label, lObjects...) ->

	assert isString(label), "1st arg #{OL(label)} should be a string"

	if internalDebugging
		console.log "call debug('#{label}')"

	if notdefined(lFuncList)
		type = undef
	else
		[type, funcName] = getType(label, lObjects)

	if internalDebugging
		console.log "   - type = #{OL(type)}"
		console.log "   - func = #{OL(funcName)}"

	switch type
		when 'enter','return','yield','continue'
			assert nonEmpty(funcName), "enter without funcName"
			doLog = funcMatch(funcName)
		when 'value','string'
			assert isEmpty(funcName), "string with funcName"
			doLog = funcMatch(callStack.curFunc())
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
					handled = customLogEnter label, lObjects, level, funcName
				if ! handled
					logEnter label, lObjects, level
			callStack.enter funcName, lObjects, doLog

		when 'return'
			if doLog
				if defined(customLogReturn)
					handled = customLogReturn label, lObjects, level, funcName
				if ! handled
					logReturn label, lObjects, level

			callStack.returnFrom funcName

		when 'yield'
			if doLog
				if defined(customLogYield)
					handled = customLogYield label, lObjects, level, funcName
				if ! handled
					logYield label, lObjects, level
			callStack.yield funcName, lObjects, doLog

		when 'continue'
			if doLog
				if defined(customLogContinue)
					handled = customLogContinue label, lObjects, level, funcName
				if ! handled
					logContinue label, lObjects, level
			callStack.continue funcName, lObjects, doLog

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

export logYield = (label, lObjects, level) ->

	labelPre = getPrefix(level, 'plain')
	idPre = getPrefix(level+1, 'plain')
	itemPre = getPrefix(level+2, 'dotLast2Vbars')
	LOG label, labelPre
	for obj,i in lObjects
		LOGVALUE "arg[#{i}]", obj, idPre, itemPre
	return

# ---------------------------------------------------------------------------

export logContinue = (label, lObjects, level) ->

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
	# --- returns [type, funcName], where funcName might be undef

	if lMatches = label.match(///^
			(    enter
				| (?: return \b .+ from )
				| (?: yield \b .+ from )
				| continue
				)
			\s+
			(
				[A-Za-z_][A-Za-z0-9_]*
				(?:
					\.
					[A-Za-z_][A-Za-z0-9_]*
					)?
				)
			///)
		[_, typeStr, funcName] = lMatches
		return [words(typeStr)[0], funcName]
	else if (lObjects.length == 1)
		return ['value', undef]
	else if (lObjects.length == 0)
		return ['string', undef]
	else
		throw new Error("More than 1 object not allowed")

# ---------------------------------------------------------------------------

export funcMatch = (fullName) ->
	# --- fullName came from a call to debug()

	if internalDebugging
		console.log "funcMatch(#{OL(fullName)})"

	for h in lFuncList
		if (h.fullName == fullName)
			return true
		if h.plus && callStack.isActive(fullName)
			return true
	return false

# ........................................................................

export parseFunc = (str) ->
	# --- returns [fullName, modifier]

	if lMatches = str.match(///^
			(
				[A-Za-z_][A-Za-z0-9_]*
				(?:
					\.
					[A-Za-z_][A-Za-z0-9_]*
					)?
				)
			(\+)?
			$///)
		[_, fullName, modifier] = lMatches
		return [fullName, modifier]
	else
		return [undef, undef]

# ---------------------------------------------------------------------------
