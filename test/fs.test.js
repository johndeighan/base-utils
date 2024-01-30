// fs.test.coffee
var dir, file, projDir, smDir, subdir, testPath;

import {
  u
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
// --- test allLinesIn()
(() => {
  var lLines, path;
  path = './test/readline3.txt';
  lLines = Array.from(allLinesIn(path));
  return u.equal(lLines, ['ghi', 'jkl', '', 'mno', 'pqr']);
})();

// ---------------------------------------------------------------------------
u.like(parsePath(import.meta.url), {
  type: 'file',
  root: 'c:/',
  base: 'fs.test.js',
  fileName: 'fs.test.js',
  name: 'fs.test',
  stub: 'fs.test',
  ext: '.js',
  purpose: 'test'
});

u.like(parsePath(projDir), {
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

u.like(parsePath(dir), {
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

u.like(parsePath(subdir), {
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

u.like(parsePath(file), {
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

u.like(parsePath(testPath), {
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
u.equal(slurp(testPath, {
  maxLines: 2
}), `abc
def`);

u.equal(slurp(testPath, {
  maxLines: 3
}), `abc
def
ghi`);

u.equal(slurp(testPath, {
  maxLines: 1000
}), `abc
def
ghi
jkl
mno`);

// --- Test without building path first
u.equal(slurp(projDir, 'test', 'readline.txt', {
  maxLines: 2
}), `abc
def`);

u.equal(slurp(projDir, 'test', 'readline.txt', {
  maxLines: 3
}), `abc
def
ghi`);

u.equal(slurp(projDir, 'test', 'readline.txt', {
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
  return u.equal(h, {
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
  return u.like(lFiles, [
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
  u.truthy(isFile(path));
  text = slurp(path);
  return u.equal(text, "line 1\nline 2\n");
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
  return u.equal(result, ['--> def', '--> jkl']);
})();

// ---------------------------------------------------------------------------
// --- test dirContents()
smDir = './test/source-map';

u.equal(dirContents(smDir, '*.coffee').length, 1);

u.equal(dirContents(smDir, '*.js').length, 2);

u.equal(dirContents(smDir, '*').length, 6);

u.equal(dirContents(smDir, '*', 'filesOnly').length, 4);

u.equal(dirContents(smDir, '*', 'dirsOnly').length, 2);

//# sourceMappingURL=fs.test.js.map
