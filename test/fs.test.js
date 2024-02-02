// fs.test.coffee
var dir, file, projDir, smDir, subdir, testPath;

import {
  u
} from '@jdeighan/base-utils/utest';

import {
  undef,
  fromJSON,
  toJSON,
  LOG,
  chomp,
  jsType
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
  dirContents,
  FileWriter
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

u.equal(slurp(testPath, 'maxLines=3'), `abc
def
ghi`);

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

// ---------------------------------------------------------------------------
(() => {
  var filePath4, lLines, line, ref;
  lLines = [];
  filePath4 = './test/readline4.txt';
  ref = allLinesIn(filePath4);
  for (line of ref) {
    lLines.push(line);
  }
  return u.equal(lLines, ['ghi', 'jkl', '', 'mno', 'pqr']);
})();

// ---------------------------------------------------------------------------
// --- Produce capitalized version, with a prefix "> "
//        skipping blank lines
(() => {
  var filePath3, func, lLines;
  func = (line, hContext) => {
    if (line === '') {
      return undef;
    } else {
      return `${hContext.prefix}${line.toUpperCase()}`;
    }
  };
  filePath3 = './test/readline3.txt';
  lLines = forEachLineInFile(filePath3, func, {
    prefix: '> '
  });
  return u.equal(lLines, ['> GHI', '> JKL', '> MNO', '> PQR']);
})();

// ---------------------------------------------------------------------------
// --- Produce capitalized version, with a prefix "> "
//        skipping blank lines
(() => {
  var filePath4, func, lLines;
  func = (line, hContext) => {
    if (line === '') {
      return undef;
    } else {
      return `${hContext.prefix}${line.toUpperCase()}`;
    }
  };
  filePath4 = './test/readline4.txt';
  lLines = forEachLineInFile(filePath4, func, {
    prefix: '> '
  });
  return u.equal(lLines, ['> GHI', '> JKL', '> MNO', '> PQR']);
})();

// ---------------------------------------------------------------------------
// --- This time, stop processing when a blank line is found
(() => {
  var filePath4, func, lLines;
  func = (line, hContext) => {
    if (line === '') {
      throw 'stop';
    } else {
      return `${hContext.prefix}${line.toUpperCase()}`;
    }
  };
  filePath4 = './test/readline4.txt';
  lLines = forEachLineInFile(filePath4, func, {
    prefix: '> '
  });
  return u.equal(lLines, ['> GHI', '> JKL']);
})();

// ---------------------------------------------------------------------------
(() => {
  var path, text, writer;
  // --- put garbage into the file
  path = './test/testfile.txt';
  barf("garbage...", path);
  writer = new FileWriter(path);
  writer.writeln("line 1");
  writer.writeln("line 2");
  writer.close();
  u.truthy(isFile(path));
  text = slurp(path);
  return u.equal(text, "line 1\nline 2\n");
})();

// ---------------------------------------------------------------------------
(() => {
  var path, text, writer;
  // --- put garbage into the file
  path = './test/testfile.txt';
  barf("garbage...", path);
  writer = new FileWriter(path);
  writer.writeln("line 1");
  writer.writeln("line 2");
  writer.close();
  u.truthy(isFile(path));
  text = slurp(path);
  return u.equal(chomp(text), `line 1
line 2`);
})();

// ---------------------------------------------------------------------------
(() => {
  var path, text, writer;
  // --- put garbage into the file
  path = './test/testfile.txt';
  barf("garbage...", path);
  writer = new FileWriter(path);
  writer.writeln("line 1", " - some text");
  writer.writeln("line 2", " - more text");
  writer.close();
  u.truthy(isFile(path));
  text = slurp(path);
  return u.equal(text, "line 1 - some text\nline 2 - more text\n");
})();

// ---------------------------------------------------------------------------
(async() => {
  var path, text, writer;
  // --- put garbage into the file
  path = './test/testfile.txt';
  barf("garbage...", path);
  writer = new FileWriter(path, {
    async: true
  });
  await writer.writeln("line 1");
  await writer.writeln("line 2");
  await writer.close();
  u.truthy(isFile(path));
  text = slurp(path);
  return u.equal(text, "line 1\nline 2\n");
})();

//# sourceMappingURL=fs.test.js.map
