# bootstrap.coffee

# --- NOTE: CoffeeScript must be installed globally and locally

# --- We want to run low-level-build.js,
#     however that requires:
#        - src/lib .coffee files must be compiled
#        - src/bin/low-level-build.coffee must be compiled
#        - some fake JS files, corresponding to peggy files, must exist

import {globSync} from 'glob'
import {
	brewFile, withExt, normalize, createFakeFiles,
	} from './bootstrap-utils.js'

# ---------------------------------------------------------------------------
# --- Compile all coffee files in src/lib and src/bin

console.log "-- bootstrap --"

try
	# --- Compile all *.coffee files in src/lib
	for filePath in globSync('./src/lib/*.coffee')
		brewFile filePath

	# --- Compile src/bin/low-level-build.coffee
	brewFile './src/bin/low-level-build.coffee'

	# --- Create fake *.js file for each *.peggy file
	#     These will be rebuilt in low-level-build.coffee

	createFakeFiles()

catch err
	console.error err
	process.exit()

