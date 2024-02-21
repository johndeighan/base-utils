`#!/usr/bin/env node
`
# gen-parsers.coffee

import {
	undef, defined, notdefined, LOG,
	} from '@jdeighan/base-utils'
import {allFilesIn} from '@jdeighan/base-utils/fs'

# ---------------------------------------------------------------------------

LOG "You are running the gen-parsers script"
hOptions = {
	recursive: true
	eager: false
	regexp: /\.peggy$/
	}
for hFile from allFilesIn('./src/grammar')
	LOG hFile.fileName
	execCmd "peggy --format es #{hFile.filePath}"
