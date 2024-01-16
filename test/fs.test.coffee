# fs.test.coffee

import {utest} from '@jdeighan/base-utils/utest'
import {undef, fromJSON, toJSON} from '@jdeighan/base-utils'
import {
	mkpath, isFile,
	getPkgJsonDir, getPkgJsonPath,
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

utest.equal 43, slurp(testPath, {maxLines: 2}), """
	abc
	def
	"""

utest.equal 48, slurp(testPath, {maxLines: 3}), """
	abc
	def
	ghi
	"""

utest.equal 54, slurp(testPath, {maxLines: 1000}), """
	abc
	def
	ghi
	jkl
	mno
	"""

# --- Test without building path first

utest.equal 64, slurp(dir, 'test', 'readline.txt', {maxLines: 2}), """
	abc
	def
	"""

utest.equal 69, slurp(dir, 'test', 'readline.txt', {maxLines: 3}), """
	abc
	def
	ghi
	"""

utest.equal 75, slurp(dir, 'test', 'readline.txt', {maxLines: 1000}), """
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
	fp.procAll()
	utest.equal 107, fp.hWords, {
		'ABC': true
		'DEF': true
		'GHI': true
		'JKL': true
		'MNO': true
		'PQR': true
		}

	)()

# ---------------------------------------------------------------------------
# --- test getTextFileContents

(() =>
	path = "./test/test/file3.txt"
	h = getTextFileContents(path)
	utest.equal 124, h, {
		metadata: {fName: 'John', lName: 'Deighan'}
		lLines: ['', 'This is a test']
		}
	)()

# ---------------------------------------------------------------------------
# --- test allFilesIn

(() =>
	lFiles = []
	for hFileInfo from allFilesIn('./test/test', {eager: true})
		lFiles.push hFileInfo

	utest.like 138, lFiles, [
		{fileName: 'file1.txt', metadata: undef, lLines: ['DONE']}
		{fileName: 'file1.zh',  metadata: undef, lLines: ['DONE']}
		{fileName: 'file2.txt', metadata: undef, lLines: ['DONE']}
		{fileName: 'file2.zh',  metadata: undef, lLines: ['DONE']}
		{
			fileName: 'file3.txt'
			metadata: {fName: 'John', lName: 'Deighan'}
			lLines: ['','This is a test']
			}
		]

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

	utest.truthy 165, isFile(path)

	text = slurp path
	utest.equal 168, text, "line 1\nline 2\n"
	)()
