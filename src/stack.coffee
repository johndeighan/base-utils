# stack.coffee

import {assert, croak} from '@jdeighan/base-utils/exceptions'
import {
	undef, defined, notdefined, OL, OLS, deepCopy, warn, oneof,
	isString, isArray, isBoolean, isInteger, isFunctionName,
	isEmpty, nonEmpty, isNonEmptyString,
	spaces, tabs, getOptions,
	} from '@jdeighan/base-utils/utils'
import {LOG, LOGVALUE, getMyLog} from '@jdeighan/base-utils/log'

mainName = '_MAIN_'

# ---------------------------------------------------------------------------
# --- export only to allow unit tests

export class Node

	constructor: (@id, @funcName, @lArgs, @caller, @doLog=false) ->

		assert isInteger(@id), "id not an integer"
		assert isFunctionName(@funcName), "not a function name"
		assert isArray(@lArgs), "not an array"
		assert notdefined(@caller) || (@caller instanceof Node),
			"Bad caller"

		@lCalling = []
		@isYielded = false

# ---------------------------------------------------------------------------

export getStackLog = () =>

	return getMyLog() || ''

# ---------------------------------------------------------------------------

export class CallStack

	@nextID: 1

	constructor: (hOptions={}) ->
		# --- Valid options: (all default to false)
		#        logCalls
		#        debugStack
		#        throwErrors
		hOptions = getOptions(hOptions)
		@logCalls = hOptions.logCalls
		@debugStack = hOptions.debugStack
		@throwErrors = hOptions.throwErrors
		@reset()

	# ........................................................................

	logCalls: (flag=true) ->

		@logCalls = flag
		return

	# ........................................................................

	log: (str) ->

		LOG "#{tabs(@level)}#{str}"
		return

	# ........................................................................

	reset: () ->

		if @logCalls
			@log "RESET STACK"
		@level = 0
		@logLevel = 0
		@root = @getNewNode(mainName, [], undef)
		@setCurFunc(@root)
		return

	# ........................................................................

	getNewNode: (funcName, lArgs, caller, doLog=false) ->

		assert isNonEmptyString(funcName), "funcName not a non-empty string"
		id = CallStack.nextID
		CallStack.nextID += 1
		return new Node(id, funcName, deepCopy(lArgs), caller, doLog)

	# ........................................................................

	setCurFunc: (node) ->

		assert defined(node), "node is undef"
		@curFunc = node
		@curFuncName = node.funcName
		return

	# ........................................................................

	isEmpty: () ->

		return (@curFunc == @root)

	# ........................................................................

	nonEmpty: () ->

		return ! @isEmpty()

	# ........................................................................

	isActive: (funcName, node=@root) ->

		if (node.funcName == funcName)
			return true
		for node in node.lCalling
			if @isActive(funcName, node) && ! node.isYielded
				return true
		return false

	# ........................................................................

	isLogging: () ->

		return @curFunc.doLog

	# ........................................................................
	# ........................................................................

	enter: (funcName, lArgs=[], doLog=false) ->

		assert isNonEmptyString(funcName), "funcName not a non-empty string"
		if @logCalls
			if (lArgs.length == 0)
				@log "ENTER #{OL(funcName)}"
			else
				@log "ENTER #{OL(funcName)} #{OLS(lArgs)}"

		node = @getNewNode(funcName, lArgs, @curFunc, doLog)
		@curFunc.lCalling.push node
		@setCurFunc node

		@level += 1
		if doLog
			@logLevel += 1

		if @debugStack
			@dump(@level)
		return

	# ........................................................................

	returnFrom: (lParms...) ->
		# --- Always returns from the current function
		#     parameter is just a check for correct function name
		# --- We must use spread operator to distinguish between
		#        returnFrom('func', undef)
		#        returnFrom('func')

		nArgs = lParms.length
		[funcName, val] = lParms

		# --- Adjust levels before logging
		assert (@level > 0), "dec level when level is 0"
		@level -= 1
		if @isLogging()
			assert (@logLevel > 0), "dec logLevel when logLevel is 0"
			@logLevel -= 1

		if @logCalls
			if (nArgs == 1)
				@log "RETURN FROM #{OL(funcName)}"
			else
				@log "RETURN FROM #{OL(funcName)} #{OL(val)}"

		assert (nArgs==1) || (nArgs==2), "Bad num args: #{nArgs}"
		assert isFunctionName(funcName), "Not a function name: #{funcName}"
		assert (@curFuncName != mainName), "Return from #{mainName}"
		assert (funcName == @curFuncName),
			"return from #{funcName}, but cur func is #{@curFuncName}"

		@setCurFunc @curFunc.caller
		assert (@curFunc.lCalling.length > 0), "calling stack empty"
		@curFunc.lCalling.pop()

		if @debugStack
			@dump(@level)
		return

	# ........................................................................

	yield: (lArgs...) ->
		# --- We must use spread operator to distinguish between
		#        yield('func', undef)
		#        yield('func')

		nArgs = lArgs.length
		assert (nArgs==1) || (nArgs==2), "Bad num args: #{nArgs}"
		[funcName, val] = lArgs

		# --- Adjust levels before logging
		@level -= 1
		if @isLogging()
			@logLevel -= 1

		if @logCalls
			if (nArgs == 1)
				@log "YIELD FROM #{OL(funcName)}"
			else
				@log "YIELD FROM #{OL(funcName)} #{OL(val)}"

		assert isFunctionName(funcName), "Not a function name: #{funcName}"
		assert (@curFuncName != mainName), "yield from #{mainName}"
		assert (funcName == @curFuncName),
			"yield #{funcName}, but cur func is #{@curFuncName}"

		@curFunc.isYielded = true
		newCurFunc = @curFunc.caller
		while (newCurFunc.isYielded)
			newCurFunc = newCurFunc.caller
		@setCurFunc newCurFunc

		if @debugStack
			@dump(@level)
		return

	# ........................................................................

	resume: (funcName) ->

		if @logCalls
			@log "RESUME #{OL(funcName)}"
		assert isFunctionName(funcName), "Not a function name"

		@setCurFunc @curFunc.lCalling[@curFunc.lCalling.length - 1]
		assert (@curFunc.funcName == funcName),
			"resume #{funcName} but resumed @curFunc.funcName"
		assert @curFunc.isYielded, "resume #{funcName} but it's not yielded"
		@curFunc.isYielded = false

		@level += 1
		if @curFunc.doLog
			@logLevel += 1

		if @debugStack
			@dump(@level)
		return

	# ........................................................................
	# ........................................................................

	decLevel: (doLog) ->

		@level -= 1
		if doLog
			@logLevel -= 1
		return

	# ........................................................................

	stackAssert: (cond, msg) ->
		# --- We don't really want to throw exceptions here

		if !cond
			if @throwErrors
				croak "#{msg}\n#{@dumpStr(@root)}"
			else
				warn "#{msg}\n#{@dumpStr(@root)}"
		return

	# ........................................................................

	dump: (level=0, oneIndent=spaces(5)) ->

		prefix = oneIndent.repeat(level)
		console.log prefix + '-------- CALL STACK --------'
		console.log prefix + "curFunc = #{@curFuncName}"
		console.log @dumpStr @root, level, oneIndent
		console.log prefix + '----------------------------'
		return

	# ........................................................................

	dumpStr: (node, level, oneIndent) ->

		assert (node instanceof Node), "not a Node obj in dump()"
		lLines = []
		lLines.push oneIndent.repeat(level) + @callStr(node)
		assert isArray(node.lCalling), "not an array"
		for node in node.lCalling
			lLines.push @dumpStr(node, level+1, oneIndent)
		str = lLines.join("\n")
		return str

	# ........................................................................

	callStr: (hNode) ->

		if (hNode == @curFunc)
			curSym = '> '
		else
			curSym = '. '

		{caller, lCalling} = hNode
		assert isArray(lCalling), "lCalling not an array"

		if defined(caller)
			callerStr = caller.id.toString(10)
		else
			callerStr = '-'

		callingStr = @idStr(lCalling)

		if hNode.doLog
			if hNode.isYielded
				sym = ' LY'
			else
				sym = ' L'
		else
			if hNode.isYielded
				sym = ' Y'
			else
				sym = ''

		str = "#{curSym}[#{hNode.id}] #{hNode.funcName} #{callerStr} #{callingStr} #{sym}"
		return str

	# ........................................................................

	idStr: (lNodes) ->

		assert isArray(lNodes), "not an array in idStr()"
		if (lNodes.length == 0)
			return '-'
		lIDs = []
		for node in lNodes
			lIDs.push node.id.toString(10)
		str = lIDs.join(',')
		assert defined(str), "str not defined"
		assert (str != 'undefined'), "str is 'undefined'"
		return str
