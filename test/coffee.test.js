// coffee.test.coffee
import {
  undef
} from '@jdeighan/base-utils';

import * as lib from '@jdeighan/base-utils/coffee';

Object.assign(global, lib);

import {
  succeeds,
  fails
} from '@jdeighan/base-utils/utest';

// ---------------------------------------------------------------------------
succeeds(() => {
  return brew('v = 5');
});

fails(() => {
  return brew('let v = 5');
});

succeeds(() => {
  return toAST('v = 5');
});

fails(() => {
  return toAST('let v = 5');
});