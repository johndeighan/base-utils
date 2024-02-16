  // cmd-args.test.coffee
import {
  undef
} from '@jdeighan/base-utils';

import {
  UnitTester
} from '@jdeighan/base-utils/utest';

import {
  getArgs
} from '@jdeighan/base-utils/cmd-args';

// ---------------------------------------------------------------------------
(() => {
  var u;
  u = new UnitTester();
  u.transformValue = (cmdline) => {
    var hOptions;
    hOptions = {
      boolean: ['d'],
      default: {
        d: false
      }
    };
    return getArgs(hOptions, cmdline);
  };
  u.equal('sveltekit', {
    d: false,
    _: ['sveltekit']
  });
  u.equal('sveltekit -d', {
    d: true,
    _: ['sveltekit']
  });
  return u.equal('-d sveltekit', {
    d: true,
    _: ['sveltekit']
  });
})();

// ---------------------------------------------------------------------------
(() => {
  var u;
  u = new UnitTester();
  u.transformValue = (cmdline) => {
    var hOptions;
    hOptions = {
      boolean: ['a', 'b', 'c', 'h'],
      string: ['name'],
      number: ['count'],
      default: {
        a: true
      }
    };
    return getArgs(hOptions, cmdline);
  };
  u.equal('-c def', {
    a: true, // default value
    c: true, // explicitly on cmd line
    _: ['def'] // non-options
  });
  return u.equal('-c --name=abc --count=5 def ghi', {
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

//# sourceMappingURL=cmd-args.test2.js.map
