# fs.test.coffee

import test from 'ava'
import {
	isFile, isDir, mkpath, mkdirSync, slurp, barf, forEachFileInDir,
	} from '@jdeighan/base-utils/fs'

dir = process.cwd()     # should be root directory of @jdeighan/base-utils

# ---------------------------------------------------------------------------

test "line 10", (t) => t.is(mkpath("abc","def"), "abc/def")
test "line 11", (t) => t.is(mkpath("c:\\Users","johnd"), "c:/Users/johnd")
test "line 12", (t) => t.is(mkpath("C:\\Users","johnd"), "c:/Users/johnd")

test "line 14", (t) => t.truthy(isFile(mkpath(dir, 'package.json')))
test "line 15", (t) => t.falsy (isFile(mkpath(dir, 'doesNotExist.txt')))
test "line 16", (t) => t.truthy(isDir(mkpath(dir, 'src')))
test "line 17", (t) => t.truthy(isDir(mkpath(dir, 'test')))
test "line 18", (t) => t.falsy (isDir(mkpath(dir, 'doesNotExist')))
