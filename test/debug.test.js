// Generated by CoffeeScript 2.7.0
// debug.test.coffee
var Class1, Class2, double, quadruple;

import test from 'ava';

import {
  undef,
  pass,
  arrayToBlock,
  isNumber,
  spaces
} from '@jdeighan/exceptions/utils';

import {
  toTAML
} from '@jdeighan/exceptions/taml';

import {
  haltOnError,
  assert,
  croak
} from '@jdeighan/exceptions';

import {
  getPrefix
} from '@jdeighan/exceptions/prefix';

import {
  utReset,
  LOG,
  utGetLog
} from '@jdeighan/exceptions/log';

import {
  setDebugging,
  resetDebugging,
  setCustomDebugLogger,
  debug,
  getType
} from '@jdeighan/exceptions/debug';

// ---------------------------------------------------------------------------

// --- Until setDebugging() is called with a nonEmpty string,
//     all debugging is turned off
test("line 22", (t) => {
  return t.deepEqual(getType("something"), [undef, undef, undef]);
});

test("line 27", (t) => {
  setDebugging("myfunc");
  t.deepEqual(getType("something"), ["string", undef, undef]);
  return resetDebugging();
});

test("line 34", (t) => {
  setDebugging("myfunc");
  t.deepEqual(getType("enter myfunc"), ["enter", "myfunc", undef]);
  return resetDebugging();
});

test("line 41", (t) => {
  setDebugging("myfunc");
  t.deepEqual(getType("enter obj.method()"), ["enter", "method", "obj"]);
  return resetDebugging();
});

test("line 48", (t) => {
  setDebugging("myfunc");
  t.deepEqual(getType("return from myfunc"), ["return", "myfunc", undef]);
  return resetDebugging();
});

test("line 55", (t) => {
  setDebugging("myfunc");
  t.deepEqual(getType("return 42 from myobj.mymethod"), ["return", "mymethod", "myobj"]);
  return resetDebugging();
});

// ---------------------------------------------------------------------------
double = (x) => {
  var result;
  debug("enter double()", x);
  assert(isNumber(x), "not a number");
  debug("inside double()");
  result = 2 * x;
  debug("return from double()", result);
  return result;
};

quadruple = (x) => {
  var result;
  debug("enter quadruple()", x);
  debug("inside quadruple()");
  result = 2 * double(x);
  debug("return from quadruple()", result);
  return result;
};

// ---------------------------------------------------------------------------
test("line 81", (t) => {
  var result;
  utReset();
  result = quadruple(3);
  return t.is(result, 12);
});

// ---------------------------------------------------------------------------
test("line 89", (t) => {
  var result;
  utReset();
  setDebugging('double');
  result = quadruple(3);
  resetDebugging();
  return t.is(result, 12);
});

// ---------------------------------------------------------------------------
test("line 99", (t) => {
  var result;
  utReset();
  setDebugging('double');
  result = quadruple(3);
  resetDebugging();
  return t.is(utGetLog(), `enter double()
│   arg[0] = 3
│   inside double()
└─> return from double()
    ret[0] = 6`);
});

// ---------------------------------------------------------------------------
test("line 115", (t) => {
  var result;
  utReset();
  setDebugging('double quadruple');
  result = quadruple(3);
  resetDebugging();
  t.is(result, 12);
  return t.is(utGetLog(), `enter quadruple()
│   arg[0] = 3
│   inside quadruple()
│   enter double()
│   │   arg[0] = 3
│   │   inside double()
│   └─> return from double()
│       ret[0] = 6
└─> return from quadruple()
    ret[0] = 12`);
});

// ---------------------------------------------------------------------------
Class1 = class Class1 {
  constructor() {
    this.lStrings = [];
  }

  add(str) {
    debug("enter Class1.add()", str);
    this.lStrings.push(str);
    debug("return from Class1.add()");
  }

};

Class2 = class Class2 {
  constructor() {
    this.lStrings = [];
  }

  add(str) {
    debug("enter Class2.add()", str);
    this.lStrings.push(str);
    debug("return from Class2.add()");
  }

};

// ---------------------------------------------------------------------------
test("line 157", (t) => {
  utReset();
  setDebugging('add');
  new Class1().add('abc');
  new Class2().add('def');
  resetDebugging();
  return t.is(utGetLog(), `enter Class1.add()
│   arg[0] = 'abc'
└─> return from Class1.add()
enter Class2.add()
│   arg[0] = 'def'
└─> return from Class2.add()`);
});

// ---------------------------------------------------------------------------
test("line 176", (t) => {
  utReset();
  setDebugging('Class2.add');
  new Class1().add('abc');
  new Class2().add('def');
  resetDebugging();
  return t.is(utGetLog(), `enter Class2.add()
│   arg[0] = 'def'
└─> return from Class2.add()`);
});

// ---------------------------------------------------------------------------
test("line 192", (t) => {
  var result;
  utReset();
  setDebugging('double quadruple');
  result = double(quadruple(3));
  resetDebugging();
  t.is(result, 24);
  return t.is(utGetLog(), `enter quadruple()
│   arg[0] = 3
│   inside quadruple()
│   enter double()
│   │   arg[0] = 3
│   │   inside double()
│   └─> return from double()
│       ret[0] = 6
└─> return from quadruple()
    ret[0] = 12
enter double()
│   arg[0] = 12
│   inside double()
└─> return from double()
    ret[0] = 24`);
});

// ---------------------------------------------------------------------------
// Test custom loggers
test("line 220", (t) => {
  var result;
  utReset();
  setDebugging('double quadruple');
  setCustomDebugLogger('enter', function(label, lObjects, level, funcName, objName) {
    LOG(getPrefix(level, 'plain') + funcName);
    return true;
  });
  setCustomDebugLogger('return', function(label, lObjects, level, funcName, objName) {
    return true;
  });
  result = double(quadruple(3));
  resetDebugging();
  t.is(result, 24);
  return t.is(utGetLog(), `quadruple
│   inside quadruple()
│   double
│   │   inside double()
double
│   inside double()`);
});
