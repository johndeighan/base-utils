// debug.test.coffee
var TEST, callGen, callGen1, callGen2, callGen3, callGen4, func1, func2, gen, main;

import {
  assert,
  croak
} from '@jdeighan/base-utils/exceptions';

import {
  undef,
  defined,
  notdefined,
  isFunction
} from '@jdeighan/base-utils';

import {
  LOG,
  LOGVALUE,
  LOGSTRING,
  clearAllLogs,
  getMyLogs,
  echoLogs
} from '@jdeighan/base-utils/log';

import {
  CallStack
} from '@jdeighan/base-utils/stack';

import * as lib from '@jdeighan/base-utils/debug';

Object.assign(global, lib);

import {
  UnitTester,
  equal,
  notequal,
  like,
  truthy,
  falsy,
  fails,
  succeeds
} from '@jdeighan/base-utils/utest';

echoLogs(false);

setDebugging(false, 'noecho');

// ---------------------------------------------------------------------------
// --- Define some functions to use in testing
main = function() {
  var i, j, len, ref;
  dbgEnter('main');
  ref = [13, 15];
  for (j = 0, len = ref.length; j < len; j++) {
    i = ref[j];
    func1(i);
    LOG(i + 1);
  }
  dbgReturn('main');
};

func1 = function(i) {
  dbgEnter('func1', i);
  func2(i);
  dbgReturn('func1');
};

func2 = function(i) {
  dbgEnter('func2', i);
  LOG(2 * i);
  dbgReturn('func2');
};

callGen = function() {
  var i, ref;
  dbgEnter('callGen');
  ref = gen();
  for (i of ref) {
    dbg(`GOT ${i}`);
    LOG(i);
  }
  dbgReturn('callGen');
};

callGen1 = function() {
  dbgEnter('func');
  dbgReturn('func');
  return LOG('abc');
};

callGen2 = function() {
  dbgEnter('obj.func');
  dbgReturn('obj.func');
  return LOG('abc');
};

callGen3 = function() {
  dbgEnter('obj.func');
  dbgReturn('obj.func');
  return LOG('abc');
};

callGen4 = function() {
  dbgEnter('Getter.get');
  dbgEnter('Fetcher.fetch');
  dbgReturn('Fetcher.fetch', {
    str: 'abcdef abcdef abcdef abcdef abcdef',
    node: 'abcdef abcdef abcdef abcdef abcdef',
    lineNum: 15
  });
  dbgReturn('Getter.get', {
    str: 'abcdef abcdef abcdef abcdef abcdef',
    node: 'abcdef abcdef abcdef abcdef abcdef',
    lineNum: 15
  });
  return LOG('abc');
};

gen = function*() {
  dbgEnter('gen');
  dbgYield('gen', 1);
  yield 1;
  dbgResume('gen');
  dbgYield('gen', 2);
  yield 2;
  dbgResume('gen');
  dbgReturn('gen');
};

// ---------------------------------------------------------------------------
clearDebugLog();

stdLogString(2, `---
- abc
- def`);

equal(getDebugLog(), `│   │   ---
│   │   - abc
│   │   - def`);

// ---------------------------------------------------------------------------
// --- possible values for debugWhat:
//        false - no debug output
//        true - debug all calls
//        <string> - space separated names
//                   of functions/methods to debug
TEST = function(debugWhat, func, expectedDbg, expectedLog) {
  var dbgStr, logStr;
  assert(defined(debugWhat), "1st arg must be defined");
  setDebugging(debugWhat, 'noecho');
  assert(isFunction(func), "not a function");
  debugStack.logCalls(true);
  clearAllLogs();
  func();
  dbgStr = getDebugLog();
  logStr = getMyLogs();
  equal(dbgStr, expectedDbg);
  equal(logStr, expectedLog);
  truthy(debugStack.isEmpty());
};

// ---------------------------------------------------------------------------
(function() {
  return TEST(false, main, '', `26
14
30
16`);
})();

// ---------------------------------------------------------------------------
(function() {
  return TEST('main', main, `enter main
└─> return from main`, `26
14
30
16`);
})();

// ---------------------------------------------------------------------------
(function() {
  return TEST('main func2', main, `enter main
│   enter func2 13
│   └─> return from func2
│   enter func2 15
│   └─> return from func2
└─> return from main`, `26
14
30
16`);
})();

// ---------------------------------------------------------------------------
(function() {
  return TEST('func2', main, `enter func2 13
└─> return from func2
enter func2 15
└─> return from func2`, `26
14
30
16`);
})();

// ---------------------------------------------------------------------------
// --- PROBLEM

  // (() ->

// 	TEST 'callGen get', callGen, """
// 		enter callGen
// 		│   enter gen
// 		│   ├<─ yield 1
// 		│   GOT 1
// 		│   ├─> resume
// 		│   ├<─ yield 2
// 		│   GOT 2
// 		│   ├─> resume
// 		│   └─> return from gen
// 		└─> return from callGen
// 		""", """
// 		1
// 		2
// 		"""
// 	)()

  // ---------------------------------------------------------------------------
(function() {
  return TEST(true, callGen1, `enter func
└─> return from func`, `abc`);
})();

// ---------------------------------------------------------------------------
(function() {
  return TEST('obj.func', callGen2, `enter obj.func
└─> return from obj.func`, `abc`);
})();

// ---------------------------------------------------------------------------
(function() {
  return TEST('func', callGen3, `enter obj.func
└─> return from obj.func`, `abc`);
})();

// ---------------------------------------------------------------------------
(function() {
  return TEST('get fetch', callGen4, `enter Getter.get
│   enter Fetcher.fetch
│   └─> return from Fetcher.fetch
│       val =
│       lineNum: 15
│       node: abcdef˳abcdef˳abcdef˳abcdef˳abcdef
│       str: abcdef˳abcdef˳abcdef˳abcdef˳abcdef
└─> return from Getter.get
    val =
    lineNum: 15
    node: abcdef˳abcdef˳abcdef˳abcdef˳abcdef
    str: abcdef˳abcdef˳abcdef˳abcdef˳abcdef`, `abc`);
})();

// ---------------------------------------------------------------------------
(function() {
  var FUNC1, FUNC2, MAIN;
  MAIN = function() {
    dbgEnter('MAIN');
    FUNC1();
    FUNC2();
    dbgReturn('MAIN');
  };
  FUNC1 = function() {
    dbgEnter('FUNC1');
    LOG('Hello');
    dbgReturn('FUNC1');
  };
  FUNC2 = function() {
    dbgEnter('FUNC2');
    LOG('Hi');
    dbgReturn('FUNC2');
  };
  return TEST('MAIN+', MAIN, `enter MAIN
│   enter FUNC1
│   └─> return from FUNC1
│   enter FUNC2
│   └─> return from FUNC2
└─> return from MAIN`, `Hello
Hi`);
})();

// ---------------------------------------------------------------------------
equal(2 + 2, 4);