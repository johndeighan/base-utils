// Generated by CoffeeScript 2.7.0
// debug.test.coffee
var Class1, Class2, allNumbers, double, quadruple;

import test from 'ava';

import {
  undef,
  pass,
  arrayToBlock,
  isNumber,
  isArray,
  spaces
} from '@jdeighan/base-utils/utils';

import {
  toTAML
} from '@jdeighan/base-utils/taml';

import {
  haltOnError,
  assert,
  croak
} from '@jdeighan/base-utils';

import {
  getPrefix
} from '@jdeighan/base-utils/prefix';

import {
  LOG,
  LOGVALUE,
  utReset,
  utGetLog
} from '@jdeighan/base-utils/log';

import {
  setDebugging,
  resetDebugging,
  getType,
  dumpDebugLoggers,
  dbgEnter,
  dbgReturn,
  dbgYield,
  dbgResume,
  dbg,
  dbgReset,
  dbgGetLog
} from '@jdeighan/base-utils/debug';

// ---------------------------------------------------------------------------
test("line 20", (t) => {
  setDebugging("myfunc");
  t.deepEqual(getType("something"), ["string", undef]);
  return resetDebugging();
});

test("line 27", (t) => {
  setDebugging("myfunc");
  t.deepEqual(getType("enter myfunc"), ["enter", "myfunc"]);
  return resetDebugging();
});

test("line 34", (t) => {
  setDebugging("myfunc");
  t.deepEqual(getType("return from X"), ["returnFrom", 'X']);
  return resetDebugging();
});

// ---------------------------------------------------------------------------
double = (x) => {
  var result;
  dbgEnter("double", x);
  assert(isNumber(x), "not a number");
  dbg("inside double");
  result = 2 * x;
  dbgReturn("double", result);
  return result;
};

quadruple = (x) => {
  var result;
  dbgEnter("quadruple", x);
  dbg("inside quadruple");
  result = 2 * double(x);
  dbgReturn("quadruple", result);
  return result;
};

// ---------------------------------------------------------------------------
test("line 60", (t) => {
  var result;
  utReset();
  result = quadruple(3);
  return t.is(result, 12);
});

// ---------------------------------------------------------------------------
test("line 68", (t) => {
  var result;
  utReset();
  setDebugging('double');
  result = quadruple(3);
  resetDebugging();
  return t.is(result, 12);
});

// ---------------------------------------------------------------------------
test("line 78", (t) => {
  var result;
  utReset();
  setDebugging('double');
  result = quadruple(3);
  resetDebugging();
  return t.is(utGetLog(), `enter double
│   arg[0] = 3
│   inside double
└─> return from double
    ret[0] = 6`);
});

// ---------------------------------------------------------------------------
test("line 94", (t) => {
  var result;
  utReset();
  setDebugging('double quadruple');
  result = quadruple(3);
  resetDebugging();
  t.is(result, 12);
  return t.is(utGetLog(), `enter quadruple
│   arg[0] = 3
│   inside quadruple
│   enter double
│   │   arg[0] = 3
│   │   inside double
│   └─> return from double
│       ret[0] = 6
└─> return from quadruple
    ret[0] = 12`);
});

// ---------------------------------------------------------------------------
test("line 116", (t) => {
  var result;
  utReset();
  setDebugging('double', 'quadruple');
  result = quadruple(3);
  resetDebugging();
  t.is(result, 12);
  return t.is(utGetLog(), `enter quadruple
│   arg[0] = 3
│   inside quadruple
│   enter double
│   │   arg[0] = 3
│   │   inside double
│   └─> return from double
│       ret[0] = 6
└─> return from quadruple
    ret[0] = 12`);
});

// ---------------------------------------------------------------------------
Class1 = class Class1 {
  constructor() {
    this.lStrings = [];
  }

  add(str) {
    dbgEnter("Class1.add", str);
    this.lStrings.push(str);
    dbgReturn("Class1.add");
  }

};

Class2 = class Class2 {
  constructor() {
    this.lStrings = [];
  }

  add(str) {
    dbgEnter("Class2.add", str);
    this.lStrings.push(str);
    dbgReturn("Class2.add");
  }

};

// ---------------------------------------------------------------------------
test("line 158", (t) => {
  utReset();
  setDebugging('Class1.add Class2.add');
  new Class1().add('abc');
  new Class2().add('def');
  resetDebugging();
  return t.is(utGetLog(), `enter Class1.add
│   arg[0] = 'abc'
└─> return from Class1.add
enter Class2.add
│   arg[0] = 'def'
└─> return from Class2.add`);
});

// ---------------------------------------------------------------------------
test("line 177", (t) => {
  utReset();
  setDebugging('Class2.add');
  new Class1().add('abc');
  new Class2().add('def');
  resetDebugging();
  return t.is(utGetLog(), `enter Class2.add
│   arg[0] = 'def'
└─> return from Class2.add`);
});

// ---------------------------------------------------------------------------
test("line 193", (t) => {
  var result;
  utReset();
  setDebugging('double quadruple');
  result = double(quadruple(3));
  resetDebugging();
  t.is(result, 24);
  return t.is(utGetLog(), `enter quadruple
│   arg[0] = 3
│   inside quadruple
│   enter double
│   │   arg[0] = 3
│   │   inside double
│   └─> return from double
│       ret[0] = 6
└─> return from quadruple
    ret[0] = 12
enter double
│   arg[0] = 12
│   inside double
└─> return from double
    ret[0] = 24`);
});

// ---------------------------------------------------------------------------
// Test using generators
allNumbers = function*(lItems) {
  var item, j, len;
  dbgEnter("allNumbers");
  for (j = 0, len = lItems.length; j < len; j++) {
    item = lItems[j];
    if (isNumber(item)) {
      dbgYield("allNumbers", item);
      yield item;
      dbgResume("allNumbers");
    } else if (isArray(item)) {
      dbgYield("allNumbers", item);
      yield* allNumbers(item);
      dbgResume("allNumbers");
    }
  }
  dbgReturn("allNumbers");
};

test("line 236", (t) => {
  var i, lItems, ref, total;
  lItems = ['a', 2, ['b', 3], 5];
  total = 0;
  ref = allNumbers(lItems);
  for (i of ref) {
    total += i;
  }
  return t.is(total, 10);
});

// ---------------------------------------------------------------------------
// Test custom loggers
test("line 246", (t) => {
  var result;
  utReset();
  setDebugging('double quadruple', {
    // --- on dbgEnter('<func>'), just log the function name
    enter: function(funcName, lObjects, level) {
      LOG(getPrefix(level, 'plain') + funcName);
      return true;
    },
    // --- on dbgReturn('<func>'), don't log anything at all
    returnFrom: function(funcName, lObjects, level) {
      return true;
    }
  });
  result = double(quadruple(3));
  t.is(result, 24);
  return t.is(utGetLog(), `quadruple
│   inside quadruple
│   double
│   │   inside double
double
│   inside double`);
});

// ---------------------------------------------------------------------------
(function() {
  var A, B, C, D, lOutput, main, output;
  lOutput = undef;
  output = function(str) {
    return lOutput.push(str);
  };
  main = function() {
    A();
  };
  A = function() {
    var ref, x;
    dbgEnter("A");
    C();
    ref = B();
    for (x of ref) {
      output(x);
      C();
    }
    dbgReturn("A");
  };
  B = function*() {
    dbgEnter("B");
    output(13);
    dbgYield("B", 5);
    yield 5;
    dbgResume("B");
    C();
    dbgYield("B");
    yield* D();
    dbgResume("B");
    dbgReturn("B");
  };
  C = function() {
    dbgEnter("C");
    output('here');
    dbg("here");
    dbg("x", 9);
    dbgReturn("C");
  };
  D = function*() {
    dbgEnter("D");
    dbgYield("D", 1);
    yield 1;
    dbgResume("D");
    dbgYield("D", 2);
    yield 2;
    dbgResume("D");
    dbgReturn("D");
  };
  test("line 69", (t) => {
    lOutput = [];
    utReset();
    main();
    t.is(arrayToBlock(lOutput), `here
13
5
here
here
1
here
2
here`);
    return t.is(utGetLog(), undef);
  });
  // --- Try with various settings of setDebugging()
  test("line 88", (t) => {
    lOutput = [];
    utReset();
    resetDebugging();
    setDebugging("C");
    main();
    // --- C should be called 5 times
    return t.is(utGetLog(), `enter C
│   here
│   x = 9
└─> return from C
enter C
│   here
│   x = 9
└─> return from C
enter C
│   here
│   x = 9
└─> return from C
enter C
│   here
│   x = 9
└─> return from C
enter C
│   here
│   x = 9
└─> return from C`);
  });
  test("line 109", (t) => {
    lOutput = [];
    utReset();
    resetDebugging();
    setDebugging("D");
    main();
    // --- D should be called once, yielding twice
    return t.is(utGetLog(), `enter D
│   yield D
│   │   arg[0] = 1
│   yield D
│   │   arg[0] = 2
└─> return from D`);
  });
  test("line 126", (t) => {
    lOutput = [];
    utReset();
    resetDebugging();
    setDebugging("C D");
    main();
    // --- D should be called once, yielding twice
    return t.is(utGetLog(), `enter C
│   here
│   x = 9
└─> return from C
enter C
│   here
│   x = 9
└─> return from C
enter C
│   here
│   x = 9
└─> return from C
enter D
│   yield D
│   │   arg[0] = 1
│   enter C
│   │   here
│   │   x = 9
│   └─> return from C
│   yield D
│   │   arg[0] = 2
│   enter C
│   │   here
│   │   x = 9
│   └─> return from C
└─> return from D`);
  });
  return test("line 153", (t) => {
    lOutput = [];
    utReset();
    resetDebugging();
    setDebugging("A B C D");
    main();
    // --- debug all
    return t.is(utGetLog(), `enter A
│   enter C
│   │   here
│   │   x = 9
│   └─> return from C
│   enter B
│   │   yield B
│   │   │   arg[0] = 5
│   │   enter C
│   │   │   here
│   │   │   x = 9
│   │   └─> return from C
│   │   resume B
│   │   enter C
│   │   │   here
│   │   │   x = 9
│   │   └─> return from C
│   │   yield B
│   │   enter D
│   │   │   yield D
│   │   │   │   arg[0] = 1
│   │   │   enter C
│   │   │   │   here
│   │   │   │   x = 9
│   │   │   └─> return from C
│   │   │   resume D
│   │   │   yield D
│   │   │   │   arg[0] = 2
│   │   │   enter C
│   │   │   │   here
│   │   │   │   x = 9
│   │   │   └─> return from C
│   │   │   resume D
│   │   └─> return from D
│   │   resume B
│   └─> return from B
└─> return from A`);
  });
})();

// ---------------------------------------------------------------------------
// --- We want to separate debug and normal logging
(function() {
  var A, dbgOutput, hCustomLoggers, logOutput, main;
  utReset(); // sets a custom logger for calls to LOG, LOGVALUE
  dbgReset(); // sets a custom logger for calls to debug functions
  main = function() {
    dbgEnter('main');
    LOG('in main()');
    A();
    dbgReturn('main');
  };
  A = function() {
    dbgEnter('A');
    LOG('in A()');
    dbgReturn('A');
  };
  hCustomLoggers = {
    enter: function(funcName, lVals, level) {
      return LOG(`ENTERING ${funcName}`);
    }
  };
  setDebugging('A', hCustomLoggers);
  main();
  dbgOutput = dbgGetLog();
  logOutput = utGetLog();
  test("line 533", (t) => {
    return t.is(logOutput, `in main()
in A()`);
  });
  return test("line 538", (t) => {
    return t.is(dbgOutput, `ENTERING A
└─> return from A`);
  });
})();
