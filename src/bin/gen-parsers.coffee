`#!/usr/bin/env node
`
# gen-parsers.coffee

import {
	undef, defined, notdefined, LOG, execCmd,
	} from '@jdeighan/base-utils'
import {allFilesIn, withExt} from '@jdeighan/base-utils/fs'

# ---------------------------------------------------------------------------

LOG "Generate parser files"
hOptions = {
	recursive: true
	eager: false
	regexp: /\.peggy$/
	}
for hFile from allFilesIn('./src/grammar', hOptions)
	{fileName, filePath} = hFile
	newName = withExt(fileName, '.js')
	newPath = withExt(filePath, '.js')
	execCmd "peggy -m --format es #{filePath}"
	LOG "#{fileName} => #{newName}"
