// utils.coffee
import {
  undef,
  defined,
  notdefined,
  getOptions,
  CWS,
  shuffle,
  keys,
  hasKey
} from '@jdeighan/base-utils';

import {
  assert,
  croak
} from '@jdeighan/base-utils/exceptions';

import {
  LOG
} from '@jdeighan/base-utils/log';

import {
  dbgEnter,
  dbgReturn,
  dbg
} from '@jdeighan/base-utils/debug';

import {
  mkpath,
  isFile
} from '@jdeighan/base-utils/fs';

import {
  FileProcessor
} from '@jdeighan/base-utils/file-processor';

// ---------------------------------------------------------------------------
export var splitEn = (enStr) => {
  var i, lWords, len, ref, str;
  dbgEnter('splitEn', enStr);
  lWords = [];
  ref = enStr.split(',');
  for (i = 0, len = ref.length; i < len; i++) {
    str = ref[i];
    lWords.push(CWS(str));
  }
  dbgReturn('splitEn', lWords);
  return lWords;
};

// ---------------------------------------------------------------------------
// e.g. splits "打扰 dǎ rǎo, 麻烦 má fan"
// into [
//    {zh: '打扰', pinyin: 'dǎ rǎo'}
//    {zh: '麻烦', pinyin: 'má fan'}
//    ]
export var splitZh = (zhStr) => {
  var _, i, lParts, lWords, len, pinyin, ref, str, zh;
  lWords = [];
  ref = zhStr.split(',');
  for (i = 0, len = ref.length; i < len; i++) {
    str = ref[i];
    if (lParts = str.match(/^\s*([A-Z\u4E00-\u9FFF]+)(?:\s*[\!\?])?\s+([A-Za-z\s'āáǎàēéěèīíǐìōóǒòūúǔùǖüǘǚǜ]+)(?:\s*[\!\?])?\s*$/)) { // Chinese characters
      [_, zh, pinyin] = lParts;
      lWords.push({
        zh: CWS(zh),
        pinyin: CWS(pinyin)
      });
    } else {
      croak(`splitZh('${zhStr}') - bad zh string`);
    }
  }
  return lWords;
};

// ---------------------------------------------------------------------------
// --- Should handle lines in:
//        test.zh
//        keepers.zh
//        nouns.zh, etc.
export var line2hWord = function(line) {
  var _, astStr, enStr, hWord, lMatches, num, numStr, pos, rest, zhStr;
  dbgEnter('line2hWord', line);
  if (notdefined(line) || (line.length === 0)) {
    dbgReturn('line2hWord', undef);
    return undef;
  } else if (lMatches = line.match(/^\s*(?:([0-9]+)\s*)?(?:(\*+)\s*)?(?:□\s*)?\s*(.*)$/)) { // one or more digits
    // some number of * chars
    // optional empty checkbox
    // skip white space
    // the rest
    [_, numStr, astStr, rest] = lMatches;
    dbg(`rest = '${rest}'`);
    // --- get number of correct tests
    num = 0;
    if (defined(numStr)) {
      num = parseInt(numStr, 10);
    }
    if (defined(astStr)) {
      num += astStr.length;
    }
    pos = rest.indexOf('-');
    dbg(`pos = ${pos}`);
    zhStr = rest.substring(0, pos);
    enStr = rest.substring(pos + 1);
    dbg(`zhStr = '${zhStr}'`);
    dbg(`enStr = '${enStr}'`);
    hWord = {
      num,
      zh: splitZh(zhStr),
      en: splitEn(enStr)
    };
    addKey(hWord);
    dbgReturn('line2hWord', hWord);
    return hWord;
  } else {
    return croak(`Bad line: '${line}'`);
  }
};

// ---------------------------------------------------------------------------
export var zh_pinyin = function(h) {
  return `${h.zh} ${h.pinyin}`;
};

// ---------------------------------------------------------------------------
export var zhStr = function(hWord) {
  var h, lParts;
  lParts = (function() {
    var i, len, ref, results;
    ref = hWord.zh;
    results = [];
    for (i = 0, len = ref.length; i < len; i++) {
      h = ref[i];
      results.push(zh_pinyin(h));
    }
    return results;
  })();
  return lParts.join(', ');
};

// ---------------------------------------------------------------------------
export var enStr = function(hWord) {
  return hWord.en.join(', ');
};

// ---------------------------------------------------------------------------
export var hWord2line = function(hWord, hOptions = {}) {
  var box, number, str;
  ({box, number} = getOptions(hOptions, {
    box: false,
    number: true
  }));
  str = "";
  if (number) {
    str += `${hWord.num} `;
  }
  if (box) {
    str += "□ ";
  }
  str += `${zhStr(hWord)} - ${enStr(hWord)}\n`;
  return str;
};

// ---------------------------------------------------------------------------
export var addKey = function(hWord) {
  var h, i, key, lParts, len, ref;
  lParts = [hWord.en.join('/')];
  ref = hWord.zh;
  for (i = 0, len = ref.length; i < len; i++) {
    h = ref[i];
    lParts.push(h.zh);
    lParts.push(h.pinyin);
  }
  key = lParts.join('/');
  hWord.key = key;
};

// ---------------------------------------------------------------------------
export var getWords = function(hOptions = {}) {
  var addWord, debug, filter, fp, hWords, i, lExclude, lWords, len, limit, num, path, ref;
  // --- path can be a file or a directory
  //     words are ordered by hWord.num, but
  //        scrambled for words w/same num
  dbgEnter('getWords', hOptions);
  ({path, debug, limit, filter, lExclude} = getOptions(hOptions, {
    path: './words',
    debug: false,
    filter: function(h) {
      return h.ext === '.zh';
    },
    lExclude: []
  }));
  // --- { <num>: [hWord, ...] }
  hWords = {};
  addWord = (h) => {
    var num;
    num = h.num;
    if (hasKey(hWords, num)) {
      return hWords[num].push(h);
    } else {
      return hWords[num] = [h];
    }
  };
  fp = new FileProcessor(path, {debug});
  fp.filter = filter;
  fp.handleLine = function(line, lineNum, hFileInfo) {
    var hWord;
    hWord = line2hWord(line);
    if (lExclude.includes(hWord.key)) {
      return;
    }
    hWord.filePath = hFileInfo.filePath;
    hWord.lineNum = lineNum;
    return addWord(hWord);
  };
  fp.go();
  lWords = [];
  ref = keys(hWords);
  for (i = 0, len = ref.length; i < len; i++) {
    num = ref[i];
    shuffle(hWords[num]);
    lWords.push(...hWords[num]);
  }
  // --- lWords is an array of all words, ordered by
  //     num, but scrambled within a num
  if (defined(limit)) {
    lWords = lWords.slice(0, limit);
  }
  dbgReturn('getWords', lWords);
  return lWords;
};

// ---------------------------------------------------------------------------
export var getTestWords = function(hOptions = {}) {
  var hWord, i, lTestWords, len, totalCount;
  lTestWords = getWords(getOptions(hOptions, {
    path: './test.zh'
  }));
  totalCount = 0;
  for (i = 0, len = lTestWords.length; i < len; i++) {
    hWord = lTestWords[i];
    totalCount += hWord.num;
  }
  assert(totalCount > 5, "Bad test file");
  return lTestWords;
};