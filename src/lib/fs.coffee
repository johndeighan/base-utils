# fs.coffee

import pathLib from 'node:path'
import urlLib from 'url'
import fs from 'fs'
import NReadLines from 'n-readlines'

import {
	undef, defined, nonEmpty, toBlock, toArray, getOptions,
	isString, isNumber, isHash, isArray, isIterable,
	fromJSON, toJSON,
	} from '@jdeighan/base-utils'
import {assert, croak} from '@jdeighan/base-utils/exceptions'
import {LOG, LOGVALUE} from '@jdeighan/base-utils/log'
import {dbgEnter, dbgReturn, dbg} from '@jdeighan/base-utils/debug'
import {toTAML, fromTAML} from '@jdeighan/base-utils/taml'
import {
	myself, mydir, mkpath,
	mkDir, clearDir, touch, isFile, isDir, rename,
	pathType, rmFile, rmDir, parsePath, parseSource,
	} from '@jdeighan/base-utils/ll-fs'

export {
	myself, mydir, mkpath,
	mkDir, clearDir, touch, isFile, isDir, rename,
	pathType, rmFile, rmDir, parsePath, parseSource,
	}

# ---------------------------------------------------------------------------

export getPkgJsonDir = () =>

	pkgJsonDir = undef

	# --- First, get the directory this file is in
	dir = mydir(import.meta.url)

	# --- parse into parts
	{root, lDirs} = parsePath(dir)

	# --- search upward for package.json
	while (lDirs.length > 0)
		path = mkpath(root, lDirs, 'package.json')
		if isFile(path)
			return mkpath(root, lDirs)
		lDirs.pop()

		dir = mkpath('..', dir)

# ---------------------------------------------------------------------------

export getPkgJsonPath = () =>

	filePath = mkpath(process.cwd(), 'package.json')
	assert isFile(filePath), "Missing pacakge.json at cur dir"
	return filePath

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

export getTextFileContents = (filePath) =>
	# --- handles metadata if present

	dbgEnter 'getTextFileContents', filePath
	lMetaLines = undef
	inMeta = false

	lLines = []

	numLines = 0
	for line from allLinesIn(filePath)
		if (numLines == 0) && (line == '---')
			lMetaLines = ['---']
			inMeta = true
		else if inMeta
			if (line == '---')
				inMeta = false
			else
				lMetaLines.push line
		else
			lLines.push line
		numLines += 1

	if defined(lMetaLines)
		metadata = fromTAML(toBlock(lMetaLines))
	else
		metadata = undef
	hResult = {
		metadata
		lLines
		}
	dbgReturn 'getTextFileContents', hResult
	return hResult

# ---------------------------------------------------------------------------

export allFilesIn = (dir, hOptions={}) ->
	# --- yields hFileInfo with keys:
	#        filePath, fileName, stub, ext, metadata, contents
	# --- dir must be a directory
	# --- Valid options:
	#        recursive - descend into subdirectories
	#        eager - read the file and add keys metadata, contents

	dbgEnter 'allFilesIn', dir, hOptions
	{recursive, eager} = getOptions(hOptions, {
		recursive: true
		eager: false
		})
	assert isDir(dir), "Not a directory: #{dir}"
	hOptions = {withFileTypes: true, recursive}
	for ent in fs.readdirSync(dir, hOptions)
		dbg "ENT:", ent
		if ent.isFile()
			path = mkpath(ent.path, ent.name)
			dbg "PATH = #{path}"
			hFileInfo = parseSource(path)
			assert defined(hFileInfo), "allFilesIn(): hFileInfo = undef"
			if eager
				hContents = getTextFileContents(hFileInfo.filePath)
				Object.assign hFileInfo, hContents
			dbg 'hFileInfo', hFileInfo
			yield hFileInfo
	dbgReturn 'allFilesIn'
	return

# ---------------------------------------------------------------------------

export allLinesIn = (filePath) ->

	reader = new NReadLines(filePath)
	while (buffer = reader.next())
		yield buffer.toString().replace(/\r/g, '')
	return

export lineIterator = allLinesIn     # for backward compatibility

# ---------------------------------------------------------------------------

export forEachFileInDir = (dir, func, hContext={}) =>
	# --- callback will get parms (filePath, hContext)
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

export forEachLineInFile = (filePath, func, hContext={}) =>
	# --- func gets (line, hContext) - lineNum starts at 1
	#     hContext will include keys:
	#        filePath
	#        lineNum - first line is line 1

	linefunc = (line, hContext) =>
		hContext.filePath = filePath
		hContext.lineNum = hContext.index + 1
		return func(line, hContext)

	return forEachItem(allLinesIn(filePath), linefunc, hContext)

# ---------------------------------------------------------------------------

export class FileWriter

	constructor: (@filePath) ->

		assert isString(@filePath), "Not a string: #{@filePath}"
		@writer = fs.createWriteStream(@filePath)

	DESTROY: () ->

		if defined(@writer)
			@end()
		return

	write: (lStrings...) ->

		assert defined(@writer), "Write after end()"
		for str in lStrings
			assert isString(str), "Not a string: '#{str}'"
			@writer.write str
		return

	writeln: (lStrings...) ->

		assert defined(@writer), "Write after end()"
		for str in lStrings
			assert isString(str), "Not a string: '#{str}'"
			@writer.write str
			@writer.write "\n"
		return

	end: () ->

		@writer.end()
		@writer = undef
		return

# ---------------------------------------------------------------------------

export class FileWriterSync

	constructor: (@filePath) ->

		assert isString(@filePath), "Not a string: #{@filePath}"
		@fullPath = mkpath(@filePath)
		assert isString(@fullPath), "Bad path: #{@filePath}"
		@fd = fs.openSync(@fullPath, 'w')

	DESTROY: () ->

		if defined(@fd)
			@end()
		return

	write: (lStrings...) ->

		assert defined(@fd), "Write after end()"
		for str in lStrings
			if isNumber(str)
				fs.writeSync @fd, str.toString()
			else
				assert isString(str), "Not a string: '#{str}'"
				fs.writeSync @fd, str
		return

	writeln: (lStrings...) ->

		@write lStrings...
		@write "\n"
		return

	end: () ->

		fs.closeSync(@fd)
		@fd = undef
		return

