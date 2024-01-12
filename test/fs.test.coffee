# fs.test.coffee

import test from 'ava'
import {
	undef, defined, notdefined, LOG,
	} from '@jdeighan/base-utils'
import {setDebugging} from '@jdeighan/base-utils/debug'
import {mkpath} from '@jdeighan/base-utils/ll-fs'
import {
	resolve, pathType,
	getPkgJsonDir, getPkgJsonPath,
	fileExists, isFile, rmFile,
	dirExists, isDir, mkdir, rmDir,
	fromJSON, toJSON,
	slurp, slurpJSON, slurpTAML, slurpPkgJSON,
	barf, barfJSON, barfTAML, barfPkgJSON,
	parseSource, getTextFileContents, allFilesIn, allLinesIn,
	forEachFileInDir, forEachItem, forEachLineInFile,
	FileWriter, FileWriterSync, FileProcessor,
	} from '@jdeighan/base-utils/fs'

dir = process.cwd()     # should be root directory of @jdeighan/base-utils
testDir = mkpath(dir, 'test')
testPath = mkpath(dir, 'test', 'readline.txt')

# ---------------------------------------------------------------------------
# --- test pathType

test "line 29", (t) => t.throws () => pathType(42)
test "line 30", (t) => t.is pathType('.'), 'dir'
test "line 31", (t) => t.is pathType('./package.json'), 'file'
test "line 32", (t) => t.is pathType('./package2.json'), 'missing'

test "line 34", (t) => t.throws () => pathType(['a'])
test "line 35", (t) => t.is pathType('.', 'test'), 'dir'
test "line 36", (t) => t.is pathType('.','package.json'), 'file'
test "line 37", (t) => t.is pathType('.','package2.json'), 'missing'

# ---------------------------------------------------------------------------

test "line 41", (t) => t.truthy(isFile(mkpath(dir, 'package.json')))
test "line 42", (t) => t.falsy (isFile(mkpath(dir, 'doesNotExist.txt')))
test "line 43", (t) => t.truthy(isDir(mkpath(dir, 'src')))
test "line 44", (t) => t.truthy(isDir(mkpath(dir, 'test')))
test "line 45", (t) => t.falsy (isDir(mkpath(dir, 'doesNotExist')))

test "line 47", (t) => t.is slurp(testPath, {maxLines: 2}), """
	abc
	def
	"""

test "line 52", (t) => t.is slurp(testPath, {maxLines: 3}), """
	abc
	def
	ghi
	"""

test "line 58", (t) => t.is slurp(testPath, {maxLines: 1000}), """
	abc
	def
	ghi
	jkl
	mno
	"""

# --- Test without building path first

test "line 68", (t) => t.is slurp(dir, 'test', 'readline.txt', {maxLines: 2}), """
	abc
	def
	"""

test "line 73", (t) => t.is slurp(dir, 'test', 'readline.txt', {maxLines: 3}), """
	abc
	def
	ghi
	"""

test "line 79", (t) => t.is slurp(dir, 'test', 'readline.txt', {maxLines: 1000}), """
	abc
	def
	ghi
	jkl
	mno
	"""

# ---------------------------------------------------------------------------
# --- test FileProcessor

(() =>
	class TestProcessor extends FileProcessor

		constructor: () ->
			super './test'

		begin: () ->
			# --- We need to clear out hWords each time go() is called
			@hWords = {}
			return

		filter: (hFileInfo) ->
			{stub, ext} = hFileInfo
			return (ext == '.txt') && stub.match(/^readline/)

		handleLine: (line) ->
			@hWords[line.toUpperCase()] = true
			return

	fp = new TestProcessor()
	fp.go()
	test "line 111", (t) => t.deepEqual(fp.hWords, {
		'ABC': true
		'DEF': true
		'GHI': true
		'JKL': true
		'MNO': true
		'PQR': true
		})

	)()

# ---------------------------------------------------------------------------
# --- test getTextFileContents

(() =>
	path = "./test/test/file3.txt"
	h = getTextFileContents(path)
	test "line 128", (t) => t.deepEqual(h, {
		metadata: {fName: 'John', lName: 'Deighan'}
		lLines: ['', 'This is a test']
		})
	)()

# ---------------------------------------------------------------------------
# --- test allFilesIn

(() =>
	lFiles = []
	for hFileInfo from allFilesIn('./test/test', {eager: true})
		lFiles.push hFileInfo

	test "line 142", (t) => t.like(lFiles, [
		{fileName: 'file1.txt', metadata: undef, lLines: ['DONE']}
		{fileName: 'file1.zh',  metadata: undef, lLines: ['DONE']}
		{fileName: 'file2.txt', metadata: undef, lLines: ['DONE']}
		{fileName: 'file2.zh',  metadata: undef, lLines: ['DONE']}
		{
			fileName: 'file3.txt'
			metadata: {fName: 'John', lName: 'Deighan'}
			lLines: ['','This is a test']
			}
		])

	)()

# ---------------------------------------------------------------------------

(() =>
	path = './test/testfile.txt'

	# --- put garbage into the file
	barf "garbage...", path

	writer = new FileWriterSync(path)
	writer.writeln "line 1"
	writer.writeln "line 2"
	writer.end()

	test "line 169", (t) => t.truthy(isFile(path))

	text = slurp path
	test "line 172", (t) => t.is(text, "line 1\nline 2\n")
	)()
