// pll-parser.test.coffee
import {
  undef,
  defined,
  OL,
  sortArrayOfHashes,
  isString,
  toArray
} from '@jdeighan/base-utils';

import {
  assert
} from '@jdeighan/base-utils/exceptions';

import {
  LOG
} from '@jdeighan/base-utils/log';

import {
  setDebugging
} from '@jdeighan/base-utils/debug';

import {
  mkpath,
  allFilesMatching,
  globFiles
} from '@jdeighan/base-utils/fs';

import * as lib from '@jdeighan/base-utils/pll-parser';

Object.assign(global, lib);

import {
  transformValue,
  transformExpected,
  equal,
  fails,
  succeeds
} from '@jdeighan/base-utils/utest';

// ---------------------------------------------------------------------------
transformValue((item) => {
  return parse(item);
});

transformExpected((str) => {
  var i, lTokens, len, line, ref;
  assert(isString(str), `Not a string: ${OL(str)}`);
  lTokens = [];
  ref = toArray(str);
  for (i = 0, len = ref.length; i < len; i++) {
    line = ref[i];
    if (line === '>>') {
      lTokens.push({
        type: 'indent'
      });
    } else if (line === '<<') {
      lTokens.push({
        type: 'undent'
      });
    } else {
      lTokens.push({
        type: 'text',
        text: line
      });
    }
  }
  return lTokens;
});

// ---------------------------------------------------------------------------
succeeds(() => {
  return parse("abc");
});

succeeds(() => {
  return parse("abc\n\t\tdef");
});

succeeds(() => {
  return parse("abc\r\n\t\tdef");
});

fails(() => {
  return parse("abc\t\tdef");
});

fails(() => {
  return parse("\t \t ");
});

// ---------------------------------------------------------------------------
equal(`line 1
	line 2
line 3`, `line 1
>>
line 2
<<
line 3`);

// --- blank lines are ignored
equal(`line 1
	line 2

line 4`, `line 1
>>
line 2
<<
line 4`);

equal(`line 1
	line 2
			and more
line 4`, `line 1
>>
line 2 and more
<<
line 4`);

equal(`line 1
	line 2
			and more
line 4
	line 5
			and more
line 7`, `line 1
>>
line 2 and more
<<
line 4
>>
line 5 and more
<<
line 7`);