# gen-parser-libs.coffee

import {
	undef, defined, notdefined, LOG, execCmd,
	} from '@jdeighan/base-utils'
import {allFilesMatching, withExt} from '@jdeighan/base-utils/fs'

# ---------------------------------------------------------------------------

for hFile from allFilesMatching('./src/lib/*.peggy')
	{fileName, filePath} = hFile
	execCmd "npx peggy -m --format es --allowed-start-rules * #{filePath}"
	LOG "#{fileName} => #{withExt(fileName, '.js')}"
