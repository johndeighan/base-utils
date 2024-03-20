# gen-parser-libs.coffee

import {
	undef, defined, notdefined, execCmd,
	} from '@jdeighan/base-utils'
import {LOG} from '@jdeighan/base-utils/log'
import {allFilesMatching, withExt} from '@jdeighan/base-utils/fs'

# ---------------------------------------------------------------------------

for hFile from allFilesMatching('./src/lib/*.peggy')
	{fileName, filePath} = hFile
	execCmd "npx peggy -m --format es --allowed-start-rules * #{filePath}"
	LOG "#{fileName} => #{withExt(fileName, '.js')}"
