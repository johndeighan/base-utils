# v8-stack.coffee

import pathLib from 'node:path'

import {
	undef, defined, notdefined, pass, OL,
	isIdentifier, isFunctionName, getOptions, isEmpty, nonEmpty,
	} from '@jdeighan/base-utils'

export internalDebugging = false
sep_eq = '============================================================'
sep_dash = '------------------------------------------------------------'

# ---------------------------------------------------------------------------
# assert() for use in this file only

assert = (cond, msg) =>

	if !cond
		throw new Error(msg)
	return true

# ---------------------------------------------------------------------------

export debugV8Stack = (flag=true) =>

	internalDebugging = flag
	return

# ---------------------------------------------------------------------------

export getV8StackStr = (maxDepth=Infinity) =>

	oldLimit = Error.stackTraceLimit
	Error.stackTraceLimit = maxDepth + 1

	stackStr = new Error().stack
	assert nonEmpty(stackStr), "stackStr is empty!"

	# --- reset to previous value
	Error.stackTraceLimit = oldLimit

	if internalDebugging
		console.log "STACK STRING:"
		console.log stackStr

	return stackStr

# ---------------------------------------------------------------------------

export getV8Stack = (maxDepth=Infinity) =>

	stackStr = getV8StackStr(maxDepth)
	return Array.from(stackFrames(stackStr))

# ---------------------------------------------------------------------------

export getMyself = (depth=3) =>

	stackStr = getV8StackStr(2)
	for hNode from stackFrames(stackStr)
		return hNode
	croak "empty stack"

# ---------------------------------------------------------------------------

export getMyDirectCaller = (depth=3) =>

	if internalDebugging
		console.log "in getMyDirectCaller()"

	try
		stackStr = getV8StackStr(depth)
	catch err
		console.log sep_eq
		console.log "ERROR in getV8Stack(): #{err.message}"
		console.log sep_eq
# --- unfortunately, process.exit() prevents the above console logs
#		process.exit()
		return undef

	for hNode from stackFrames(stackStr)
		if (hNode.depth == depth)
			return hNode

	return undef

# ---------------------------------------------------------------------------

export getMyOutsideCaller = () =>

	if internalDebugging
		console.log "in getMyOutsideCaller()"

	try
		stackStr = getV8StackStr(10)
	catch err
		console.log sep_eq
		console.log "ERROR in getV8Stack(): #{err.message}"
		console.log sep_eq
# --- unfortunately, process.exit() prevents the above console logs
#		process.exit()
		return undef

	try
		# --- states:
		#        1 - no source yet
		#        2 - source is this module
		#        3 - source is calling module
		#        4 - source is caller outside calling module
		state = 1
		source = undef
		for hNode from stackFrames(stackStr)
			orgstate = state
			switch state
				when 1
					source = hNode.source
					state = 2
				when 2
					if (hNode.source != source)
						source = hNode.source
						state = 3
				when 3
					if (hNode.source != source)
						if internalDebugging
							console.log "   RETURN:"
							console.log hNode
						return hNode
			if internalDebugging
				console.log "   #{orgstate} => #{state}"

	catch err
		console.log sep_eq
		console.log "ERROR in stackFrames(): #{err.message}"
		console.log sep_eq
# --- unfortunately, process.exit() prevents the above console logs
#		process.exit()
		return undef

	return result

# ---------------------------------------------------------------------------

export getMyOutsideSource = () ->

	caller = getMyOutsideCaller()
	if caller
		return caller.source
	else
		return undef

# ---------------------------------------------------------------------------

export nodeStr = (node) =>

	try
		switch node.type
			when 'function', 'method'
				return "#{node.funcName}() #{getFilePos(node)}"
			when 'script'
				return "script #{node.hFile.base} #{getFilePos(node)}"
			else
				return "Unknown node type: '#{node.type}'"
	catch err
		return "ERROR: #{err.message} in: '#{JSON.stringify(node)}'"

# ---------------------------------------------------------------------------

export getFilePos = (node) =>

	if notdefined(node) || notdefined(node.hFile)
		return ''
	result = node.hFile.base
	if defined(node.hFile.lineNum)
		result += ":#{node.hFile.lineNum}"
		if defined(node.hFile.colNum)
			result += ":#{node.hFile.colNum}"
	return result

# ---------------------------------------------------------------------------
# This is a generator

export stackFrames = (stackStr) ->
	#     generator of nodes
	#
	#     Each node has keys:
	#        isAsync
	#        depth (starting at 0)
	#
	#        source - full path name to source file
	#        dir - directory part of source
	#        filename - filename part of source
	#        lineNum
	#        colNum
	#
	#        type = 'function | method | script
	#           script
	#              scriptName
	#           function
	#              funcName
	#           method
	#              objName
	#              funcName
	#        desc - type plus script/function/method name

	assert nonEmpty(stackStr), "stackStr is empty in stackFrames()"
	curDepth = 0
	for line in stackStr.split("\n")
		hNode = parseLine(line, curDepth)
		if defined(hNode)
			hNode.depth = curDepth
			curDepth += 1
			yield hNode
	return

# ---------------------------------------------------------------------------

export dumpNode = (hNode) =>

	console.log "   source = #{hNode.source}"
	console.log "   desc = #{hNode.desc}"
	return

# ---------------------------------------------------------------------------

export parseLine = (line, depth) =>

	assert defined(line), "line is undef in parseLine()"
	line = line.trim()
	if internalDebugging
		console.log "LINE: '#{shorten(line)}'"

	if (line == 'Error')
		if internalDebugging
			console.log "   - no match (was 'Error')"
		return undef

	lMatches = line.match(///^
			at
			\s+
			(async \s+) ?
			(\S+)      # func | object.method | file URL
			(?:
				\s*
				\(
				([^)]+)   # containing file | node:internal
				\)
				)?
			$///)

	assert defined(lMatches), "BAD LINE: '#{line}'"

	[_, async, fromWhere, fileURL] = lMatches

	# --- check for NodeJS internal functions
	if defined(fileURL) && lMatches = fileURL.match(///^
			node : internal /
			(.*)
			: (\d+)
			: (\d+)
			$///)

		[_, module, lineNum, colNum] = lMatches
		hNode = {
			isAsync: !!async
			depth
			source: 'node'
			lineNum
			colNum
			desc: "node #{module}"
			}
		if internalDebugging
			dumpNode hNode
		return hNode

	# --- Parse file URL, set lParts, set type
	if (fromWhere.indexOf('file://') == 0)
		assert isEmpty(fileURL), "two file URLs present"
		type = 'script'
		h = parseFileURL(fromWhere)
	else
		lParts = isFunctionName(fromWhere)
		assert defined(lParts), "Bad line: '#{line}'"
		if (lParts.length == 1)
			type = 'function'
		else
			type = 'method'
		h = parseFileURL(fileURL)

	# --- construct hNode
	hNode = {
		isAsync: !!async
		depth
		source: h.source
		dir: h.dir
		filename: h.base
		lineNum: h.lineNum
		colNum: h.colNum
		type
		}
	switch type
		when 'script'
			hNode.scriptName = hNode.base
			hNode.desc = "script #{h.base}"
		when 'function'
			hNode.funcName = lParts[0]
			hNode.desc = "function #{lParts[0]}"
		when 'method'
			hNode.objName = lParts[0]
			hNode.funcName = lParts[1]
			hNode.desc = "method #{lParts[0]}.#{lParts[1]}"

	if internalDebugging
		dumpNode(hNode)
	return hNode

# ---------------------------------------------------------------------------

export parseFileURL = (url) =>
	# --- Return value will have these keys:
	#        root
	#        dir
	#        base
	#        ext
	#        name
	#        lineNum
	#        colNum

	assert defined(url), "url is undef in parseFileURL()"
	lMatches = url.match(///^
			file : \/\/
			(.*)
			:
			(\d+)
			:
			(\d+)
			$///)
	assert defined(lMatches), "Invalid file URL: #{url}"
	[_, pathStr, lineNum, colNum] = lMatches
	hParsed = pathLib.parse(pathStr)
	hParsed.lineNum = parseInt(lineNum, 10)
	hParsed.colNum = parseInt(colNum, 10)
	{dir, base} = hParsed
	if defined(dir) && (dir.indexOf('/') == 0)
		hParsed.dir = dir.substr(1)
		hParsed.source = "#{hParsed.dir}/#{base}"
	else
		hParsed.source = "./#{base}"
	return hParsed

# ---------------------------------------------------------------------------

export shorten = (line) =>

	if isEmpty(line)
		return ''
	root = getRoot()
	if isEmpty(root)
		return line
	pos = line.indexOf(root)
	if (pos == -1)
		return line
	else
		return line.replace(root, 'ROOT')

# ---------------------------------------------------------------------------

export getRoot = () =>

	result = process.env.ProjectRoot
	if isEmpty(result)
		return undef
	else
		return result

# ---------------------------------------------------------------------------
