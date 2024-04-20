---
shebang: true
---
# gen-parser-libs.coffee

import {
	undef, defined, notdefined, execCmd,
	} from '@jdeighan/base-utils'
import {allFilesMatching, withExt} from '@jdeighan/base-utils/fs'

# ---------------------------------------------------------------------------

for hFile from allFilesMatching('./src/lib/*.peggy')
	{fileName, filePath} = hFile
	execCmd "npx peggy -m --format es --allowed-start-rules * #{filePath}"
	console.log "#{fileName} => #{withExt(fileName, '.js')}"
