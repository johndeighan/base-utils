# peggy.coffee

import peggy from 'peggy'
{generate} = peggy

import {
	undef, OL, toBlock,
	} from '@jdeighan/base-utils'
import {assert} from '@jdeighan/base-utils/exceptions'
import {
	isFile, slurp, barf, withExt, readTextFile,
	} from '@jdeighan/base-utils/fs'

hPeggyOptions = {
	allowedStartRules: ['*']
	format: 'es'
	output: 'source-and-map'
	}

# ---------------------------------------------------------------------------

export peggify = (peggyCode, source) =>

	assert isFile(source), "Not a file: #{OL(source)}"
	try
		hPeggyOptions.grammarSource = source
		srcNode = generate(peggyCode, hPeggyOptions)
		h = srcNode.toStringWithSourceMap()
		return [h.code, h.map.toString()]
	catch err
		console.log "ERROR: #{err.message}"
		return [undef, undef]

# ---------------------------------------------------------------------------

export peggifyFile = (filePath) =>

	{metadata, lLines} = readTextFile(filePath)
	[jsCode, sourceMap] = peggify toBlock(lLines), filePath
	barf jsCode, withExt(filePath, '.js')
	barf sourceMap, withExt(filePath, '.js.map')
	return
