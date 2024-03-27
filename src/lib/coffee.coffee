# coffee.coffee

import fs from 'fs'
import CoffeeScript from 'coffeescript'

import {
	undef, defined, notdefined, getOptions, toBlock,
	OL, words, removeKeys,
	} from '@jdeighan/base-utils'
import {
	assert, croak,
	} from '@jdeighan/base-utils/exceptions'
import {
	dbgEnter, dbgReturn, dbg,
	} from '@jdeighan/base-utils/debug'
import {isUndented} from '@jdeighan/base-utils/indent'
import {toTAML} from '@jdeighan/base-utils/taml'
import {barf, barfAST} from '@jdeighan/base-utils/fs'

# ---------------------------------------------------------------------------

export brew = (coffeeCode, filePath=undef) ->

	coffeeCode = toBlock(coffeeCode)  # allow passing array
	if defined(filePath)
		assert fs.existsSync(filePath), "Not a file: #{filePath}"
		h = CoffeeScript.compile(coffeeCode, {
			bare: true
			header: false
			filename: filePath
			sourceMap: true
			filename: undef     # must be filled in
			})
		jsCode = h.js
		assert defined(jsCode), "No JS code generated"
		return [jsCode.trim(), h.v3SourceMap]
	else
		jsCode = CoffeeScript.compile(coffeeCode, {
			bare: true
			header: false
			sourceMap: false
			})
		assert defined(jsCode), "No JS code generated"
		return [jsCode.trim(), undef]

# ---------------------------------------------------------------------------

export brewFile = (filePath) ->

	{hMetaData, lLines} = readTextFile(filePath)
	[jsCode, sourceMap] = brew lLines, filePath
	barf jsCode, withExt(filePath, '.js')
	barf sourceMap, withExt(filePath, '.js.map')
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
