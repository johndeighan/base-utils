# fs.coffee

import pathLib from 'node:path'
import urlLib from 'url'
import fs from 'fs'
import NReadLines from 'n-readlines'
import {globSync as glob} from 'glob'
import {open} from 'node:fs/promises'

import {
	undef, defined, notdefined, nonEmpty, words,
	toBlock, toArray, getOptions, isNonEmptyString,
	isString, isNumber, isInteger, deepCopy,
	isHash, isArray, isIterable, isRegExp, removeKeys,
	fromJSON, toJSON, OL, forEachItem, jsType, hasKey,
	fileExt, withExt, newerDestFilesExist,
	} from '@jdeighan/base-utils'
import {
	workingDir, myself, mydir, mkpath, relpath,
	mkDir, clearDir, touch, isFile, isDir, rename,
	pathType, rmFile, rmDir, parsePath,
	parentDir, parallelPath, subPath,
	fileDirPath, mkDirsForFile, getFileStats, lStatFields,
	} from '@jdeighan/base-utils/ll-fs'
import {assert, croak} from '@jdeighan/base-utils/exceptions'
import {LOG, LOGVALUE} from '@jdeighan/base-utils/log'
import {
	dbgEnter, dbgReturn, dbg, dbgYield, dbgResume,
	} from '@jdeighan/base-utils/debug'
import {toTAML, fromTAML} from '@jdeighan/base-utils/taml'
import {
	isMetaDataStart, convertMetaData,
	} from '@jdeighan/base-utils/metadata'
export {
	fileExt, workingDir, myself, mydir, mkpath, relpath,
	mkDir, clearDir, touch, isFile, isDir, rename,
	pathType, rmFile, rmDir, parsePath, withExt,
	parentDir, parallelPath, subPath,
	fileDirPath,  mkDirsForFile, getFileStats,
	newerDestFilesExist,
	}

lDirs = []

# ---------------------------------------------------------------------------

export pushCWD = (dir) =>

	lDirs.push process.cwd()
	process.chdir(dir)
	return

# ---------------------------------------------------------------------------

export popCWD = () =>

	assert (lDirs.length > 0), "directory stack is empty"
	dir = lDirs.pop()
	process.chdir(dir)
	return

# ---------------------------------------------------------------------------

export isProjRoot = (hOptions={}) =>

	{strict} = getOptions hOptions, {
		strict: false
		}

	# --- Current directory must have file 'package.json'
	if !isFile("./package.json")
		return false
	if strict
		if !isFile("./package-lock.json") then return false
		if !isDir("./node_modules") then return false
		if !isDir("./.git") then return false
		if !isFile("./.gitignore") then return false
		if !isDir("./src") then return false
		if !isDir("./src/lib") then return false
		if !isDir("./src/bin") then return false
		if !isDir("./test") then return false
		if !isFile("./README.md") then return false
	return true

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

export readTextFile = (filePath) =>
	# --- handles metadata if present

	dbgEnter 'readTextFile', filePath
	assert isFile(filePath), "Not a file: #{OL(filePath)}"

	lMetaLines = undef
	hMetaData = undef
	lLines = []

	numLines = 0
	for line from allLinesIn(filePath)
		dbg "LINE: #{OL(line)}"
		if (numLines == 0) && isMetaDataStart(line)
			dbg "   - start hMetaData with #{OL(line)}"
			lMetaLines = [line]
		else if defined(lMetaLines)
			if (line == lMetaLines[0])
				dbg "   - end meta data"
				hMetaData = convertMetaData(lMetaLines)
				lMetaLines = undef
			else
				dbg "META: #{OL(line)}"
				lMetaLines.push line
		else
			lLines.push line
		numLines += 1

	hResult = {
		hMetaData: hMetaData || {}
		lLines
		}
	dbgReturn 'readTextFile', hResult
	return hResult

# ---------------------------------------------------------------------------
# --- yield hFile with keys:
#        path, filePath
#        type
#        root
#        dir
#        base, fileName
#        name, stub
#        ext
#        purpose
#     ...plus stat fields

export globFiles = (pattern='*', hGlobOptions={}) ->

	dbgEnter 'globFiles', pattern, hGlobOptions

	hGlobOptions = getOptions hGlobOptions, {
		withFileTypes: true
		stat: true
		}

	dbg 'pattern', pattern
	dbg 'hGlobOptions', hGlobOptions

	for ent in glob(pattern, hGlobOptions)
		filePath = mkpath(ent.fullpath())
		{root, dir, base, name, ext} = pathLib.parse(filePath)
		if lMatches = name.match(///
				\.
				([A-Za-z_]+)
				$///)
			purpose = lMatches[1]
		else
			purpose = undef
		if ent.isDirectory()
			type = 'dir'
		else if ent.isFile()
			type = 'file'
		else
			type = 'unknown'
		hFile = {
			filePath
			path: filePath
			relPath: relpath(filePath)
			type
			root
			dir
			base
			fileName: base
			name
			stub: name
			ext
			purpose
			}
		for key in lStatFields
			hFile[key] = ent[key]
		dbgYield 'globFiles', hFile
		yield hFile
		dbgResume 'globFiles'

	dbgReturn 'globFiles'
	return

# ---------------------------------------------------------------------------
# --- return true to include file

fileFilter = (filePath) =>

	return isFile(filePath) && notdefined(filePath.match(/\bnode_modules\b/))

# ---------------------------------------------------------------------------

export allFilesMatching = (pattern='*', hOptions={}) ->
	# --- yields hFile with keys:
	#        path, filePath,
	#        type, root, dir, base, fileName,
	#        name, stub, ext, purpose
	#        (if eager) hMetaData, lLines
	# --- Valid options:
	#        hGlobOptions - options to pass to glob
	#        fileFilter - return path iff fileFilter(filePath) returns true
	#        eager - read the file and add keys hMetaData, lLines
	# --- Valid glob options:
	#        ignore - glob pattern for files to ignore
	#        dot - include dot files/directories (default: false)
	#        cwd - change working directory

	dbgEnter 'allFilesMatching', pattern, hOptions
	{hGlobOptions, fileFilter, eager} = getOptions(hOptions, {
		hGlobOptions: {
			ignore: "node_modules"
			}
		fileFilter: (h) =>
			{filePath: path} = h
			return isFile(path) && ! path.match(/\bnode_modules\b/)
		eager: false
		})

	dbg "pattern = #{OL(pattern)}"
	dbg "hGlobOptions = #{OL(hGlobOptions)}"
	dbg "eager = #{OL(eager)}"

	numFiles = 0
	for h from globFiles(pattern, hGlobOptions)
		{filePath} = h
		dbg "GLOB: #{OL(filePath)}"
		if eager && isFile(filePath)
			hContents = readTextFile(filePath)
			Object.assign h, hContents
		if fileFilter(h)
			dbgYield 'allFilesMatching', h
			yield h
			numFiles += 1
			dbgResume 'allFilesMatching'
	dbg "#{numFiles} files matched"
	dbgReturn 'allFilesMatching'
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
	assert isFile(filePath), "Not a file: #{OL(filePath)}"
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
	assert isFile(pkgJsonPath),
			"Missing package.json at cur dir #{OL(process.cwd())}"
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
#   barfAST - write AST to a file
#      Valid options:
#         full = write out complete AST

export barfAST = (hAST, filePath, hOptions={}) =>

	{full} = getOptions hOptions, {
		full: false
		}
	lSortBy = words("type params body left right")
	if full
		barf toTAML(hAST, {sortKeys: lSortBy}), filePath
	else
		hCopy = deepCopy hAST
		removeKeys hCopy, words(
			'start end extra declarations loc range tokens comments',
			'assertions implicit optional async generate hasIndentedBody'
			)
		barf toTAML(hCopy, {sortKeys: lSortBy}), filePath
	return

# ---------------------------------------------------------------------------
#   barfPkgJSON - write a string to a file

export barfPkgJSON = (hJson) =>

	barfJSON(hJson, getPkgJsonPath())
	return

# ---------------------------------------------------------------------------

export allLinesIn = (filePath) ->

	reader = new NReadLines(filePath)
	while buffer = reader.next()
		yield buffer.toString().replaceAll('\r', '')
	return

# ---------------------------------------------------------------------------

export allLinesInEx = (filePath) ->

	dbgEnter 'allLinesInEx', filePath
	reader = new NReadLines(filePath)
	nLines = 0
	metaDataStart = undef   # if defined, we're in metadata
	lMetaData = []
	while buffer = reader.next()
		line = buffer.toString().replaceAll('\r', '')
		if (nLines == 0)
			if isMetaDataStart(line)
				dbg "metadata: #{OL(line)}"
				metaDataStart = line
				lMetaData.push line
			else
				dbg "no metadata"
		else if defined(metaDataStart)
			if (line == metaDataStart)
				# --- end line for metadata
				metaDataStart = undef
				hMetaData = convertMetaData(lMetaData, line)
				dbgYield 'allLinesInEx', hMetaData
				yield hMetaData
				dbgResume 'allLinesInEx'
			else
				dbg "metadata: #{OL(line)}"
				lMetaData.push line
		else
			dbgYield 'allLinesInEx', line
			yield line
			dbgResume 'allLinesInEx'
		nLines += 1
	dbgReturn 'allLinesInEx'
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
