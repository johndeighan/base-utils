  // exceptions.test.coffee
import {
  assert,
  croak,
  suppressExceptionLogging
} from '@jdeighan/base-utils/exceptions';

import {
  utest
} from '@jdeighan/base-utils/utest';

// ---------------------------------------------------------------------------
utest.throws(function() {
  suppressExceptionLogging(true);
  return croak("BAD");
});

utest.throws(function() {
  suppressExceptionLogging(true);
  return assert(2 + 2 !== 4, 'EXCEPTION');
});

utest.succeeds(function() {
  return assert(2 + 2 === 4);
});

//# sourceMappingURL=exceptions.test.js.map
