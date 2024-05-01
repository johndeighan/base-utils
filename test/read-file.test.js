// read-file.test.coffee
import {
  undef,
  defined,
  notdefined,
  isArray,
  sortArrayOfHashes,
  toArray,
  toBlock,
  isEmpty,
  nonEmpty,
  spaces,
  tabs,
  OL
} from '@jdeighan/base-utils';

import {
  assert,
  croak
} from '@jdeighan/base-utils/exceptions';

import {
  splitLine
} from '@jdeighan/base-utils/indent';

import * as lib1 from '@jdeighan/base-utils/utest';

Object.assign(global, lib1);

import * as lib2 from '@jdeighan/base-utils/read-file';

Object.assign(global, lib2);

// ---------------------------------------------------------------------------
// --- test readTextFile
(() => {
  var hMetaData, lLines, path;
  path = "./test/read-file/file3.txt";
  [hMetaData, lLines] = readTextFile(path, 'eager');
  assert(isArray(lLines), "Bad return from readTextFile");
  equal(hMetaData, {
    fName: 'John',
    lName: 'Deighan'
  });
  return equal(lLines, ['', 'This is a test']);
})();

// ---------------------------------------------------------------------------
// Contents of ./test/read-file/readline5.txt
// abc
// defg

// abcdefg
// more text
// ---------------------------------------------------------------------------
// --- get all lines in file
(() => {
  var hMetaData, lLines, path;
  path = './test/read-file/readline5.txt';
  [hMetaData, lLines] = readTextFile(path, 'eager');
  return equal(lLines, ['abc', 'defg', '', 'abcdefg', 'more text']);
})();

(() => {
  var hMetaData, lLines, path;
  path = './test/read-file/readline4.txt';
  [hMetaData, lLines] = readTextFile(path, 'eager');
  return equal(lLines, ['ghi', 'jkl', '', 'mno', 'pqr']);
})();

// ---------------------------------------------------------------------------
// --- test allFilesMatching()
(() => {
  var ext, hFile, lFiles, ref;
  lFiles = [];
  ref = allFilesMatching('./test/read-file/*', 'eager');
  for (hFile of ref) {
    ({ext} = hFile);
    if ((ext !== '.map') && (ext !== '.js')) {
      lFiles.push(hFile);
    }
  }
  sortArrayOfHashes(lFiles, 'fileName');
  return like(lFiles, [
    {
      fileName: 'empty-meta.txt',
      hMetaData: {
        key: 'myself'
      },
      lLines: []
    },
    {
      fileName: 'empty.txt',
      hMetaData: {},
      lLines: []
    },
    {
      fileName: 'file3.txt',
      hMetaData: {
        fName: 'John',
        lName: 'Deighan'
      },
      lLines: ['',
    'This is a test']
    },
    {
      fileName: 'readline4.txt',
      hMetaData: {},
      lLines: ['ghi',
    'jkl',
    '',
    'mno',
    'pqr']
    },
    {
      fileName: 'readline5.txt',
      hMetaData: {},
      lLines: ['abc',
    'defg',
    '',
    'abcdefg',
    'more text']
    },
    {
      fileName: 'zzz.zh',
      hMetaData: {},
      lLines: ['zzz']
    }
  ]);
})();

// ---------------------------------------------------------------------------
// --- test allFilesMatching with pattern
(() => {
  var hFile, hOptions, lFiles, ref;
  lFiles = [];
  hOptions = {
    eager: true
  };
  ref = allFilesMatching('./test/read-file/*.txt', hOptions);
  for (hFile of ref) {
    lFiles.push(hFile);
  }
  sortArrayOfHashes(lFiles, 'fileName');
  return like(lFiles, [
    {
      fileName: 'empty-meta.txt',
      hMetaData: {
        key: 'myself'
      },
      lLines: []
    },
    {
      fileName: 'empty.txt',
      hMetaData: {},
      lLines: []
    },
    {
      fileName: 'file3.txt',
      hMetaData: {
        fName: 'John',
        lName: 'Deighan'
      },
      lLines: ['',
    'This is a test']
    },
    {
      fileName: 'readline4.txt',
      hMetaData: {},
      lLines: ['ghi',
    'jkl',
    '',
    'mno',
    'pqr']
    },
    {
      fileName: 'readline5.txt',
      hMetaData: {},
      lLines: ['abc',
    'defg',
    '',
    'abcdefg',
    'more text']
    }
  ]);
})();

// ---------------------------------------------------------------------------
// --- test allFilesMatching with pattern and cwd
(() => {
  var hFile, hOptions, lFiles, ref;
  lFiles = [];
  hOptions = {
    eager: true,
    hGlobOptions: {
      cwd: './test/test'
    }
  };
  ref = allFilesMatching('*.txt', hOptions);
  for (hFile of ref) {
    lFiles.push(hFile);
  }
  sortArrayOfHashes(lFiles, 'fileName');
  return like(lFiles, [
    {
      fileName: 'file1.txt',
      hMetaData: {},
      lLines: ['Hello']
    },
    {
      fileName: 'file2.txt',
      hMetaData: {},
      lLines: ['Goodbye']
    },
    {
      fileName: 'file3.txt',
      hMetaData: {
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
  var filePath, hMetaData, handleLine, line, numWords, reader, ref;
  filePath = './test/words/adjectives.zh';
  numWords = undef;
  handleLine = function(line) {
    if (defined(numWords)) {
      numWords += 1;
    } else {
      numWords = 1;
    }
  };
  [hMetaData, reader] = readTextFile(filePath);
  ref = reader();
  for (line of ref) {
    handleLine(line);
  }
  return equal(numWords, 256);
})();

// ---------------------------------------------------------------------------
(() => {
  var h, hMetaData, handleLine, line, numWords, reader, ref, ref1;
  numWords = undef;
  handleLine = function(line) {
    if (defined(numWords)) {
      numWords += 1;
    } else {
      numWords = 1;
    }
  };
  ref = allFilesMatching('./test/words/*.zh');
  for (h of ref) {
    [hMetaData, reader] = readTextFile(h.filePath);
    ref1 = reader();
    for (line of ref1) {
      handleLine(line);
    }
  }
  return equal(numWords, 2048);
})();

// ---------------------------------------------------------------------------
(() => {
  var hMetaData, handleLine, lLines, line, numWords, reader, ref;
  numWords = undef;
  handleLine = function(line) {
    if (nonEmpty(line)) {
      if (defined(numWords)) {
        numWords += 1;
      } else {
        numWords = 1;
      }
    }
  };
  lLines = ['abc', '   ', '\t\t', 'def', '', undef, '你好'];
  [hMetaData, reader] = readTextFile(lLines);
  ref = reader();
  for (line of ref) {
    handleLine(line);
  }
  return equal(numWords, 3);
})();

// ---------------------------------------------------------------------------
(() => {
  var hMetaData, handleLine, line, numWords, reader, ref, text;
  numWords = undef;
  handleLine = function(line) {
    if (nonEmpty(line)) {
      if (defined(numWords)) {
        numWords += 1;
      } else {
        numWords = 1;
      }
    }
  };
  text = `abc
${spaces(3)}
${tabs(2)}
def

你好`;
  [hMetaData, reader] = readTextFile(toArray(text));
  ref = reader();
  for (line of ref) {
    handleLine(line);
  }
  return equal(numWords, 3);
})();

// ---------------------------------------------------------------------------
(() => {
  var hMetaData, handleLine, line, numWords, reader, ref, text;
  numWords = undef;
  handleLine = function(line) {
    if (nonEmpty(line)) {
      if (defined(numWords)) {
        numWords += 1;
      } else {
        numWords = 1;
      }
    }
  };
  text = `abc
def
你好
ghi
__END__
abc
def`;
  [hMetaData, reader] = readTextFile(toArray(text));
  ref = reader();
  for (line of ref) {
    handleLine(line);
  }
  return equal(numWords, 4);
})();

// ---------------------------------------------------------------------------
(() => {
  var hMetaData, handleExtraLine, handleLine, line, numExtraWords, numWords, reader, ref, ref1, text;
  numWords = undef;
  numExtraWords = undef;
  handleLine = function(line) {
    if (nonEmpty(line)) {
      if (defined(numWords)) {
        numWords += 1;
      } else {
        numWords = 1;
      }
    }
  };
  handleExtraLine = function(line) {
    if (nonEmpty(line)) {
      if (defined(numExtraWords)) {
        numExtraWords += 1;
      } else {
        numExtraWords = 1;
      }
    }
  };
  text = `abc
def
你好
ghi
__END__
mno
pqr`;
  [hMetaData, reader] = readTextFile(toArray(text));
  ref = reader();
  for (line of ref) {
    handleLine(line);
  }
  ref1 = reader();
  for (line of ref1) {
    handleExtraLine(line);
  }
  equal(numWords, 4);
  return equal(numExtraWords, 2);
})();

// ---------------------------------------------------------------------------
(() => {
  var hMetaData, input, lExtraLines, lLines, line, numMetaLines, reader, ref, ref1;
  lLines = [];
  lExtraLines = [];
  input = toArray(`---
fName: John
lName: Deighan
gender: male
---
abc
def
你好
ghi
__END__
mno
pqr`);
  [hMetaData, reader, numMetaLines] = readTextFile(input);
  ref = reader();
  for (line of ref) {
    lLines.push(line);
  }
  ref1 = reader();
  for (line of ref1) {
    lExtraLines.push(line);
  }
  equal(hMetaData, {
    fName: 'John',
    lName: 'Deighan',
    gender: 'male'
  });
  equal(numMetaLines, 5);
  equal(lLines.length, 4);
  equal(toBlock(lLines), `abc
def
你好
ghi`);
  equal(lExtraLines.length, 2);
  return equal(toBlock(lExtraLines), `mno
pqr`);
})();

// ---------------------------------------------------------------------------
// --- test readTextFile with string pattern
(() => {
  var hMetaData, input, lLines, line, reader, ref;
  lLines = [];
  input = toArray(`abc
abcdef
xxxab
def
你好`);
  [hMetaData, reader] = readTextFile(input, {
    pattern: 'ab'
  });
  ref = reader();
  for (line of ref) {
    lLines.push(line);
  }
  return equal(lLines, ['abc', 'abcdef', 'xxxab']);
})();

// ---------------------------------------------------------------------------
// --- test readTextFile with regexp pattern
(() => {
  var hMetaData, input, lLines, line, reader, ref;
  lLines = [];
  input = toArray(`abc
abcdef
xxxab
def
你好`);
  [hMetaData, reader] = readTextFile(input, {
    pattern: /^ab/
  });
  ref = reader();
  for (line of ref) {
    lLines.push(line);
  }
  return equal(lLines, ['abc', 'abcdef']);
})();

// ---------------------------------------------------------------------------
// --- test simple 'transform' option
(() => {
  var hMetaData, input, reader, transform;
  input = toArray(`abc
def
你好
ghi`);
  transform = function(line) {
    return line.toUpperCase();
  };
  [hMetaData, reader] = readTextFile(input, {transform});
  return equal(toBlock(Array.from(reader())), `ABC
DEF
你好
GHI`);
})();

// ---------------------------------------------------------------------------
// --- test complex 'transform' option
(() => {
  var hMetaData, input, reader, transform;
  input = toArray(`if (x == 2)
	y = 15
	log y
log 'done'`);
  transform = function(line) {
    var lMatches, level, obj, text;
    [level, text] = splitLine(line);
    if (lMatches = text.match(/^if\s+(.*)$/)) {
      obj = {
        type: 'if',
        cond: lMatches[1]
      };
    } else if (lMatches = text.match(/^log\s+(.*)$/)) {
      obj = {
        type: 'log',
        text: lMatches[1]
      };
    } else if (lMatches = text.match(/^([a-z])\s*=\s*(.*)$/)) {
      obj = {
        type: 'assign',
        var: lMatches[1],
        val: lMatches[2]
      };
    } else {
      croak(`syntax error: ${OL(line)}`);
    }
    return [level, obj];
  };
  [hMetaData, reader] = readTextFile(input, {transform});
  return equal(Array.from(reader()), [
    [
      0,
      {
        type: 'if',
        cond: "(x == 2)"
      }
    ],
    [
      1,
      {
        type: 'assign',
        var: 'y',
        val: '15'
      }
    ],
    [
      1,
      {
        type: 'log',
        text: 'y'
      }
    ],
    [
      0,
      {
        type: 'log',
        text: "'done'"
      }
    ]
  ]);
})();

// ---------------------------------------------------------------------------
(() => {
  var filePath, hMetaData, handleLine, line, numLines, reader, ref;
  filePath = './test/read-file/empty.txt';
  numLines = 0;
  handleLine = function(line) {
    numLines += 1;
  };
  [hMetaData, reader] = readTextFile(filePath);
  ref = reader();
  for (line of ref) {
    handleLine(line);
  }
  equal(numLines, 0);
  return equal(hMetaData, {});
})();

// ---------------------------------------------------------------------------
(() => {
  var filePath, hMetaData, handleLine, line, numLines, reader, ref;
  filePath = './test/read-file/empty-meta.txt';
  numLines = 0;
  handleLine = function(line) {
    numLines += 1;
  };
  [hMetaData, reader] = readTextFile(filePath);
  ref = reader();
  for (line of ref) {
    handleLine(line);
  }
  equal(numLines, 0);
  return equal(hMetaData, {
    key: 'myself'
  });
})();