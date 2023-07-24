// fs.test.coffee
var dir, testDir, testPath;

import test from 'ava';

import {
  undef,
  defined
} from '@jdeighan/base-utils';

import {
  setDebugging
} from '@jdeighan/base-utils/debug';

import {
  isFile,
  isDir,
  mkpath,
  mkdirSync,
  slurp,
  barf,
  forEachFileInDir,
  forEachItem,
  forEachLineInFile,
  FileProcessor
} from '@jdeighan/base-utils/fs';

dir = process.cwd(); // should be root directory of @jdeighan/base-utils

testDir = mkpath(dir, 'test');

testPath = mkpath(dir, 'test', 'readline.txt');

// ---------------------------------------------------------------------------
test("line 17", (t) => {
  return t.is(mkpath("abc", "def"), "abc/def");
});

test("line 18", (t) => {
  return t.is(mkpath("c:\\Users", "johnd"), "c:/Users/johnd");
});

test("line 19", (t) => {
  return t.is(mkpath("C:\\Users", "johnd"), "c:/Users/johnd");
});

test("line 21", (t) => {
  return t.truthy(isFile(mkpath(dir, 'package.json')));
});

test("line 22", (t) => {
  return t.falsy(isFile(mkpath(dir, 'doesNotExist.txt')));
});

test("line 23", (t) => {
  return t.truthy(isDir(mkpath(dir, 'src')));
});

test("line 24", (t) => {
  return t.truthy(isDir(mkpath(dir, 'test')));
});

test("line 25", (t) => {
  return t.falsy(isDir(mkpath(dir, 'doesNotExist')));
});

test("line 27", (t) => {
  return t.truthy(isFile(dir, 'package.json'));
});

test("line 28", (t) => {
  return t.falsy(isFile(dir, 'doesNotExist.txt'));
});

test("line 29", (t) => {
  return t.truthy(isDir(dir, 'src'));
});

test("line 30", (t) => {
  return t.truthy(isDir(dir, 'test'));
});

test("line 31", (t) => {
  return t.falsy(isDir(dir, 'doesNotExist'));
});

test("line 33", (t) => {
  return t.is(slurp(testPath, {
    maxLines: 2
  }), `abc
def`);
});

test("line 38", (t) => {
  return t.is(slurp(testPath, {
    maxLines: 3
  }), `abc
def
ghi`);
});

test("line 44", (t) => {
  return t.is(slurp(testPath, {
    maxLines: 1000
  }), `abc
def
ghi
jkl
mno`);
});

// --- Test without building path first
test("line 54", (t) => {
  return t.is(slurp(dir, 'test', 'readline.txt', {
    maxLines: 2
  }), `abc
def`);
});

test("line 59", (t) => {
  return t.is(slurp(dir, 'test', 'readline.txt', {
    maxLines: 3
  }), `abc
def
ghi`);
});

test("line 65", (t) => {
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
  var TestProcessor, fp, lItems;
  TestProcessor = class TestProcessor extends FileProcessor {
    constructor() {
      super('./test');
    }

    filter() {
      var ext, stub;
      ({stub, ext} = this.hOptions);
      return (ext === '.txt') && stub.match(/^readline/);
    }

    init() {
      // --- We need to clear out hWords each time all() is called
      this.hOptions.hWords = {};
    }

    handleLine(line) {
      var hWords;
      ({hWords} = this.hOptions);
      if (hWords.hasOwnProperty(line)) {
        return undef;
      }
      hWords[line] = true;
      return line.toUpperCase();
    }

  };
  fp = new TestProcessor();
  lItems = fp.getAll();
  return test("line 100", (t) => {
    return t.deepEqual(lItems, ['ABC', 'DEF', 'GHI', 'JKL', 'MNO', 'PQR']);
  });
})();
