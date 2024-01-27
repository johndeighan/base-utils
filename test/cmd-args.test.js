  // cmd-args.test.coffee
import {
  getArgs
} from '@jdeighan/base-utils/cmd-args';

import {
  undef
} from '@jdeighan/base-utils';

import {
  utest
} from '@jdeighan/base-utils/utest';

// ---------------------------------------------------------------------------
(() => {
  var cmdLine, hExpected, hOpts;
  hExpected = {
    boolean: ['a', 'b', 'c', 'h'],
    string: ['name'],
    number: ['count'],
    default: {
      a: true
    }
  };
  cmdLine = '-c --name=abc --count=5 def ghi';
  hOpts = getArgs(hExpected, cmdLine);
  return utest.equal(hOpts, {
    a: true, // default value
    b: false, // not on cmd line
    c: true, // explicitly on cmd line
    h: false, // not on command line
    name: 'abc',
    count: 5, // returned as a number
    _: [
      'def',
      'ghi' // non-options
    ]
  });
})();

//# sourceMappingURL=cmd-args.test.js.map
