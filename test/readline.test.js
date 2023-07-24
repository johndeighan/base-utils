// readline.test.coffee
var dir, testDir, testPath;

import test from 'ava';

import {
  undef
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
  fileIterator,
  forEachLineInFile
} from '@jdeighan/base-utils/fs';

dir = process.cwd(); // should be root directory of @jdeighan/base-utils

testDir = mkpath(dir, 'test');

testPath = mkpath(dir, 'test', 'readline.txt');

// ---------------------------------------------------------------------------
// --- test fileIterator()
(() => {
  var iter, lLines, line;
  iter = fileIterator(testPath);
  // --- Contents:
  //        abc
  //        def
  //        ghi
  //        jkl
  //        mno

  lLines = [];
  for (line of iter) {
    lLines.push(line.toUpperCase());
  }
  return test("line 29", (t) => {
    return t.deepEqual(lLines, ['ABC', 'DEF', 'GHI', 'JKL', 'MNO']);
  });
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
  return test("line 51", (t) => {
    return t.deepEqual(result, ['X 3', 'X 4']);
  });
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
  return test("line 74", (t) => {
    return t.deepEqual(result, ['--> def', '--> jkl']);
  });
})();
