---
shebang: true
---
# low-level-build.coffee

import {globSync} from 'glob'

import {
	undef, defined, notdefined, isEmpty, nonEmpty, OL,
	hasKey, execCmd, toBlock, add_s,
	fileExt, withExt, newerDestFilesExist,
	} from '@jdeighan/base-utils'
import {assert} from '@jdeighan/base-utils/exceptions'
import {LOG} from '@jdeighan/base-utils/log'
import {setDebugging} from '@jdeighan/base-utils/debug'
import {
	slurp, barf, isFakeFile,
	isProjRoot, slurpPkgJSON, barfPkgJSON,
	} from '@jdeighan/base-utils/fs'
import {
	readTextFile, allFilesMatching,
	} from '@jdeighan/base-utils/read-file'
import {brew, brewFile} from '@jdeighan/base-utils/coffee'
import {peggifyFile} from '@jdeighan/base-utils/peggy'

hFilesProcessed = {
	coffee: 0
	peggy: 0
	}

console.log "-- low-level-build --"

# ---------------------------------------------------------------------------
# 1. Make sure we're in a project root directory

assert isProjRoot('.', 'strict'), "Not in package root dir"

# ---------------------------------------------------------------------------
# --- A file (either *.coffee or *.peggy) is out of date unless both:
#        - a *.js file exists that's newer than the original file
#        - a *.js.map file exists that's newer than the original file

fileFilter = ({filePath}) =>
	jsFile = withExt(filePath, '.js')
	mapFile = withExt(filePath, '.js.map')
	if (fileExt(filePath) == '.peggy') && isFakeFile(jsFile)
		return true
	return ! newerDestFilesExist(filePath, jsFile, mapFile)

# ---------------------------------------------------------------------------
# 2. Search project for *.coffee files and compile them
#    unless newer *.js and *.js.map files exist

for hFile from allFilesMatching('**/*.coffee', {fileFilter})
	{relPath} = hFile
	LOG relPath
	brewFile relPath
	hFilesProcessed.coffee += 1

# ---------------------------------------------------------------------------
# 3. Search src folder for *.peggy files and compile them
#    unless newer *.js and *.js.map files exist OR it needs rebuilding

for hFile from allFilesMatching('**/*.peggy', {fileFilter})
	{relPath} = hFile
	LOG relPath
	peggifyFile relPath
	hFilesProcessed.peggy += 1

# ---------------------------------------------------------------------------

hBin = {}    # --- keys to add in package.json / bin

# ---------------------------------------------------------------------------
# --- generate a 3 letter acronym if file stub is <str>-<str>-<str>

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
# 4. For every *.coffee file in the 'src/bin' directory that
#       has key "shebang" set:
#       - save <stub>: <jsPath> in hBin
#       - if has a tla, save <tla>: <jsPath> in hBin

for {relPath, stub} from allFilesMatching('./src/bin/**/*.coffee')
	[hMetaData] = readTextFile relPath
	if hMetaData?.shebang
		jsPath = withExt(relPath, '.js')
		hBin[stub] = jsPath
		short_name = tla(stub)
		if defined(short_name)
			hBin[short_name] = jsPath

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
