  // FileProcessor.test.coffee
import {
  undef,
  defined,
  notdefined,
  LOG,
  rtrim,
  toArray
} from '@jdeighan/base-utils';

import {
  setDebugging
} from '@jdeighan/base-utils/debug';

import {
  slurp,
  subPath,
  isDir
} from '@jdeighan/base-utils/fs';

import {
  FileProcessor,
  LineProcessor
} from '@jdeighan/base-utils/FileProcessor';

import {
  line2hWord,
  hWord2line
} from './utils.js';

import {
  utest
} from '@jdeighan/base-utils/utest';

// setDebugging 'readAll'

  // ---------------------------------------------------------------------------
// --- Build array of paths to files matching a glob pattern
//     Explanation:
//        we override the `handleFile()` method by simply
//        assigning to the key. For each file, we return an
//        empty hash. If we returned undef, it would be ignored.
//        Although the hash we return is empty, `FileProcessor`
//        will add the key `filePath` containing the full path
//        to the file. But, our unit test simply checks how
//        many hashes there are in `lUserData`.
(() => {
  var fp, lUserData;
  fp = new FileProcessor('./test/test', '*.zh');
  fp.handleFile = function(filePath) {
    return {};
  };
  fp.readAll();
  lUserData = fp.getUserData();
  return utest.equal(lUserData.length, 2);
})();

(() => {
  var fp, lUserData;
  fp = new FileProcessor('./test/test', '*.txt');
  fp.handleFile = function(filePath) {
    return {};
  };
  fp.readAll();
  lUserData = fp.getUserData();
  return utest.equal(lUserData.length, 3);
})();

(() => {
  var fp, lUserData;
  fp = new FileProcessor('./test/words', '*');
  fp.handleFile = function(filePath) {
    return {};
  };
  fp.readAll();
  lUserData = fp.getUserData();
  return utest.equal(lUserData.length, 26);
})();

(() => {
  var fp, lUserData;
  fp = new FileProcessor('./test/words', '*.zh');
  fp.handleFile = function(filePath) {
    return {};
  };
  fp.readAll();
  lUserData = fp.getUserData();
  return utest.equal(lUserData.length, 25);
})();

// ---------------------------------------------------------------------------
// --- Keep track of the contents of each *.zh file
//     Explanation:
//        we override the `handleFile()` method by simply
//        assigning to the key. For each file, we return a
//        hash that includes the file contents. The unit test
//        then tests if lUserData includes that content.
//        rtrim() will trim trailing whitespace, including \n
(() => {
  var fp, lUserData;
  fp = new FileProcessor('./test/test', '*.zh');
  fp.handleFile = function(filePath) {
    return {
      zh: rtrim(slurp(filePath))
    };
  };
  fp.readAll();
  lUserData = fp.getSortedUserData();
  utest.equal(lUserData.length, 2);
  utest.like(lUserData[0], {
    zh: '你好'
  });
  return utest.like(lUserData[1], {
    zh: '再见'
  });
})();

// ---------------------------------------------------------------------------
// --- Count total number of words in all `*.zh` files
//        in `words` dir
//     Explanation:
//        we override the `handleFile()` to increment the
//        value of @numWords, but return undef
(() => {
  var fp;
  fp = new FileProcessor('./test/words', '*.zh');
  fp.handleFile = function(filePath) {
    var content, count;
    content = rtrim(slurp(filePath));
    count = toArray(content).length;
    if (defined(this.numWords)) {
      this.numWords += count;
    } else {
      this.numWords = count;
    }
    return undef;
  };
  fp.readAll();
  return utest.equal(fp.numWords, 2048);
})();

// ---------------------------------------------------------------------------
// --- Count total number of words in all `*.zh` files
//        in `words` dir - using a LineProcessor
//     Explanation:
//        we override the `handleLine()`, which is called
//        for each line in any file, to increment the
//        value of @numWords, but return undef
(() => {
  var fp;
  fp = new LineProcessor('./test/words', '*.zh');
  fp.handleLine = function(line) {
    if (defined(this.numWords)) {
      this.numWords += 1;
    } else {
      this.numWords = 1;
    }
    return undef;
  };
  fp.readAll();
  return utest.equal(fp.numWords, 2048);
})();

// ---------------------------------------------------------------------------
// --- Write out new files in `./test/words/temp` that contain
//        just the Chinese words in `*.zh` files
(() => {
  var fp;
  fp = new LineProcessor('./test/words', '*.zh');
  fp.handleLine = function(line) {
    if (defined(this.numWords)) {
      this.numWords += 1;
    } else {
      this.numWords = 1;
    }
    return {
      hWord: line2hWord(line)
    };
  };
  fp.writeLine = function(hLine) {
    var hWord, word;
    ({hWord} = hLine); // extract previously written hWord
    word = hWord.zh[0].zh;
    return word;
  };
  fp.readAll();
  fp.writeAll();
  return utest.equal(fp.numWords, 2048);
})();

// ---------------------------------------------------------------------------
// --- Write out new files in `./test/words/temp` that contain
//        the same lines in the original file, but with
//        the number incremented by 5
(() => {
  var fp;
  fp = new LineProcessor('./test/words', '*.zh');
  fp.handleLine = function(line) {
    return {
      hWord: line2hWord(line)
    };
  };
  fp.writeFileTo = function(hUserData) {
    return subPath(hUserData.filePath, 'temp2');
  };
  fp.writeLine = function(hLine) {
    var hWord;
    ({hWord} = hLine); // extract previously written hWord
    hWord.num += 5;
    return hWord2line(hWord);
  };
  fp.readAll();
  fp.writeAll();
  utest.truthy(isDir('./test/words/temp2'));
  utest.truthy(slurp('./test/words/adjectives.zh').startsWith('11 '));
  return utest.truthy(slurp('./test/words/temp2/adjectives.zh').startsWith('16 '));
})();

//# sourceMappingURL=FileProcessor.test.js.map
