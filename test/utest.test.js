  // u.test.coffee
import {
  isString,
  OL
} from '@jdeighan/base-utils';

import {
  assert
} from '@jdeighan/base-utils/exceptions';

import {
  u,
  UnitTester,
  equal,
  like,
  notequal,
  truthy,
  falsy,
  throws,
  succeeds
} from '@jdeighan/base-utils/utest';

// ---------------------------------------------------------------------------
u.equal(2 + 2, 4);

u.like({
  a: 1,
  b: 2,
  c: 3
}, {
  a: 1,
  c: 3
});

u.notequal(2 + 2, 5);

u.truthy(42);

u.falsy(false);

u.throws(() => {
  throw new Error("bad");
});

u.succeeds(() => {
  return 'me';
});

u.like("abc\n", "abc"); // strings are right trimmed

u.like("abc\n", "abc   ");

// ---------------------------------------------------------------------------
equal(2 + 2, 4);

like({
  a: 1,
  b: 2,
  c: 3
}, {
  a: 1,
  c: 3
});

notequal(2 + 2, 5);

truthy(42);

falsy(false);

throws(() => {
  throw new Error("bad");
});

succeeds(() => {
  return 'me';
});

like("abc\n", "abc"); // strings are right trimmed

like("abc\n", "abc   ");

// ---------------------------------------------------------------------------
(() => {
  var utest2;
  utest2 = new UnitTester();
  utest2.transformValue = (val) => {
    assert(isString(val), `val is ${val}`);
    return val.toUpperCase();
  };
  return utest2.equal('abc', 'ABC');
})();

//# sourceMappingURL=utest.test.js.map
