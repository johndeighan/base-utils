  // utest.test.coffee
import {
  isString,
  OL
} from '@jdeighan/base-utils';

import {
  assert
} from '@jdeighan/base-utils/exceptions';

import {
  utest,
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
utest.equal(2 + 2, 4);

utest.like({
  a: 1,
  b: 2,
  c: 3
}, {
  a: 1,
  c: 3
});

utest.notequal(2 + 2, 5);

utest.truthy(42);

utest.falsy(false);

utest.throws(() => {
  throw new Error("bad");
});

utest.succeeds(() => {
  return 'me';
});

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
