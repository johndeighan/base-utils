# debug.coffee

import {strict as assert} from 'node:assert'

import {
	undef, defined, notdefined, OL, isString,
	isEmpty, nonEmpty, words,
	} from '@jdeighan/exceptions/utils'
import {toTAML} from '@jdeighan/exceptions/taml'
import {getPrefix} from '@jdeighan/exceptions/prefix'
import {LOG, LOGVALUE} from '@jdeighan/exceptions/log'
import {CallStack} from '@jdeighan/exceptions/stack'

callStack = new CallStack()
lFuncList = undef           # array of {funcName, objName, plus}
internalDebugging = false   # set true on setDebugging('debug')

# ---------------------------------------------------------------------------

export resetDebugging = () ->

	callStack.reset()
	lFuncList = undef
	internalDebugging = false
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

	[type, funcName, objName] = getType(label)
	if internalDebugging
		console.log "   - type = #{OL(type)}, func = #{OL(funcName)}, obj = #{OL(objName)}"

	switch type
		when 'enter','return'
			assert nonEmpty(funcName), "enter without funcName"
			doLog = funcMatch(funcName, objName)
		when 'string'
			assert isEmpty(funcName), "string with funcName"
			doLog = funcMatch(callStack.curFunc()...)
		else
			doLog = false   # debugging is turned off, i.e. lFuncList == undef

	if internalDebugging
		console.log "   - doLog = #{OL(doLog)}"

	switch type
		when 'enter'
			if doLog
				doTheLogging type, label, lObjects
			callStack.enter funcName, objName, lObjects, doLog

		when 'return'
			if doLog
				doTheLogging type, label, lObjects
			callStack.returnFrom funcName, objName

		when 'string'
			if doLog
				doTheLogging type, label, lObjects

	return true   # allow use in boolean expressions

# ---------------------------------------------------------------------------

export getType = (label) ->

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
	else
		return ['string', undef, undef]

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

export doTheLogging = (type, label, lObjects) ->

	assert isString(label), "non-string label #{OL(label)}"
	level = callStack.getLevel()

	switch type

		when 'enter'
			LOG label, getPrefix(level, 'plain')
			pre = getPrefix(level+1, 'plain')
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
