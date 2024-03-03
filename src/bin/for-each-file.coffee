`#!/usr/bin/env node
`
# for-each-file.coffee

import {
	undef, defined, notdefined, nonEmpty, LOG, OL, execCmd,
	} from '@jdeighan/base-utils'
import {setDebugging} from '@jdeighan/base-utils/debug'
import {assert} from '@jdeighan/base-utils/exceptions'
import {parseCmdArgs} from '@jdeighan/base-utils/parse-cmd-args'
import {allFilesMatching} from '@jdeighan/base-utils/fs'

debug = false
cmdStr = undef
dir = undef
setDebugging 'allFilesMatching'

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

handleGlob = (glob) =>

	if debug
		LOG "GLOB: #{OL(glob)}"
	hOptions = {
		pattern: glob
		eager: false
		cwd: dir
		}

	for hFile from allFilesMatching(glob, hOptions)
		{filePath} = hFile
		if debug
			LOG "   GLOB FILE: #{OL(filePath)}"
		handleFile(hFile.filePath)
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

# --- NOTE: debug, cmdStr and dir are global vars
{_:lFiles, d:debug, dir, glob, cmd:cmdStr} = hCmdArgs

LOG "Running for-each-file"
if debug
	LOG "DEBUGGING ON"
	LOG 'hCmdArgs', hCmdArgs

if notdefined(dir)
	dir = process.cwd()

# --- First, cycle through all non-options files
#     NOTE: any filename that contains '*' or '?'
#           is treated as a glob

if defined(lFiles)
	for name in lFiles
		if name.includes('*') || name.includes('?')
			handleGlob(name)
		else
			handleFile(name)

# --- Next, use glob if defined

if defined(glob)
	handleGlob(glob)
