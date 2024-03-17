# coffee.coffee

import assert from 'node:assert'
import fs from 'fs'
import CoffeeScript from 'coffeescript'

hCoffeeOptions = {
	bare: true
	header: false
	sourceMap: true
	}

# ---------------------------------------------------------------------------

export brew = (coffeeCode, filePath, hOptions={quiet: false}) ->

	assert fs.existsSync(filePath), "Not a file: #{filePath}"
	try
		hCoffeeOptions.filename = filePath
		h = CoffeeScript.compile(coffeeCode, hCoffeeOptions)
		return [h.js.trim(), h.v3SourceMap]
	catch err
		console.log "ERROR: #{err.message}"
		return [undefined, undefined]
