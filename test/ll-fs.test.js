// ll-fs.test.coffee
var dir, dir2, file2, subdir;

import {
  undef,
  LOG,
  samelist
} from '@jdeighan/base-utils';

import {
  utest
} from '@jdeighan/base-utils/utest';

import {
  myself,
  mydir,
  mkpath,
  mkDir,
  touch,
  isFile,
  isDir,
  pathType,
  rmFile,
  rmDir,
  parsePath,
  rename,
  clearDir,
  dirContents
} from '@jdeighan/base-utils/ll-fs';

dir = mydir(import.meta.url);

subdir = mkpath(dir, 'test');

// ---------------------------------------------------------------------------
utest.equal(15, mkpath('C:\\test\\me'), 'c:/test/me');

utest.equal(16, mkpath('c:/test/me', 'def'), 'c:/test/me/def');

utest.equal(17, mkpath('c:\\Users', 'johnd'), 'c:/Users/johnd');

utest.equal(19, mkpath('C:\\test\\me'), 'c:/test/me');

utest.equal(20, mkpath('c:\\test\\me'), 'c:/test/me');

utest.equal(21, mkpath('C:/test/me'), 'c:/test/me');

utest.equal(22, mkpath('c:/test/me'), 'c:/test/me');

// --- Test providing multiple args
utest.equal(25, mkpath('c:/', 'test', 'me'), 'c:/test/me');

utest.equal(26, mkpath('c:\\', 'test', 'me'), 'c:/test/me');

// --- The following exists in the test folder:
//        test/
//           file1.txt
//           file1.zh
//           file2.txt
//           file2.zh
//           file3.txt
utest.truthy(36, isDir(mkpath(dir, 'test')));

utest.falsy(37, isDir(mkpath(dir, 'xxxxx')));

utest.truthy(38, isFile(mkpath(dir, 'test', 'file1.txt')));

utest.truthy(39, isFile(mkpath(dir, 'test', 'file1.zh')));

utest.falsy(40, isFile(mkpath(dir, 'test', 'file1')));

utest.throws(42, function() {
  return pathType(42);
});

utest.fails(43, function() {
  return pathType(42);
});

utest.equal(44, pathType(':::::'), 'missing');

// --- Test creating dir, then deleting dir
dir2 = mkpath(subdir, 'test2');

utest.falsy(48, isDir(dir2));

utest.equal(49, pathType(dir2), 'missing');

mkDir(dir2);

utest.truthy(51, isDir(dir2));

utest.equal(52, pathType(dir2), 'dir');

if (dir === 'c:/User/johnd/base-utils/test') {
  utest.equal(54, parsePath(dir2), {
    root: 'c:/',
    dir: 'c:/Users/johnd/base-utils/test/test'
  });
}

rmDir(dir2);

utest.falsy(59, isDir(dir2));

// --- Test creating file, then deleting dir
file2 = mkpath(subdir, 'file99.test.txt');

utest.falsy(63, isFile(file2));

utest.equal(64, pathType(file2), 'missing');

touch(file2);

utest.truthy(66, isFile(file2));

utest.equal(67, pathType(file2), 'file');

if (dir === 'c:/Users/johnd/base-utils/test') {
  utest.equal(69, parsePath(dir), {
    root: 'c:/',
    dir: 'c:/Users/johnd/base-utils/test', // parent directory
    lDirs: ['c:', 'Users', 'johnd', 'base-utils', 'test']
  });
  utest.equal(74, parsePath(file2), {
    dir: 'c:/Users/johnd/base-utils/test/test',
    ext: '.txt',
    fileName: 'file99.test.txt',
    filePath: 'c:/Users/johnd/base-utils/test/test/file99.test.txt',
    lDirs: ['c:', 'Users', 'johnd', 'base-utils', 'test', 'test'],
    purpose: 'test',
    root: 'c:/',
    stub: 'file99.test'
  });
}

rmFile(file2);

utest.falsy(85, isFile(file2));

// ---------------------------------------------------------------------------
(() => {
  var dirPath, file1, file3;
  dirPath = "./test/tempdir";
  file1 = mkpath(dirPath, 'file1.txt');
  file2 = mkpath(dirPath, 'file2.txt');
  file3 = mkpath(dirPath, 'file3.txt');
  utest.falsy(95, isDir(dirPath));
  mkDir(dirPath);
  utest.truthy(97, isDir(dirPath));
  touch(file1);
  touch(file2);
  utest.truthy(102, isFile(file1));
  utest.truthy(103, isFile(file2));
  utest.falsy(104, isFile(file3));
  utest.equal(106, pathType(dirPath), 'dir');
  utest.equal(107, pathType(file2), 'file');
  utest.equal(108, pathType(file3), 'missing');
  utest.truthy(110, samelist(dirContents(dirPath), ['file1.txt', 'file2.txt']));
  rename(file2, file3);
  utest.truthy(112, samelist(dirContents(dirPath), ['file1.txt', 'file3.txt']));
  rmFile(file1);
  utest.truthy(114, samelist(dirContents(dirPath), ['file3.txt']));
  clearDir(dirPath);
  utest.truthy(116, samelist(dirContents(dirPath), []));
  utest.truthy(118, isDir(dirPath));
  rmDir(dirPath);
  return utest.falsy(120, isDir(dirPath));
})();

//# sourceMappingURL=ll-fs.test.js.map
