# read-file.test.coffee

import {
	undef, defined, notdefined, isArray,
	sortArrayOfHashes, toArray, toBlock,
	isEmpty, nonEmpty, spaces, tabs, OL,
	} from '@jdeighan/base-utils'
import {
	assert, croak,
	} from '@jdeighan/base-utils/exceptions'
import {splitLine} from '@jdeighan/base-utils/indent'

import * as lib1 from '@jdeighan/base-utils/utest'
Object.assign(global, lib1)
import * as lib2 from '@jdeighan/base-utils/read-file'
Object.assign(global, lib2)

# ---------------------------------------------------------------------------
# --- test readTextFile

(() =>
	path = "./test/test/file3.txt"
	[hMetaData, lLines] = readTextFile(path, 'eager')
	assert isArray(lLines), "Bad return from readTextFile"
	equal hMetaData, {fName: 'John', lName: 'Deighan'}
	equal lLines, ['', 'This is a test']
	)()

# ---------------------------------------------------------------------------
# Contents of ./test/readline5.txt
# abc
# defg
#
# abcdefg
# more text
# ---------------------------------------------------------------------------
# --- get all lines in file

(() =>
	path = './test/readline5.txt'
	[hMetaData, lLines] = readTextFile(path, 'eager')
	equal lLines, [
		'abc'
		'defg'
		''
		'abcdefg'
		'more text'
		]
	)()

(() =>
	path = './test/readline4.txt'
	[hMetaData, lLines] = readTextFile(path, 'eager')
	equal lLines, [
		'ghi'
		'jkl'
		''
		'mno'
		'pqr'
		]
	)()

# ---------------------------------------------------------------------------
# --- test allFilesMatching()

(() =>
	lFiles = []
	for hFile from allFilesMatching('./test/test/*', 'eager')
		{ext} = hFile
		if (ext != '.map') && (ext != '.js')
			lFiles.push hFile
	sortArrayOfHashes lFiles, 'fileName'

	like lFiles, [
		{
			fileName: 'file1.txt',
			hMetaData: {},
			lLines: ['Hello']
			}
		{
			fileName: 'file1.zh',
			hMetaData: {},
			lLines: ['你好']
			}
		{
			fileName: 'file2.txt',
			hMetaData: {},
			lLines: ['Goodbye']
			}
		{
			fileName: 'file2.zh',
			hMetaData: {},
			lLines: ['再见']
			}
		{
			fileName: 'file3.txt'
			hMetaData: {
				fName: 'John'
				lName: 'Deighan'
				}
			lLines: ['', 'This is a test']
			}
		{
			fileName: 'test.coffee',
			hMetaData: {},
			lLines: [ 'console.log "Hello"' ]
			}
		]

	)()

# ---------------------------------------------------------------------------
# --- test allFilesMatching with pattern

(() =>
	lFiles = []
	hOptions = {
		eager: true
		}
	for hFile from allFilesMatching('./test/test/*.txt', hOptions)
		lFiles.push hFile
	sortArrayOfHashes lFiles, 'fileName'

	like lFiles, [
		{
			fileName: 'file1.txt',
			hMetaData: {},
			lLines: ['Hello']
			}
		{
			fileName: 'file2.txt',
			hMetaData: {},
			lLines: ['Goodbye']
			}
		{
			fileName: 'file3.txt'
			hMetaData: {
				fName: 'John'
				lName: 'Deighan'
				}
			lLines: ['', 'This is a test']
			}
		]

	)()

# ---------------------------------------------------------------------------
# --- test allFilesMatching with pattern and cwd

(() =>
	lFiles = []
	hOptions = {
		eager: true
		hGlobOptions: {
			cwd: './test/test'
			}
		}
	for hFile from allFilesMatching('*.txt', hOptions)
		lFiles.push hFile
	sortArrayOfHashes lFiles, 'fileName'

	like lFiles, [
		{
			fileName: 'file1.txt',
			hMetaData: {},
			lLines: ['Hello']
			}
		{
			fileName: 'file2.txt',
			hMetaData: {},
			lLines: ['Goodbye']
			}
		{
			fileName: 'file3.txt'
			hMetaData: {
				fName: 'John'
				lName: 'Deighan'
				}
			lLines: ['', 'This is a test']
			}
		]

	)()

# ---------------------------------------------------------------------------

(() =>
	filePath = './test/words/adjectives.zh'
	numWords = undef

	handleLine = (line) ->
		if defined(numWords)
			numWords += 1
		else
			numWords = 1
		return

	[hMetaData, reader] = readTextFile(filePath)
	for line from reader()
		handleLine line

	equal numWords, 256
	)()

# ---------------------------------------------------------------------------

(() =>
	numWords = undef

	handleLine = (line) ->
		if defined(numWords)
			numWords += 1
		else
			numWords = 1
		return

	for h from allFilesMatching('./test/words/*.zh')
		[hMetaData, reader] = readTextFile(h.filePath)
		for line from reader()
			handleLine line

	equal numWords, 2048
	)()

# ---------------------------------------------------------------------------

(() =>
	numWords = undef

	handleLine = (line) ->
		if nonEmpty(line)
			if defined(numWords)
				numWords += 1
			else
				numWords = 1
		return

	lLines = [
		'abc'
		'   '
		'\t\t'
		'def'
		''
		undef
		'你好'
		]
	[hMetaData, reader] = readTextFile(lLines)
	for line from reader()
		handleLine line

	equal numWords, 3
	)()

# ---------------------------------------------------------------------------

(() =>
	numWords = undef

	handleLine = (line) ->
		if nonEmpty(line)
			if defined(numWords)
				numWords += 1
			else
				numWords = 1
		return

	text = """
		abc
		#{spaces(3)}
		#{tabs(2)}
		def

		你好
		"""

	[hMetaData, reader] = readTextFile(toArray(text))
	for line from reader()
		handleLine line

	equal numWords, 3
	)()

# ---------------------------------------------------------------------------

(() =>
	numWords = undef

	handleLine = (line) ->
		if nonEmpty(line)
			if defined(numWords)
				numWords += 1
			else
				numWords = 1
		return

	text = """
		abc
		def
		你好
		ghi
		__END__
		abc
		def
		"""

	[hMetaData, reader] = readTextFile(toArray(text))
	for line from reader()
		handleLine line

	equal numWords, 4
	)()

# ---------------------------------------------------------------------------

(() =>
	numWords = undef
	numExtraWords = undef

	handleLine = (line) ->
		if nonEmpty(line)
			if defined(numWords)
				numWords += 1
			else
				numWords = 1
		return

	handleExtraLine = (line) ->
		if nonEmpty(line)
			if defined(numExtraWords)
				numExtraWords += 1
			else
				numExtraWords = 1
		return

	text = """
		abc
		def
		你好
		ghi
		__END__
		mno
		pqr
		"""

	[hMetaData, reader] = readTextFile(toArray(text))
	for line from reader()
		handleLine line
	for line from reader()
		handleExtraLine line

	equal numWords, 4
	equal numExtraWords, 2
	)()

# ---------------------------------------------------------------------------

(() =>
	lLines = []
	lExtraLines = []

	input = toArray("""
		---
		fName: John
		lName: Deighan
		gender: male
		---
		abc
		def
		你好
		ghi
		__END__
		mno
		pqr
		""")

	[hMetaData, reader, numMetaLines] = readTextFile(input)

	for line from reader()
		lLines.push line

	for line from reader()
		lExtraLines.push line

	equal hMetaData, {
		fName: 'John'
		lName: 'Deighan'
		gender: 'male'
		}
	equal numMetaLines, 5
	equal lLines.length, 4
	equal toBlock(lLines), """
		abc
		def
		你好
		ghi
		"""
	equal lExtraLines.length, 2
	equal toBlock(lExtraLines), """
		mno
		pqr
		"""
	)()

# ---------------------------------------------------------------------------
# --- test readTextFile with string pattern

(() =>
	lLines = []

	input = toArray("""
		abc
		abcdef
		xxxab
		def
		你好
		""")

	[hMetaData, reader] = readTextFile(input, {pattern: 'ab'})
	for line from reader()
		lLines.push line

	equal lLines, [
		'abc'
		'abcdef'
		'xxxab'
		]
	)()

# ---------------------------------------------------------------------------
# --- test readTextFile with regexp pattern

(() =>
	lLines = []

	input = toArray("""
		abc
		abcdef
		xxxab
		def
		你好
		""")

	[hMetaData, reader] = readTextFile(input, {pattern: /^ab/})
	for line from reader()
		lLines.push line

	equal lLines, [
		'abc'
		'abcdef'
		]
	)()

# ---------------------------------------------------------------------------
# --- test simple 'transform' option

(() =>
	input = toArray("""
		abc
		def
		你好
		ghi
		""")

	transform = (line) ->
		return line.toUpperCase()
	[hMetaData, reader] = readTextFile(input, {transform})

	equal toBlock(Array.from(reader())), """
		ABC
		DEF
		你好
		GHI
		"""
	)()

# ---------------------------------------------------------------------------
# --- test complex 'transform' option

(() =>
	input = toArray("""
		if (x == 2)
			y = 15
			log y
		log 'done'
		""")

	transform = (line) ->
		[level, text] = splitLine(line)
		if lMatches = text.match(/^if\s+(.*)$/)
			obj = {type: 'if', cond: lMatches[1]}
		else if lMatches = text.match(/^log\s+(.*)$/)
			obj = {type: 'log', text: lMatches[1]}
		else if lMatches = text.match(/^([a-z])\s*=\s*(.*)$/)
			obj = {type: 'assign', var: lMatches[1], val: lMatches[2]}
		else
			croak "syntax error: #{OL(line)}"
		return [level, obj]

	[hMetaData, reader] = readTextFile(input, {transform})

	equal Array.from(reader()), [
		[0, {type: 'if', cond: "(x == 2)"}]
		[1, {type: 'assign', var: 'y', val: '15'}]
		[1, {type: 'log', text: 'y'}]
		[0, {type: 'log', text: "'done'"}]
		]
	)()

