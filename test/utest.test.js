// utest.test.coffee
import test from 'ava';

import {
  utest
} from '@jdeighan/base-utils/utest';

// ---------------------------------------------------------------------------
utest.truthy(9, 42);

utest.equal(10, 2 + 2, 4);

utest.falsy(11, false);

utest.like(12, {
  a: 1,
  b: 2,
  c: 3
}, {
  a: 1,
  c: 3
});

utest.throws(13, () => {
  throw new Error("bad");
});

utest.succeeds(14, () => {
  return 'me';
});

//# sourceMappingURL=utest.test.js.map
