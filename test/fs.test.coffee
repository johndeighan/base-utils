# fs.test.coffee

import test from 'ava'
import {
	undef, defined, notdefined, LOG,
	} from '@jdeighan/base-utils'
import {setDebugging} from '@jdeighan/base-utils/debug'
import {mkpath} from '@jdeighan/base-utils/ll-fs'
import {
	resolve, getPkgJsonDir, getPkgJsonPath,
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

test "line 21", (t) => t.truthy(isFile(mkpath(dir, 'package.json')))
test "line 22", (t) => t.falsy (isFile(mkpath(dir, 'doesNotExist.txt')))
test "line 23", (t) => t.truthy(isDir(mkpath(dir, 'src')))
test "line 24", (t) => t.truthy(isDir(mkpath(dir, 'test')))
test "line 25", (t) => t.falsy (isDir(mkpath(dir, 'doesNotExist')))

test "line 33", (t) => t.is slurp(testPath, {maxLines: 2}), """
	abc
	def
	"""

test "line 38", (t) => t.is slurp(testPath, {maxLines: 3}), """
	abc
	def
	ghi
	"""

test "line 44", (t) => t.is slurp(testPath, {maxLines: 1000}), """
	abc
	def
	ghi
	jkl
	mno
	"""

# --- Test without building path first

test "line 54", (t) => t.is slurp(dir, 'test', 'readline.txt', {maxLines: 2}), """
	abc
	def
	"""

test "line 59", (t) => t.is slurp(dir, 'test', 'readline.txt', {maxLines: 3}), """
	abc
	def
	ghi
	"""

test "line 65", (t) => t.is slurp(dir, 'test', 'readline.txt', {maxLines: 1000}), """
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
			# --- We need to clear out hWords each time procAll() is called
			@hWords = {}
			return

		filter: (hFileInfo) ->
			{stub, ext} = hFileInfo
			return (ext == '.txt') && stub.match(/^readline/)

		handleLine: (line) ->
			@hWords[line.toUpperCase()] = true
			return

	fp = new TestProcessor()
	fp.procAll()
	test "line 101", (t) => t.deepEqual(fp.hWords, {
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
	test "line 112", (t) => t.deepEqual(h, {
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

	test "line 126", (t) => t.like(lFiles, [
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

	test "line 151", (t) => t.truthy(isFile(path))

	text = slurp path
	test "line 154", (t) => t.is(text, "line 1\nline 2\n")
	)()
