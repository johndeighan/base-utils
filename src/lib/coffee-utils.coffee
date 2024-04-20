# coffee-utils.coffee

# ---------------------------------------------------------------------------

export allExportsFrom = (filePath) ->

	regexp = ///^
			\s*
			export
			\s+
			([A-Za-z_][A-Za-z0-9_]*)
			///
	[hMetaData, lMatches] = readTextFile filePath, {
		eager: true
		pattern: regexp
		wantMatches: true
		}
	return lMatches.map((lMatches) => lMatches[1])

# ---------------------------------------------------------------------------

export allExportsListing = (filePath) =>

	return Array.from(allExportsFrom(filePath))

# ---------------------------------------------------------------------------
# --- Returns number of usages found

# --- HOW TO SKIP imports !!!!!

export symbolNumUsages = (symbol, dir, hOptions={}) =>

	{log, from} = getOptions hOptions, {
		log: false
		from: undef
		}
	assert isNonEmptyString(symbol), "Empty symbol"
	if defined(from)
		from = mkpath(from)
	assert isDir(dir), "Not a directory: #{OL(dir)}"

	numUsages = numTestUsages = numInternalUsages = 0
	projHeader = false
	for hFile from allFilesMatching("#{dir}/**/*.coffee")
		{relPath, filePath} = hFile
		isTest = relPath.match(/[\\\/]test[\\\/]/)
		if defined(from)
			isInternal = samefile(filePath, from)
		else
			isInternal = false
		nMatches = 0
		fileHeader = false
		for [line,lineNum] from allMatchingLinesIn(relPath, symbol)
			# --- We found a match!
			if isTest
				numTestUsages += 1
			else if isInternal
				numInternalUsages += 1
			else
				numUsages += 1
			if log
				# --- Print project & file if not printed yet
				if !projHeader
					LOG centeredText(dir, 40, 'char=-')
					projHeader = true
				if !fileHeader
					LOG "FILE: #{relPath}"
					fileHeader = true
				LOG "   #{lineNum}: #{truncateStr(line, 64)}"
	return [numUsages, numTestUsages, numInternalUsages]
