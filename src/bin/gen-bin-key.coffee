`#!/usr/bin/env node
`
# gen-bin-key.coffee

import {undef, isEmpty, nonEmpty} from '@jdeighan/base-utils'
import {assert, croak} from '@jdeighan/base-utils/exceptions'
# import {LOG} from '@jdeighan/base-utils/log'
import {
	isFile, isDir, mkpath, rmFileSync, withExt,
	slurp, allFilesIn, slurpJSON, barfJSON,
	} from '@jdeighan/base-utils/fs'

dir = process.cwd()
pkgJsonPath = mkpath(dir, 'package.json')
binDir = mkpath(dir, 'src', 'bin')

LOG = (str) => console.log str

# ---------------------------------------------------------------------------

# 1. Error if current directory has no `package.json` file

assert isFile(pkgJsonPath), "Not in package root dir"
LOG "package.json exists"

# 2. If no ./src/bin dir, exit

if ! isDir(binDir)
	console.log "No #{binDir} dir, exiting"
	process.exit()
LOG "dir #{binDir} exists"

# 3. For every *.coffee file in the 'bin' directory:
#       - error if no corresponding JS file
#       - save stub and filename in hBin
#    For every *.js file in the 'bin' directory:
#       - error if JS file doesn't start with a shebang line

hBin = {}
for hFile from allFilesIn('*.coffee', {cwd: binDir})
	{fileName, filePath, stub} = hFile
	jsFileName = withExt(fileName, '.js')
	jsPath = withExt(filePath, '.js')
	assert isFile(jsPath), "Missing file #{jsFileName}"
	jsCode = slurp jsPath
	assert jsCode.startsWith("#!/usr/bin/env node"), "Missing shebang"

	LOG "FOUND #{fileName}"

	hBin[stub] = "./src/bin/#{jsFileName}"
	LOG "   #{stub} => #{hBin[stub]}"

# 4. Add sub-keys to key 'bin' in package.json (create if not exists)
if isEmpty(hBin)
	LOG "No bin keys to set"
else
	LOG "SET 'bin' key in package.json"
	hJson = slurpJSON pkgJsonPath
	if ! hJson.hasOwnProperty('bin')
		hJson.bin = {}
	for key,value of hBin
		hJson.bin[key] = value
	barfJSON hJson, pkgJsonPath

LOG "DONE"
