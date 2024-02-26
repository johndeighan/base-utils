`#!/usr/bin/env node
`
# for-each-file.coffee

import {
	undef, defined, notdefined, nonEmpty, LOG, execCmd,
	} from '@jdeighan/base-utils'
import {assert} from '@jdeighan/base-utils/exceptions'
import {parseCmdArgs} from '@jdeighan/base-utils/parse-cmd-args'
import {allFilesIn} from '@jdeighan/base-utils/fs'

# ---------------------------------------------------------------------------
# --- Usage:
#    for-each-file *.coffee -cmd="coffee -cm <file>"

hCmdArgs = parseCmdArgs({
	hExpect: {
		_: [0,1]
		d: 'boolean'
		dir: 'string'    # dir to search in, def = current dir
		cmd: 'string'    # command to run (replace '<file>')
		}
	})

console.log "Running bin for-each-file"

{dir, cmd:cmdStr, d:debug} = hCmdArgs
if debug
	LOG "DEBUGGING ON"
assert nonEmpty(cmdStr), "Missing or empty command"
if notdefined(dir)
	dir = process.cwd()
pattern = hCmdArgs._[0]    # might be undef

hOptions = {
	pattern
	eager: false
	}

for hFile from allFilesIn(dir, hOptions)
	{fileName, filePath} = hFile
	cmd = cmdStr.replaceAll('<file>', filePath)
	if debug
		LOG "CMD: #{cmd}"
	else
		execCmd cmd
