# file-processor.test.coffee

import {
	undef, defined, notdefined, rtrim, toArray,
	} from '@jdeighan/base-utils'
import {LOG} from '@jdeighan/base-utils/log'
import {setDebugging} from '@jdeighan/base-utils/debug'
import {
	slurp, subPath, isDir, dirContents, dirListing,
	} from '@jdeighan/base-utils/fs'
import * as lib from '@jdeighan/base-utils/file-processor'
Object.assign(global, lib)
import {
	line2hWord, hWord2line,
	} from './utils.js'   # relative to this dir?
import {
	UnitTester,
	equal, like, notequal, truthy, falsy, fails, succeeds,
	} from '@jdeighan/base-utils/utest'

# ---------------------------------------------------------------------------
# --- Build array of paths to files matching a glob pattern
#     Explanation:
#        we override the `handleFile()` method by simply
#        assigning to the key. For each file, we return an
#        empty hash. If we returned undef, it would be ignored.
#        Although the hash we return is empty, `FileProcessor`
#        will add the key `filePath` containing the full path
#        to the file. But, our unit test simply checks how
#        many hashes there are in `lUserData`.

(() =>
	# --- There are 2 *.zh files in `./test/fp-test`

	fp = new FileProcessor './test/fp-test/*.zh'
	fp.handleFile = (hFile) ->
		return {}
	fp.readAll()

	lUserData = fp.getUserData()
	equal lUserData.length, 2
	)()

# --- We can also pass option 'cwd' in hGlobOptions

(() =>
	# --- There are 2 *.zh files in `./test/fp-test`

	fp = new FileProcessor '*.zh', {
		hGlobOptions: {cwd: './test/fp-test'}
		}
	fp.handleFile = (hFile) ->
		return {}
	fp.readAll()

	lUserData = fp.getUserData()
	equal lUserData.length, 2
	)()

(() =>
	# --- There are 3 *.txt files in `./test/fp-test`

	fp = new FileProcessor './test/fp-test/*.txt'
	fp.handleFile = (hFile) ->
		return {}
	fp.readAll()

	lUserData = fp.getUserData()
	equal lUserData.length, 3
	)()

(() =>
	# --- There are 26 total files in `./test/words`

	fp = new FileProcessor './test/words/*'
	fp.handleFile = (hFile) ->
		{type} = hFile
		if (type == 'file')
			return {}
		else
			return undef
	fp.readAll()

	lUserData = fp.getUserData()
	equal lUserData.length, 26
	)()

(() =>
	# --- There are 25 *.zh files in `./test/words`

	fp = new FileProcessor './test/words/*.zh'
	fp.handleFile = (hFile) ->
		return {}
	fp.readAll()

	lUserData = fp.getUserData()
	equal lUserData.length, 25
	)()

# ---------------------------------------------------------------------------
# --- Keep track of the contents of each *.zh file
#     Explanation:
#        we override the `handleFile()` method by simply
#        assigning to the key. For each file, we return a
#        hash that includes the file contents. The unit test
#        then tests if lUserData includes that content.
#        rtrim() will trim trailing whitespace, including \n

(() =>
	fp = new FileProcessor './test/fp-test/*.zh'
	fp.handleFile = (hFile) ->
		return {
			zh: rtrim(slurp(hFile.filePath))
			}
	fp.readAll()

	lUserData = fp.getSortedUserData()
	equal lUserData.length, 2
	like lUserData[0], {zh: '你好'}
	like lUserData[1], {zh: '再见'}
	)()

# ---------------------------------------------------------------------------
# --- Count total number of words in all `*.zh` files
#        in `words` dir
#     Explanation:
#        we override the `handleFile()` to increment the
#        value of @numWords, but return undef

(() =>
	fp = new FileProcessor './test/words/*.zh'
	fp.handleFile = (hFile) ->
		content = rtrim(slurp(hFile.filePath))
		count = toArray(content).length
		if defined(@numWords)
			@numWords += count
		else
			@numWords = count
		return undef
	fp.readAll()

	equal fp.numWords, 2048
	)()

# ---------------------------------------------------------------------------
# --- Count total number of words in all `*.zh` files in `words` dir
#     by overriding transformFile() to pass integers to handleFile()

(() =>
	fp = new FileProcessor './test/words/*.zh'
	fp.transformFile = (hFile) ->
		content = rtrim(slurp(hFile.filePath))
		return toArray(content).length

	fp.handleFile = (count) ->
		if defined(@numWords)
			@numWords += count
		else
			@numWords = count
		return undef
	fp.readAll()

	equal fp.numWords, 2048
	)()

# ---------------------------------------------------------------------------
# --- Count total number of words in all `*.zh` files
#        in `words` dir - using a LineProcessor
#     Explanation:
#        we override the `handleLine()`, which is called
#        for each line in any file, to increment the
#        value of @numWords, but return undef

(() =>
	fp = new LineProcessor './test/words/*.zh'
	fp.handleLine = (line) ->
		if defined(@numWords)
			@numWords += 1
		else
			@numWords = 1
		return undef     # write nothing out
	fp.readAll()

	equal fp.numWords, 2048
	)()

# ---------------------------------------------------------------------------
# --- Write out new files in `./test/words/temp` that contain
#        just the Chinese words in `*.zh` files

(() =>
	fp = new LineProcessor './test/words/*.zh'
	fp.handleLine = (line) ->
		if defined(@numWords)
			@numWords += 1
		else
			@numWords = 1
		return {hWord: line2hWord(line)}
	fp.writeLine = (h) ->
		{hWord} = h         # extract previously written hWord
		word = hWord.zh[0].zh
		return word
	fp.readAll()
	fp.writeAll()

	equal fp.numWords, 2048
	equal dirListing('./test/words/temp').length, 25
	equal dirListing('./test/words/temp', {regexp: /\.zh$/}).length, 25
	equal dirListing('./test/words/temp', 'filesOnly').length, 25
	equal dirListing('./test/words/temp', 'dirsOnly').length, 0
	)()

# ---------------------------------------------------------------------------
# --- Write out new files in `./test/words/temp` that contain
#        the same lines in the original file, but with
#        the number incremented by 5

(() =>
	fp = new LineProcessor './test/words/*.zh'
	fp.handleLine = (line) ->
		return {hWord: line2hWord(line)}
	fp.writeFileTo = (hUserData) ->
		return subPath hUserData.filePath, 'temp2'
	fp.writeLine = (hLine) ->
		{hWord} = hLine   # extract previously written hWord
		hWord.num += 5
		return hWord2line(hWord)
	fp.readAll()
	fp.writeAll()

	truthy isDir('./test/words/temp2')
	truthy slurp('./test/words/adjectives.zh').startsWith('11 ')
	truthy slurp('./test/words/temp2/adjectives.zh').startsWith('16 ')
	equal dirListing('./test/words/temp2').length, 25
	equal dirListing('./test/words/temp2', {regexp: /\.zh$/}).length, 25
	equal dirListing('./test/words/temp2', 'filesOnly').length, 25
	equal dirListing('./test/words/temp2', 'dirsOnly').length, 0

	)()

# ---------------------------------------------------------------------------
# --- Write out new files in `./test/words/temp` that contain
#        the same lines in the original file, but with
#        the number incremented by 5
#     Override transformLine() to do this, override handleLin() to
#        return its first arg

(() =>
	fp = new LineProcessor './test/words/*.zh'
	fp.transformLine = (line) =>
		return {hWord: line2hWord(line)}
	fp.handleLine = (h) ->
		return h
	fp.writeFileTo = (hUserData) ->
		return subPath hUserData.filePath, 'temp2'
	fp.writeLine = (hLine) ->
		{hWord} = hLine   # extract previously written hWord
		hWord.num += 5
		return hWord2line(hWord)
	fp.readAll()
	fp.writeAll()

	truthy isDir('./test/words/temp2')
	truthy slurp('./test/words/adjectives.zh').startsWith('11 ')
	truthy slurp('./test/words/temp2/adjectives.zh').startsWith('16 ')
	equal dirListing('./test/words/temp2').length, 25
	equal dirListing('./test/words/temp2', {regexp: /\.zh$/}).length, 25
	equal dirListing('./test/words/temp2', 'filesOnly').length, 25
	equal dirListing('./test/words/temp2', 'dirsOnly').length, 0
	)()
