// v8-stack-str.coffee
import test from 'ava';

import {
  undef,
  defined
} from '@jdeighan/base-utils';

import {
  getV8Stack,
  getV8StackStr
} from '@jdeighan/base-utils/v8-stack';

import {
  getStack,
  getCaller
} from './templib.js';

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
  return test("line 19", async(t) => {
    return t.is((await func1()), `function at v8-stack.js:70:19
function at v8-stack-str.test.js:27:23
function at v8-stack-str.test.js:23:19
script at v8-stack-str.test.js:31:24`);
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
  return test("line 38", async(t) => {
    return t.is((await func1()), `function at v8-stack.js:70:19
function at v8-stack-str.test.js:43:19
script at v8-stack-str.test.js:51:24`);
  });
})();

//# sourceMappingURL=v8-stack-str.test.js.map
