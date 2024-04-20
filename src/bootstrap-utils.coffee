# bootstrap-utils.coffee

import assertLib from 'node:assert'
import {execSync} from 'node:child_process'
import fs from 'node:fs'
import {globSync} from 'glob'
import NReadLines from 'n-readlines'
import YAML from 'yaml'
import CoffeeScript from 'coffeescript'

`const undef = void 0`

# ---------------------------------------------------------------------------
# low-level version of assert()

export assert = (cond, msg) =>

	assertLib.ok cond, msg
	return true

# ---------------------------------------------------------------------------
# These are duplicates of standard functions
# However, when starting with a clean stalte, we can't be sure
#    that the standard libraries have been compiled, so
#    we start with these

export brewFile = (filePath) =>

	jsPath = withExt(filePath, '.js')
	mapPath = withExt(filePath, '.js.map')
	if newerDestFilesExist(filePath, jsPath, mapPath)
		return

	# --- define getLine() to read line by line
	nReader = new NReadLines(filePath)
	getLine = () =>
		buffer = nReader.next()
		if (buffer == false)
			nReader = undef   # prevent further reads
			return undef
		result = buffer.toString().replaceAll('\r', '')
		if (result == '__END__')
			return undef
		return result

	firstLine = getLine()

	shebang = undef

	# --- fetch any metadata
	if (firstLine == '---')
		lYaml = []
		line = getLine()
		while (line != '---')
			lYaml.push line
			line = getLine()
		hMetaData = YAML.parse lYaml.join("\n")
		shebang = hMetaData.shebang
		if (shebang == true)
			shebang = "#!/usr/bin/env node"

	if (firstLine == '---')
		lLines = []
	else
		lLines = [firstLine]

	line = getLine()
	while (line != undef) && (line != '__END__')
		lLines.push line
		line = getLine()

	coffeeCode = lLines.join("\n")
	{js, v3SourceMap} = CoffeeScript.compile coffeeCode, {
		bare: true
		header: false
		sourceMap: true
		filename: filePath
		}
	if (shebang == undef)
		fs.writeFileSync(jsPath, js)
	else
		fs.writeFileSync(jsPath, shebang + "\n" + js)
	fs.writeFileSync(mapPath, v3SourceMap)

	console.log filePath.replaceAll('\\', '/')
	return

# ---------------------------------------------------------------------------

export fileExt = (filePath) =>

	if lMatches = filePath.match(/\.[^\.]+$/)
		return lMatches[0]
	else
		return ''

# ---------------------------------------------------------------------------

export withExt = (filePath, newExt) =>

	if newExt.indexOf('.') != 0
		newExt = '.' + newExt

	if lMatches = filePath.match(/^(.*)\.[^\.]+$/)
		[_, pre] = lMatches
		return pre + newExt
	throw new Error("Bad path: '#{filePath}'")

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

export execCmd = (cmdLine) =>

	execSync cmdLine, {
		encoding: 'utf8'
		windowsHide: true
		}
	return

# ---------------------------------------------------------------------------
# --- convert \ to /
#     convert "C:..." to "c:..."

export normalize = (filePath) =>

	filePath = filePath.replaceAll '\\', '/'
	if (filePath.charAt(1) == ':')
		return filePath.charAt(0).toLowerCase() + filePath.substring(1)
	else
		return filePath

# ---------------------------------------------------------------------------

export isFakeFile = (filePath) =>

	return false

# ---------------------------------------------------------------------------

export createFakeFiles = () =>

	for filePath in globSync('./src/{bin,lib}/*.peggy')
		destPath = withExt(filePath, '.js')
		if ! fs.existsSync(destPath)
			console.log normalize(destPath) + ' (fake)'
			fs.writeFileSync(destPath, """
				// fake
				export function parse(str) {
					throw new Error("Attempt to use fake peggy file #{destPath}");
					}
				""")
	return
