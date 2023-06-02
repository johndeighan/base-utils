# fs.test.coffee

import test from 'ava'
import {setDebugging} from '@jdeighan/base-utils/debug'
import {
	isFile, isDir, mkpath, mkdirSync, slurp, barf, forEachFileInDir,
	} from '@jdeighan/base-utils/fs'

dir = process.cwd()     # should be root directory of @jdeighan/base-utils

# ---------------------------------------------------------------------------

test "line 13", (t) => t.is(mkpath("abc","def"), "abc/def")
test "line 14", (t) => t.is(mkpath("c:\\Users","johnd"), "c:/Users/johnd")
test "line 15", (t) => t.is(mkpath("C:\\Users","johnd"), "c:/Users/johnd")

test "line 17", (t) => t.truthy(isFile(mkpath(dir, 'package.json')))
test "line 18", (t) => t.falsy (isFile(mkpath(dir, 'doesNotExist.txt')))
test "line 19", (t) => t.truthy(isDir(mkpath(dir, 'src')))
test "line 20", (t) => t.truthy(isDir(mkpath(dir, 'test')))
test "line 21", (t) => t.falsy (isDir(mkpath(dir, 'doesNotExist')))

test "line 23", (t) => t.truthy(isFile(dir, 'package.json'))
test "line 24", (t) => t.falsy (isFile(dir, 'doesNotExist.txt'))
test "line 25", (t) => t.truthy(isDir(dir, 'src'))
test "line 26", (t) => t.truthy(isDir(dir, 'test'))
test "line 27", (t) => t.falsy (isDir(dir, 'doesNotExist'))
