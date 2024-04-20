# fs.coffee

import pathLib from 'node:path'
import urlLib from 'url'
import fs from 'fs'
import NReadLines from 'n-readlines'
import {open} from 'node:fs/promises'

import {
	undef, defined, notdefined, nonEmpty, words, truncateStr,
	toBlock, toArray, getOptions, isNonEmptyString,
	isString, isNumber, isInteger, deepCopy,
	isHash, isArray, isIterable, isRegExp, removeKeys,
	fromJSON, toJSON, OL, forEachItem, jsType, hasKey,
	fileExt, withExt, newerDestFilesExist, centeredText,
	} from '@jdeighan/base-utils'
import {
	workingDir, myself, mydir, mkpath, samefile, relpath,
	mkDir, clearDir, touch, isFile, isDir, rename,
	pathType, rmFile, rmDir, parsePath, dirListing,
	parentDir, parallelPath, subPath, dirContents,
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
	fileExt, workingDir, myself, mydir, mkpath, samefile, relpath,
	mkDir, clearDir, touch, isFile, isDir, rename,
	pathType, rmFile, rmDir, parsePath, withExt,
	parentDir, parallelPath, subPath, lStatFields,
	fileDirPath,  mkDirsForFile, getFileStats,
	newerDestFilesExist, dirContents, dirListing,
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

export isProjRoot = (dir='.', hOptions={}) =>

	{strict} = getOptions hOptions, {
		strict: false
		}

	filePath = "#{dir}/package.json"
	if !isFile(filePath)
		return false

	if !strict
		return true

	lExpectedFiles = [
		'package-lock.json'
		'README.md'
		'.gitignore'
		]

	for name in lExpectedFiles
		filePath = "#{dir}/#{name}"
		if !isFile(filePath)
			return false

	lExpectedDirs = [
		'node_modules'
		'.git'
		'src'
		'src/lib'
		'src/bin'
		'test'
		]
	for name in lExpectedDirs
		dirPath = "#{dir}/#{name}"
		if !isDir(dirPath)
			return false

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

export isFakeFile = (filePath) =>

	if ! fs.existsSync(filePath)
		throw new Error("file #{filePath} does not exist")
	reader = new NReadLines(filePath)
	firstLine = reader.next().toString()
	return firstLine.match(/// \/ \/ \s* fake///)

# ---------------------------------------------------------------------------
# --- return true to include file

fileFilter = (filePath) =>

	return isFile(filePath) && notdefined(filePath.match(/\bnode_modules\b/))

# ---------------------------------------------------------------------------
#   slurp - read a file into a string

export slurp = (filePath, hOptions) =>

	dbgEnter 'slurp', filePath, hOptions
	assert isNonEmptyString(filePath), "empty path"
	filePath = mkpath(filePath)
	assert isFile(filePath), "Not a file: #{OL(filePath)}"
	block = fs.readFileSync(filePath, 'utf8') \
			.toString() \
			.replaceAll('\r', '')
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

export FileWriter = class

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
