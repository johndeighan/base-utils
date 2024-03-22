# coffee.coffee

import assert from 'node:assert'
import fs from 'fs'
import CoffeeScript from 'coffeescript'

import {undef, defined, getOptions, toBlock} from '@jdeighan/base-utils'

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
