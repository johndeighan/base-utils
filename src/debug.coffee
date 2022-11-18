# debug.coffee

import {assert, croak} from '@jdeighan/base-utils/exceptions'
import {
	undef, defined, notdefined, OL, OLS, isIdentifier, isFunctionName,
	isString, isFunction, isArray, isHash, isBoolean, isInteger,
	isEmpty, nonEmpty,
	words, firstWord, inList, oneof,
	arrayToBlock,
	} from '@jdeighan/base-utils/utils'
import {getPrefix} from '@jdeighan/base-utils/prefix'
import {
	LOG, LOGVALUE, stringFits, setLogger, debugLogging,
	} from '@jdeighan/base-utils/log'
import {toTAML} from '@jdeighan/base-utils/taml'
import {CallStack, debugStack} from '@jdeighan/base-utils/stack'

export {debugStack, debugLogging}

export callStack = new CallStack()

lFuncList = []      # array of {funcName, plus}
logAll = false      # if true, always log
internalDebugging = false

logEnter     = undef
logReturn    = undef
logReturnVal = undef
logYield     = undef
logYieldFrom = undef
logResume    = undef
logValue     = undef
logString    = undef

# ---------------------------------------------------------------------------

export debugDebug = (debugFlag=true) =>

	internalDebugging = debugFlag
	return

# ---------------------------------------------------------------------------

export dumpDebugLoggers = (label=undef) ->

	lLines = []
	if nonEmpty(label)
		lLines.push "LOGGERS (#{label})"
	else
		lLines.push "LOGGERS"
	lLines.push "   enter      - #{logType(logEnter, stdLogEnter)}"
	lLines.push "   return     - #{logType(logReturn, stdLogReturn)}"
	lLines.push "   return val - #{logType(logReturnVal, stdLogReturnVal)}"
	lLines.push "   yield      - #{logType(logYield, stdLogYield)}"
	lLines.push "   yield from - #{logType(logYieldFrom, stdLogYieldFrom)}"
	lLines.push "   resume     - #{logType(logResume, stdLogResume)}"
	lLines.push "   string     - #{logType(logString, stdLogString)}"
	lLines.push "   value      - #{logType(logValue, stdLogValue)}"
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

	if internalDebugging
		console.log "setDebugging() with #{lParms.length} parms"

	callStack.reset()
	lFuncList = []
	logAll = false
	logEnter     = stdLogEnter
	logReturn    = stdLogReturn
	logReturnVal = stdLogReturnVal
	logYield     = stdLogYield
	logYieldFrom = stdLogYieldFrom
	logResume    = stdLogResume
	logValue     = stdLogValue
	logString    = stdLogString

	customSet = false
	for parm,i in lParms
		if isBoolean(parm)
			logAll = parm
		else if isString(parm)
			logAll = false
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
		when 'returnVal'
			logReturnVal = func
		when 'yield'
			logYield = func
		when 'yieldFrom'
			logYieldFrom = func
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

	lFuncs = []
	for word in words(str)
		if (word == 'debug')
			internalDebugging = true
		[fullName, modifier] = parseFunc(word)
		assert defined(fullName), "Bad debug object: #{OL(word)}"
		lFuncs.push {
			fullName
			plus: (modifier == '+')
			}
	return lFuncs

# ---------------------------------------------------------------------------
# simple redirect to an array - useful in unit tests

lDebugLog = undef

export dbgReset = () =>
	lDebugLog = []
	return

export dbgGetLog = () =>
	result = arrayToBlock(lDebugLog)
	lDebugLog = undef
	return result

# ---------------------------------------------------------------------------
# Stack is only modified in these 8 functions (it is reset in setDebugging())
# ---------------------------------------------------------------------------

export dbgEnter = (funcName, lValues...) ->

	assert isFunctionName(funcName), "not a valid function name"
	doLog = logAll || funcMatch(funcName)
	if internalDebugging
		nVals = lValues.length
		console.log "dbgEnter #{OL(funcName)}, #{OL(nVals)} vals"
		console.log "   - doLog = #{OL(doLog)}"

	if doLog
		if defined(lDebugLog)
			orgLogger = setLogger (str) => lDebugLog.push(str)

		level = callStack.logLevel
		if ! logEnter funcName, lValues, level
			stdLogEnter funcName, lValues, level

		if defined(lDebugLog)
			setLogger orgLogger

	callStack.enter funcName, lValues, doLog
	return true

# ---------------------------------------------------------------------------

export dbgReturn = (funcName) ->

	assert isFunctionName(funcName), "not a valid function name"
	doLog = logAll || callStack.isLogging()
	if internalDebugging
		console.log "dbgReturn #{OL(funcName)}"
		console.log "   - doLog = #{OL(doLog)}"
	if doLog
		if defined(lDebugLog)
			orgLogger = setLogger (str) => lDebugLog.push(str)

		level = callStack.logLevel
		if ! logReturn funcName, level
			stdLogReturn funcName, level

		if defined(lDebugLog)
			setLogger orgLogger

	callStack.returnFrom funcName
	return true

# ---------------------------------------------------------------------------

export dbgReturnVal = (funcName, val) ->

	assert isFunctionName(funcName), "not a valid function name"
	doLog = logAll || callStack.isLogging()
	if internalDebugging
		console.log "dbgReturn #{OL(funcName)}, #{OL(val)}"
		console.log "   - doLog = #{OL(doLog)}"
	if doLog
		if defined(lDebugLog)
			orgLogger = setLogger (str) => lDebugLog.push(str)

		level = callStack.logLevel
		if ! logReturnVal funcName, val, level
			stdLogReturnVal funcName, val, level

		if defined(lDebugLog)
			setLogger orgLogger

	callStack.returnVal funcName, val
	return true

# ---------------------------------------------------------------------------

export dbgYield = (funcName, val) ->

	assert isFunctionName(funcName), "not a function name"
	doLog = logAll || callStack.isLogging()
	if internalDebugging
		console.log "dbgYield #{OL(val)}"
		console.log "   - doLog = #{OL(doLog)}"
	if doLog
		if defined(lDebugLog)
			orgLogger = setLogger (str) => lDebugLog.push(str)

		level = callStack.logLevel
		if ! logYield funcName, val, level
			stdLogYield funcName, val, level

		if defined(lDebugLog)
			setLogger orgLogger

	callStack.yield funcName, val
	return true

# ---------------------------------------------------------------------------

export dbgYieldFrom = (funcName) ->

	assert isFunctionName(funcName), "not a function name"
	doLog = logAll || callStack.isLogging()
	if internalDebugging
		console.log "dbgYieldFrom"
		console.log "   - doLog = #{OL(doLog)}"
	if doLog
		if defined(lDebugLog)
			orgLogger = setLogger (str) => lDebugLog.push(str)

		level = callStack.logLevel
		if ! logYieldFrom funcName, level
			stdLogYieldFrom funcName, level

		if defined(lDebugLog)
			setLogger orgLogger

	callStack.yieldFrom funcName
	return true

# ---------------------------------------------------------------------------

export dbgResume = (funcName) ->

	assert isFunctionName(funcName), "not a valid function name"
	doLog = logAll || callStack.isLogging()
	if internalDebugging
		console.log "dbgResume(#{OL(funcName)})"
		console.log "   - doLog = #{OL(doLog)}"
	if doLog
		if defined(lDebugLog)
			orgLogger = setLogger (str) => lDebugLog.push(str)

		level = callStack.logLevel
		if ! logResume funcName, level
			stdLogResume funcName, level

		if defined(lDebugLog)
			setLogger orgLogger

	callStack.resume funcName
	return true

# ---------------------------------------------------------------------------

export dbgValue = (label, val) ->

	assert isString(label), "not a string"

	doLog = logAll || callStack.isLogging()
	if internalDebugging
		console.log "dbgValue #{OL(label)}, #{OL(val)}"
		console.log "   - doLog = #{OL(doLog)}"
	if doLog
		if defined(lDebugLog)
			orgLogger = setLogger (str) => lDebugLog.push(str)

		level = callStack.logLevel
		if ! logValue label, val, level
			stdLogValue label, val, level

		if defined(lDebugLog)
			setLogger orgLogger

	return true

# ---------------------------------------------------------------------------

export dbgString = (str) ->

	assert isString(str), "not a string"
	doLog = logAll || callStack.isLogging()
	if internalDebugging
		console.log "dbgString(#{OL(str)})"
		console.log "   - doLog = #{OL(doLog)}"
	if doLog
		if defined(lDebugLog)
			orgLogger = setLogger (str) => lDebugLog.push(str)

		level = callStack.logLevel
		if ! logString str, level
			stdLogString str, level

		if defined(lDebugLog)
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
#    Only these 8 functions ever call LOG or LOGVALUE

export stdLogEnter = (funcName, lArgs, level) ->

	assert isFunctionName(funcName), "bad function name"
	assert isArray(lArgs), "not an array"
	assert isInteger(level), "level not an integer"

	labelPre = getPrefix(level, 'plain')
	if (lArgs.length == 0)
		LOG "enter #{funcName}", labelPre
	else
		str = "enter #{funcName} #{OLS(lArgs)}"
		if stringFits("#{labelPre}#{str}")
			LOG str, labelPre
		else
			idPre = getPrefix(level+1, 'plain')
			itemPre = getPrefix(level+2, 'dotLast2Vbars')
			LOG "enter #{funcName}", labelPre
			for arg,i in lArgs
				LOGVALUE "arg[#{i}]", arg, idPre, itemPre
	return true

# ---------------------------------------------------------------------------

export stdLogReturn = (funcName, level) ->

	assert isFunctionName(funcName), "bad function name"
	assert isInteger(level), "level not an integer"

	labelPre = getPrefix(level, 'withArrow')
	LOG "return from #{funcName}", labelPre
	return true

# ---------------------------------------------------------------------------

export stdLogReturnVal = (funcName, val, level) ->

	assert isFunctionName(funcName), "bad function name"
	assert isInteger(level), "level not an integer"

	labelPre = getPrefix(level, 'withArrow')
	str = "return #{OL(val)} from #{funcName}"
	if stringFits(str)
		LOG str, labelPre
	else
		idPre = getPrefix(level, 'noLastVbar')
		itemPre = getPrefix(level, 'noLast2Vbars')
		LOG "return from #{funcName}", labelPre
		LOGVALUE "val", val, idPre, itemPre
	return true

# ---------------------------------------------------------------------------

export stdLogYield = (funcName, val, level) ->

	labelPre = getPrefix(level, 'withFlat')
	valStr = OL(val)
	str = "yield #{valStr}"
	if stringFits(str)
		LOG str, labelPre
	else
		idPre = getPrefix(level+1, 'plain')
		itemPre = getPrefix(level+2, 'dotLast2Vbars')
		LOG "yield", labelPre
		LOGVALUE "val", val, idPre, itemPre
	return true

# ---------------------------------------------------------------------------

export stdLogYieldFrom = (funcName, level) ->

	labelPre = getPrefix(level, 'withFlat')
	LOG "yieldFrom", labelPre
	return true

# ---------------------------------------------------------------------------

export stdLogResume = (funcName, level) ->

	assert isInteger(level), "level not an integer"
	labelPre = getPrefix(level, 'plain')
	# LOG "resume", labelPre  # no need to log it
	return true

# ---------------------------------------------------------------------------

export stdLogString = (str, level) ->

	assert isString(str), "not a string"
	assert isInteger(level), "level not an integer"

	labelPre = getPrefix(level, 'plain')
	LOG str, labelPre
	return true

# ---------------------------------------------------------------------------

export stdLogValue = (label, val, level) ->

	assert isInteger(level), "level not an integer"

	labelPre = getPrefix(level, 'plain')
	LOGVALUE label, val, labelPre
	return true

# ---------------------------------------------------------------------------
# ---------------------------------------------------------------------------

export getType = (label, lValues=[]) ->
	# --- returns [type, funcName]
	#     <type> is one of:
	#        'enter'      - funcName is set
	#        'returnFrom' - funcName is set
	#        'yield'      - funcName is set
	#        'resume'     - funcName is set
	#        'string'     - funcName is undef
	#        'value'      - funcName is undef

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
	# --- fullName came from a call to dbgEnter()

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

setDebugging()
