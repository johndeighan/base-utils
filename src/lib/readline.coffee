# readline.coffee

import fs from 'node:fs'
import NReadLines from 'n-readlines'

import {
	undef, defined, forEachItem,
	} from '@jdeighan/base-utils'
import {assert} from '@jdeighan/base-utils/exceptions'

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

