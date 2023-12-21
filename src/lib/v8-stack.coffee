# v8-stack.coffee

import pathLib from 'node:path'
import fs from 'fs'

import {
	undef, defined, notdefined, assert,
	isEmpty, nonEmpty,
	} from '@jdeighan/base-utils/ll-utils'
import {mydir} from '@jdeighan/base-utils/ll-fs'
import {
	OL, isIdentifier, isFunctionName, getOptions,
	} from '@jdeighan/base-utils'
import {mapSourcePos} from '@jdeighan/base-utils/source-map'
import {
	nodeStr, getV8Stack, getMyDirectCaller, getMyOutsideCaller,
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

export getV8StackStr = (hOptions={}) =>

	lStack = await getV8Stack(hOptions)
	lParts = for hNode in lStack
		nodeStr(hNode)
	return lParts.join("\n")
