# fs.coffee

import pathLib from 'node:path'
import urlLib from 'url'
import fs from 'fs'
import NReadLines from 'n-readlines'
import {globSync as glob} from 'glob'
import {open} from 'node:fs/promises'

import {
	undef, defined, notdefined, nonEmpty,
	toBlock, toArray, getOptions, isNonEmptyString,
	isString, isNumber, isInteger,
	isHash, isArray, isIterable, isRegExp,
	fromJSON, toJSON, OL, forEachItem, jsType,
	} from '@jdeighan/base-utils'
import {
	fileExt, workingDir, myself, mydir, mkpath, withExt,
	mkDir, clearDir, touch, isFile, isDir, rename,
	pathType, rmFile, rmDir, parsePath,
	parentDir, parallelPath, subPath,
	fileDirPath, mkDirsForFile,
	} from '@jdeighan/base-utils/ll-fs'
import {assert, croak} from '@jdeighan/base-utils/exceptions'
import {LOG, LOGVALUE} from '@jdeighan/base-utils/log'
import {dbgEnter, dbgReturn, dbg} from '@jdeighan/base-utils/debug'
import {toTAML, fromTAML} from '@jdeighan/base-utils/taml'

export {
	fileExt, workingDir, myself, mydir, mkpath, withExt,
	mkDir, clearDir, touch, isFile, isDir, rename,
	pathType, rmFile, rmDir, parsePath,
	parentDir, parallelPath, subPath,
	fileDirPath,  mkDirsForFile,
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
	# --- yields hFile with keys:
	#        path, filePath,
	#        type, root, dir, base, fileName,
	#        name, stub, ext, purpose
	#        (if eager) metadata, lLines
	# --- dir must be a directory
	# --- Valid options:
	#        recursive - descend into subdirectories
	#        eager - read the file and add keys metadata, contents
	#        regexp - only if fileName matches regexp

	dbgEnter 'allFilesIn', dir, hOptions
	{recursive, eager, regexp} = getOptions(hOptions, {
		recursive: true
		eager: false
		regexp: undef
		})
	dir = mkpath dir
	assert isDir(dir), "Not a directory: #{dir}"
	hOptions = {withFileTypes: true, recursive}
	for ent in fs.readdirSync(dir, hOptions)
		dbg "ENT:", ent
		if ent.isFile()
			path = mkpath(ent.path, ent.name)
			dbg "PATH = #{path}"
			hFile = parsePath(path)
			assert isHash(hFile), "hFile = #{OL(hFile)}"
			if eager
				hContents = getTextFileContents(path)
				Object.assign hFile, hContents
			dbg 'hFile', hFile
			if defined(regexp)
				assert isRegExp(regexp), "Not a regular expression"
				if hFile.fileName.match(regexp)
					yield hFile
			else
				yield hFile
	dbgReturn 'allFilesIn'
	return

# ---------------------------------------------------------------------------

export dirContents = (dirPath, pattern='*', hOptions={}) ->

	{absolute, cwd, dot, filesOnly, dirsOnly
		} = getOptions hOptions, {
		absolute: true
		dot: false
		filesOnly: false
		dirsOnly: false
		}

	assert ! (filesOnly && dirsOnly), "Incompatible options"
	lPaths = glob(pattern, {absolute, cwd: dirPath, dot})
	if filesOnly
		return lPaths.filter((path) => isFile(path))
	else if dirsOnly
		return lPaths.filter((path) => isDir(path))
	else
		return lPaths

# ---------------------------------------------------------------------------

export forEachFileInDir = (dir, func, hContext={}) =>
	# --- callback will get parms (filePath, hContext)
	#     DOES NOT RECURSE INTO SUBDIRECTORIES

	for ent in fs.readdirSync(dir, {withFileTypes: true})
		if ent.isFile()
			func(ent.name, dir, hContext)
	return

# ---------------------------------------------------------------------------
#   slurp - read a file into a string

export slurp = (filePath, hOptions) =>
	# --- Valid options:
	#        maxLines: <int>

	dbgEnter 'slurp', filePath, hOptions
	assert isNonEmptyString(filePath), "empty path"
	{maxLines} = getOptions hOptions, {
		maxLines: undef
		}
	if defined(maxLines)
		assert isInteger(maxLines), "maxLines must be an integer"
	filePath = mkpath(filePath)
	if defined(maxLines)
		dbg "maxLines = #{maxLines}"
		lLines = []
		for line from allLinesIn(filePath)
			lLines.push line
			if (lLines.length == maxLines)
				break
		dbg 'lLines', lLines
		block = toBlock(lLines)
	else
		block = fs.readFileSync(filePath, 'utf8') \
				.toString() \
				.replaceAll('\r', '')
	dbg 'block', block

	dbgReturn 'slurp', block
	return block

# ---------------------------------------------------------------------------
#   slurpJSON - read a file into a hash

export slurpJSON = (filePath) =>

	return fromJSON(slurp(filePath))

# ---------------------------------------------------------------------------
#   slurpTAML - read a file into a hash

export slurpTAML = (filePath) =>

	return fromTAML(slurp(filePath))

# ---------------------------------------------------------------------------
#   slurpPkgJSON - read package.json into a hash

export slurpPkgJSON = () =>

	pkgJsonPath = getPkgJsonPath()
	assert isFile(pkgJsonPath), "Missing package.json at cur dir"
	return slurpJSON(pkgJsonPath)

# ---------------------------------------------------------------------------
#   barf - write a string to a file
#          will ensure that all necessary directories exist

export barf = (text, lParts...) =>

	assert (lParts.length > 0), "Missing file path"
	filePath = mkpath(lParts...)
	mkDirsForFile(filePath)
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

export allLinesIn = (filePath) ->

	reader = new NReadLines(filePath)
	while buffer = reader.next()
		yield buffer.toString().replaceAll('\r', '')
	# --- reader.close() fails with error if EOF reached
	return

# ---------------------------------------------------------------------------

export forEachLineInFile = (filePath, func, hContext={}) =>
	# --- func gets (line, hContext)
	#     hContext will include keys:
	#        filePath
	#        lineNum - first line is line 1

	linefunc = (line, hContext) =>
		hContext.filePath = filePath
		hContext.lineNum = hContext.index + 1
		return func(line, hContext)

	return forEachItem(
		allLinesIn(filePath),
		linefunc,
		hContext
		)

# ---------------------------------------------------------------------------

export class FileWriter

	constructor: (@filePath, hOptions) ->

		@hOptions = getOptions hOptions, {
			async: false
			}
		@async = @hOptions.async
		@fullPath = mkpath(@filePath)

	# ..........................................................

	convert: (item) ->
		# --- convert arbitrary value into a string

		switch jsType(item)[0]
			when 'string'
				return item
			when 'number'
				return item.toString()
			else
				return OL(item)

	# ..........................................................

	write: (lItems...) ->

		lStrings = []
		for item in lItems
			lStrings.push @convert(item)

		# --- open on first use
		if @async
			if notdefined(@writer)
				@fd = await open(@fullPath, 'w')
				@writer = @fd.createWriteStream()
			for str in lStrings
				@writer.write str
		else
			if notdefined(@fd)
				@fd = fs.openSync(@fullPath, 'w')
			for str in lStrings
				fs.writeSync @fd, str
		return

	# ..........................................................

	writeln: (lItems...) ->

		await @write lItems..., "\n"
		return

	# ..........................................................

	DESTROY: () ->

		@end()
		return

	# ..........................................................

	close: () ->

		if @async
			if defined(@writer)
				await @writer.close()
				@writer = undef
		else
			if defined(@fd)
				fs.closeSync(@fd)
				@fd = undef

		return
