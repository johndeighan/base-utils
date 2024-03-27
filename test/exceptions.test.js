// exceptions.test.coffee
import * as lib from '@jdeighan/base-utils/exceptions';

Object.assign(global, lib);

import {
  fails,
  succeeds
} from '@jdeighan/base-utils/utest';

// ---------------------------------------------------------------------------
fails(function() {
  suppressExceptionLogging(true);
  return croak("BAD");
});

fails(function() {
  suppressExceptionLogging(true);
  return assert(2 + 2 !== 4, 'EXCEPTION');
});

succeeds(function() {
  return assert(2 + 2 === 4);
});