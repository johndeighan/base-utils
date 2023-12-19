// ll-v8-stack.test.coffee
import test from 'ava';

import {
  pass,
  undef,
  defined,
  notdefined,
  assert
} from '@jdeighan/base-utils/ll-utils';

import {
  getV8Stack,
  getMyOutsideCaller,
  getMyDirectCaller
} from '@jdeighan/base-utils/ll-v8-stack';

import {
  getStack,
  getCaller
} from './templib.js';

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
  return test("line 30", (t) => {
    main();
    t.like(stack1, [
      {
        functionName: 'func1'
      }
    ]);
    return t.like(stack2, [
      {
        functionName: 'func2'
      }
    ]);
  });
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
  return test("line 61", (t) => {
    main();
    t.like(caller1, {
      functionName: 'main',
      fileName: 'll-v8-stack.test.js'
    });
    return t.like(caller2, {
      functionName: 'main',
      fileName: 'll-v8-stack.test.js'
    });
  });
})();

// ---------------------------------------------------------------------------
(function() {
  var func1, h, main;
  h = undef;
  main = function() {
    return func1();
  };
  func1 = function() {
    return h = getCaller();
  };
  return test("line 82", (t) => {
    main();
    t.is(h.fileName, 'll-v8-stack.test.js');
    return t.is(h.line, 89); // --- from *.js file
  });
})();

//# sourceMappingURL=ll-v8-stack.test.js.map
