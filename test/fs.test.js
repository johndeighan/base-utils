// fs.test.coffee
var dir, file, projDir, smDir, subdir, testPath;

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
  FileWriterSync,
  dirContents
} from '@jdeighan/base-utils/fs';

// --- should be root directory of @jdeighan/base-utils
projDir = workingDir();

dir = mydir(import.meta.url); // project test folder

subdir = mkpath(dir, 'test'); // subdir test inside test

file = myself(import.meta.url);

testPath = mkpath(projDir, 'test', 'readline.txt');

// ---------------------------------------------------------------------------
utest.like(parsePath(import.meta.url), {
  type: 'file',
  root: 'c:/',
  base: 'fs.test.js',
  fileName: 'fs.test.js',
  name: 'fs.test',
  stub: 'fs.test',
  ext: '.js',
  purpose: 'test'
});

utest.like(parsePath(projDir), {
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

utest.like(parsePath(dir), {
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

utest.like(parsePath(subdir), {
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

utest.like(parsePath(file), {
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

utest.like(parsePath(testPath), {
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
utest.equal(slurp(testPath, {
  maxLines: 2
}), `abc
def`);

utest.equal(slurp(testPath, {
  maxLines: 3
}), `abc
def
ghi`);

utest.equal(slurp(testPath, {
  maxLines: 1000
}), `abc
def
ghi
jkl
mno`);

// --- Test without building path first
utest.equal(slurp(projDir, 'test', 'readline.txt', {
  maxLines: 2
}), `abc
def`);

utest.equal(slurp(projDir, 'test', 'readline.txt', {
  maxLines: 3
}), `abc
def
ghi`);

utest.equal(slurp(projDir, 'test', 'readline.txt', {
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
  return utest.equal(h, {
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
  return utest.like(lFiles, [
    {
      fileName: 'file1.txt',
      metadata: undef,
      lLines: ['Hello']
    },
    {
      fileName: 'file1.zh',
      metadata: undef,
      lLines: ['你好']
    },
    {
      fileName: 'file2.txt',
      metadata: undef,
      lLines: ['Goodbye']
    },
    {
      fileName: 'file2.zh',
      metadata: undef,
      lLines: ['再见']
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

// ---------------------------------------------------------------------------
// --- test forEachItem()
(() => {
  var callback, countGenerator, result;
  countGenerator = function*() {
    yield 1;
    yield 2;
    yield 3;
    yield 4;
  };
  callback = (item, hContext) => {
    if (item > 2) {
      return `${hContext.label} ${item}`;
    } else {
      return undef;
    }
  };
  result = forEachItem(countGenerator(), callback, {
    label: 'X'
  });
  return utest.equal(result, ['X 3', 'X 4']);
})();

// ---------------------------------------------------------------------------
// --- test forEachLineInFile()
(() => {
  var callback, result;
  // --- Contents:
  //        abc
  //        def
  //        ghi
  //        jkl
  //        mno

  callback = (item, hContext) => {
    if ((item === 'def') || (item === 'jkl')) {
      return `${hContext.label} ${item}`;
    } else {
      return undef;
    }
  };
  result = forEachLineInFile(testPath, callback, {
    label: '-->'
  });
  return utest.equal(result, ['--> def', '--> jkl']);
})();

// ---------------------------------------------------------------------------
// --- test dirContents()
smDir = './test/source-map';

utest.equal(dirContents(smDir, '*.coffee').length, 1);

utest.equal(dirContents(smDir, '*.js').length, 2);

utest.equal(dirContents(smDir, '*').length, 6);

utest.equal(dirContents(smDir, '*', 'filesOnly').length, 4);

utest.equal(dirContents(smDir, '*', 'dirsOnly').length, 2);

//# sourceMappingURL=fs.test.js.map
