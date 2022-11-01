# debug.coffee

import {strict as assert} from 'node:assert'

import {
	undef, defined, notdefined, OL, isString, isFunction,
	isEmpty, nonEmpty, words, firstWord, inList, oneof, arrayToBlock,
	} from '@jdeighan/exceptions/utils'
import {toTAML} from '@jdeighan/exceptions/taml'
import {getPrefix} from '@jdeighan/exceptions/prefix'
import {LOG, LOGVALUE} from '@jdeighan/exceptions/log'
import {CallStack, debugStack} from '@jdeighan/exceptions/stack'

export callStack = new CallStack()

lFuncList = []             # array of {funcName, plus}
internalDebugging = false  # set true on setDebugging('debug')


logEnter      = undef
logReturnFrom = undef
logYield      = undef
logResume     = undef
logValue      = undef
logString     = undef

# ---------------------------------------------------------------------------

export debugDebug = (debugFlag=false) =>

	internalDebugging = debugFlag
	return

# ---------------------------------------------------------------------------

export resetDebugging = () ->

	callStack.reset()
	lFuncList = []
	internalDebugging = false

	logEnter      = stdLogEnter
	logReturnFrom = stdLogReturnFrom
	logYield      = stdLogYield
	logResume     = stdLogResume
	logValue      = stdLogValue
	logString     = stdLogString
	return

# ---------------------------------------------------------------------------

export setCustomDebugLogger = (type, func) ->

	assert isFunction(func), "Not a function"
	switch type
		when 'enter'
			logEnter = func
		when 'returnFrom'
			logReturnFrom = func
		when 'yield'
			logYield = func
		when 'resume'
			logResume = func
		when 'value'
			logValue = func
		when 'string'
			logString = func
		else
			throw new Error("Unknown type: #{OL(type)}")
	return

# ---------------------------------------------------------------------------

export dumpDebugLoggers = (label) ->

	lLines = []
	lLines.push "LOGGERS (#{label})"
	lLines.push "   enter  - #{logType(logEnter, stdLogEnter)}"
	lLines.push "   return - #{logType(logReturnFrom, stdLogReturnFrom)}"
	lLines.push "   yield  - #{logType(logYield, stdLogYield)}"
	lLines.push "   resume - #{logType(logResume, stdLogResume)}"
	lLines.push "   value  - #{logType(logValue, stdLogValue)}"
	lLines.push "   string - #{logType(logString, stdLogString)}"
	console.log arrayToBlock(lLines)

# ---------------------------------------------------------------------------

logType = (cur, std) ->

	if (cur == std)
		return 'std'
	else if defined(cur)
		return 'custom'
	else
		return 'undef'

# ---------------------------------------------------------------------------

export setDebugging = (lStrings...) ->

	lFuncList = []   # a package global
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

export debug = (label, lValues...) ->

	if internalDebugging
		console.log "call debug('#{label}')"

	[type, funcName] = getType(label, lValues)
	switch type
		when 'enter'
			dbgEnter funcName, lValues
		when 'returnFrom'
			dbgReturn funcName, lValues
		when 'yield'
			dbgYield funcName, lValues
		when 'resume'
			dbgResume funcName
		when 'value'
			dbgValue label, lValues[0]
		when 'string'
			dbgString label

	return true   # allow use in boolean expressions

# ---------------------------------------------------------------------------

export dbgEnter = (funcName, lValues) ->

	assert isString(funcName), "not a string"
	doLog = funcMatch(funcName)
	if internalDebugging
		nVals = lValues.length
		console.log "dbgEnter(#{OL(funcName)},#{OL(nVals)} vals)"
		console.log "   - doLog = #{OL(doLog)}"

	if doLog
		logEnter funcName, lValues, callStack.getIndentLevel()
	callStack.enter funcName, lValues, doLog
	return true

# ---------------------------------------------------------------------------

export dbgReturn = (funcName, lValues) ->

	assert isString(funcName), "not a string"
	doLog = callStack.isLogging()
	if internalDebugging
		nVals = lValues.length
		console.log "dbgReturn(#{OL(funcName)},#{OL(nVals)} vals)"
		console.log "   - doLog = #{OL(doLog)}"
	if doLog
		logReturnFrom funcName, lValues, callStack.getIndentLevel()
	callStack.returnFrom funcName, lValues
	return true

# ---------------------------------------------------------------------------

export dbgYield = (funcName, lValues) ->

	assert isString(funcName), "not a string"
	doLog = callStack.isLogging()
	if internalDebugging
		nVals = lValues.length
		console.log "dbgYield(#{OL(funcName)},#{OL(nVals)} vals)"
		console.log "   - doLog = #{OL(doLog)}"
	if doLog
		logYield funcName, lValues, callStack.getIndentLevel()
	callStack.yield funcName, lValues
	return true

# ---------------------------------------------------------------------------

export dbgResume = (funcName) ->

	assert isString(funcName), "not a string"
	doLog = callStack.isLogging()
	if internalDebugging
		console.log "dbgResume(#{OL(funcName)})"
		console.log "   - doLog = #{OL(doLog)}"
	if doLog
		logResume funcName, callStack.getIndentLevel()
	callStack.resume funcName
	return true

# ---------------------------------------------------------------------------

export dbgValue = (str, value) ->

	assert isString(str), "not a string"
	doLog = callStack.isLogging()
	if internalDebugging
		console.log "dbgValue(#{OL(str)},#{OL(value)})"
		console.log "   - doLog = #{OL(doLog)}"
	if doLog
		logValue str, value, callStack.getIndentLevel()
	return true

# ---------------------------------------------------------------------------

export dbgString = (str) ->

	assert isString(str), "not a string"
	doLog = callStack.isLogging()
	if internalDebugging
		console.log "dbgString(#{OL(str)})"
		console.log "   - doLog = #{OL(doLog)}"
	if doLog
		logString str, callStack.getIndentLevel()
	return true

# ---------------------------------------------------------------------------

export dbg = (lArgs...) ->

	if lArgs.length == 1
		return dbgString lArgs[0]
	else
		return dbgValue lArgs[0], lArgs[1]

# ---------------------------------------------------------------------------

export getType = (label, lValues=[]) ->
	# --- returns [type, funcName]
	#     <type> is one of:
	#        'enter'  - funcName is set
	#        'returnFrom' - funcName is set
	#        'yield'  - funcName is set
	#        'resume' - funcName is set
	#        'string' - funcName is undef
	#        'value'  - funcName is undef

	if lMatches = label.match(///^
			( enter | yield | resume )
			\s+
			(
				[A-Za-z_][A-Za-z0-9_]*
				(?:
					\.
					[A-Za-z_][A-Za-z0-9_]*
					)?
				)
			(?: \( \) )?
			$///)
		return [lMatches[1], lMatches[2]]

	if lMatches = label.match(///^
			return
			\s+
			from
			\s+
			(
				[A-Za-z_][A-Za-z0-9_]*
				(?:
					\.
					[A-Za-z_][A-Za-z0-9_]*
					)?
				)
			(?: \( \) )?
			$///)
		return ['returnFrom', lMatches[1]]

	# --- Check for deprecated forms
	assert ! oneof(firstWord(label), 'enter','returnFrom','yield','resume'),
		"deprecated form for debug(): #{OL(label)}"

	# --- if none of the above returned, then...
	if (lValues.length == 1)
		return ['value', undef]
	else if (lValues.length == 0)
		return ['string', undef]
	else
		throw new Error("More than 1 object not allowed here")

# ---------------------------------------------------------------------------

export funcMatch = (fullName) ->
	# --- fullName came from a call to debug()

	if internalDebugging
		console.log "funcMatch(#{OL(fullName)})"

	if defined(lFuncList)
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

export stdLogEnter = (funcName, lValues, level) ->

	labelPre = getPrefix(level, 'plain')
	idPre = getPrefix(level+1, 'plain')
	itemPre = getPrefix(level+2, 'dotLast2Vbars')
	LOG "enter #{funcName}", labelPre
	for obj,i in lValues
		LOGVALUE "arg[#{i}]", obj, idPre, itemPre
	return true

# ---------------------------------------------------------------------------

export stdLogReturnFrom = (funcName, lValues, level) ->

	labelPre = getPrefix(level, 'withArrow')
	idPre = getPrefix(level, 'noLastVbar')
	itemPre = getPrefix(level, 'noLast2Vbars')
	LOG "return from #{funcName}", labelPre
	for obj,i in lValues
		LOGVALUE "ret[#{i}]", obj, idPre, itemPre
	return true

# ---------------------------------------------------------------------------

export stdLogYield = (funcName, lValues, level) ->

	labelPre = getPrefix(level, 'plain')
	idPre = getPrefix(level+1, 'plain')
	itemPre = getPrefix(level+2, 'dotLast2Vbars')
	LOG "yield #{funcName}", labelPre
	for obj,i in lValues
		LOGVALUE "arg[#{i}]", obj, idPre, itemPre
	return true

# ---------------------------------------------------------------------------

export stdLogResume = (funcName, level) ->

	labelPre = getPrefix(level, 'plain')
	LOG "resume #{funcName}", labelPre
	return true

# ---------------------------------------------------------------------------

export stdLogValue = (label, obj, level) ->

	labelPre = getPrefix(level, 'plain')
	LOGVALUE label, obj, labelPre
	return true

# ---------------------------------------------------------------------------

export stdLogString = (label, level) ->

	labelPre = getPrefix(level, 'plain')
	LOG label, labelPre
	return true

# ---------------------------------------------------------------------------

resetDebugging()
