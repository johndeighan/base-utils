// Generated by CoffeeScript 2.7.0
// base-utils.test.coffee
var double, getLog, lLog, quadruple;

import test from 'ava';

import {
  pass,
  isNumber,
  arrayToBlock
} from '@jdeighan/base-utils/utils';

import {
  haltOnError,
  assert,
  croak
} from '@jdeighan/base-utils';

import {
  setLogger,
  debugLogging,
  LOG,
  sep_dash
} from '@jdeighan/base-utils/log';

// ---------------------------------------------------------------------------
double = (x) => {
  assert(isNumber(x), "not a number");
  return 2 * x;
};

quadruple = (x) => {
  return 2 * double(x);
};

// ---------------------------------------------------------------------------

// --- clear lLog before each test
lLog = [];

setLogger((str) => {
  return lLog.push(str);
});

getLog = () => {
  return arrayToBlock(lLog);
};

// ---------------------------------------------------------------------------
test("line 31", (t) => {
  lLog = [];
  LOG('abc');
  LOG('def');
  return t.is(getLog(), "abc\ndef");
});

test("line 37", (t) => {
  var x;
  x = 5;
  return t.is(quadruple(x), 20);
});

test("line 41", (t) => {
  var result;
  lLog = [];
  try {
    result = quadruple('abc');
  } catch (error) {}
  return t.is(getLog(), `${sep_dash}
JavaScript CALL STACK:
   double
   quadruple
${sep_dash}
ERROR: not a number (in double())`);
});

test("line 57", (t) => {
  var err;
  lLog = [];
  try {
    croak("Bad Moon Rising");
  } catch (error) {
    err = error;
    LOG(err.message);
  }
  return t.is(getLog(), "ERROR (croak): Bad Moon Rising");
});