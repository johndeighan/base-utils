// fs.test.coffee
var dir, file, projDir, subdir, testPath;

import {
  utest
} from '@jdeighan/base-utils/utest';

import {
  undef,
  fromJSON,
  toJSON,
  LOG
} from '@jdeighan/base-utils';

import {
  setDebugging
} from '@jdeighan/base-utils/debug';

import {
  workingDir,
  parentDir,
  myself,
  mydir,
  mkpath,
  isFile,
  getPkgJsonDir,
  getPkgJsonPath,
  slurp,
  slurpJSON,
  slurpTAML,
  slurpPkgJSON,
  barf,
  barfJSON,
  barfTAML,
  barfPkgJSON,
  parsePath,
  getTextFileContents,
  allFilesIn,
  allLinesIn,
  forEachFileInDir,
  forEachItem,
  forEachLineInFile,
  FileWriter,
  FileWriterSync
} from '@jdeighan/base-utils/fs';

// --- should be root directory of @jdeighan/base-utils
projDir = workingDir();

dir = mydir(import.meta.url); // project test folder

subdir = mkpath(dir, 'test'); // subdir test inside test

file = myself(import.meta.url);

testPath = mkpath(projDir, 'test', 'readline.txt');

// ---------------------------------------------------------------------------
utest.like(24, parsePath(import.meta.url), {
  type: 'file',
  root: 'c:/',
  base: 'fs.test.js',
  fileName: 'fs.test.js',
  name: 'fs.test',
  stub: 'fs.test',
  ext: '.js',
  purpose: 'test'
});

utest.like(36, parsePath(projDir), {
  path: projDir,
  type: 'dir',
  root: 'c:/',
  dir: parentDir(projDir),
  base: 'base-utils',
  fileName: 'base-utils',
  name: 'base-utils',
  stub: 'base-utils',
  ext: '',
  purpose: undef
});

utest.like(49, parsePath(dir), {
  path: dir,
  type: 'dir',
  root: 'c:/',
  dir: parentDir(dir),
  base: 'test',
  fileName: 'test',
  name: 'test',
  stub: 'test',
  ext: '',
  purpose: undef
});

utest.like(62, parsePath(subdir), {
  path: subdir,
  type: 'dir',
  root: 'c:/',
  dir: parentDir(subdir),
  base: 'test',
  fileName: 'test',
  name: 'test',
  stub: 'test',
  ext: '',
  purpose: undef
});

utest.like(75, parsePath(file), {
  path: file,
  type: 'file',
  root: 'c:/',
  dir: parentDir(file),
  base: 'fs.test.js',
  fileName: 'fs.test.js',
  name: 'fs.test',
  stub: 'fs.test',
  ext: '.js',
  purpose: 'test'
});

utest.like(88, parsePath(testPath), {
  path: testPath,
  type: 'file',
  root: 'c:/',
  dir: parentDir(testPath),
  base: 'readline.txt',
  fileName: 'readline.txt',
  name: 'readline',
  stub: 'readline',
  ext: '.txt',
  purpose: undef
});

// ---------------------------------------------------------------------------
utest.equal(43, slurp(testPath, {
  maxLines: 2
}), `abc
def`);

utest.equal(48, slurp(testPath, {
  maxLines: 3
}), `abc
def
ghi`);

utest.equal(54, slurp(testPath, {
  maxLines: 1000
}), `abc
def
ghi
jkl
mno`);

// --- Test without building path first
utest.equal(64, slurp(projDir, 'test', 'readline.txt', {
  maxLines: 2
}), `abc
def`);

utest.equal(69, slurp(projDir, 'test', 'readline.txt', {
  maxLines: 3
}), `abc
def
ghi`);

utest.equal(75, slurp(projDir, 'test', 'readline.txt', {
  maxLines: 1000
}), `abc
def
ghi
jkl
mno`);

// ---------------------------------------------------------------------------
// --- test getTextFileContents
(() => {
  var h, path;
  path = "./test/test/file3.txt";
  h = getTextFileContents(path);
  return utest.equal(124, h, {
    metadata: {
      fName: 'John',
      lName: 'Deighan'
    },
    lLines: ['', 'This is a test']
  });
})();

// ---------------------------------------------------------------------------
// --- test allFilesIn
(() => {
  var hFileInfo, lFiles, ref;
  lFiles = [];
  ref = allFilesIn('./test/test', 'eager');
  for (hFileInfo of ref) {
    lFiles.push(hFileInfo);
  }
  return utest.like(138, lFiles, [
    {
      fileName: 'file1.txt',
      metadata: undef,
      lLines: ['DONE']
    },
    {
      fileName: 'file1.zh',
      metadata: undef,
      lLines: ['DONE']
    },
    {
      fileName: 'file2.txt',
      metadata: undef,
      lLines: ['DONE']
    },
    {
      fileName: 'file2.zh',
      metadata: undef,
      lLines: ['DONE']
    },
    {
      fileName: 'file3.txt',
      metadata: {
        fName: 'John',
        lName: 'Deighan'
      },
      lLines: ['',
    'This is a test']
    }
  ]);
})();

// ---------------------------------------------------------------------------
(() => {
  var path, text, writer;
  path = './test/testfile.txt';
  // --- put garbage into the file
  barf("garbage...", path);
  writer = new FileWriterSync(path);
  writer.writeln("line 1");
  writer.writeln("line 2");
  writer.end();
  utest.truthy(165, isFile(path));
  text = slurp(path);
  return utest.equal(168, text, "line 1\nline 2\n");
})();

//# sourceMappingURL=fs.test.js.map
