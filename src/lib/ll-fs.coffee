# ll-fs.coffee

import pathLib from 'node:path'
import urlLib from 'url'
import fs from 'fs'

import {
	pass, undef, defined, notdefined, LOG,
	isString, getOptions, words,
	assert, croak,                  # low level versions
	} from '@jdeighan/base-utils'

export lStatFields = words(
	'dev ino mode nlink uid gid rdev size blksize blocks',
	'atimeMs mtimeMs ctimeMs birthtimeMs',
	'atime mtime ctime birthtime',
	)

# ---------------------------------------------------------------------------

export fileDirPath = (filePath) =>
	# --- file does not need to exist yet, but
	#     it should be a file path

	assert isString(filePath), "not a string: '#{filePath}'"
	fullPath = mkpath(filePath)
	hFile = parsePath(fullPath)
	dirStr = hFile.dir
	rootLen = hFile.root.length
	lParts = dirStr.substring(rootLen).split(/[\\\/]/)
	return [hFile.root, lParts]

# ---------------------------------------------------------------------------

export mkDirsForFile = (filePath) =>

	[root, lParts] = fileDirPath(filePath)
	dir = root
	for part in lParts
		dir = "#{dir}/#{part}"
		if ! isDir(dir)
			mkDir(dir)
	return

# ---------------------------------------------------------------------------

export fileExt = (path) =>

	assert isString(path), "fileExt(): path not a string"
	if lMatches = path.match(/\.[A-Za-z0-9_]+$/)
		return lMatches[0]
	else
		return ''

# ---------------------------------------------------------------------------
#   withExt - change file extention in a file name

export withExt = (path, newExt) =>

	assert newExt, "withExt(): No newExt provided"
	if newExt.indexOf('.') != 0
		newExt = '.' + newExt

	if lMatches = path.match(/^(.*)\.[^\.]+$/)
		[_, pre] = lMatches
		return pre + newExt
	croak "Bad path: '#{path}'"

# ---------------------------------------------------------------------------
#     convert \ to /
# --- convert "C:..." to "c:..."

normalize = (path) =>

	path = path.replaceAll '\\', '/'
	if (path.charAt(1) == ':')
		return path.charAt(0).toLowerCase() + path.substring(1)
	else
		return path

# ---------------------------------------------------------------------------

export workingDir = () ->

	return normalize process.cwd()

# ---------------------------------------------------------------------------
# --- Should be called like: myself(import.meta.url)
#     returns full path of current file

export myself = (url) =>

	path = urlLib.fileURLToPath url
	return normalize path

# ---------------------------------------------------------------------------
# --- Should be called like: mydir(import.meta.url)
#     returns the directory that the current file is in

export mydir = (url) =>

	path = urlLib.fileURLToPath url
	dir = pathLib.dirname path
	return normalize dir

# ---------------------------------------------------------------------------

export mkpath = (lParts...) =>

	fullPath = pathLib.resolve lParts...
	return normalize fullPath

# ---------------------------------------------------------------------------
# --- returned hash has keys:
#
#  dev: 2114,
#  ino: 48064969,
#  mode: 33188,
#  nlink: 1,
#  uid: 85,
#  gid: 100,
#  rdev: 0,
#  size: 527,
#  blksize: 4096,
#  blocks: 8,
#  atimeMs: 1318289051000.1,
#  mtimeMs: 1318289051000.1,
#  ctimeMs: 1318289051000.1,
#  birthtimeMs: 1318289051000.1,
#  atime: Mon, 10 Oct 2011 23:24:11 GMT,
#  mtime: Mon, 10 Oct 2011 23:24:11 GMT,
#  ctime: Mon, 10 Oct 2011 23:24:11 GMT,
#  birthtime: Mon, 10 Oct 2011 23:24:11 GMT

export getFileStats = (path) =>

	return fs.lstatSync(path)

# ---------------------------------------------------------------------------
# --- Since a disk's directory is kept in memory,
#     directory operations can be done synchronously

export isDir = (dirPath) =>

	if ! fs.existsSync(dirPath)
		return false
	try
		return getFileStats(dirPath).isDirectory()
	catch
		return false

# ---------------------------------------------------------------------------

export mkDir = (dirPath, hOptions={}) =>

	hOptions = getOptions hOptions, {
		clear: false
		}
	try
		fs.mkdirSync dirPath
		return true
	catch err
		if (err.code == 'EEXIST')
			if hOptions.clear
				clearDir dirPath
			return false
		else
			throw err

# ---------------------------------------------------------------------------

export dirContents = (dirPath) =>

	try
		lContents = []
		hOptions = {withFileTypes: true, recursive: false}
		for ent in fs.readdirSync(dirPath, hOptions)
			if ent.isFile() || ent.isDir()
				lContents.push ent.name
		return lContents
	catch err
		return undef


# ---------------------------------------------------------------------------

export clearDir = (dirPath) =>

	try
		hOptions = {withFileTypes: true, recursive: true}
		for ent in fs.readdirSync(dirPath, hOptions)
			if ent.isFile()
				fs.rmSync mkpath(ent.path, ent.name)
	catch err
		pass()
	return

# ---------------------------------------------------------------------------

export rmDir = (dirPath, recursive=true) =>

	assert isDir(dirPath), "#{dirPath} is not a directory"
	fs.rmSync dirPath, {recursive}
	return

# ---------------------------------------------------------------------------

export touch = (filePath) =>

	fd = fs.openSync(filePath, 'a')
	fs.closeSync(fd)
	return

# ---------------------------------------------------------------------------

export isFile = (filePath) =>

	if ! fs.existsSync(filePath)
		return false
	try
		return getFileStats(filePath).isFile()
	catch
		return false

# ---------------------------------------------------------------------------

export rename = (oldPath, newPath) =>

	fs.renameSync oldPath, newPath
	return

# ---------------------------------------------------------------------------

export rmFile = (filePath) =>

	assert isFile(filePath), "#{filePath} is not a file"
	fs.rmSync filePath
	return

# ---------------------------------------------------------------------------
# --- returns one of:
#        'missing'  - does not exist
#        'dir'      - is a directory
#        'file'     - is a file
#        'unknown'  - exists, but not a file or directory

export pathType = (fullPath) =>

	assert isString(fullPath), "not a string"
	if fs.existsSync fullPath
		if isFile fullPath
			return 'file'
		else if isDir fullPath
			return 'dir'
		else
			return 'unknown'
	else
		return 'missing'

# ---------------------------------------------------------------------------

export parsePath = (path, shouldNotExist) =>
	# --- NOTE: path may be a file URL, e.g. import.meta.url
	#           path may be a relative path

	assert isString(path), "path is type #{typeof path}"

	# --- check for deprecated args
	assert notdefined(shouldNotExist), "multiple arguments!"

	if path.match(/^file\:\/\//)
		path = normalize urlLib.fileURLToPath(path)
	else
		# --- handles relative paths
		path = normalize pathLib.resolve(path)
	type = pathType path

	{root, dir, base, name, ext} = pathLib.parse(path)
	if lMatches = name.match(///
			\.
			([A-Za-z_]+)
			$///)
		purpose = lMatches[1]
	else
		purpose = undef
	hFile = {
		path
		filePath: path
		type
		root
		dir
		base
		fileName: base   # my preferred name
		name             # use this for directory name
		stub: name       # my preferred name
		ext
		purpose
		}
	Object.assign hFile, getFileStats(path)
	return hFile

# ---------------------------------------------------------------------------

export parentDir = (path) =>

	hParsed = parsePath(path)
	return hParsed.dir

# ---------------------------------------------------------------------------

export parallelPath = (path, name="temp") =>

	fullPath = mkpath(path)  # make full path with '/' as separator
	{dir, fileName} = parsePath fullPath
	if (lMatches = dir.match(///^
			(.*)
			\/         # separator
			[^\/]+     # final dir name
			$///))
		[_, subpath] = lMatches
		return "#{subpath}/#{name}/#{fileName}"
	else
		croak "Can't get parallelPath for '#{path}'"

# ---------------------------------------------------------------------------

export subPath = (path, name="temp") =>

	fullPath = mkpath(path)  # make full path with '/' as separator
	{dir, fileName} = parsePath fullPath
	return "#{dir}/#{name}/#{fileName}"
