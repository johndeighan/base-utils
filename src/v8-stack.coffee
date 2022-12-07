# v8-stack.coffee

import pathLib from 'node:path'
import assert from 'node:assert/strict'
import {
	undef, defined, notdefined, pass, OL,
	isIdentifier, isFunctionName, getOptions, isEmpty, nonEmpty,
	} from '@jdeighan/base-utils/utils'

export internalDebugging = false
sep_eq = '============================================================'
sep_dash = '------------------------------------------------------------'

# ---------------------------------------------------------------------------

export debugV8Stack = (flag=true) ->

	internalDebugging = flag
	return

# ---------------------------------------------------------------------------

export getV8StackStr = (maxDepth=Infinity) ->

	oldLimit = Error.stackTraceLimit
	Error.stackTraceLimit = maxDepth + 1

	stackStr = new Error().stack

	# --- reset to previous value
	Error.stackTraceLimit = oldLimit

	return stackStr

# ---------------------------------------------------------------------------

export getV8Stack = (maxDepth=Infinity) ->

	stackStr = getV8StackStr(maxDepth)
	return Array.from(stackFrames(stackStr))

# ---------------------------------------------------------------------------

export getMyself = (depth=3) ->

	stackStr = getV8StackStr(2)
	for hNode from stackFrames(stackStr)
		return hNode
	croak "empty stack"

# ---------------------------------------------------------------------------

export getMyDirectCaller = (depth=3) ->

	stackStr = getV8StackStr(depth)
	for hNode from stackFrames(stackStr)
		if (hNode.depth == depth)
			return hNode
	return

# ---------------------------------------------------------------------------

export getMyOutsideCaller = () ->

	if internalDebugging
		console.log "in getMyOutsideCaller()"
	try
		stackStr = getV8StackStr(10)
	catch err
		console.log sep_eq
		console.log "ERROR in getV8Stack(): #{err.message}"
		console.log sep_eq
		process.exit()

	try
		# --- list of distinct sources
		#     when we find the 3rd, we return it
		lSources = []
		for hNode from stackFrames(stackStr)
			source = hNode.source
			if (lSources.indexOf(source) == -1)
				lSources.push source
			if (lSources.length == 3)
				result = hNode
				break
	catch err
		console.log sep_eq
		console.log "ERROR in stackFrames(): #{err.message}"
		console.log sep_eq
		process.exit()

	return result

# ---------------------------------------------------------------------------

export nodeStr = (node) =>

	switch node.type

		when 'function', 'method'
			return "#{node.funcName}() #{getFilePos(node)}"

		when 'script'
			return "script #{node.hFile.base} #{getFilePos(node)}"

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
	#        type = function | method | script
	#        depth (starting at 0)
	#        source - full path name to source file
	#        isAsync
	#        funcName
	#        objName   - if a method call
	#        hFile
	#           root
	#           dir
	#           base
	#           ext
	#           name
	#           lineNum
	#           colNum

	curDepth = 0
	if internalDebugging && (root = getRoot())
		console.log "ROOT = #{OL(root)}"
	try
		for line in stackStr.split("\n")
			hNode = parseLine(line, curDepth)
			if defined(hNode)
				hNode.depth = curDepth
				curDepth += 1
				yield hNode
	catch err
		console.log "ERROR IN stackFrames(): #{err.message}"
		throw err
	return

# ---------------------------------------------------------------------------

mksource = (dir, base) ->

	return "#{dir}/#{base}"

# ---------------------------------------------------------------------------

export parseLine = (line, depth) ->

	line = line.trim()
	if internalDebugging
		console.log "LINE: '#{shorten(line)}'"
	lMatches = line.match(///^
			at
			\s+
			(async \s+) ?
			(\S+)      # func | object.method | file URL
			(?:
				\s*
				\(
				([^)]+)   # containing file
				\)
				)?
			$///)
	if ! lMatches
		if internalDebugging
			console.log "   - no match"
		return undef

	[_, async, funcName, inFile] = lMatches
	hNode = {
		isAsync: !!async
		}
	if defined(funcName) && (funcName.indexOf('file://') == 0)
		if internalDebugging
			console.log "   - [#{depth}] file URL"
		hNode.type = 'script'
		h = parseFileURL(funcName)
		hNode.hFile = h
		hNode.source = mksource(h.dir, h.base)

	else if lParts = isFunctionName(funcName)
		if (lParts.length == 1)
			hNode.type = 'function'
			hNode.funcName = funcName
			if internalDebugging
				console.log "   - [#{depth}] function #{funcName}"
		else   # must be 2
			hNode.type = 'method'
			[objName, funcName] = lParts
			Object.assign(hNode, {objName, funcName})
			if internalDebugging
				console.log "   - [#{depth}] method #{objName}.#{funcName}"
		if defined(inFile)
			if (inFile.indexOf('file://') == 0)
				h = parseFileURL(inFile)
				hNode.hFile = h
				hNode.source = mksource(h.dir, h.base)
			else if lMatches = inFile.match(///^
					node : internal /
					(.*)
					: (\d+)
					: (\d+)
					$///)
				[_, module, lineNum, colNum] = lMatches
				hNode.hFile = {
					root: 'node'
					base: module
					lineNum
					colNum
					}

	if internalDebugging
		console.log "   - from #{shorten(hNode.source)} - #{hNode.type}"
	return hNode

# ---------------------------------------------------------------------------

export parseFileURL = (url) ->
	# --- Return value will have these keys:
	#        root
	#        dir
	#        base
	#        ext
	#        name
	#        lineNum
	#        colNum

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
	return hParsed

# ---------------------------------------------------------------------------

export shorten = (line) ->

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

export getRoot = () ->

	result = process.env.ProjectRoot
	if isEmpty(result)
		return undef
	else
		return result

# ---------------------------------------------------------------------------

