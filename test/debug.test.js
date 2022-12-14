// Generated by CoffeeScript 2.7.0
// debug.test.coffee
var TEST, callGen, func1, func2, gen, hTestNumbers, main;

import test from 'ava';

import {
  assert,
  croak
} from '@jdeighan/base-utils/exceptions';

import {
  undef,
  defined,
  notdefined
} from '@jdeighan/base-utils';

import {
  LOG,
  LOGVALUE,
  LOGSTRING,
  clearAllLogs,
  getMyLog
} from '@jdeighan/base-utils/log';

import {
  CallStack
} from '@jdeighan/base-utils/stack';

import {
  callStack,
  setDebugging,
  debugDebug,
  getType,
  dumpDebugLoggers,
  dbgEnter,
  dbgReturn,
  dbgYield,
  dbgResume,
  dbg,
  clearDebugLog,
  getDebugLog,
  stdLogString
} from '@jdeighan/base-utils/debug';

setDebugging(undef, 'noecho');

// ---------------------------------------------------------------------------
test("line 24", (t) => {
  clearDebugLog();
  stdLogString(2, `---
- abc
- def`);
  return t.is(getDebugLog(), `│   │   ---
│   │   - abc
│   │   - def`);
});

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
hTestNumbers = {};

TEST = function(lineNum, debugWhat, func, expectedDbg, expectedLog) {
  var dbgStr, logStr;
  // --- Make sure test numbers are unique
  while (hTestNumbers[lineNum]) {
    lineNum += 1000;
  }
  hTestNumbers[lineNum] = true;
  if (defined(debugWhat)) {
    setDebugging(debugWhat, 'noecho');
  } else {
    setDebugging(false, 'noecho');
  }
  callStack.logCalls(true);
  clearAllLogs();
  func();
  dbgStr = getDebugLog();
  logStr = getMyLog();
  test(`line ${lineNum}-DEBUG`, (t) => {
    return t.is(dbgStr, expectedDbg);
  });
  if (defined(expectedLog)) {
    test(`line ${lineNum}-LOG`, (t) => {
      return t.is(logStr, expectedLog);
    });
  }
  test(`line ${lineNum}-final`, (t) => {
    return t.truthy(callStack.isEmpty());
  });
};

// ---------------------------------------------------------------------------
(function() {
  return TEST(107, undef, main, undef, `26
14
30
16`);
})();

// ---------------------------------------------------------------------------
(function() {
  return TEST(119, 'main', main, `enter main
└─> return from main`, `26
14
30
16`);
})();

// ---------------------------------------------------------------------------
(function() {
  return TEST(134, 'main func2', main, `enter main
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
  return TEST(153, 'func2', main, `enter func2 13
└─> return from func2
enter func2 15
└─> return from func2`, `26
14
30
16`);
})();

// ---------------------------------------------------------------------------
(function() {
  return TEST(170, true, callGen, `enter callGen
│   enter gen
│   ├<─ yield 1
│   GOT 1
│   ├─> resume
│   ├<─ yield 2
│   GOT 2
│   ├─> resume
│   └─> return from gen
└─> return from callGen`, `1
2`);
})();

// ---------------------------------------------------------------------------
(function() {
  callGen = function() {
    dbgEnter('func');
    dbgReturn('func');
    return LOG('abc');
  };
  return TEST(193, 'func', callGen, `enter func
└─> return from func`, `abc`);
})();

// ---------------------------------------------------------------------------
(function() {
  callGen = function() {
    dbgEnter('obj.func');
    dbgReturn('obj.func');
    return LOG('abc');
  };
  return TEST(193, 'obj.func', callGen, `enter obj.func
└─> return from obj.func`, `abc`);
})();

// ---------------------------------------------------------------------------
(function() {
  callGen = function() {
    dbgEnter('obj.func');
    dbgReturn('obj.func');
    return LOG('abc');
  };
  return TEST(193, 'func', callGen, `enter obj.func
└─> return from obj.func`, `abc`);
})();

// ---------------------------------------------------------------------------
(function() {
  callGen = function() {
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
  return TEST(193, 'get fetch', callGen, `enter Getter.get
│   enter Fetcher.fetch
│   └─> return from Fetcher.fetch
│       val =
│       ---
│       lineNum: 15
│       node: abcdef˳abcdef˳abcdef˳abcdef˳abcdef
│       str: abcdef˳abcdef˳abcdef˳abcdef˳abcdef
└─> return from Getter.get
    val =
    ---
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
  return TEST(297, 'MAIN+', MAIN, `enter MAIN
│   enter FUNC1
│   └─> return from FUNC1
│   enter FUNC2
│   └─> return from FUNC2
└─> return from MAIN`, `Hello
Hi`);
})();

// ---------------------------------------------------------------------------
