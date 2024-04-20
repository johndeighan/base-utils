# fs.test.coffee

import {
	UnitTester,
	equal, like, notequal, truthy, falsy, fails, succeeds,
	} from '@jdeighan/base-utils/utest'
import {
	undef, fromJSON, toJSON, OL, chomp, jsType,
	words, hslice, sortArrayOfHashes,
	newerDestFilesExist, isArray,
	} from '@jdeighan/base-utils'
import {LOG} from '@jdeighan/base-utils/log'
import {setDebugging} from '@jdeighan/base-utils/debug'
import {assert} from '@jdeighan/base-utils/exceptions'
import * as lib from '@jdeighan/base-utils/fs'
Object.assign(global, lib)

# --- should be root directory of @jdeighan/base-utils
projDir = workingDir()
dir = mydir(import.meta.url)    # project test folder
subdir = mkpath(dir, 'test')    # subdir test inside test
file = myself(import.meta.url)
testPath = mkpath(projDir, 'test', 'readline.txt')

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
