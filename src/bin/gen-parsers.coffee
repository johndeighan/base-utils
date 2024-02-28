`#!/usr/bin/env node
`
# gen-parsers.coffee

import {
	undef, defined, notdefined, LOG, execCmd,
	} from '@jdeighan/base-utils'
import {allFilesIn, withExt} from '@jdeighan/base-utils/fs'

DEBUG = false

# ---------------------------------------------------------------------------

execCmd "npx peggy -m --format es src/lib/cmd-args.peggy"
execCmd "npx peggy -m --format es src/lib/pll-parser.peggy"

# ---------------------------------------------------------------------------

oldcode = () =>

	hOptions = {
		pattern: '**/*.peggy'
		}
	for hFile from allFilesIn('./src/**/*.peggy')
		{fileName, filePath} = hFile
		newName = withExt(fileName, '.js')
		newPath = withExt(filePath, '.js')
		execCmd "peggy -m --format es --allowed-start-rules * #{filePath}"
		if DEBUG
			LOG "#{filePath} => #{newName}"
