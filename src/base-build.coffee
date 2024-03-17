# base-build.coffee

# --- build this library
# --- NOTE: If this file is modified or deleted, you must execute:
#           npx coffee -cmb --no-header ./src/base-build.coffee
#           npm run build
# --- We want to run low-level-build.js, however that requires:
#        - libraries must be compiled
#        - low-level-build.coffee must be compiled

import {execSync} from 'node:child_process'
import fs from 'node:fs'
import {globSync} from 'glob'

# ---------------------------------------------------------------------------
# --- These 3 functions are duplicates of those in base-utils.coffee
#     however, we can't be sure that has been compiled

export execCmd = (cmdLine) =>

	try
		execSync cmdLine, {
			encoding: 'utf8'
			windowsHide: true
			}
	catch err
		console.log "ERROR: exec of '#{cmdLine}' failed"
		process.exit()
	return

# ---------------------------------------------------------------------------

export withExt = (path, newExt) =>

	if newExt.indexOf('.') != 0
		newExt = '.' + newExt

	if lMatches = path.match(/^(.*)\.[^\.]+$/)
		[_, pre] = lMatches
		return pre + newExt
	console.log "Bad path: '#{path}'"
	process.exit()

# ---------------------------------------------------------------------------

export newerDestFilesExist = (srcPath, lDestPaths...) =>

	for destPath in lDestPaths
		if ! fs.existsSync(destPath)
			return false
		srcModTime = fs.statSync(srcPath).mtimeMs
		destModTime = fs.statSync(destPath).mtimeMs
		if (destModTime < srcModTime)
			return false
	return true

# ---------------------------------------------------------------------------

compile = (filePath) =>

	jsPath = withExt(filePath, '.js')
	mapPath = withExt(filePath, '.js.map')
	if newerDestFilesExist(filePath, jsPath, mapPath)
		return
	console.log filePath.replaceAll('\\', '/')
	execCmd "npx coffee -cmb --no-header #{filePath}"
	return

# ---------------------------------------------------------------------------

console.log "-- base-build --"

# --- Compile all *.coffee files in src/lib
for filePath in globSync('./src/lib/*.coffee')
	compile filePath

# --- Compile low-level-build.coffee
compile "src/bin/low-level-build.coffee"
