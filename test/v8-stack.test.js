// v8-stack.test.coffee
import test from 'ava';

import {
  assert,
  croak
} from '@jdeighan/base-utils/exceptions';

import {
  undef
} from '@jdeighan/base-utils';

import {
  fromTAML
} from '@jdeighan/base-utils/taml';

import {
  LOG,
  LOGVALUE
} from '@jdeighan/base-utils/log';

import {
  getMyDirectCaller,
  getMyOutsideCaller,
  getV8Stack,
  debugV8Stack,
  shorten
} from '@jdeighan/base-utils/v8-stack';

import {
  getCallers
} from './v8-module.js';

// ---------------------------------------------------------------------------
test("line 21", (t) => {
  var expStr, orgStr, replace;
  orgStr = "(file:///C:/Users/johnd/base-utils/src/v8-stack.js)";
  replace = "file:///C:/Users/johnd";
  expStr = "(file:///ROOT/base-utils/src/v8-stack.js)";
  return t.is(shorten(orgStr, replace), expStr);
});

// ---------------------------------------------------------------------------
(function() {
  var func1, func2, hCaller, hExpected, main;
  hCaller = undef;
  main = function() {
    func1();
    return func2();
  };
  func1 = function() {};
  func2 = function() {
    hCaller = getMyDirectCaller();
  };
  // ------------------------------------------------------------------------
  hExpected = fromTAML(`---
type: function
funcName: main
source: C:/Users/johnd/base-utils/test/v8-stack.test.js
hFile:
	base: v8-stack.test.js
	dir: C:/Users/johnd/base-utils/test
	ext: .js
	name: v8-stack.test
	root: /`);
  return test("line 60", (t) => {
    main();
    return t.like(hCaller, hExpected);
  });
})();

// ---------------------------------------------------------------------------
(function() {
  var func1, func2, lCallers1, lCallers2, main;
  lCallers1 = undef;
  lCallers2 = undef;
  main = function() {
    func1();
    return func2();
  };
  func1 = function() {
    return lCallers1 = getCallers();
  };
  func2 = function() {
    lCallers2 = getCallers();
  };
  return test("line 83", (t) => {
    main();
    t.like(lCallers1[0], {
      type: 'function',
      funcName: 'secondFunc',
      source: 'C:/Users/johnd/base-utils/test/v8-module.js',
      hFile: {
        base: 'v8-module.js',
        lineNum: 16,
        colNum: 10
      }
    });
    t.like(lCallers1[1], {
      type: 'function',
      funcName: 'func1',
      source: 'C:/Users/johnd/base-utils/test/v8-stack.test.js',
      hFile: {
        base: 'v8-stack.test.js',
        lineNum: 82,
        colNum: 24
      }
    });
    t.like(lCallers2[0], {
      type: 'function',
      funcName: 'secondFunc',
      source: 'C:/Users/johnd/base-utils/test/v8-module.js',
      hFile: {
        base: 'v8-module.js',
        lineNum: 16,
        colNum: 10
      }
    });
    return t.like(lCallers2[1], {
      type: 'function',
      funcName: 'func2',
      source: 'C:/Users/johnd/base-utils/test/v8-stack.test.js',
      hFile: {
        base: 'v8-stack.test.js',
        lineNum: 85,
        colNum: 17
      }
    });
  });
})();
