# ll-utils.coffee

import urlLib from 'url'
import pathLib from 'node:path'

###*
# undef is a synonym for undefined
###

`export const undef = void 0`

# ---------------------------------------------------------------------------
###*
# Should be called like: mydir(import.meta.url)
# @returns {string} the directory that the current file is in
###

export mydir = (url) =>

	path = urlLib.fileURLToPath(url)
	dir = pathLib.dirname(path)
	return dir.replaceAll('\\', '/')

# ---------------------------------------------------------------------------

export getFullPath = (lPaths...) =>

	return pathLib.resolve(lPaths...).replaceAll("\\", "/")

# ---------------------------------------------------------------------------
# --- Returned object has keys: dir, fileName, stub, ext

export parsePath = (lPaths...) =>

	fullPath = getFullPath(lPaths...)
	h = pathLib.parse(fullPath)
	return {
		dir: h.dir
		fileName: h.base
		stub: h.name
		ext: h.ext
		}

# ---------------------------------------------------------------------------
#   pass - do nothing

export pass = () =>

	return true

# ---------------------------------------------------------------------------
# low-level version of assert()

export assert = (cond, msg) =>

	if !cond
		throw new Error(msg)
	return true

# ---------------------------------------------------------------------------

export defined = (obj) =>

	return (obj != undef) && (obj != null)

# ---------------------------------------------------------------------------

export notdefined = (obj) =>

	return (obj == undef) || (obj == null)

# ---------------------------------------------------------------------------

export alldefined = (lObj...) =>

	for obj in lObj
		if (obj == undef) || (obj == null)
			return false
	return true

# ---------------------------------------------------------------------------
#   isEmpty
#      - string is whitespace, array has no elements, hash has no keys

export isEmpty = (x) =>

	if (x == undef) || (x == null)
		return true
	if (typeof x == 'string')
		return x.match(/^\s*$/)
	if Array.isArray(x)
		return (x.length == 0)
	if (typeof x == 'object')
		return Object.keys(x).length == 0
	else
		return false

# ---------------------------------------------------------------------------
#   nonEmpty
#      - string has non-whitespace, array has elements, hash has keys

export nonEmpty = (x) =>

	return ! isEmpty(x)

# ---------------------------------------------------------------------------
#   deepCopy - deep copy an array or object

export deepCopy = (obj) =>

	if (obj == undef)
		return undef
	objStr = JSON.stringify(obj)
	try
		newObj = JSON.parse(objStr)
	catch err
		throw new Error("ERROR: err.message")

	return newObj

