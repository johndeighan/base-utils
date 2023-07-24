# fs.coffee

import pathLib from 'node:path'
import fs from 'fs'
import NReadLines from 'n-readlines'

import {
	undef, defined, nonEmpty, toBlock, getOptions,
	isString, isHash, isArray, isIterable,
	} from '@jdeighan/base-utils'
import {assert, croak} from '@jdeighan/base-utils/exceptions'
import {LOG, LOGVALUE} from '@jdeighan/base-utils/log'
import {dbgEnter, dbgReturn, dbg} from '@jdeighan/base-utils/debug'
import {toTAML, fromTAML} from '@jdeighan/base-utils/taml'

# ---------------------------------------------------------------------------

export mkpath = (lParts...) =>

	dbgEnter 'mkpath', lParts
	lParts = lParts.filter((x) => nonEmpty(x))
	str = lParts.join('/')
	str = str.replaceAll('\\', '/')
	if lMatches = str.match(/^([A-Z])\:(.*)$/)
		[_, drive, rest] = lMatches
		str = "#{drive.toLowerCase()}:#{rest}"
	dbgReturn 'mkpath', str
	return str

# ---------------------------------------------------------------------------

export getPkgJsonPath = () =>

	filePath = mkpath(process.cwd(), 'package.json')
	assert isFile(filePath), "Missing pacakge.json at cur dir"
	return filePath

# ---------------------------------------------------------------------------

export isFile = (lParts...) =>

	dbgEnter 'isFile', lParts
	filePath = mkpath(lParts...)
	dbg "filePath is '#{filePath}'"
	try
		result = fs.lstatSync(filePath).isFile()
		dbgReturn 'isFile', result
		return result
	catch
		dbgReturn 'isFile', false
		return false

# ---------------------------------------------------------------------------

export isDir = (lParts...) =>

	dbgEnter 'isDir', lParts
	dirPath = mkpath(lParts...)
	dbg "dirPath is '#{dirPath}'"
	try
		result = fs.lstatSync(dirPath).isDirectory()
		dbgReturn 'isDir', result
		return result
	catch
		dbgReturn 'isDir', false
		return false

# ---------------------------------------------------------------------------

export rmFileSync = (filepath) =>

	assert isFile(filepath), "#{filepath} is not a file"
	fs.rmSync filepath
	return

# ---------------------------------------------------------------------------

export mkdirSync = (dirpath) =>

	try
		fs.mkdirSync dirpath
	catch err
		if (err.code == 'EEXIST')
			console.log 'Directory exists. Please choose another name'
		else
			console.log err
		process.exit 1
	return

# ---------------------------------------------------------------------------

export fromJSON = (strJson) =>
	# --- string to data structure

	return JSON.parse(strJson)

# ---------------------------------------------------------------------------

export toJSON = (hJson) =>
	# --- data structure to string

	return JSON.stringify(hJson, null, "\t")

# ---------------------------------------------------------------------------
#   slurp - read a file into a string

export slurp = (lParts...) =>
	# --- last argument can be an options hash
	#     Valid options:
	#        maxLines: <int>

	assert (lParts.length > 0), "No parameters"
	if isHash(lParts[lParts.length - 1])
		hOptions = lParts.pop()
		assert (lParts.length > 0), "Options hash but no parameters"
		{maxLines} = hOptions
	filePath = mkpath(lParts...)
	if defined(maxLines)
		lLines = []

		reader = new NReadLines(filePath)
		nLines = 0

		while (buffer = reader.next()) && (nLines < maxLines)
			nLines += 1
			# --- text is split on \n chars,
			#     we also need to remove \r chars
			lLines.push buffer.toString().replace(/\r/g, '')
		contents = toBlock(lLines)
	else
		contents = fs.readFileSync(filePath, 'utf8').toString()
	return contents

# ---------------------------------------------------------------------------
#   slurpJSON - read a file into a hash

export slurpJSON = (lParts...) =>

	return fromJSON(slurp(lParts...))

# ---------------------------------------------------------------------------
#   slurpTAML - read a file into a hash

export slurpTAML = (lParts...) =>

	return fromTAML(slurp(lParts...))

# ---------------------------------------------------------------------------
#   slurpPkgJSON - read package.json into a hash

export slurpPkgJSON = (lParts...) =>

	if (lParts.length == 0)
		pkgJsonPath = getPkgJsonPath()
	else
		pkgJsonPath = mkpath(lParts...)
		assert isFile(pkgJsonPath), "Missing package.json at cur dir"
	return slurpJSON(pkgJsonPath)

# ---------------------------------------------------------------------------
#   barf - write a string to a file

export barf = (text, lParts...) =>

	assert (lParts.length > 0), "Missing file path"
	filePath = mkpath(lParts...)
	fs.writeFileSync(filePath, text)
	return

# ---------------------------------------------------------------------------
#   barfJSON - write a string to a file

export barfJSON = (hJson, lParts...) =>

	assert isHash(hJson), "hJson not a hash"
	barf(toJSON(hJson), lParts...)
	return

# ---------------------------------------------------------------------------
#   barfTAML - write a string to a file

export barfTAML = (ds, lParts...) =>

	assert isHash(ds) || isArray(ds), "ds not a hash or array"
	barf(toTAML(ds), lParts...)
	return

# ---------------------------------------------------------------------------
#   barfPkgJSON - write a string to a file

export barfPkgJSON = (hJson, lParts...) =>

	if (lParts.length == 0)
		pkgJsonPath = getPkgJsonPath()
	else
		pkgJsonPath = mkpath(lParts...)
		assert isFile(pkgJsonPath), "Missing package.json at cur dir"
	barfJSON(hJson, pkgJsonPath)
	return

# ---------------------------------------------------------------------------

export hasPackageJson = (lParts...) =>

	return isFile(lParts...)

# ---------------------------------------------------------------------------

export forEachFileInDir = (dir, func, hContext={}) =>
	# --- callback will get parms (filepath, hContext)
	#     DOES NOT RECURSE INTO SUBDIRECTORIES

	for ent in fs.readdirSync(dir, {withFileTypes: true})
		if ent.isFile()
			func(ent.name, dir, hContext)
	return

# ---------------------------------------------------------------------------

export forEachItem = (iter, func, hContext={}) =>
	# --- func() gets (item, hContext)

	assert isIterable(iter), "not an iterable"
	lItems = []
	index = 0
	for item from iter
		hContext.index = index
		index += 1
		try
			result = func(item, hContext)
			if defined(result)
				lItems.push result
		catch err
			reader.close()
			if isString(err)
				return lItems
			else
				throw err    # rethrow the error
	return lItems

# ---------------------------------------------------------------------------

export lineIterator = (filepath) ->

	reader = new NReadLines(filepath)
	while (buffer = reader.next())
		yield buffer.toString().replace(/\r/g, '')
	return

# ---------------------------------------------------------------------------

export forEachLineInFile = (filepath, func, hContext={}) =>
	# --- func gets (line, hContext) - lineNum starts at 1
	#     hContext will include keys:
	#        filepath
	#        lineNum - first line is line 1

	linefunc = (line, hContext) =>
		hContext.filepath = filepath
		hContext.lineNum = hContext.index + 1
		return func(line, hContext)

	return forEachItem(lineIterator(filepath), linefunc, hContext)

# ---------------------------------------------------------------------------

export class FileProcessor

	constructor: (@src, hOptions={}) ->
		# --- Valid options:
		#        debug
		# --- hOptions should not contain keys:
		#        filepath
		#        ext
		#        lineNum

		assert isString(@src), "Source not a string"
		@src = pathLib.resolve(@src)
		@hOptions = getOptions(hOptions)
		@debug = !! @hOptions.debug

	# ..........................................................

	init: () ->

	# ..........................................................

	all: () ->
		# --- yields items

		@init()
		if isDir(@src)
			if @debug
				console.log "Source is a directory"
			for ent in fs.readdirSync(@src, {withFileTypes: true})
				if ent.isFile()
					yield from @handleFile mkpath(@src, ent.name)
		else if isFile(@src)
			if @debug
				console.log "Source is a file"
			yield from @handleFile @src
		else
			croak "Source not a file or directory"
		return

	# ..........................................................

	getAll: () ->
		# --- Returns an array of items

		lItems = for item from @all()
			item
		return lItems

	# ..........................................................

	filter: () ->

		return true    # by default, handle all files in dir

	# ..........................................................

	handleFile: (filepath) ->

		@hOptions.filepath = filepath
		hInfo = pathLib.parse(filepath)
		@hOptions.ext = hInfo.ext
		@hOptions.filename = hInfo.base
		@hOptions.stub = hInfo.name
		if @debug
			LOGVALUE 'hOptions', @hOptions
		if @filter()
			if @debug
				console.log "filter() returned true"
			@hOptions.lineNum = 1

			for line from lineIterator(filepath)
				result = @handleLine(line)
				if defined(result)
					yield result
				@hOptions.lineNum += 1
		else
			if @debug
				console.log "filter() returned false"
		return

	# ..........................................................

	handleLine: (line) ->

		return "[#{@hOptions.filename}:#{@hOptions.lineNum}] #{line}"
