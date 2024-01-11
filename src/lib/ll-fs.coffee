# ll-fs.coffee

import pathLib from 'node:path'
import urlLib from 'url'
import fs from 'fs'

import {undef, nonEmpty} from '@jdeighan/base-utils'

# ---------------------------------------------------------------------------
#     convert \ to /
# --- convert "C:..." to "c:..."

export fixPath = (path) =>

	path = path.replaceAll('\\', '/')
	if (path.charAt(1) == ':')
		return path.charAt(0).toLowerCase() + path.substring(1)
	return path

# ---------------------------------------------------------------------------
# --- Should be called like: mydir(import.meta.url)
#     returns the directory that the current file is in

export mydir = (url) =>

	path = urlLib.fileURLToPath(url)
	dir = pathLib.dirname(path)
	return fixPath(dir)

# ---------------------------------------------------------------------------

export mkpath = (lParts...) =>

	lParts = lParts.filter((x) => nonEmpty(x))
	if (lParts.length == 0)
		throw new Error "mkpath(): empty input"
	if lParts[0].match(/[\/\\]$/)
		root = lParts.shift().toLowerCase()
		str = root + lParts.join('/')
	else
		str = lParts.join('/')
	return fixPath(str)

# ---------------------------------------------------------------------------

export resolve = (lParts...) =>

	return fixPath(pathLib.resolve(lParts...))

# ---------------------------------------------------------------------------
# --- Returned object has keys:
#        root, dir, lDirs, filename, fileName, stub, ext
#        NOTE: unable to determine if it's a file or directory

export parsePath = (lParts...) =>

	path = mkpath(lParts...)
	if path.match(/^\./)
		throw new Error("parsePath() got '#{path}' - you should resolve first")
	{root, dir, base, name, ext} = pathLib.parse(path)
	return {
		root
		dir
		lDirs: dir.split(/[\/\\]/)
		fileName: base
		filename: base
		stub: name
		ext
		}
