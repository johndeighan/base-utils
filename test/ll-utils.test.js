// ll-utils.test.coffee
var a, b, c, d, dir, e, fullPath;

import test from 'ava';

import {
  undef,
  mydir,
  pass,
  assert,
  defined,
  notdefined,
  alldefined,
  isEmpty,
  nonEmpty,
  getFullPath,
  deepCopy
} from '@jdeighan/base-utils/ll-utils';

import {
  getStack,
  getCaller
} from './templib.js';

dir = mydir(import.meta.url);

fullPath = getFullPath('.');

// ---------------------------------------------------------------------------
test("line 16", (t) => {
  return t.is(undef, void 0);
});

test("line 17", (t) => {
  return t.truthy(dir.match(/\/base\-utils\/test$/));
});

test("line 18", (t) => {
  return t.truthy(pass());
});

test("line 19", (t) => {
  return t.truthy(defined(1));
});

test("line 20", (t) => {
  return t.falsy(defined(void 0));
});

test("line 21", (t) => {
  return t.truthy(notdefined(void 0));
});

test("line 22", (t) => {
  return t.falsy(notdefined(12));
});

test("line 23", (t) => {
  return t.notThrows(() => {
    return pass();
  });
});

test("line 24", (t) => {
  return t.notThrows(() => {
    return assert(12 === 12, "BAD");
  });
});

// ---------------------------------------------------------------------------
test("line 28", (t) => {
  return t.truthy(isEmpty(''));
});

test("line 29", (t) => {
  return t.truthy(isEmpty('  \t\t'));
});

test("line 30", (t) => {
  return t.truthy(isEmpty([]));
});

test("line 31", (t) => {
  return t.truthy(isEmpty({}));
});

test("line 33", (t) => {
  return t.truthy(nonEmpty('a'));
});

test("line 34", (t) => {
  return t.truthy(nonEmpty('.'));
});

test("line 35", (t) => {
  return t.truthy(nonEmpty([2]));
});

test("line 36", (t) => {
  return t.truthy(nonEmpty({
    width: 2
  }));
});

test("line 38", (t) => {
  return t.is(fullPath, "C:/Users/johnd/base-utils");
});

// ---------------------------------------------------------------------------
a = undef;

b = null;

c = 42;

d = 'dog';

e = {
  a: 42
};

test("line 48", (t) => {
  return t.truthy(alldefined(c, d, e));
});

test("line 49", (t) => {
  return t.falsy(alldefined(a, b, c, d, e));
});

test("line 50", (t) => {
  return t.falsy(alldefined(a, c, d, e));
});

test("line 51", (t) => {
  return t.falsy(alldefined(b, c, d, e));
});

test("line 53", (t) => {
  return t.deepEqual(deepCopy(e), {
    a: 42
  });
});

//# sourceMappingURL=ll-utils.test.js.map
