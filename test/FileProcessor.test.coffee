# FileProcessor.test.coffee

import {
	undef, defined, notdefined, LOG, rtrim, toArray,
	} from '@jdeighan/base-utils'
import {setDebugging} from '@jdeighan/base-utils/debug'
import {slurp, subPath, isDir} from '@jdeighan/base-utils/fs'
import {
	FileProcessor, LineProcessor,
	} from '@jdeighan/base-utils/FileProcessor'
import {
	line2hWord, hWord2line,
	} from './utils.js'   # relative to this dir?
import {utest} from '@jdeighan/base-utils/utest'

# setDebugging 'readAll'

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
	fp = new FileProcessor './test/test', '*.zh'
	fp.handleFile = (filePath) ->
		return {}
	fp.readAll()

	lUserData = fp.getUserData()
	utest.equal lUserData.length, 2
	)()

(() =>
	fp = new FileProcessor './test/test', '*.txt'
	fp.handleFile = (filePath) ->
		return {}
	fp.readAll()

	lUserData = fp.getUserData()
	utest.equal lUserData.length, 3
	)()

(() =>
	fp = new FileProcessor './test/words', '*'
	fp.handleFile = (filePath) ->
		return {}
	fp.readAll()

	lUserData = fp.getUserData()
	utest.equal lUserData.length, 26
	)()

(() =>
	fp = new FileProcessor './test/words', '*.zh'
	fp.handleFile = (filePath) ->
		return {}
	fp.readAll()

	lUserData = fp.getUserData()
	utest.equal lUserData.length, 25
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
	fp = new FileProcessor './test/test', '*.zh'
	fp.handleFile = (filePath) ->
		return {zh: rtrim(slurp(filePath))}
	fp.readAll()

	lUserData = fp.getSortedUserData()
	utest.equal lUserData.length, 2
	utest.like lUserData[0], {zh: '你好'}
	utest.like lUserData[1], {zh: '再见'}
	)()

# ---------------------------------------------------------------------------
# --- Count total number of words in all `*.zh` files
#        in `words` dir
#     Explanation:
#        we override the `handleFile()` to increment the
#        value of @numWords, but return undef

(() =>
	fp = new FileProcessor './test/words', '*.zh'
	fp.handleFile = (filePath) ->
		content = rtrim(slurp(filePath))
		count = toArray(content).length
		if defined(@numWords)
			@numWords += count
		else
			@numWords = count
		return undef
	fp.readAll()

	utest.equal fp.numWords, 2048
	)()

# ---------------------------------------------------------------------------
# --- Count total number of words in all `*.zh` files
#        in `words` dir - using a LineProcessor
#     Explanation:
#        we override the `handleLine()`, which is called
#        for each line in any file, to increment the
#        value of @numWords, but return undef

(() =>
	fp = new LineProcessor './test/words', '*.zh'
	fp.handleLine = (line) ->
		if defined(@numWords)
			@numWords += 1
		else
			@numWords = 1
		return undef
	fp.readAll()

	utest.equal fp.numWords, 2048
	)()

# ---------------------------------------------------------------------------
# --- Write out new files in `./test/words/temp` that contain
#        just the Chinese words in `*.zh` files

(() =>
	fp = new LineProcessor './test/words', '*.zh'
	fp.handleLine = (line) ->
		if defined(@numWords)
			@numWords += 1
		else
			@numWords = 1
		return {hWord: line2hWord(line)}
	fp.writeLine = (hLine) ->
		{hWord} = hLine   # extract previously written hWord
		word = hWord.zh[0].zh
		return word
	fp.readAll()
	fp.writeAll()

	utest.equal fp.numWords, 2048
	)()

# ---------------------------------------------------------------------------
# --- Write out new files in `./test/words/temp` that contain
#        the same lines in the original file, but with
#        the number incremented by 5

(() =>
	fp = new LineProcessor './test/words', '*.zh'
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

	utest.truthy isDir('./test/words/temp2')
	utest.truthy slurp('./test/words/adjectives.zh').startsWith('11 ')
	utest.truthy slurp('./test/words/temp2/adjectives.zh').startsWith('16 ')

	)()
