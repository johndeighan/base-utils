// Generated by CoffeeScript 2.7.0
// base-utils.test.coffee
var double, quadruple;

import test from 'ava';

import {
  assert,
  croak,
  exReset,
  exGetLog
} from '@jdeighan/base-utils/exceptions';

import {
  undef,
  pass,
  isNumber,
  arrayToBlock
} from '@jdeighan/base-utils/utils';

import {
  setLogger,
  debugLogging,
  LOG,
  sep_dash,
  clearAllLogs,
  getMyLog
} from '@jdeighan/base-utils/log';

import {
  getDebugLog
} from '@jdeighan/base-utils/debug';

import {
  debugV8Stack
} from '@jdeighan/base-utils/v8-stack';

// ---------------------------------------------------------------------------
double = (x) => {
  assert(isNumber(x), "not a number");
  return 2 * x;
};

quadruple = (x) => {
  return 2 * double(x);
};

// ---------------------------------------------------------------------------
test("line 29", (t) => {
  clearAllLogs();
  LOG('abc');
  LOG('def');
  return t.is(getMyLog(), "abc\ndef");
});

test("line 35", (t) => {
  var x;
  x = 5;
  return t.is(quadruple(x), 20);
});

test("line 40", (t) => {
  var result;
  exReset();
  try {
    result = quadruple('abc');
  } catch (error) {}
  return t.is(exGetLog(), `-------------------------
JavaScript CALL STACK:
   double() base-utils.test.js:40:3
   quadruple() base-utils.test.js:45:14
   script base-utils.test.js base-utils.test.js:66:14
-------------------------
ERROR: not a number`);
});

test("line 53", (t) => {
  var err;
  clearAllLogs();
  try {
    croak("Bad Moon Rising");
  } catch (error) {
    err = error;
    LOG(err.message);
  }
  return t.is(getMyLog(), "ERROR (croak): Bad Moon Rising");
});
