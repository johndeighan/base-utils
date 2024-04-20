# coffee.coffee

import fs from 'fs'
import CoffeeScript from 'coffeescript'

import {
	undef, defined, notdefined, getOptions, toBlock,
	OL, words, removeKeys, isArray, withExt,
	} from '@jdeighan/base-utils'
import {
	assert, croak,
	} from '@jdeighan/base-utils/exceptions'
import {
	dbgEnter, dbgReturn, dbg,
	} from '@jdeighan/base-utils/debug'
import {isUndented} from '@jdeighan/base-utils/indent'
import {toTAML} from '@jdeighan/base-utils/taml'
import {isFile, barf, barfAST} from '@jdeighan/base-utils/fs'
import {
	readTextFile, getShebang,
	} from '@jdeighan/base-utils/read-file'

# ---------------------------------------------------------------------------

export brew = (coffeeCode, hOptions={}) ->

	# --- metadata is used to add a shebang line
	#     if true, use "#!/usr/bin/env node"
	#     else use value of shebang key
	# --- filePath is used to check for a source map
	#     without it, no source map is produced

	dbgEnter 'brew', coffeeCode, hOptions
	{hMetaData, filePath} = getOptions hOptions, {
		hMetaData: {}
		filePath: undef
		}
	assert defined(coffeeCode), "Missing coffee code"
	coffeeCode = toBlock(coffeeCode)  # allow passing array
	dbg 'hMetaData', hMetaData
	dbg 'filePath', filePath

	if defined(filePath)
		assert isFile(filePath), "Not a file: #{filePath}"
		{js, v3SourceMap} = CoffeeScript.compile coffeeCode, {
			bare: true
			header: false
			sourceMap: true
			filename: filePath
			}
	else
		js = CoffeeScript.compile coffeeCode, {
			bare: true
			header: false
			sourceMap: false
			}
		v3SourceMap = undef

	assert defined(js), "No JS code generated"

	shebang = getShebang(hMetaData)
	dbg 'shebang', shebang
	if defined(shebang)
		js = shebang + "\n" + js.trim()
	else
		js = js.trim()
	result = [js, v3SourceMap]
	dbgReturn 'brew', result
	return result

# ---------------------------------------------------------------------------

export brewFile = (filePath) ->

	dbgEnter 'brewFile', filePath
	[hMetaData, lLines] = readTextFile(filePath, 'eager')
	dbg 'hMetaData', hMetaData
	dbg 'lLines', lLines
	assert isArray(lLines), "Bad return from readTextFile"
	[jsCode, sourceMap] = brew lLines, {hMetaData, filePath}
	dbg 'jsCode', jsCode
	dbg 'sourceMap', sourceMap
	jsFilePath = withExt(filePath, '.js')
	mapFilePath = withExt(filePath, '.js.map')
	dbg 'jsFilePath', jsFilePath
	dbg 'mapFilePath', mapFilePath
	barf jsCode, jsFilePath
	barf sourceMap, mapFilePath
	dbgReturn 'brewFile'
	return

# ---------------------------------------------------------------------------

export removeExtraKeys = (hAST) =>

	removeKeys hAST, words(
		'loc range extra start end',
		'directives comments tokens',
		)
	return hAST

# ---------------------------------------------------------------------------

export astToTAML = (hAST, full=false) =>

	if !full
		removeExtraKeys hAST
	lSortBy = [
		'type'
		'params'
		'body'
		'left'
		'operator'
		'right'
		]
	return toTAML(hAST, {sortKeys: lSortBy})

# ---------------------------------------------------------------------------
# --- Valid options:
#        full - retain all keys
#        format - undef=JS value, else 'taml'

export toAST = (coffeeCode, hOptions={}) ->

	dbgEnter "toAST", coffeeCode
	assert isUndented(coffeeCode), "code has indentation"
	{full, format} = getOptions hOptions, {
		full: false
		format: undef
		}
	try
		hAST = CoffeeScript.compile(coffeeCode, {ast: true})
		assert defined(hAST), "hAST is empty"
	catch err
		LOG "ERROR in CoffeeScript: #{err.message}"
		LOG '-'.repeat(78)
		LOG "#{OL(coffeeCode)}"
		LOG '-'.repeat(78)
		croak "ERROR in CoffeeScript: #{err.message}"


	switch format
		when undef
			if !full
				removeExtraKeys hAST
			ast = hAST
		when 'taml'
			ast = astToTAML hAST, full
		else
			croak "Invalid format"
	dbgReturn "toAST", ast
	return ast

# ---------------------------------------------------------------------------

export toASTFile = (coffeeCode, filePath, hOptions={}) ->

	hAST = toAST(coffeeCode, hOptions)
	barfAST hAST, filePath
	return
