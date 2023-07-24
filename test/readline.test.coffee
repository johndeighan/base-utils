# readline.test.coffee

import test from 'ava'
import {undef} from '@jdeighan/base-utils'
import {setDebugging} from '@jdeighan/base-utils/debug'
import {
	isFile, isDir, mkpath, mkdirSync, slurp, barf, forEachFileInDir,
	forEachItem, fileIterator, forEachLineInFile,
	} from '@jdeighan/base-utils/fs'

dir = process.cwd()     # should be root directory of @jdeighan/base-utils
testDir = mkpath(dir, 'test')
testPath = mkpath(dir, 'test', 'readline.txt')

# ---------------------------------------------------------------------------
# --- test fileIterator()

(() =>
	iter = fileIterator(testPath)
	# --- Contents:
	#        abc
	#        def
	#        ghi
	#        jkl
	#        mno
	#

	lLines = []
	for line from iter
		lLines.push line.toUpperCase()
	test "line 29", (t) => t.deepEqual(lLines, ['ABC','DEF','GHI','JKL','MNO'])
	)()

# ---------------------------------------------------------------------------
# --- test forEachItem()

(() =>
	countGenerator = () ->
		yield 1
		yield 2
		yield 3
		yield 4
		return

	callback = (item, hContext) =>
		if (item > 2)
			return "#{hContext.label} #{item}"
		else
			return undef

	result = forEachItem countGenerator(), callback, {label: 'X'}
	test "line 51", (t) => t.deepEqual(result, ['X 3', 'X 4'])
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
	test "line 74", (t) => t.deepEqual(result, ['--> def', '--> jkl'])
	)()
