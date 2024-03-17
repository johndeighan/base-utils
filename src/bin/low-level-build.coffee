# low-level-build.coffee

import {
	undef, defined, notdefined, isEmpty, nonEmpty, LOG, OL,
	hasKey, execCmd, toBlock, add_s,
	} from '@jdeighan/base-utils'
import {assert} from '@jdeighan/base-utils/exceptions'
import {
	withExt, newerDestFilesExist, allFilesMatching,
	slurp, barf, isProjRoot, slurpPkgJSON, barfPkgJSON,
	} from '@jdeighan/base-utils/fs'
import {brew} from '@jdeighan/base-utils/coffee'
import {peggify} from '@jdeighan/base-utils/peggy'

hFilesProcessed = {
	coffee: 0
	peggy: 0
	js: 0
	}

numCoffee = process.argv[2]
if (numCoffee && numCoffee.match(/^\d+$/))
	hFilesProcessed.coffee += parseInt(numCoffee)

console.log "-- low-level-build --"

# ---------------------------------------------------------------------------
# 1. Make sure we're in a project root directory

assert isProjRoot('strict'), "Not in package root dir"

# ---------------------------------------------------------------------------
# --- A file (either *.coffee or *.peggy) is out of date unless both:
#        - a *.js file exists that's newer than the original file
#        - a *.js.map file exists that's newer than the original file

fileFilter = ({filePath}) =>
	jsFile = withExt(filePath, '.js')
	mapFile = withExt(filePath, '.js.map')
	return ! newerDestFilesExist(filePath, jsFile, mapFile)

# ---------------------------------------------------------------------------
# 2. Search project for *.coffee files and compile them
#    unless newer *.js and *.js.map files exist

hOptions = {
	fileFilter
	eager: true
	}

for hFile from allFilesMatching('**/*.coffee', hOptions)
	{filePath, relPath, metadata, lLines} = hFile
	LOG relPath
	hFilesProcessed.coffee += 1
	[jsCode, sourceMap] = brew toBlock(lLines), relPath
	barf jsCode, withExt(filePath, '.js')
	barf sourceMap, withExt(filePath, '.js.map')

# ---------------------------------------------------------------------------
# 3. Search project for *.peggy files and compile them
#    unless newer *.js and *.js.map files exist

for hFile from allFilesMatching('**/*.peggy', hOptions)
	{filePath, relPath, metadata, lLines} = hFile
	LOG relPath
	hFilesProcessed.peggy += 1
	[jsCode, sourceMap] = peggify toBlock(lLines), relPath
	barf jsCode, withExt(filePath, '.js')
	barf sourceMap, withExt(filePath, '.js.map')

# ---------------------------------------------------------------------------

shebang = "#!/usr/bin/env node"
hBin = {}    # --- keys to add in package.json / bin

tla = (stub) =>

	if lMatches = stub.match(///^
			([a-z])(?:[a-z]*)
			\-
			([a-z])(?:[a-z]*)
			\-
			([a-z])(?:[a-z]*)
			$///)
		[_, a, b, c] = lMatches
		result = a + b + c
		return result
	else
		return undef

# ---------------------------------------------------------------------------
# 4. For every *.js file in the 'src/bin' directory:
#       - add shebang line if missing
#       - save <stub>: <path> in hBin

hOptions = {
	fileFilter: ({metadata, lLines}) =>
		assert notdefined(metadata), "metadata in bin *.js file"
		if (lLines.length == 0)
			return false
		return (lLines[0] != shebang)
	eager: true    # --- h will have keys metadata and lLines
	}

for h from allFilesMatching('./src/bin/**/*.js', hOptions)
	{filePath, relPath, stub, lLines} = h
	LOG "#{relPath} -> add shebang line"
	hFilesProcessed.js += 1
	contents = shebang + "\n" + toBlock(lLines)
	barf contents, filePath

	hBin[stub] = relPath
	short_name = tla(stub)
	if defined(short_name)
		hBin[short_name] = relPath

# ---------------------------------------------------------------------------
# 5. Add sub-keys to key 'bin' in package.json
#    (create if not exists)

if nonEmpty(hBin)
	hJson = slurpPkgJSON()
	if ! hasKey(hJson, 'bin')
		LOG "   - add key 'bin'"
		hJson.bin = {}
	for key,value of hBin
		if (hJson.bin[key] != value)
			LOG "   - add bin/#{key} = #{value}"
			hJson.bin[key] = value
	barfPkgJSON hJson

nCoffee = hFilesProcessed.coffee
if (nCoffee > 0)
	console.log "(#{nCoffee} coffee file#{add_s(nCoffee)} compiled)"

nPeggy = hFilesProcessed.peggy
if (nPeggy > 0)
	console.log "(#{nPeggy} peggy file#{add_s(nPeggy)} compiled)"

nJS = hFilesProcessed.js
if (nJS > 0)
	console.log "(#{nJS} js file#{add_s(nJS)} had shebang line added)"
