// ll-utils.test.coffee
var a, b, c, d, e;

import test from 'ava';

import {
  undef,
  pass,
  assert,
  defined,
  notdefined,
  alldefined,
  isEmpty,
  nonEmpty,
  deepCopy
} from '@jdeighan/base-utils/ll-utils';

// ---------------------------------------------------------------------------
test("line 13", (t) => {
  return t.is(undef, void 0);
});

test("line 14", (t) => {
  return t.truthy(pass());
});

test("line 15", (t) => {
  return t.truthy(defined(1));
});

test("line 16", (t) => {
  return t.falsy(defined(void 0));
});

test("line 17", (t) => {
  return t.truthy(notdefined(void 0));
});

test("line 18", (t) => {
  return t.falsy(notdefined(12));
});

test("line 19", (t) => {
  return t.notThrows(() => {
    return pass();
  });
});

test("line 20", (t) => {
  return t.notThrows(() => {
    return assert(12 === 12, "BAD");
  });
});

// ---------------------------------------------------------------------------
test("line 24", (t) => {
  return t.truthy(isEmpty(''));
});

test("line 25", (t) => {
  return t.truthy(isEmpty('  \t\t'));
});

test("line 26", (t) => {
  return t.truthy(isEmpty([]));
});

test("line 27", (t) => {
  return t.truthy(isEmpty({}));
});

test("line 29", (t) => {
  return t.truthy(nonEmpty('a'));
});

test("line 30", (t) => {
  return t.truthy(nonEmpty('.'));
});

test("line 31", (t) => {
  return t.truthy(nonEmpty([2]));
});

test("line 32", (t) => {
  return t.truthy(nonEmpty({
    width: 2
  }));
});

// ---------------------------------------------------------------------------
a = undef;

b = null;

c = 42;

d = 'dog';

e = {
  a: 42
};

test("line 42", (t) => {
  return t.truthy(alldefined(c, d, e));
});

test("line 43", (t) => {
  return t.falsy(alldefined(a, b, c, d, e));
});

test("line 44", (t) => {
  return t.falsy(alldefined(a, c, d, e));
});

test("line 45", (t) => {
  return t.falsy(alldefined(b, c, d, e));
});

test("line 47", (t) => {
  return t.deepEqual(deepCopy(e), {
    a: 42
  });
});

//# sourceMappingURL=ll-utils.test.js.map
