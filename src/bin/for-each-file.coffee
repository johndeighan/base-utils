`#!/usr/bin/env node
`
# for-each-file.coffee

import {
	undef, defined, notdefined, nonEmpty, LOG, execCmd,
	} from '@jdeighan/base-utils'
import {assert} from '@jdeighan/base-utils/exceptions'
import {parseCmdArgs} from '@jdeighan/base-utils/parse-cmd-args'
import {allFilesIn} from '@jdeighan/base-utils/fs'

debug = false
cmdStr = undef

# ---------------------------------------------------------------------------

handleFile = (filePath) =>

	if debug
		if defined(cmdStr)
			cmd = cmdStr.replaceAll('<file>', filePath)
			LOG "CMD: #{cmd}"
		else
			LOG "FILE: #{filePath}"
	else
		cmd = cmdStr.replaceAll('<file>', filePath)
		execCmd cmd
	return

# ---------------------------------------------------------------------------
# --- Usage:
#    for-each-file *.coffee -cmd="coffee -cm <file>"

hCmdArgs = parseCmdArgs({
	hExpect: {
		_: [0,Number.MAX_VALUE]
		d: 'boolean'     # debug mode - don't exec, just print
		dir: 'string'    # dir to search in, def = current dir
		glob: 'string'
		cmd: 'string'    # command to run (replace '<file>')
		}
	})

# --- NOTE: debug and cmdStr are global vars
{_:lFiles, d:debug, dir, glob, cmd:cmdStr} = hCmdArgs

LOG "Running for-each-file"
if debug
	LOG "DEBUGGING ON"
	LOG 'hCmdArgs', hCmdArgs

if notdefined(dir)
	dir = process.cwd()

# --- First, cycle through all non-options files

for filePath in lFiles
	handleFile(filePath)

# --- Next, use glob if defined

if defined(glob)
	hOptions = {
		pattern: glob
		eager: false
		}

	for hFile from allFilesIn(dir, hOptions)
		handleFile(hFile.filePath)
