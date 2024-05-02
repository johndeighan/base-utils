# file-processor.coffee

import {globSync as glob} from 'glob'

import {
	undef, defined, notdefined, getOptions, add_s, isEmpty, nonEmpty,
	isString, isHash, toJSON, jsType, OL,
	hasKey, hasAnyKey, addNewKey, toBlock, toArray,
	sortedArrayOfHashes,
	} from '@jdeighan/base-utils'
import {toTAML} from '@jdeighan/base-utils/taml'
import {assert, croak} from '@jdeighan/base-utils/exceptions'
import {
	mkpath, mkDir, pathType, parsePath, subPath,
	slurp, barf, isFile,
	} from '@jdeighan/base-utils/fs'
import {
	allFilesMatching, readTextFile,
	} from '@jdeighan/base-utils/read-file'
import {
	dbgEnter, dbgReturn, dbg,
	} from '@jdeighan/base-utils/debug'
import {indented} from '@jdeighan/base-utils/indent'

# ---------------------------------------------------------------------------

export class FileProcessor

	constructor: (@pattern=undef, hOptions={}) ->
		# --- pattern is a glob pattern
		#     if pattern is undef, use process.cwd() + "/*"
		# --- Valid options
		#        allowOverwrite - allow overwrite of original files
		#        hGlobOptions - options to pass to glob()
		#        eager - include content of files in hFile
		# --- Valid glob options:
		#        ignore - glob pattern for files to ignore
		#        dot - include dot files/directories (default: false)
		#        cwd - change working directory

		dbgEnter 'FileProcessor', @pattern, hOptions
		@hOptions = getOptions hOptions, {
			allowOverwrite: false
			eager: false
			hGlobOptions: {}
			}

		@lUserData = []  # --- filled in by readAll()
		dbgReturn 'FileProcessor'

	# ..........................................................

	getUserData: () ->

		return @lUserData

	# ..........................................................

	getSortedUserData: () ->

		return sortedArrayOfHashes(@lUserData, 'filePath')

	# ..........................................................

	dumpdata: (h) ->

		dbgEnter 'FileProcessor.dumpdata', h
		taml = toTAML(h, '!useTabs !useDashes indent=1')
		console.log taml
		dbgReturn 'FileProcessor.dumpdata'
		return

	# ..........................................................

	dumpUserData: (format='nice') ->
		# --- formats: 'nice', 'json', 'taml'

		dbgEnter 'FileProcessor.dumpUserData', format
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
		dbgReturn 'FileProcessor.dumpUserData'
		return

	# ..........................................................

	readAll: () ->

		dbgEnter 'FileProcessor.readAll'
		numFiles = 0

		hOptions = {
			hGlobOptions: @hOptions.hGlobOptions
			eager: @hOptions.eager
			}
		dbg "Find files matching #{OL(@pattern)}"
		if nonEmpty(hOptions)
			dbg 'hOptions', hOptions
		for hFile from allFilesMatching(@pattern, hOptions)
			{filePath} = hFile
			if @filterFile hFile
				dbg "[#{numFiles}] #{filePath} - Handle"
				h = @handleFile @transformFile(hFile)
				if defined(h)
					assert isHash(h), "handleFile() returned non-hash"
					addNewKey h, 'filePath', filePath
					@lUserData.push h
				numFiles += 1
			else
				dbg "[#{numFiles}] #{hFile.fileName} - Skip"

		dbg "#{numFiles} file#{add_s(numFiles)} processed"
		dbgReturn 'FileProcessor.readAll', @lUserData
		return @lUserData

	# ..........................................................

	transformFile: (hFile) ->

		return hFile

	# ..........................................................

	filterFile: (hFile) ->

		dbgEnter 'FileProcessor.filterFile', hFile
		dbgReturn 'FileProcessor.filterFile', true
		return true    # by default, handle all files in dir

	# ..........................................................

	handleFile: (hFile) ->
		# --- does nothing, returns nothing

		dbgEnter 'FileProcessor.handleFile', hFile.fileName
		dbgReturn 'FileProcessor.handleFile'
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

		{lineNum, lRecipe} = hUserData
		console.log "LINE #{lineNum}:"
		console.log toTAML(lRecipe)
		return

	# ..........................................................

	handleMetaData: (hMetaData) ->

		return    # --- by default, does nothing

	# ..........................................................

	handleFile: (hFile) ->

		dbgEnter 'LineProcessor.handleFile', hFile.fileName
		{filePath} = hFile
		assert isString(filePath), "not a string: #{OL(filePath)}"
		lRecipe = []   # --- array of hashes
		numLines = 0
		fileChanged = false

		addToRecipe = (item, orgLine) =>
			switch jsType(item)[0]
				when 'string'
					lRecipe.push item
					if (item == orgLine)
						dbg "RECIPE: '#{item}'"
					else
						fileChanged = true
						dbg "RECIPE: '#{item}' - changed"
				when 'hash'
					fileChanged = true
					addNewKey item, 'lineNum', numLines
					dbg "RECIPE:", item
					lRecipe.push item
				when 'array'
					fileChanged = true
					for subitem in item
						addToRecipe subitem, orgLine
				else
					assert notdefined(item), "bad return from handleLine()"
					fileChanged = true
					dbg "RECIPE: line '#{line}' removed"


		[hMetaData, reader, numLines] = readTextFile(filePath)
		@handleMetaData hMetaData
		for line from reader()
			dbg "LINE: #{OL(line)}"
			if defined(line)
				numLines += 1

				# --- handleLine should return:
				#     - undef to ignore line
				#     - string to write a line literally
				#     - a hash which cannot contain key 'lineNum'

				obj = @transformLine(line, numLines, filePath)
				newline = @handleLine obj, numLines, filePath
				addToRecipe newline, line
			else
				dbg "line was undef"
				break

		if fileChanged
			result = {lRecipe}
		else
			result = {}

		dbg "#{numLines} lines processed"
		dbgReturn 'LineProcessor.handleFile', result
		return result

	# ..........................................................
	# --- SHOULD OVERRIDE, to transform a line

	transformLine: (line, lineNum, filePath) ->

		return line   # by default, returns original line

	# ..........................................................
	# --- SHOULD OVERRIDE, to save data for a given line

	handleLine: (line, lineNum, filePath) ->

		return   # by default, returns nothing

	# ..........................................................

	writeFile: (newPath, hUserData) ->

		dbgEnter 'LineProcessor.writeFile', newPath, hUserData
		{lRecipe, filePath} = hUserData

		if ! @hOptions.allowOverwrite
			assert (newPath != filePath), "Attempt to write org file"

		if defined(lRecipe)
			lOutput = []
			for item in lRecipe
				if isString(item)
					lOutput.push item
				else
					assert isHash(item), "Bad item in recipe: #{OL(item)}"
					text = @writeLine item
					if defined(text)
						assert isString(text), "text not a string"
						lOutput.push text

			# --- Now write out the text in lOutput
			if (lOutput.length > 0)
				barf toBlock(lOutput), newPath
		dbgReturn 'LineProcessor.writeFile'
		return

	# ..........................................................
	# --- SHOULD OVERRIDE, to write data for a given line

	writeLine: (h) ->

		return    # --- by default, returns nothing
