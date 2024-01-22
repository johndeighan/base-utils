// v8-stack.test.coffee
import test from 'ava';

import {
  assert,
  croak
} from '@jdeighan/base-utils/exceptions';

import {
  undef,
  defined
} from '@jdeighan/base-utils';

import {
  fromTAML
} from '@jdeighan/base-utils/taml';

import {
  LOG,
  LOGVALUE
} from '@jdeighan/base-utils/log';

import {
  getMyDirectCaller,
  getMyOutsideCaller,
  getV8Stack,
  debugV8Stack,
  getV8StackStr
} from '@jdeighan/base-utils/v8-stack';

import {
  getBoth
} from './v8-module.js';

// ---------------------------------------------------------------------------
(function() {
  var func1, func2, hCaller, main;
  hCaller = undef;
  main = function() {
    func1();
    return func2();
  };
  func1 = function() {};
  func2 = function() {
    hCaller = getMyDirectCaller();
  };
  // ------------------------------------------------------------------------
  return test("line 33", (t) => {
    main();
    return t.like(hCaller, {
      type: 'function',
      functionName: 'main',
      fileName: 'v8-stack.test.js'
    });
  });
})();

// ---------------------------------------------------------------------------
(function() {
  var func1, func2, lCallers1, lCallers2, main;
  lCallers1 = undef;
  lCallers2 = undef;
  main = function() {
    func1();
    return func2();
  };
  func1 = function() {
    return lCallers1 = getBoth();
  };
  func2 = function() {
    lCallers2 = getBoth();
  };
  return test("line 60", (t) => {
    main();
    t.like(lCallers1[0], {
      type: 'function',
      functionName: 'secondFunc',
      fileName: 'v8-module.js'
    });
    t.like(lCallers1[1], {
      type: 'function',
      functionName: 'func1',
      fileName: 'v8-stack.test.js'
    });
    t.like(lCallers2[0], {
      type: 'function',
      functionName: 'secondFunc',
      fileName: 'v8-module.js'
    });
    return t.like(lCallers2[1], {
      type: 'function',
      functionName: 'func2',
      fileName: 'v8-stack.test.js'
    });
  });
})();

// ---------------------------------------------------------------------------
(() => {
  var func1, func2;
  func1 = async() => {
    return (await func2());
  };
  func2 = async() => {
    var stackStr;
    stackStr = (await getV8StackStr());
    return stackStr;
  };
  return test("line 94", async(t) => {
    return t.is((await func1()), `function at v8-stack.js:62:19
function at v8-stack.test.js:106:23
function at v8-stack.test.js:102:19
script at v8-stack.test.js:110:24`);
  });
})();

// ---------------------------------------------------------------------------
(() => {
  var func1, func2;
  func1 = async() => {
    func2();
    return (await getV8StackStr('debug'));
  };
  func2 = () => {
    var x;
    x = 2 * 2;
    return x;
  };
  return test("line 113", async(t) => {
    return t.is((await func1()), `function at v8-stack.js:62:19
function at v8-stack.test.js:122:19
script at v8-stack.test.js:130:24`);
  });
})();

//# sourceMappingURL=v8-stack.test.js.map
