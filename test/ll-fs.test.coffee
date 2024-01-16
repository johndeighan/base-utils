# ll-fs.test.coffee

import {undef, LOG} from '@jdeighan/base-utils'
import {utest} from '@jdeighan/base-utils/utest'
import {
	myself, mydir, mkpath, mkDir, touch, isFile, isDir,
	pathType, rmFile, rmDir, parsePath,
	} from '@jdeighan/base-utils/ll-fs'

dir = mydir(import.meta.url)
subdir = mkpath(dir, 'test')

# ---------------------------------------------------------------------------

utest.equal 15, mkpath('C:\\test\\me'), 'c:/test/me'
utest.equal 16, mkpath('c:/test/me', 'def'), 'c:/test/me/def'
utest.equal 17, mkpath('c:\\Users', 'johnd'), 'c:/Users/johnd'

utest.equal 19, mkpath('C:\\test\\me'), 'c:/test/me'
utest.equal 20, mkpath('c:\\test\\me'), 'c:/test/me'
utest.equal 21, mkpath('C:/test/me'), 'c:/test/me'
utest.equal 22, mkpath('c:/test/me'), 'c:/test/me'

# --- Test providing multiple args
utest.equal 25, mkpath('c:/', 'test', 'me'), 'c:/test/me'
utest.equal 26, mkpath('c:\\', 'test', 'me'), 'c:/test/me'

# --- The following exists in the test folder:
#        test/
#           file1.txt
#           file1.zh
#           file2.txt
#           file2.zh
#           file3.txt

utest.truthy 36, isDir(mkpath(dir, 'test'))
utest.falsy  37, isDir(mkpath(dir, 'xxxxx'))
utest.truthy 38, isFile(mkpath(dir, 'test', 'file1.txt'))
utest.truthy 39, isFile(mkpath(dir, 'test', 'file1.zh'))
utest.falsy  40, isFile(mkpath(dir, 'test', 'file1'))

utest.throws 42, () -> pathType(42)
utest.fails 43, () -> pathType(42)
utest.equal 44, pathType(':::::'), 'missing'

# --- Test creating dir, then deleting dir
dir2 = mkpath(subdir, 'test2')
utest.falsy 48, isDir(dir2)
utest.equal 49, pathType(dir2), 'missing'
mkDir dir2
utest.truthy 51, isDir(dir2)
utest.equal 52, pathType(dir2), 'dir'
if (dir == 'c:/User/johnd/base-utils/test')
	utest.equal 54, parsePath(dir2), {
		root: 'c:/'
		dir: 'c:/Users/johnd/base-utils/test/test'
		}
rmDir dir2
utest.falsy 59, isDir(dir2)

# --- Test creating file, then deleting dir
file2 = mkpath(subdir, 'file99.test.txt')
utest.falsy 63, isFile(file2)
utest.equal 64, pathType(file2), 'missing'
touch file2
utest.truthy 66, isFile(file2)
utest.equal 67, pathType(file2), 'file'
if (dir == 'c:/User/johnd/base-utils/test')
	utest.equal 69, parsePath(file2), {
		root: 'c:/'
		dir: 'c:/Users/johnd/base-utils/test/test'
		fileName: 'file99.test.txt'
		filePath: 'c:/Users/johnd/base-utils/test/test/file99.test.txt'
		stub: 'file99.test'
		ext: '.txt'
		purpose: 'test'
		}
rmFile file2
utest.falsy 79, isFile(file2)
