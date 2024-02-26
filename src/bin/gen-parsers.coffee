`#!/usr/bin/env node
`
# gen-parsers.coffee

import {
	undef, defined, notdefined, LOG, execCmd,
	} from '@jdeighan/base-utils'
import {allFilesIn, withExt} from '@jdeighan/base-utils/fs'

DEBUG = false

# ---------------------------------------------------------------------------

hOptions = {
	pattern: '**/*.peggy'
	}
for hFile from allFilesIn('./src/**/*.peggy')
	{fileName, filePath} = hFile
	newName = withExt(fileName, '.js')
	newPath = withExt(filePath, '.js')
	execCmd "peggy -m --format es #{filePath}"
	if DEBUG
		LOG "#{filePath} => #{newName}"
