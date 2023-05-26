# fs.coffee

import fs from 'fs'

import {assert, croak} from '@jdeighan/base-utils/exceptions'
import {nonEmpty} from '@jdeighan/base-utils'

# ---------------------------------------------------------------------------

export isFile = (fullpath) =>

	try
		return fs.lstatSync(fullpath).isFile()
	catch
		return false

# ---------------------------------------------------------------------------

export isDir = (fullpath) =>

	try
		return fs.lstatSync(fullpath).isDirectory()
	catch
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
#   slurp - read a file into a string

export slurp = (filepath) =>

	filepath = filepath.replace(/\//g, "\\")
	return fs.readFileSync(filepath, 'utf8').toString()

# ---------------------------------------------------------------------------
#   barf - write a string to a file

export barf = (filepath, contents) =>

	fs.writeFileSync(filepath, contents)
	return

# ---------------------------------------------------------------------------
#   slurpJson - read a file into a string

export slurpJson = (filepath) =>

	filepath = filepath.replace(/\//g, "\\")
	contents = fs.readFileSync(filepath, 'utf8').toString()
	return JSON.parse(contents)

# ---------------------------------------------------------------------------
#   barfJson - write a string to a file

export barfJson = (filepath, hJson) =>

	contents = JSON.stringify(hJson, null, "\t")
	fs.writeFileSync(filepath, contents)
	return

# ---------------------------------------------------------------------------

export forEachFileInDir = (dir, func) =>
	# --- callback will get parms (filename, dir)
	#     NOT RECURSIVE

	for ent in fs.readdirSync(dir, {withFileTypes: true})
		if ent.isFile()
			func(ent.name, dir)
	return

# ---------------------------------------------------------------------------

export mkpath = (lParts...) =>

	lParts = lParts.filter((x) => nonEmpty(x))
	str = lParts.join('/')
	str = str.replaceAll('\\', '/')
	if lMatches = str.match(/^([A-Z])\:(.*)$/)
		[_, drive, rest] = lMatches
		return "#{drive.toLowerCase()}:#{rest}"
	else
		return str
