# source-map.coffee

import {readFileSync, existsSync} from 'node:fs'
import {SourceMapConsumer} from 'source-map-js'

import {
	undef, pass, defined, notdefined, alldefined,
	isEmpty, nonEmpty, deepCopy,
	} from '@jdeighan/base-utils/ll-utils'
import {isInteger} from '@jdeighan/base-utils'
import {mkpath, parsePath} from '@jdeighan/base-utils/ll-fs'

# --- cache to hold previously fetched file contents
hSourceMaps = {}    # { filepath => rawMap, ... }

# ---------------------------------------------------------------------------
# This lib uses the library source-map-js
# ---------------------------------------------------------------------------

export getRawMap = (mapFilePath) =>

	if hSourceMaps.hasOwnProperty(mapFilePath)
		return hSourceMaps[mapFilePath]
	else
		rawMap = readFileSync mapFilePath, 'utf8'
		hSourceMaps[mapFilePath] = rawMap
		return rawMap

# ---------------------------------------------------------------------------
# --- returns {source, line, column, name}

export mapPos = (rawMap, hPos, debug=false) ->
	# --- hPos should be {line, column}

	if notdefined(rawMap)
		console.log "empty map!"
		process.exit()

	smc = new SourceMapConsumer(rawMap)
	hResult = smc.originalPositionFor(hPos)
	try
		resolved = mkpath(hResult.source)
		source = mkpath(resolved)
		hResult.source = source
	return hResult

# ---------------------------------------------------------------------------

export mapSourcePos = (hFileInfo, line, column, debug=false) =>
	# --- Currently only maps if hFileInfo.ext = '.js'
	#
	#     hFileInfo must have keys:
	#        EITHER:
	#           dir, stub, ext
	#           dir, fileName
	#           filePath

	# --- Can map only if:
	#        1. ext is .js
	#        2. <stub>.coffee and <stub>.js.map exist in dir
	#
	#     returns {source, line, column, name}

	if ! isInteger(line, {min: 0})
		if debug
			console.log "mapSourcePos: invalid line #{line}"
		return undef

	if ! isInteger(column, {min: 0})
		if debug
			console.log "mapSourcePos: invalid column #{column}"
		return undef

	{dir, stub, ext, fileName, filePath} = hFileInfo

	# --- Ensure that dir, stub, ext are defined
	if ! alldefined(dir, stub, ext)
		# --- Make sure filePath is defined
		if notdefined(filePath) && alldefined(dir, fileName)
			filePath = "#{dir}/#{fileName}"
		if notdefined(filePath)
			if debug
				console.log "CANNOT MAP: Not all needed fields defined"
			return

		{dir, stub, ext} = parsePath(filePath)

	if (ext != '.js')
		if debug
			console.log "CANNOT MAP: ext = '#{ext}'"
		return

	mapFilePath = "#{dir}/#{stub}.js.map"
	if ! existsSync(mapFilePath)
		if debug
			console.log "CANNOT MAP - MISSING MAP FILE #{mapFilePath}"
		return

	if isEmpty(dir) || isEmpty(stub)
		if debug
			console.log "CANNOT MAP - dir='#{dir}', stub='#{stub}'"
		return

	rawMap = getRawMap(mapFilePath)   # get from cache if available
	if debug
		console.log "MAP FILE FOUND: '#{mapFilePath}'"

	# --- hMapped is {source, line, column, name}
	hMapped = mapPos rawMap, {line, column}, debug
	return hMapped

	hMapped = undef
