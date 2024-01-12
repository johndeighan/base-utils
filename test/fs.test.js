// fs.test.coffee
var dir, testDir, testPath;

import test from 'ava';

import {
  undef,
  defined,
  notdefined,
  LOG
} from '@jdeighan/base-utils';

import {
  setDebugging
} from '@jdeighan/base-utils/debug';

import {
  mkpath
} from '@jdeighan/base-utils/ll-fs';

import {
  resolve,
  pathType,
  getPkgJsonDir,
  getPkgJsonPath,
  fileExists,
  isFile,
  rmFile,
  dirExists,
  isDir,
  mkdir,
  rmDir,
  fromJSON,
  toJSON,
  slurp,
  slurpJSON,
  slurpTAML,
  slurpPkgJSON,
  barf,
  barfJSON,
  barfTAML,
  barfPkgJSON,
  parseSource,
  getTextFileContents,
  allFilesIn,
  allLinesIn,
  forEachFileInDir,
  forEachItem,
  forEachLineInFile,
  FileWriter,
  FileWriterSync,
  FileProcessor
} from '@jdeighan/base-utils/fs';

dir = process.cwd(); // should be root directory of @jdeighan/base-utils

testDir = mkpath(dir, 'test');

testPath = mkpath(dir, 'test', 'readline.txt');

// ---------------------------------------------------------------------------
// --- test pathType
test("line 29", (t) => {
  return t.throws(() => {
    return pathType(42);
  });
});

test("line 30", (t) => {
  return t.is(pathType('.'), 'dir');
});

test("line 31", (t) => {
  return t.is(pathType('./package.json'), 'file');
});

test("line 32", (t) => {
  return t.is(pathType('./package2.json'), 'missing');
});

test("line 34", (t) => {
  return t.throws(() => {
    return pathType(['a']);
  });
});

test("line 35", (t) => {
  return t.is(pathType('.', 'test'), 'dir');
});

test("line 36", (t) => {
  return t.is(pathType('.', 'package.json'), 'file');
});

test("line 37", (t) => {
  return t.is(pathType('.', 'package2.json'), 'missing');
});

// ---------------------------------------------------------------------------
test("line 41", (t) => {
  return t.truthy(isFile(mkpath(dir, 'package.json')));
});

test("line 42", (t) => {
  return t.falsy(isFile(mkpath(dir, 'doesNotExist.txt')));
});

test("line 43", (t) => {
  return t.truthy(isDir(mkpath(dir, 'src')));
});

test("line 44", (t) => {
  return t.truthy(isDir(mkpath(dir, 'test')));
});

test("line 45", (t) => {
  return t.falsy(isDir(mkpath(dir, 'doesNotExist')));
});

test("line 47", (t) => {
  return t.is(slurp(testPath, {
    maxLines: 2
  }), `abc
def`);
});

test("line 52", (t) => {
  return t.is(slurp(testPath, {
    maxLines: 3
  }), `abc
def
ghi`);
});

test("line 58", (t) => {
  return t.is(slurp(testPath, {
    maxLines: 1000
  }), `abc
def
ghi
jkl
mno`);
});

// --- Test without building path first
test("line 68", (t) => {
  return t.is(slurp(dir, 'test', 'readline.txt', {
    maxLines: 2
  }), `abc
def`);
});

test("line 73", (t) => {
  return t.is(slurp(dir, 'test', 'readline.txt', {
    maxLines: 3
  }), `abc
def
ghi`);
});

test("line 79", (t) => {
  return t.is(slurp(dir, 'test', 'readline.txt', {
    maxLines: 1000
  }), `abc
def
ghi
jkl
mno`);
});

// ---------------------------------------------------------------------------
// --- test FileProcessor
(() => {
  var TestProcessor, fp;
  TestProcessor = class TestProcessor extends FileProcessor {
    constructor() {
      super('./test');
    }

    begin() {
      // --- We need to clear out hWords each time go() is called
      this.hWords = {};
    }

    filter(hFileInfo) {
      var ext, stub;
      ({stub, ext} = hFileInfo);
      return (ext === '.txt') && stub.match(/^readline/);
    }

    handleLine(line) {
      this.hWords[line.toUpperCase()] = true;
    }

  };
  fp = new TestProcessor();
  fp.go();
  return test("line 111", (t) => {
    return t.deepEqual(fp.hWords, {
      'ABC': true,
      'DEF': true,
      'GHI': true,
      'JKL': true,
      'MNO': true,
      'PQR': true
    });
  });
})();

// ---------------------------------------------------------------------------
// --- test getTextFileContents
(() => {
  var h, path;
  path = "./test/test/file3.txt";
  h = getTextFileContents(path);
  return test("line 128", (t) => {
    return t.deepEqual(h, {
      metadata: {
        fName: 'John',
        lName: 'Deighan'
      },
      lLines: ['', 'This is a test']
    });
  });
})();

// ---------------------------------------------------------------------------
// --- test allFilesIn
(() => {
  var hFileInfo, lFiles, ref;
  lFiles = [];
  ref = allFilesIn('./test/test', {
    eager: true
  });
  for (hFileInfo of ref) {
    lFiles.push(hFileInfo);
  }
  return test("line 142", (t) => {
    return t.like(lFiles, [
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
  });
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
  test("line 169", (t) => {
    return t.truthy(isFile(path));
  });
  text = slurp(path);
  return test("line 172", (t) => {
    return t.is(text, "line 1\nline 2\n");
  });
})();

//# sourceMappingURL=fs.test.js.map
