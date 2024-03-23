// exceptions.test.coffee
import * as lib from '@jdeighan/base-utils/exceptions';

Object.assign(global, lib);

import {
  throws,
  succeeds
} from '@jdeighan/base-utils/utest';

// ---------------------------------------------------------------------------
throws(function() {
  suppressExceptionLogging(true);
  return croak("BAD");
});

throws(function() {
  suppressExceptionLogging(true);
  return assert(2 + 2 !== 4, 'EXCEPTION');
});

succeeds(function() {
  return assert(2 + 2 === 4);
});