# gen-bin-files.coffee

import {nonEmpty} from '@jdeighan/base-utils'
import {assert, croak} from '@jdeighan/base-utils/exceptions'
import {
	isFile, isDir, mkpath, mkdirSync,
	slurp, barf, forEachFileInDir, brew,
	slurpJson, barfJson,
	} from '@jdeighan/base-utils/fs'

# ---------------------------------------------------------------------------

# 1. Error if current directory has no `package.json` file

dir = process.cwd()
pkgJsonPath = mkpath(dir, 'package.json')
assert isFile(pkgJsonPath), "Not in package root dir"

# 2. If no bin/ dir, exit

binDir = "#{dir}\\bin"
if ! isDir(binDir)
	console.log "Missing directory #{binDir}"
	process.exit()

# 4. For every *.coffee file in the `bin` directory:
#       - error if no corresponding JS file
#       - save stub and filename in hBin
#    For every *.js file
#       - add a shebang line if not already there

hBin = {}
forEachFileInDir binDir, (fname) =>
	if lMatches = fname.match(/// ^ (.*) \. (coffee | js) $ ///)
		[_, stub, ext] = lMatches
		jsFileName = "#{stub}.js"
		jsPath = mkpath(dir, 'bin', jsFileName)
		switch ext
			when 'coffee'
				assert isFile(jsPath), "Missing file #{jsPath}"
				hBin[stub] = "./bin/#{jsFileName}"
			when 'js'
				jsCode = slurp jsPath
				if ! jsCode.startsWith("#!/usr/bin/env node")
					barf jsPath, "#!/usr/bin/env node\n" + jsCode

# 5. Add sub-keys to key 'bin' in package.json (create if not exists)
if nonEmpty(hBin)
	hJson = slurpJson pkgJsonPath
	if ! hJson.hasOwnProperty('bin')
		hJson.bin = {}
	for key,value of hBin
		hJson.bin[key] = value
	barfJson pkgJsonPath, hJson

console.log "DONE"
