# FileProcessor.coffee

import {globSync as glob} from 'glob'

import {
	undef, defined, notdefined, getOptions, add_s,
	isString, isHash, toJSON,
	hasKey, hasAnyKey, addNewKey, toBlock, toArray,
	} from '@jdeighan/base-utils'
import {toTAML} from '@jdeighan/base-utils/taml'
import {assert, croak} from '@jdeighan/base-utils/exceptions'
import {
	mkpath, mkDir, pathType, parsePath, subPath,
	allLinesIn, slurp, barf, isFile,
	} from '@jdeighan/base-utils/fs'
import {
	dbgEnter, dbgReturn, dbg,
	} from '@jdeighan/base-utils/debug'
import {indented} from '@jdeighan/base-utils/indent'

# ---------------------------------------------------------------------------

export class FileProcessor

	constructor: (@path, @pattern='*', hOptions={}) ->
		# --- path can be a file or directory
		#     if it's a file, then pattern and hGlobOptions are ignored
		# --- Valid options
		#        allowOverwrite - allow overwrite of original files
		#        hGlobOptions - options to pass to glob()
		# --- Valid glob options:
		#        ignore - glob pattern for files to ignore
		#        dot - include dot files/directories (default: false)

		dbgEnter 'FileProcessor', @path, @pattern, hOptions
		assert isString(@path), "path not a string"
		@hOptions = getOptions hOptions, {
			allowOverwrite: false
			hGlobOptions: getOptions hOptions.hGlobOptions, {
				absolute: true
				cwd: @path
				dot: false
				}
			}

		# --- determine type of path
		@path = mkpath @path       # --- convert to full path
		@pathType = pathType @path
		dbg "path #{@path} is a #{@pathType}"
		if (@pathType == 'dir')
			@hGlobOptions = hOptions.hGlobOptions
		else if (@pathType != 'file')
			croak "invalid path '#{@path}'"

		@lUserData = []  # --- filled in by readAll()
		dbgReturn 'FileProcessor'

	# ..........................................................

	getUserData: () ->

		return @lUserData

	# ..........................................................

	getSortedUserData: () ->

		compareFunc = (a, b) =>
			if (a.filePath < b.filePath)
				return -1
			else if (a.filePath > b.filePath)
				return 1
			else
				return 0

		return @lUserData.toSorted(compareFunc)

	# ..........................................................

	dumpdata: (h) ->

		dbgEnter 'dumpdata', h
		taml = toTAML(h, '!useTabs !useDashes indent=1')
		console.log taml
		dbgReturn 'dumpdata'
		return

	# ..........................................................

	dumpUserData: (format='nice') ->
		# --- formats: 'nice', 'json', 'taml'

		dbgEnter 'dumpUserData', format
		switch format.toLowerCase()
			when 'nice'
				for h in @lUserData
					{fileName} = parsePath(h.filePath)
					dbg "dump info for file '#{fileName}'"
					str = '-'.repeat(10)
					console.log "#{str} #{fileName} #{str}"
					@dumpdata(h)
			when 'json'
				console.log toJSON(@lUserData, '!useTabs')
			when 'taml'
				console.log toTAML(@lUserData, '!useTabs')
			else
				croak "Bad format: #{format}"
		dbgReturn 'dumpUserData'
		return

	# ..........................................................

	readAll: () ->

		dbgEnter 'readAll'
		dbg "pathType = #{@pathType}"
		numFiles = 0
		switch @pathType

			when 'file'
				hFile = parsePath(@path)
				if @filterFile @path
					dbg "[#{numFiles}] #{hFile.fileName} - Handle"
					h = @handleFile @path
					if defined(h)
						assert isHash(h), "handleFile() returned non-hash"
						addNewKey h, 'filePath', hFile.filePath
						@lUserData.push h
					numFiles += 1
				else
					dbg "[#{numFiles}] #{hFile.fileName} - Skip"

			when 'dir'
				dbg "pattern = '#{@pattern}'"
				dbg 'hGlobOptions', @hGlobOptions
				for filePath in glob(@pattern, @hGlobOptions)
					if isFile(filePath)
						dbg "filePath = '#{filePath}'"
						hFile = parsePath filePath
						if @filterFile filePath
							dbg "[#{numFiles}] #{filePath} - Handle"
							h = @handleFile filePath
							if defined(h)
								assert isHash(h), "handleFile() returned non-hash"
								addNewKey h, 'filePath', filePath
								@lUserData.push h
							numFiles += 1
						else
							dbg "[#{numFiles}] #{hFile.fileName} - Skip"

		dbg "#{numFiles} file#{add_s(numFiles)} processed"
		dbgReturn 'readAll', @lUserData
		return @lUserData

	# ..........................................................

	filterFile: (filePath) ->

		dbgEnter 'filterFile', filePath
		dbgReturn 'filterFile'
		return true    # by default, handle all files in dir

	# ..........................................................

	handleFile: (filePath) ->
		# --- does nothing, returns nothing

		dbgEnter 'handleFile', filePath
		dbgReturn 'handleFile'
		return

	# ..........................................................

	writeAll: () ->

		# --- Cycle through @lUserData, rewriting files as needed
		#     Items in @lUserData are hashes with key 'filePath'
		#        and whatever was returned from @handleFile()

		for hUserData in @lUserData
			newpath = @writeFileTo hUserData
			if defined(newpath)
				@writeFile newpath, hUserData
		return

	# ..........................................................
	# SHOULD OVERRIDE if you want to write files anywhere
	#    other than the default 'temp' subfolder
	#
	# --- return undef to not write this file

	writeFileTo: (hUserData) ->

		# --- by default, write to a parallel directory
		return subPath hUserData.filePath, 'temp'

	# ..........................................................
	# --- SHOULD OVERRIDE if you intend to write files

	writeFile: (path, hUserData) ->
		# --- path may be a new path

		return    # by default, does nothing

# ---------------------------------------------------------------------------

export class LineProcessor extends FileProcessor

	dumpdata: (hUserData) ->

		{lineNum, lLines} = hUserData
		console.log "LINE #{lineNum}:"
		console.log toTAML(lLines)
		return

	# ..........................................................

	handleFile: (filePath) ->

		dbgEnter 'handleFile', filePath
		assert isString(filePath), "not a string"
		lLines = []   # --- array of hashes
		lineNum = 1
		for line from allLinesIn(filePath)
			dbg "LINE: '#{line}'"

			# --- handleLine should return undef to ignore line
			#     otherwise, a hash which:
			#        cannot contain key 'lineNum'
			#        may contain keys:
			#           newLine - to later overwrite the line
			#           delete - to later delete the line

			h = @handleLine line, lineNum, filePath
			if defined(h)
				dbg "returned by handleLine()", h
				addNewKey h, 'lineNum', lineNum
				lLines.push h
			else
				dbg "line '#{line}' ignored"
			lineNum += 1
		result = {lLines}
		dbgReturn 'handleFile', result
		return result

	# ..........................................................
	# --- SHOULD OVERRIDE, to save data for a given line

	handleLine: (line, lineNum, filePath) ->

		return   # by default, returns nothing

	# ..........................................................

	writeFile: (newPath, hUserData) ->

		dbgEnter 'writeFile', newPath, hUserData
		{lLines, filePath} = hUserData

		if ! @hOptions.allowOverwrite
			assert (newPath != filePath), "Attempt to write org file"

		lOutput = []
		for hLine in lLines
			text = @writeLine hLine
			if defined(text)
				assert isString(text), "text not a string"
				lOutput.push text

		# --- Now write out the text in lOutput
		if (lOutput.length > 0)
			barf toBlock(lOutput), newPath
		dbgReturn 'writeFile'
		return

	# ..........................................................
	# --- SHOULD OVERRIDE, to write data for a given line

	writeLine: (hLine) ->

		return    # --- by default, returns nothing
