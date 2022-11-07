# debug.coffee

import {strict as assert} from 'node:assert'

import {
	undef, defined, notdefined, OL, isString, isFunction, isHash,
	isEmpty, nonEmpty, words, firstWord, inList, oneof, arrayToBlock,
	} from '@jdeighan/base-utils/utils'
import {toTAML} from '@jdeighan/base-utils/taml'
import {getPrefix} from '@jdeighan/base-utils/prefix'
import {LOG, LOGVALUE, setLogger} from '@jdeighan/base-utils/log'
import {CallStack, debugStack} from '@jdeighan/base-utils/stack'

export callStack = new CallStack()

lFuncList = []             # array of {funcName, plus}
internalDebugging = false


logEnter  = undef
logReturn = undef
logYield  = undef
logResume = undef
logValue  = undef
logString = undef

# ---------------------------------------------------------------------------

export debugDebug = (debugFlag=true) =>

	internalDebugging = debugFlag
	return

# ---------------------------------------------------------------------------

export resetDebugging = () ->

	callStack.reset()
	lFuncList = []
	internalDebugging = false

	logEnter  = stdLogEnter
	logReturn = stdLogReturn
	logYield  = stdLogYield
	logResume = stdLogResume
	logValue  = stdLogValue
	logString = stdLogString
	return

# ---------------------------------------------------------------------------

export dumpDebugLoggers = (label=undef) ->

	lLines = []
	if nonEmpty(label)
		lLines.push "LOGGERS (#{label})"
	else
		lLines.push "LOGGERS"
	lLines.push "   enter  - #{logType(logEnter, stdLogEnter)}"
	lLines.push "   return - #{logType(logReturn, stdLogReturn)}"
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

export setDebugging = (lParms...) ->
	# --- pass a hash to set custom loggers

	lFuncList = []   # a package global
	customSet = false
	if internalDebugging
		console.log "setDebugging() with #{lParms.length} parms"
	for parm,i in lParms
		if isString(parm)
			if internalDebugging
				console.log "lParms[#{i}] is string #{OL(parm)}"
			lFuncList = lFuncList.concat(getFuncList(parm))
		else if isHash(parm)
			if internalDebugging
				console.log "lParms[#{i}] is hash #{OL(parm)}"
			customSet = true
			for key,value of parm
				setCustomDebugLogger key, value
		else
			croak "Invalid parm to setDebugging(): #{OL(parm)}"

	if internalDebugging
		console.log 'lFuncList:'
		console.log toTAML(lFuncList)
		if customSet
			dumpDebugLoggers()
	return

# ---------------------------------------------------------------------------

export setCustomDebugLogger = (type, func) ->

	assert isFunction(func), "Not a function"
	switch type
		when 'enter'
			logEnter = func
		when 'returnFrom'
			logReturn = func
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
# simple redirect to an array - useful in unit tests

lUTLog = undef

export dbgReset = () =>
	lUTLog = []
	return

export dbgGetLog = () =>
	result = arrayToBlock(lUTLog)
	lUTLog = undef
	return result

# ---------------------------------------------------------------------------

export dbgEnter = (funcName, lValues...) ->

	assert isString(funcName), "not a string"
	doLog = funcMatch(funcName)
	if internalDebugging
		nVals = lValues.length
		console.log "dbgEnter(#{OL(funcName)},#{OL(nVals)} vals)"
		console.log "   - doLog = #{OL(doLog)}"

	if doLog
		if defined(lUTLog)
			orgLogger = setLogger (str) => lUTLog.push(str)

		level = callStack.getIndentLevel()
		result = logEnter funcName, lValues, level
		if (result == false)
			stdLogEnter funcName, lValues, level

		if defined(lUTLog)
			setLogger orgLogger

	callStack.enter funcName, lValues, doLog
	return true

# ---------------------------------------------------------------------------

export dbgReturn = (funcName, lValues...) ->

	assert isString(funcName), "not a string"
	doLog = callStack.isLogging()
	if internalDebugging
		nVals = lValues.length
		console.log "dbgReturn(#{OL(funcName)},#{OL(nVals)} vals)"
		console.log "   - doLog = #{OL(doLog)}"
	if doLog
		if defined(lUTLog)
			orgLogger = setLogger (str) => lUTLog.push(str)

		level = callStack.getIndentLevel()
		result = logReturn funcName, lValues, level
		if (result == false)
			stdLogReturn funcName, lValues, level

		if defined(lUTLog)
			setLogger orgLogger

	callStack.returnFrom funcName, lValues
	return true

# ---------------------------------------------------------------------------

export dbgYield = (funcName, lValues...) ->

	assert isString(funcName), "not a string"
	doLog = callStack.isLogging()
	if internalDebugging
		nVals = lValues.length
		console.log "dbgYield(#{OL(funcName)},#{OL(nVals)} vals)"
		console.log "   - doLog = #{OL(doLog)}"
	if doLog
		if defined(lUTLog)
			orgLogger = setLogger (str) => lUTLog.push(str)

		level = callStack.getIndentLevel()
		result = logYield funcName, lValues, level
		if (result == false)
			stdLogYield funcName, lValues, level

		if defined(lUTLog)
			setLogger orgLogger

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
		if defined(lUTLog)
			orgLogger = setLogger (str) => lUTLog.push(str)

		level = callStack.getIndentLevel()
		result = logResume funcName, level
		if (result == false)
			stdLogResume funcName, level

		if defined(lUTLog)
			setLogger orgLogger

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
		if defined(lUTLog)
			orgLogger = setLogger (str) => lUTLog.push(str)

		level = callStack.getIndentLevel()
		result = logValue str, value, level
		if (result == false)
			stdLogValue str, value, level

		if defined(lUTLog)
			setLogger orgLogger

	return true

# ---------------------------------------------------------------------------

export dbgString = (str) ->

	assert isString(str), "not a string"
	doLog = callStack.isLogging()
	if internalDebugging
		console.log "dbgString(#{OL(str)})"
		console.log "   - doLog = #{OL(doLog)}"
	if doLog
		if defined(lUTLog)
			orgLogger = setLogger (str) => lUTLog.push(str)

		level = callStack.getIndentLevel()
		result = logString str, level
		if (result == false)
			stdLogString str, level

		if defined(lUTLog)
			setLogger orgLogger

	return true

# ---------------------------------------------------------------------------

export dbg = (lArgs...) ->

	if lArgs.length == 1
		return dbgString lArgs[0]
	else
		return dbgValue lArgs[0], lArgs[1]

# ---------------------------------------------------------------------------
# ---------------------------------------------------------------------------
#    Only these 6 functions ever call LOG or LOGVALUE

export stdLogEnter = (funcName, lValues, level) ->

	labelPre = getPrefix(level, 'plain')
	idPre = getPrefix(level+1, 'plain')
	itemPre = getPrefix(level+2, 'dotLast2Vbars')
	LOG "enter #{funcName}", labelPre
	for obj,i in lValues
		LOGVALUE "arg[#{i}]", obj, idPre, itemPre
	return true

# ---------------------------------------------------------------------------

export stdLogReturn = (funcName, lValues, level) ->

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

resetDebugging()
