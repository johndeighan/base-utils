# debug.coffee

import {strict as assert} from 'node:assert'

import {
	undef, pass, defined, notdefined, untabify,
	escapeStr, OL,
	jsType, isString, isNumber, isInteger, isHash, isArray, isBoolean,
	isConstructor, isFunction, isRegExp, isObject,
	isEmpty, nonEmpty, blockToArray, arrayToBlock, chomp, words,
	} from '@jdeighan/exceptions/utils'
import {toTAML} from '@jdeighan/exceptions/taml'
import {getPrefix} from '@jdeighan/exceptions/prefix'
import {
	LOG, LOGVALUE, sep_dash, sep_eq,
	} from '@jdeighan/exceptions/log'
import {CallStack} from '@jdeighan/exceptions/stack'

callStack = new CallStack()

# --- set in resetDebugging() and setDebugging()
#     returns undef for no logging, or a label to log
export shouldLog = () -> undef

lFuncList = []          # names of functions being debugged
strFuncList = undef     # original string

# ---------------------------------------------------------------------------

export interp = (label) ->

	return label.replace(/// \$ (\@)? ([A-Za-z_][A-Za-z0-9_]*) ///g,
			(_, atSign, varName) ->
				if atSign
					return "\#{OL(@#{varName})\}"
				else
					return "\#{OL(#{varName})\}"
			)

# ---------------------------------------------------------------------------

export debug = (orgLabel, lObjects...) ->

	assert isString(orgLabel), "1st arg #{OL(orgLabel)} should be a string"

	[type, funcName] = getType(orgLabel, lObjects)
	label = shouldLog(orgLabel, type, funcName, callStack)
	if defined(label)
		label = interp(label)

	switch type

		when 'enter'
			if defined(label)
				doTheLogging type, label, lObjects
			callStack.enter funcName, lObjects, defined(label)

			debug2 "enter debug()", orgLabel, lObjects
			debug2 "type = #{OL(type)}, funcName = #{OL(funcName)}"
			debug2 "return from debug()"

		when 'return'
			debug2 "enter debug()", orgLabel, lObjects
			debug2 "type = #{OL(type)}, funcName = #{OL(funcName)}"
			debug2 "return from debug()"

			if defined(label)
				doTheLogging type, label, lObjects
			callStack.returnFrom funcName

		when 'string'
			debug2 "enter debug()", orgLabel, lObjects
			debug2 "type = #{OL(type)}, funcName = #{OL(funcName)}"

			if defined(label)
				doTheLogging type, label, lObjects
			debug2 "return from debug()"

	return true   # allow use in boolean expressions

# ---------------------------------------------------------------------------

debug2 = (orgLabel, lObjects...) ->

	[type, funcName] = getType(orgLabel, lObjects)
	label = shouldLog(orgLabel, type, funcName, callStack)

	switch type
		when 'enter'
			if defined(label)
				doTheLogging 'enter', label, lObjects
			callStack.enter funcName, lObjects, defined(label)

		when 'return'
			if defined(label)
				doTheLogging 'return', label, lObjects
			callStack.returnFrom funcName

		when 'string'
			if defined(label)
				doTheLogging 'string', label, lObjects

	return true   # allow use in boolean expressions

# ---------------------------------------------------------------------------

export doTheLogging = (type, label, lObjects) ->

	assert isString(label), "non-string label #{OL(label)}"
	level = callStack.getLevel()

	switch type

		when 'enter'
			LOG label, getPrefix(level)
			pre = getPrefix(level+1, 'dotLastVbar')
			itemPre = getPrefix(level+2, 'dotLast2Vbars')
			for obj,i in lObjects
				LOGVALUE "arg[#{i}]", obj, pre, itemPre

		when 'return'
			LOG label, getPrefix(level, 'withArrow')
			pre = getPrefix(level, 'noLastVbar')
			itemPre = getPrefix(level, 'noLast2Vbars')
			for obj,i in lObjects
				LOGVALUE "ret[#{i}]", obj, pre, itemPre

		when 'string'
			pre = getPrefix(level, 'plain')
			itemPre = getPrefix(level+1, 'noLastVbar')
			nVals = lObjects.length
			if (nVals == 0)
				LOG label, pre
			else
				assert (nVals == 1), "Only 1 value allowed, #{nVals} found"
				LOGVALUE label, lObjects[0], pre
	return

# ---------------------------------------------------------------------------

export stdShouldLog = (label, type, funcName, stack) ->
	# --- if type is 'enter', then funcName won't be on the stack yet
	#     returns the (possibly modified) label to log

	assert isString(label), "label #{OL(label)} not a string"
	assert isString(type),  "type #{OL(type)} not a string"
	assert stack instanceof CallStack, "not a call stack object"
	if (type == 'enter') || (type == 'return')
		assert isString(funcName), "func name #{OL(funcName)} not a string"
	else
		assert funcName == undef, "func name #{OL(funcName)} not undef"

	if funcMatch(funcName || stack.curFunc())
		return label

	if (type == 'enter') && ! isMyFunc(funcName)
		# --- As a special case, if we enter a function where we will not
		#     be logging, but we were logging in the calling function,
		#     we'll log out the call itself

		if funcMatch(stack.curFunc())
			result = label.replace('enter', 'call')
			return result
	return undef

# ---------------------------------------------------------------------------

export isMyFunc = (funcName) ->

	return funcName in words('debug debug2 doTheLogging
			stdShouldLog setDebugging resetDebugging getFuncList
			funcMatch getType dumpCallStack')

# ---------------------------------------------------------------------------

export trueShouldLog = (label, type, funcName, stack) ->

	if isMyFunc(funcName || stack.curFunc())
		return undef
	else
		return label

# ---------------------------------------------------------------------------

export setDebugging = (option) ->

	callStack.reset()
	if isBoolean(option)
		if option
			shouldLog = trueShouldLog
		else
			shouldLog = () -> return undef
	else if isString(option)
		lFuncList = getFuncList(option)
		shouldLog = stdShouldLog
	else if isFunction(option)
		shouldLog = option
	else
		throw new Error("setDebugging(): bad parameter #{OL(option)}")
	return

# ---------------------------------------------------------------------------

export resetDebugging = () ->

	callStack.reset()
	shouldLog = () -> return undef
	return

# ---------------------------------------------------------------------------
# --- export only to allow unit tests

export getFuncList = (str) ->

	strFuncList = str     # store original string for debugging
	lFuncList = []
	for word in words(str)
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
					name: ident2
					object: ident1
					plus: (plus == '+')
					}
			else
				lFuncList.push {
					name: ident1
					plus: (plus == '+')
					}
		else
			throw new Error("getFuncList: bad word : #{OL(word)}")
	return lFuncList

# ---------------------------------------------------------------------------
# --- export only to allow unit tests

export funcMatch = (funcName) ->

	assert isArray(lFuncList), "not an array #{OL(lFuncList)}"
	for h in lFuncList
		{name, object, plus} = h
		if (name == funcName)
			return true
		if plus && callStack.isActive(name)
			return true
	return false

# ---------------------------------------------------------------------------
# --- type is one of: 'enter', 'return', 'string'

export getType = (str, lObjects) ->

	if lMatches = str.match(///^
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
			funcName = ident2
		else
			funcName = ident1

		if (type == 'enter')
			return ['enter', funcName]
		else
			return ['return', funcName]
	else
		return ['string', undef]

# ---------------------------------------------------------------------------

reMethod = ///^
	([A-Za-z_][A-Za-z0-9_]*)
	\.
	([A-Za-z_][A-Za-z0-9_]*)
	$///

# ---------------------------------------------------------------------------

export dumpDebugGlobals = () ->

	LOG '='.repeat(40)
	LOG callStack.dump()
	if shouldLog == stdShouldLog
		LOG "using stdShouldLog"
	else if shouldLog == trueShouldLog
		LOG "using trueShouldLog"
	else
		LOG "using custom shouldLog"
	LOG "lFuncList:"
	for funcName in lFuncList
		LOG "   #{OL(funcName)}"
	LOG '='.repeat(40)
	return

# ---------------------------------------------------------------------------
