// ll-fs.test.coffee
var dir, dir2, file2, newpath, newpath2, newpath3, newpath4, path, subdir;

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
  dirContents,
  parallelPath,
  subPath
} from '@jdeighan/base-utils/ll-fs';

dir = mydir(import.meta.url);

subdir = mkpath(dir, 'test');

// ---------------------------------------------------------------------------
utest.equal(mkpath('C:\\test\\me'), 'c:/test/me');

utest.equal(mkpath('c:/test/me', 'def'), 'c:/test/me/def');

utest.equal(mkpath('c:\\Users', 'johnd'), 'c:/Users/johnd');

utest.equal(mkpath('C:\\test\\me'), 'c:/test/me');

utest.equal(mkpath('c:\\test\\me'), 'c:/test/me');

utest.equal(mkpath('C:/test/me'), 'c:/test/me');

utest.equal(mkpath('c:/test/me'), 'c:/test/me');

// --- Test providing multiple args
utest.equal(mkpath('c:/', 'test', 'me'), 'c:/test/me');

utest.equal(mkpath('c:\\', 'test', 'me'), 'c:/test/me');

// --- The following exists in the test folder:
//        test/
//           file1.txt
//           file1.zh
//           file2.txt
//           file2.zh
//           file3.txt
utest.truthy(isDir(mkpath(dir, 'test')));

utest.falsy(isDir(mkpath(dir, 'xxxxx')));

utest.truthy(isFile(mkpath(dir, 'test', 'file1.txt')));

utest.truthy(isFile(mkpath(dir, 'test', 'file1.zh')));

utest.falsy(isFile(mkpath(dir, 'test', 'file1')));

utest.throws(function() {
  return pathType(42);
});

utest.throws(function() {
  return pathType(42);
});

utest.equal(pathType(':::::'), 'missing');

// --- Test creating dir, then deleting dir
dir2 = mkpath(subdir, 'test2');

utest.falsy(isDir(dir2));

utest.equal(pathType(dir2), 'missing');

mkDir(dir2);

utest.truthy(isDir(dir2));

utest.equal(pathType(dir2), 'dir');

if (dir === 'c:/User/johnd/base-utils/test') {
  utest.equal(parsePath(dir2), {
    root: 'c:/',
    dir: 'c:/Users/johnd/base-utils/test/test'
  });
}

rmDir(dir2);

utest.falsy(isDir(dir2));

// --- Test creating file, then deleting dir
file2 = mkpath(subdir, 'file99.test.txt');

utest.falsy(isFile(file2));

utest.equal(pathType(file2), 'missing');

touch(file2);

utest.truthy(isFile(file2));

utest.equal(pathType(file2), 'file');

if (dir === 'c:/Users/johnd/base-utils/test') {
  utest.like(parsePath(dir), {
    base: 'test',
    dir: 'c:/Users/johnd/base-utils',
    ext: '',
    fileName: 'test',
    filePath: 'c:/Users/johnd/base-utils/test',
    name: 'test',
    path: 'c:/Users/johnd/base-utils/test',
    purpose: undef,
    root: 'c:/',
    stub: 'test',
    type: 'dir'
  });
  utest.like(parsePath(file2), {
    base: 'file99.test.txt',
    dir: 'c:/Users/johnd/base-utils/test/test',
    ext: '.txt',
    fileName: 'file99.test.txt',
    filePath: 'c:/Users/johnd/base-utils/test/test/file99.test.txt',
    name: 'file99.test',
    path: 'c:/Users/johnd/base-utils/test/test/file99.test.txt',
    purpose: 'test',
    root: 'c:/',
    stub: 'file99.test',
    type: 'file'
  });
}

rmFile(file2);

utest.falsy(isFile(file2));

// ---------------------------------------------------------------------------
(() => {
  var dirPath, file1, file3;
  dirPath = "./test/tempdir";
  file1 = mkpath(dirPath, 'file1.txt');
  file2 = mkpath(dirPath, 'file2.txt');
  file3 = mkpath(dirPath, 'file3.txt');
  utest.falsy(isDir(dirPath));
  mkDir(dirPath);
  utest.truthy(isDir(dirPath));
  touch(file1);
  touch(file2);
  utest.truthy(isFile(file1));
  utest.truthy(isFile(file2));
  utest.falsy(isFile(file3));
  utest.equal(pathType(dirPath), 'dir');
  utest.equal(pathType(file2), 'file');
  utest.equal(pathType(file3), 'missing');
  utest.truthy(samelist(dirContents(dirPath), ['file1.txt', 'file2.txt']));
  rename(file2, file3);
  utest.truthy(samelist(dirContents(dirPath), ['file1.txt', 'file3.txt']));
  rmFile(file1);
  utest.truthy(samelist(dirContents(dirPath), ['file3.txt']));
  clearDir(dirPath);
  utest.truthy(samelist(dirContents(dirPath), []));
  utest.truthy(isDir(dirPath));
  rmDir(dirPath);
  return utest.falsy(isDir(dirPath));
})();

// ---------------------------------------------------------------------------
// --- test parallelPath
path = 'c:/Users/johnd/base-utils/src/lib/indent.coffee';

newpath = 'c:/Users/johnd/base-utils/src/temp/indent.coffee';

utest.equal(parallelPath(path), newpath);

// path   = 'c:/Users/johnd/base-utils/src/lib/indent.coffee'
newpath2 = 'c:/Users/johnd/base-utils/src/dummy/indent.coffee';

utest.equal(parallelPath(path, 'dummy'), newpath2);

// path   = 'c:/Users/johnd/base-utils/src/lib/indent.coffee'
newpath3 = 'c:/Users/johnd/base-utils/src/lib/temp/indent.coffee';

utest.equal(subPath(path), newpath3);

// path   = 'c:/Users/johnd/base-utils/src/lib/indent.coffee'
newpath4 = 'c:/Users/johnd/base-utils/src/lib/dummy/indent.coffee';

utest.equal(subPath(path, 'dummy'), newpath4);

//# sourceMappingURL=ll-fs.test.js.map
