# fs.coffee

import pathLib from 'node:path'
import urlLib from 'url'
import fs from 'fs'
import {
	readFile, writeFile, rm, rmdir,   #  rmSync, rmdirSync,
	} from 'node:fs/promises'
import NReadLines from 'n-readlines'

import {
	undef, defined, nonEmpty, toBlock, getOptions,
	isString, isHash, isArray, isIterable,
	} from '@jdeighan/base-utils'
import {assert, croak} from '@jdeighan/base-utils/exceptions'
import {LOG, LOGVALUE} from '@jdeighan/base-utils/log'
import {dbgEnter, dbgReturn, dbg} from '@jdeighan/base-utils/debug'
import {toTAML, fromTAML} from '@jdeighan/base-utils/taml'
import {
	fixPath, mydir, mkpath, resolve, parsePath,
	} from '@jdeighan/base-utils/ll-fs'

export {fixPath, mydir, mkpath, resolve, parsePath}

# ---------------------------------------------------------------------------

export getFullPath = (lPaths...) =>

	return fixPath(pathLib.resolve(lPaths...).replaceAll("\\", "/"))

# ---------------------------------------------------------------------------

export allDirs = (root, lDirs) ->

	len = lDirs.length
	while (len > 0)
		yield mkpath(root, lDirs)
		lDirs

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

		dir = pathLib.resolve('..', dir)

# ---------------------------------------------------------------------------

export getPkgJsonPath = () =>

	filePath = mkpath(process.cwd(), 'package.json')
	assert isFile(filePath), "Missing pacakge.json at cur dir"
	return filePath

# ---------------------------------------------------------------------------
#    file functions
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

export rmFile = (filepath) =>

	await rm filepath
	return

# ---------------------------------------------------------------------------

export rmFileSync = (filepath) =>

	assert isFile(filepath), "#{filepath} is not a file"
	fs.rmSync filepath
	return

# ---------------------------------------------------------------------------
#    directory functions
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

export rmDir = (dirpath) =>

	await rmdir dirpath, {recursive: true}
	return

# ---------------------------------------------------------------------------

export rmDirSync = (dirpath) =>

	fs.rmdirSync dirpath, {recursive: true}
	return

# ---------------------------------------------------------------------------
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

export parseSource = (source) =>
	# --- returns {
	#        dir
	#        fileName, filename
	#        filePath, filepath
	#        stub
	#        ext
	#        purpose
	#        }
	# --- NOTE: source may be a file URL, e.g. import.meta.url

	dbgEnter 'parseSource', source
	assert isString(source), "parseSource(): source not a string"
	if source.match(/^file\:\/\//)
		source = urlLib.fileURLToPath(source)

	if isDir(source)
		hSourceInfo = {
			dir: source
			filePath: source
			filepath: source
			}
	else
		assert isFile(source), "source not a file or directory"
		hInfo = pathLib.parse(source)
		dir = hInfo.dir
		if dir
			hSourceInfo = {
				dir: dir.replaceAll("\\", "/")
				filePath: mkpath(dir, hInfo.base)
				filepath: mkpath(dir, hInfo.base)
				fileName: hInfo.base
				filename: hInfo.base
				stub: hInfo.name
				ext: hInfo.ext
				}
		else
			hSourceInfo = {
				fileName: hInfo.base
				filename: hInfo.base
				stub: hInfo.name
				ext: hInfo.ext
				}

		# --- check for a 'purpose'
		if lMatches = hSourceInfo.stub.match(///
				\.
				([A-Za-z_]+)
				$///)
			hSourceInfo.purpose = lMatches[1]
	dbgReturn 'parseSource', hSourceInfo
	return hSourceInfo

# ---------------------------------------------------------------------------

allFilesIn = (src) ->
	# --- yields hFileInfo with keys:
	#        filepath, filename, stub, ext
	# --- src must be full path to a file or directory

	dbgEnter 'allFilesIn', src
	if isDir(src)
		dbg "DIR: #{src}"
		for ent in fs.readdirSync(src, {withFileTypes: true})
			dbg "ENT:", ent
			if ent.isFile()
				yield parseSource(mkpath(src, ent.name))
			else if ent.isDirectory()
				yield from allFilesIn(ent.name)
	else if isFile(src)
		dbg "FILE: #{src}"
		yield parseSource(src)
	else
		croak "Source not a file or directory"
	dbgReturn 'allFilesIn'
	return

# ---------------------------------------------------------------------------

export class FileProcessor

	constructor: (@src, hOptions={}) ->
		# --- Valid options:
		#        debug

		# --- convert src to a full path
		assert isString(@src), "Source not a string"
		@src = pathLib.resolve(@src)

		@hOptions = getOptions(hOptions)
		@debug = !! @hOptions.debug
		@log "constructed"

	# ..........................................................

	log: (obj) ->

		if @debug
			if isString(obj)
				console.log "DEBUG: #{obj}"
			else
				console.log obj
		return

	# ..........................................................
	# --- called at beginning of @procAll()

	init: () ->

		@log "init() called"
		return

	# ..........................................................

	filter: (hFileInfo) ->

		return true    # by default, handle all files in dir

	# ..........................................................

	procAll: () ->

		if @debug
			@log "calling init()"
		@init()

		# --- NOTE: If @src is a file, allFilesIn() will
		#           only yield a single hFileInfo
		@log "process all files in '#{@src}'"
		for hFileInfo from allFilesIn(@src)
			@log hFileInfo
			if @filter(hFileInfo)
				@log "Handle file #{hFileInfo.filepath}"
				@handleFile hFileInfo
			else
				@log "Removed by filter: #{hFileInfo.filepath}"
		return

	# ..........................................................
	# --- default handleFile() calls handleLine() for each line

	handleFile: (hFileInfo) ->

		lineNum = 1
		for line from lineIterator(hFileInfo.filepath)
			result = @handleLine(line, lineNum, hFileInfo)
			switch result
				when 'abort'
					return
			lineNum += 1
		return

	# ..........................................................

	handleLine: (line, lineNum, hFileInfo) ->

		return
