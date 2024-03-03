`#!/usr/bin/env node
`
# gen-parsers.coffee

import {
	undef, defined, notdefined, LOG, execCmd,
	} from '@jdeighan/base-utils'
import {allFilesMatching, withExt} from '@jdeighan/base-utils/fs'

DEBUG = false

# ---------------------------------------------------------------------------

execCmd "npx peggy -m --format es src/lib/cmd-args.peggy"
execCmd "npx peggy -m --format es src/lib/pll-parser.peggy"

# ---------------------------------------------------------------------------

oldcode = () =>

	hOptions = {
		pattern: '**/*.peggy'
		}
	for hFile from allFilesMatching('./src/**/*.peggy')
		{fileName, filePath} = hFile
		newName = withExt(fileName, '.js')
		newPath = withExt(filePath, '.js')
		execCmd "peggy -m --format es --allowed-start-rules * #{filePath}"
		if DEBUG
			LOG "#{filePath} => #{newName}"
