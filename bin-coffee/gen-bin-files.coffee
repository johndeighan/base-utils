# gen-bin-files.coffee

import {assert, croak} from '@jdeighan/base-utils/exceptions'
import {
	isFile, isDir, mkpath, mkdirSync,
	slurp, barf, forEachFileInDir, brew,
	} from '@jdeighan/base-utils/fs'

# ---------------------------------------------------------------------------

# 1. Error if current directory has no `package.json` file

dir = process.cwd()
assert isFile("#{dir}/package.json"), "Not in package root dir"

# 2. If no bin-coffee/ dir, exit

coffeeDir = "#{dir}\\bin-coffee"
if ! isDir(coffeeDir)
	console.log "Missing directory #{coffeeDir}"
	process.exit()

# 3. Create a `bin` folder if it doesn't already exist

binDir = "#{dir}\\bin"
if ! isDir(binDir)
	mkdirSync binDir

# 4. For every *.coffee file in the `bin-coffee` directory:
#       - Compile to a JS file
#       - Add a shebang line to the JS
#       - Write the JS file to the `bin` folder
#       - Strip off the file extension

forEachFileInDir coffeeDir, (fname) =>
	if lMatches = fname.match(/// ^ (.*) \.coffee $ ///)
		[_, stub] = lMatches
		console.log "bin-coffee/#{fname} => bin/#{stub}"
		coffeeCode = slurp mkpath(coffeeDir, fname)
		jsCode = brew(coffeeCode, {shebang: true})
		barf mkpath(binDir, stub), jsCode

console.log "DONE"
