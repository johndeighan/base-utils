# v8-stack.coffee

import pathLib from 'node:path'
import fs from 'fs'

import {
	undef, defined, notdefined, assert, mydir,
	isEmpty, nonEmpty,
	} from '@jdeighan/base-utils/ll-utils'
import {
	OL, isIdentifier, isFunctionName, getOptions,
	} from '@jdeighan/base-utils'
import {mapSourcePos} from '@jdeighan/base-utils/source-map'
import {
	getV8Stack, getMyDirectCaller, getMyOutsideCaller,
	} from '@jdeighan/base-utils/ll-v8-stack'

export {getV8Stack, getMyDirectCaller, getMyOutsideCaller}

export internalDebugging = false
dir = mydir(import.meta.url)    # directory this file is in

# ---------------------------------------------------------------------------

export debugV8Stack = (flag=true) =>

	internalDebugging = flag
	return

# ---------------------------------------------------------------------------

export isFile = (filePath) =>

	try
		result = fs.lstatSync(filePath).isFile()
		return result
	catch err
		return false

# ---------------------------------------------------------------------------

export nodeStr = (hNode) =>

	{type, fileName, line, column} = hNode
	return "#{type} at #{fileName}:#{line}:#{column}"

# ---------------------------------------------------------------------------

export getV8StackStr = (hOptions={}) =>

	lStack = await getV8Stack(hOptions)
	lParts = for hNode in lStack
		nodeStr(hNode)
	return lParts.join("\n")

# ---------------------------------------------------------------------------

export shorten = (line) =>

	if isEmpty(line)
		return ''
	root = getRoot()
	if isEmpty(root)
		return line
	pos = line.indexOf(root)
	if (pos == -1)
		return line
	else
		return line.replace(root, 'ROOT')

# ---------------------------------------------------------------------------

export getRoot = () =>

	# --- Alternatively, we could search up in the directory tree
	#     for the directory that contains 'package.json'

	result = process.env.ProjectRoot
	if isEmpty(result)
		return undef
	else
		return result

