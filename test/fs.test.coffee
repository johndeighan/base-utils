# fs.test.coffee

import {
	UnitTester,
	equal, like, notequal, truthy, falsy, throws, succeeds,
	} from '@jdeighan/base-utils/utest'
import {
	undef, fromJSON, toJSON, OL, chomp, jsType,
	words, hslice, sortArrayOfHashes,
	newerDestFilesExist,
	} from '@jdeighan/base-utils'
import {LOG} from '@jdeighan/base-utils/log'
import {setDebugging} from '@jdeighan/base-utils/debug'
import * as lib from '@jdeighan/base-utils/fs'
Object.assign(global, lib)

# --- should be root directory of @jdeighan/base-utils
projDir = workingDir()
dir = mydir(import.meta.url)    # project test folder
subdir = mkpath(dir, 'test')    # subdir test inside test
file = myself(import.meta.url)
testPath = mkpath(projDir, 'test', 'readline.txt')

# ---------------------------------------------------------------------------
# --- test allLinesIn()

(() =>
	path = './test/readline3.txt'
	lLines = Array.from allLinesIn(path)
	equal lLines, [
		'ghi'
		'jkl'
		''
		'mno'
		'pqr'
		]
	)()

# ---------------------------------------------------------------------------

like parsePath(import.meta.url), {
	type: 'file'
	root: 'c:/'
	base: 'fs.test.js'
	fileName: 'fs.test.js'
	name: 'fs.test'
	stub: 'fs.test'
	ext: '.js'
	purpose: 'test'
	}

like parsePath(projDir), {
	path: projDir
	type: 'dir'
	root: 'c:/'
	dir: parentDir(projDir)
	base: 'base-utils'
	fileName: 'base-utils'
	name: 'base-utils'
	stub: 'base-utils'
	ext: ''
	purpose: undef
	}

like parsePath(dir), {
	path: dir
	type: 'dir'
	root: 'c:/'
	dir: parentDir(dir)
	base: 'test'
	fileName: 'test'
	name: 'test'
	stub: 'test'
	ext: ''
	purpose: undef
	}

like parsePath(subdir), {
	path: subdir
	type: 'dir'
	root: 'c:/'
	dir: parentDir(subdir)
	base: 'test'
	fileName: 'test'
	name: 'test'
	stub: 'test'
	ext: ''
	purpose: undef
	}

like parsePath(file), {
	path: file
	type: 'file'
	root: 'c:/'
	dir: parentDir(file)
	base: 'fs.test.js'
	fileName: 'fs.test.js'
	name: 'fs.test'
	stub: 'fs.test'
	ext: '.js'
	purpose: 'test'
	}

like parsePath(testPath), {
	path: testPath
	type: 'file'
	root: 'c:/'
	dir: parentDir(testPath)
	base: 'readline.txt'
	fileName: 'readline.txt'
	name: 'readline'
	stub: 'readline'
	ext: '.txt'
	purpose: undef
	}

# ---------------------------------------------------------------------------

equal slurp(testPath, {maxLines: 2}), """
	abc
	def
	"""

equal slurp(testPath, {maxLines: 3}), """
	abc
	def
	ghi
	"""

equal slurp(testPath, {maxLines: 1000}), """
	abc
	def
	ghi
	jkl
	mno
	"""

equal slurp(testPath, 'maxLines=3'), """
	abc
	def
	ghi
	"""

# ---------------------------------------------------------------------------
# --- test readTextFile

(() =>
	path = "./test/test/file3.txt"
	h = readTextFile(path)
	equal h, {
		hMetaData: {fName: 'John', lName: 'Deighan'}
		lLines: ['', 'This is a test']
		}
	)()

# ---------------------------------------------------------------------------
# --- test allFilesMatching

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
			hMetaData: undef,
			lLines: ['Hello']
			}
		{
			fileName: 'file1.zh',
			hMetaData: undef,
			lLines: ['你好']
			}
		{
			fileName: 'file2.txt',
			hMetaData: undef,
			lLines: ['Goodbye']
			}
		{
			fileName: 'file2.zh',
			hMetaData: undef,
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
			hMetaData: undef,
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
			hMetaData: undef,
			lLines: ['Hello']
			}
		{
			fileName: 'file2.txt',
			hMetaData: undef,
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
			hMetaData: undef,
			lLines: ['Hello']
			}
		{
			fileName: 'file2.txt',
			hMetaData: undef,
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
# --- test forEachLineInFile()

(() =>
	# --- Contents:
	#        abc
	#        def
	#        ghi
	#        jkl
	#        mno
	#

	callback = (item, hContext) =>
		if (item == 'def') || (item == 'jkl')
			return "#{hContext.label} #{item}"
		else
			return undef

	result = forEachLineInFile testPath, callback, {label: '-->'}
	equal result, ['--> def', '--> jkl']
	)()

# ---------------------------------------------------------------------------
# --- test dirContents()

smDir = './test/source-map'
equal dirContents(smDir, '*.coffee').length, 1
equal dirContents(smDir, '*.js').length, 2
equal dirContents(smDir, '*').length, 6
equal dirContents(smDir, '*', 'filesOnly').length, 4
equal dirContents(smDir, '*', 'dirsOnly').length, 2

# ---------------------------------------------------------------------------

(() =>

	lLines = []

	filePath4 = './test/readline4.txt'
	for line from allLinesIn(filePath4)
		lLines.push line

	equal lLines, ['ghi', 'jkl', '', 'mno', 'pqr']
	)()

# ---------------------------------------------------------------------------
# --- Produce capitalized version, with a prefix "> "
#        skipping blank lines

(() =>

	func = (line, hContext) =>
		if (line == '')
			return undef
		else
			return "#{hContext.prefix}#{line.toUpperCase()}"

	filePath3 = './test/readline3.txt'
	lLines = forEachLineInFile filePath3, func, {prefix: '> '}

	equal lLines, ['> GHI', '> JKL', '> MNO', '> PQR']
	)()

# ---------------------------------------------------------------------------
# --- Produce capitalized version, with a prefix "> "
#        skipping blank lines

(() =>

	func = (line, hContext) =>
		if (line == '')
			return undef
		else
			return "#{hContext.prefix}#{line.toUpperCase()}"

	filePath4 = './test/readline4.txt'
	lLines = forEachLineInFile filePath4, func, {prefix: '> '}

	equal lLines, ['> GHI', '> JKL', '> MNO', '> PQR']
	)()

# ---------------------------------------------------------------------------
# --- This time, stop processing when a blank line is found

(() =>

	func = (line, hContext) =>
		if (line == '')
			throw 'stop'
		else
			return "#{hContext.prefix}#{line.toUpperCase()}"

	filePath4 = './test/readline4.txt'
	lLines = forEachLineInFile filePath4, func, {prefix: '> '}

	equal lLines, ['> GHI', '> JKL']
	)()

# ---------------------------------------------------------------------------

(() =>
	# --- put garbage into the file
	path = './test/testfile.txt'
	barf "garbage...", path

	writer = new FileWriter(path)
	writer.writeln "line 1"
	writer.writeln "line 2"
	writer.close()

	truthy isFile(path)

	text = slurp path
	equal text, "line 1\nline 2\n"
	)()

# ---------------------------------------------------------------------------

(() =>
	# --- put garbage into the file
	path = './test/testfile.txt'
	barf "garbage...", path

	writer = new FileWriter(path)
	writer.writeln "line 1"
	writer.writeln "line 2"
	writer.close()

	truthy isFile(path)

	text = slurp path
	equal chomp(text), """
		line 1
		line 2
		"""
	)()

# ---------------------------------------------------------------------------

(() =>
	# --- put garbage into the file
	path = './test/testfile.txt'
	barf "garbage...", path

	writer = new FileWriter(path)
	writer.writeln "line 1", " - some text"
	writer.writeln "line 2", " - more text"
	writer.close()

	truthy isFile(path)

	text = slurp path
	equal text, "line 1 - some text\nline 2 - more text\n"
	)()

# ---------------------------------------------------------------------------

(() =>
	# --- put garbage into the file
	path = './test/testfile.txt'
	barf "garbage...", path

	writer = new FileWriter(path, {async: true})
	await writer.writeln "line 1"
	await writer.writeln "line 2"
	await writer.close()

	truthy isFile(path)

	text = slurp path
	equal text, "line 1\nline 2\n"
	)()

# ---------------------------------------------------------------------------

(() =>
	# --- test newerDestFilesExist()

	coffeeFile = "./src/lib/fs.coffee"
	jsFile = "./src/lib/fs.js"
	dummyFile = "./src/lib/dummy.js"

	truthy newerDestFilesExist(coffeeFile, jsFile)
	falsy newerDestFilesExist(jsFile, coffeeFile)
	falsy newerDestFilesExist(coffeeFile, dummyFile)
	)()
