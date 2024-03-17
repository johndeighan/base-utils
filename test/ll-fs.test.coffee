# ll-fs.test.coffee

import {undef, LOG, OL, samelist} from '@jdeighan/base-utils'
import {
	UnitTester,
	equal, like, notequal, succeeds, throws, truthy, falsy,
	} from '@jdeighan/base-utils/utest'
import {
	myself, mydir, mkpath, relpath, mkDir, touch,
	isFile, isDir,
	pathType, rmFile, rmDir, parsePath, rename, clearDir,
	dirContents, parallelPath, subPath,
	} from '@jdeighan/base-utils/ll-fs'

dir = mydir(import.meta.url)
subdir = mkpath(dir, 'test')
curdir = mkpath(process.cwd())   # will have '/'

# ---------------------------------------------------------------------------

equal mkpath('C:\\test\\me'), 'c:/test/me'
equal mkpath('c:/test/me', 'def'), 'c:/test/me/def'
equal mkpath('c:\\Users', 'johnd'), 'c:/Users/johnd'

equal mkpath('C:\\test\\me'), 'c:/test/me'
equal mkpath('c:\\test\\me'), 'c:/test/me'
equal mkpath('C:/test/me'), 'c:/test/me'
equal mkpath('c:/test/me'), 'c:/test/me'

# --- Test providing multiple args
equal mkpath('c:/', 'test', 'me'), 'c:/test/me'
equal mkpath('c:\\', 'test', 'me'), 'c:/test/me'

# --- The following exists in the test folder:
#        test/
#           file1.txt
#           file1.zh
#           file2.txt
#           file2.zh
#           file3.txt

truthy isDir(mkpath(dir, 'test'))
falsy  isDir(mkpath(dir, 'xxxxx'))
truthy isFile(mkpath(dir, 'test', 'file1.txt'))
truthy isFile(mkpath(dir, 'test', 'file1.zh'))
falsy  isFile(mkpath(dir, 'test', 'file1'))

throws () -> pathType(42)
equal pathType(':::::'), 'missing'

# --- parsePath() works even if the file doesn't exist
like parsePath("dummyfile.txt"), {
	fileName: 'dummyfile.txt'
	base: 'dummyfile.txt'
	dir: curdir
	ext: '.txt'
	filePath: "#{curdir}/dummyfile.txt"
	path: "#{curdir}/dummyfile.txt"
	name: 'dummyfile'
	purpose: undef
	root: 'c:/'
	stub: 'dummyfile'
	type: 'missing'
	}

# --- Test creating dir, then deleting dir
dir2 = mkpath(subdir, 'test2')
falsy isDir(dir2)
equal pathType(dir2), 'missing'
mkDir dir2
truthy isDir(dir2)
equal pathType(dir2), 'dir'
if (dir == "#{curdir}/test")
	like parsePath(dir2), {
		root: 'c:/'
		dir: "#{curdir}/test/test"
		}
rmDir dir2
falsy isDir(dir2)

# --- Test creating file, then deleting dir
file2 = mkpath(subdir, 'file99.test.txt')
falsy isFile(file2)
equal pathType(file2), 'missing'
touch file2
truthy isFile(file2)
equal pathType(file2), 'file'
if (dir == "#{curdir}/test")
	like parsePath(dir), {
		base: 'test'
		dir: curdir
		ext: ''
		fileName: 'test'
		filePath: "#{curdir}/test"
		name: 'test'
		path: "#{curdir}/test"
		purpose: undef
		root: 'c:/'
		stub: 'test'
		type: 'dir'
		}
	like parsePath(file2), {
		base: 'file99.test.txt'
		dir: "#{curdir}/test/test"
		ext: '.txt'
		fileName: 'file99.test.txt'
		filePath: "#{curdir}/test/test/file99.test.txt"
		name: 'file99.test'
		path: "#{curdir}/test/test/file99.test.txt"
		purpose: 'test'
		root: 'c:/'
		stub: 'file99.test'
		type: 'file'
		}
rmFile file2
falsy isFile(file2)

# ---------------------------------------------------------------------------

(() =>
	dirPath = "./test/tempdir"
	file1 = mkpath(dirPath, 'file1.txt')
	file2 = mkpath(dirPath, 'file2.txt')
	file3 = mkpath(dirPath, 'file3.txt')

	falsy  isDir(dirPath)
	mkDir dirPath
	truthy isDir(dirPath)

	touch file1
	touch file2

	truthy isFile(file1)
	truthy isFile(file2)
	falsy  isFile(file3)

	equal pathType(dirPath), 'dir'
	equal pathType(file2), 'file'
	equal pathType(file3), 'missing'

	truthy samelist(dirContents(dirPath), ['file1.txt','file2.txt'])
	rename file2, file3
	truthy samelist(dirContents(dirPath), ['file1.txt','file3.txt'])
	rmFile file1
	truthy samelist(dirContents(dirPath), ['file3.txt'])
	clearDir dirPath
	truthy samelist(dirContents(dirPath), [])

	truthy isDir(dirPath)
	rmDir dirPath
	falsy  isDir(dirPath)
	)()

# ---------------------------------------------------------------------------
# --- test parallelPath

path    = "#{curdir}/src/lib/indent.coffee"
newpath = "#{curdir}/src/temp/indent.coffee"
equal parallelPath(path), newpath

# path   = "#{curdir}/src/lib/indent.coffee"
newpath2 = "#{curdir}/src/dummy/indent.coffee"
equal parallelPath(path, 'dummy'), newpath2

# path   = "#{curdir}/src/lib/indent.coffee"
newpath3 = "#{curdir}/src/lib/temp/indent.coffee"
equal subPath(path), newpath3

# path   = "#{curdir}/src/lib/indent.coffee"
newpath4 = "#{curdir}/src/lib/dummy/indent.coffee"
equal subPath(path, 'dummy'), newpath4

# ---------------------------------------------------------------------------
# --- test relpath

equal relpath("#{curdir}/test/test/file3.txt"), "test/test/file3.txt"
