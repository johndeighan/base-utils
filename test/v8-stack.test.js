  // v8-stack.test.coffee
import {
  assert,
  croak
} from '@jdeighan/base-utils/exceptions';

import {
  undef,
  defined,
  notdefined
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

import {
  utest
} from '@jdeighan/base-utils/utest';

// ---------------------------------------------------------------------------
(function() {
  var func1, func2, main, stack1, stack2;
  stack1 = undef;
  stack2 = undef;
  main = function() {
    func1();
    return func2();
  };
  func1 = function() {
    return stack1 = getV8Stack();
  };
  func2 = function() {
    stack2 = getV8Stack();
  };
  main();
  utest.like(stack1, [
    {
      functionName: 'func1'
    }
  ]);
  return utest.like(stack2, [
    {
      functionName: 'func2'
    }
  ]);
})();

// ---------------------------------------------------------------------------
(function() {
  var caller1, caller2, func1, func2, main;
  caller1 = undef;
  caller2 = undef;
  main = function() {
    func1();
    return func2();
  };
  func1 = function() {
    return caller1 = getMyDirectCaller();
  };
  func2 = function() {
    caller2 = getMyDirectCaller();
  };
  main();
  utest.like(caller1, {
    functionName: 'main',
    fileName: 'v8-stack.test.js'
  });
  return utest.like(caller2, {
    functionName: 'main',
    fileName: 'v8-stack.test.js'
  });
})();

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
  main();
  return utest.like(hCaller, {
    type: 'function',
    functionName: 'main',
    fileName: 'v8-stack.test.js'
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
  main();
  utest.like(lCallers1[0], {
    type: 'function',
    functionName: 'secondFunc',
    fileName: 'v8-module.js'
  });
  utest.like(lCallers1[1], {
    type: 'function',
    functionName: 'func1',
    fileName: 'v8-stack.test.js'
  });
  utest.like(lCallers2[0], {
    type: 'function',
    functionName: 'secondFunc',
    fileName: 'v8-module.js'
  });
  return utest.like(lCallers2[1], {
    type: 'function',
    functionName: 'func2',
    fileName: 'v8-stack.test.js'
  });
})();

// ---------------------------------------------------------------------------
(async() => {
  var func1, func2;
  func1 = async() => {
    return (await func2());
  };
  func2 = async() => {
    var stackStr;
    stackStr = (await getV8StackStr());
    return stackStr;
  };
  return utest.equal((await func1()), `function at v8-stack.test.js:150:23
function at v8-stack.test.js:147:19
script at v8-stack.test.js:162:29`);
})();

// ---------------------------------------------------------------------------
(async() => {
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
  return utest.equal((await func1()), `function at v8-stack.test.js:166:19
script at v8-stack.test.js:179:29`);
})();

//# sourceMappingURL=v8-stack.test.js.map
