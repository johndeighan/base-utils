// Generated by CoffeeScript 2.7.0
// exceptions.test.coffee
import test from 'ava';

import {
  suppressExceptionLogging,
  haltOnError,
  assert,
  croak
} from '@jdeighan/base-utils/exceptions';

haltOnError(false);

// ---------------------------------------------------------------------------
test("line 12", (t) => {
  return t.throws(function() {
    suppressExceptionLogging(true);
    return croak("BAD");
  });
});

test("line 13", (t) => {
  return t.throws(function() {
    suppressExceptionLogging(true);
    return assert(2 + 2 !== 4, 'EXCEPTION');
  });
});

test("line 14", (t) => {
  return t.notThrows(function() {
    return assert(2 + 2 === 4);
  });
});