# debug.coffee

import {assert, croak} from '@jdeighan/base-utils/exceptions'
import {
	pass, undef, defined, notdefined, OL, OLS,
	isIdentifier, isFunctionName, isArrayOfStrings,
	isString, isFunction, isArray, isHash, isBoolean, isInteger,
	isEmpty, nonEmpty, arrayToBlock, getOptions,
	words, oneof, jsType, blockToArray,
	} from '@jdeighan/base-utils'
import {getPrefix} from '@jdeighan/base-utils/prefix'
import {
	LOG, LOGVALUE, stringFits, debugLogging,
	clearMyLogs, getMyLogs, echoMyLogs,
	} from '@jdeighan/base-utils/log'
import {toTAML} from '@jdeighan/base-utils/ll-taml'
import {CallStack} from '@jdeighan/base-utils/stack'

export {debugLogging}

export callStack = new CallStack()

# --- Comes from call to setDebugging()
lFuncList = []      # array of {funcName, plus}

logAll = false      # if true, always log
internalDebugging = false

# --- Custom loggers, if defined
logEnter     = undef
logReturn    = undef
logYield     = undef
logResume    = undef
logString    = undef
logValue     = undef

# ---------------------------------------------------------------------------

export clearDebugLog = () =>

	return clearMyLogs()

# ---------------------------------------------------------------------------

export getDebugLog = () =>

	return getMyLogs()

# ---------------------------------------------------------------------------

export debugDebug = (debugFlag=true) =>

	internalDebugging = debugFlag
	if debugFlag
		console.log "turn on internal debugging in debug.coffee"
	else
		console.log "turn off internal debugging in debug.coffee"
	return

# ---------------------------------------------------------------------------

export dumpDebugLoggers = (label=undef) =>

	lLines = []
	if nonEmpty(label)
		lLines.push "LOGGERS (#{label})"
	else
		lLines.push "LOGGERS"
	lLines.push "   enter      - #{logType(logEnter, stdLogEnter)}"
	lLines.push "   return     - #{logType(logReturn, stdLogReturn)}"
	lLines.push "   yield      - #{logType(logYield, stdLogYield)}"
	lLines.push "   resume     - #{logType(logResume, stdLogResume)}"
	lLines.push "   string     - #{logType(logString, stdLogString)}"
	lLines.push "   value      - #{logType(logValue, stdLogValue)}"
	console.log arrayToBlock(lLines)

# ---------------------------------------------------------------------------

logType = (cur, std) =>

	if (cur == std)
		return 'std'
	else if defined(cur)
		return 'custom'
	else
		return 'undef'

# ---------------------------------------------------------------------------

export resetDebugging = () =>

	# --- reset everything
	callStack.reset()
	lFuncList = []
	logAll = false
	logEnter  = stdLogEnter
	logReturn = stdLogReturn
	logYield  = stdLogYield
	logResume = stdLogResume
	logString = stdLogString
	logValue  = stdLogValue
	clearMyLogs()
	echoMyLogs false
	return

# ---------------------------------------------------------------------------

export setDebugging = (debugWhat=undef, hOptions={}) =>
	# --- debugWhat can be:
	#        1. a boolean
	#        2. a string
	#        3. an array of strings
	# --- Valid options:
	#        'noecho' - don't echo logs to console
	#        'enter', 'returnFrom',
	#           'yield', 'resume',
	#           'string', 'value'
	#         - to set custom loggers

	if internalDebugging
		console.log "setDebugging #{OL(debugWhat)}, #{OL(hOptions)}"

	resetDebugging()

	customSet = false     # were any custom loggers set?

	# --- First, process any options
	hOptions = getOptions(hOptions)
	if hOptions.noecho
		echoMyLogs false
		if internalDebugging
			console.log "TURN OFF ECHO"
	else
		echoMyLogs true
		if internalDebugging
			console.log "TURN ON ECHO"
	for key in words('enter returnFrom yield resume string value')
		if defined(hOptions[key])
			setCustomDebugLogger key, hOptions[key]
			customSet = true

	# --- process debugWhat if defined
	[type, subtype] = jsType(debugWhat)
	switch type
		when undef
			pass()
		when 'boolean'
			if internalDebugging
				console.log "set logAll to #{OL(debugWhat)}"
			logAll = debugWhat
		when 'string', 'array'
			if internalDebugging
				console.log "debugWhat is #{OL(debugWhat)}"
			lFuncList = getFuncList(debugWhat)
		else
			croak "Bad arg 1: #{OL(debugWhat)}"

	if internalDebugging
		dumpFuncList()
		if customSet
			dumpDebugLoggers()
	return

# ---------------------------------------------------------------------------

export dumpFuncList = () =>

	console.log 'lFuncList: --------------------------------'
	console.log toTAML(lFuncList)
	console.log '-------------------------------------------'
	return

# ---------------------------------------------------------------------------

export setCustomDebugLogger = (type, func) =>

	assert isFunction(func), "Not a function"
	if internalDebugging
		console.log "set custom logger #{OL(type)}"
	switch type
		when 'enter'
			logEnter = func
		when 'returnFrom'
			logReturn = func
		when 'yield'
			logYield = func
		when 'resume'
			logResume = func
		when 'string'
			logString = func
		when 'value'
			logValue = func
		else
			throw new Error("Unknown type: #{OL(type)}")
	return

# ---------------------------------------------------------------------------

export getFuncList = (funcs) =>
	# --- funcs can be a string or an array of strings

	lFuncs = []    # return value

	# --- Allow passing in an array of strings
	if isArray(funcs)
		assert isArrayOfStrings(funcs), "not an array of strings"
		for str in funcs
			lItems = getFuncList(str)   # recursive call
			lFuncs.push lItems...
		return lFuncs

	assert isString(funcs), "not a string"
	for word in words(funcs)
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
# Stack is only modified in these 8 functions (it is reset in setDebugging())
# ---------------------------------------------------------------------------

export dbgEnter = (funcName, lValues...) =>

	doLog = doDebugFunc(funcName)
	if internalDebugging
		if (lValues.length == 0)
			console.log "dbgEnter #{OL(funcName)}"
		else
			console.log "dbgEnter #{OL(funcName)}, #{OLS(lValues)}"
		console.log "   - doLog = #{OL(doLog)}"

	if doLog
		level = callStack.logLevel
		if ! logEnter level, funcName, lValues
			stdLogEnter level, funcName, lValues

	callStack.enter funcName, lValues, doLog
	return true

# ---------------------------------------------------------------------------

export doDebugFunc = (funcName) =>

	return logAll || funcMatch(funcName)

# ---------------------------------------------------------------------------

export funcMatch = (funcName) =>
	# --- funcName came from a call to dbgEnter()
	#     it might be of form <object>.<method>
	# --- We KNOW that funcName is active!

	if internalDebugging
		console.log "CHECK funcMatch(#{OL(funcName)})"
		console.log lFuncList
		callStack.dump 1

	lParts = isFunctionName(funcName)
	assert defined(lParts), "not a valid function name: #{OL(funcName)}"

	for h in lFuncList
		if (h.fullName == funcName)
			if internalDebugging
				console.log "   - TRUE - #{OL(funcName)} is in lFuncList"
			return true
		if h.plus && callStack.isActive(h.fullName)
			if internalDebugging
				console.log "   - TRUE - #{OL(h.fullName)} is active"
			return true

	if (lParts.length == 2)   # came from dbgEnter()
		methodName = lParts[1]
		for h in lFuncList
			if (h.fullName == methodName)
				if internalDebugging
					console.log "   - TRUE - #{OL(methodName)} is in lFuncList"
				return true
	if internalDebugging
		console.log "   - FALSE"
	return false

# ---------------------------------------------------------------------------

export dbgReturn = (lArgs...) =>

	if (lArgs.length > 1)
		return dbgReturnVal lArgs...
	funcName = lArgs[0]
	assert isFunctionName(funcName), "not a valid function name"
	doLog = logAll || callStack.isLogging()
	if internalDebugging
		console.log "dbgReturn #{OL(funcName)}"
		console.log "   - doLog = #{OL(doLog)}"
	if doLog
		level = callStack.logLevel
		if ! logReturn level, funcName
			stdLogReturn level, funcName

	callStack.returnFrom funcName
	return true

# ---------------------------------------------------------------------------

dbgReturnVal = (funcName, val) =>

	assert isFunctionName(funcName), "not a valid function name"
	doLog = logAll || callStack.isLogging()
	if internalDebugging
		console.log "dbgReturn #{OL(funcName)}, #{OL(val)}"
		console.log "   - doLog = #{OL(doLog)}"
	if doLog
		level = callStack.logLevel
		if ! logReturn level, funcName, val
			stdLogReturn level, funcName, val

	callStack.returnFrom funcName, val
	return true

# ---------------------------------------------------------------------------

export dbgYield = (lArgs...) =>

	nArgs = lArgs.length
	assert (nArgs==1) || (nArgs==2), "Bad num args: #{nArgs}"
	[funcName, val] = lArgs
	if (nArgs==1)
		return dbgYieldFrom(funcName)

	assert isFunctionName(funcName), "not a function name"
	doLog = logAll || callStack.isLogging()
	if internalDebugging
		console.log "dbgYield #{OL(funcName)} #{OL(val)}"
		console.log "   - doLog = #{OL(doLog)}"
	if doLog
		level = callStack.logLevel
		if ! logYield level, funcName, val
			stdLogYield level, funcName, val

	callStack.yield funcName, val
	return true

# ---------------------------------------------------------------------------

dbgYieldFrom = (funcName) =>

	assert isFunctionName(funcName), "not a function name"
	doLog = logAll || callStack.isLogging()
	if internalDebugging
		console.log "dbgYieldFrom #{OL(funcName)}"
		console.log "   - doLog = #{OL(doLog)}"
	if doLog
		level = callStack.logLevel
		if ! logYieldFrom level, funcName
			stdLogYieldFrom level, funcName

	callStack.yield funcName
	return true

# ---------------------------------------------------------------------------

export dbgResume = (funcName) =>

	assert isFunctionName(funcName), "not a valid function name"
	callStack.resume funcName
	doLog = logAll || callStack.isLogging()
	if internalDebugging
		console.log "dbgResume #{OL(funcName)}"
		console.log "   - doLog = #{OL(doLog)}"
	if doLog
		level = callStack.logLevel
		if ! logResume funcName, level-1
			stdLogResume funcName, level-1

	return true

# ---------------------------------------------------------------------------

export dbg = (lArgs...) =>

	if lArgs.length == 1
		return dbgString lArgs[0]
	else
		return dbgValue lArgs[0], lArgs[1]

# ---------------------------------------------------------------------------

export dbgValue = (label, val) =>

	assert isString(label), "not a string"

	doLog = logAll || callStack.isLogging()
	if internalDebugging
		console.log "dbgValue #{OL(label)}, #{OL(val)}"
		console.log "   - doLog = #{OL(doLog)}"
	if doLog
		level = callStack.logLevel
		if ! logValue level, label, val
			stdLogValue level, label, val

	return true

# ---------------------------------------------------------------------------
# --- str can be a multi-line string

export dbgString = (str) =>

	assert isString(str), "not a string"
	doLog = logAll || callStack.isLogging()
	if internalDebugging
		console.log "dbgString(#{OL(str)})"
		console.log "   - doLog = #{OL(doLog)}"
	if doLog
		level = callStack.logLevel
		if ! logString level, str
			stdLogString level, str

	return true

# ---------------------------------------------------------------------------
# ---------------------------------------------------------------------------
#    Only these 8 functions ever call LOG or LOGVALUE

export stdLogEnter = (level, funcName, lArgs) =>

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
			itemPre = getPrefix(level+2, 'noLastVbar')
			LOG "enter #{funcName}", labelPre
			for arg,i in lArgs
				LOGVALUE "arg[#{i}]", arg, idPre, itemPre
	return true

# ---------------------------------------------------------------------------

export stdLogReturn = (lArgs...) =>

	[level, funcName, val] = lArgs
	if (lArgs.length == 3)
		return stdLogReturnVal level, funcName, val
	assert isFunctionName(funcName), "bad function name"
	assert isInteger(level), "level not an integer"

	labelPre = getPrefix(level, 'withArrow')
	LOG "return from #{funcName}", labelPre
	return true

# ---------------------------------------------------------------------------

stdLogReturnVal = (level, funcName, val) =>

	assert isFunctionName(funcName), "bad function name"
	assert isInteger(level), "level not an integer"

	labelPre = getPrefix(level, 'withArrow')
	str = "return #{OL(val)} from #{funcName}"
	if stringFits(str)
		LOG str, labelPre
	else
		pre = getPrefix(level, 'noLastVbar')
		LOG "return from #{funcName}", labelPre
		LOGVALUE "val", val, pre, pre
	return true

# ---------------------------------------------------------------------------

export stdLogYield = (lArgs...) =>

	[level, funcName, val] = lArgs
	if (lArgs.length == 2)
		return stdLogYieldFrom level, funcName
	labelPre = getPrefix(level, 'withYield')
	valStr = OL(val)
	str = "yield #{valStr}"
	if stringFits(str)
		LOG str, labelPre
	else
		pre = getPrefix(level, 'plain')
		LOG "yield", labelPre
		LOGVALUE undef, val, pre, pre
	return true

# ---------------------------------------------------------------------------

export stdLogYieldFrom = (level, funcName) =>

	labelPre = getPrefix(level, 'withFlat')
	LOG "yieldFrom", labelPre
	return true

# ---------------------------------------------------------------------------

export stdLogResume = (funcName, level) =>

	assert isInteger(level), "level not an integer"
	labelPre = getPrefix(level+1, 'withResume')
	LOG "resume", labelPre
	return true

# ---------------------------------------------------------------------------

export stdLogString = (level, str) =>

	assert isString(str), "not a string"
	assert isInteger(level), "level not an integer"

	labelPre = getPrefix(level, 'plain')
	for part in blockToArray(str)
		LOG part, labelPre
	return true

# ---------------------------------------------------------------------------

export stdLogValue = (level, label, val) =>

	assert isInteger(level), "level not an integer"

	labelPre = getPrefix(level, 'plain')
	LOGVALUE label, val, labelPre
	return true

# ---------------------------------------------------------------------------
# ---------------------------------------------------------------------------

export getType = (label, lValues=[]) =>
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

	# --- if none of the above returned, then...
	if (lValues.length == 1)
		return ['value', undef]
	else if (lValues.length == 0)
		return ['string', undef]
	else
		throw new Error("More than 1 object not allowed here")

# ........................................................................

export parseFunc = (str) =>
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
