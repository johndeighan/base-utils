#!/usr/bin/env node
// analyzeObj.coffee
var NewClass, addObj, arrow, flag, func, gen, hObj, lKeys, numKeys, tt;

import {
  undef,
  defined,
  notdefined,
  pass,
  keys,
  analyzeObj,
  isString,
  isBoolean,
  truncateStr
} from '@jdeighan/base-utils';

import {
  TextTable
} from '@jdeighan/base-utils/text-table';

// ---------------------------------------------------------------------------

// --- analyzeObj always returns an object with
//     the same set of keys
hObj = analyzeObj(undef);

lKeys = keys(hObj);

numKeys = lKeys.length;

console.log(`numKeys = ${numKeys}`);

tt = new TextTable("l" + " l".repeat(numKeys));

tt.fullsep('-');

tt.labels(['value', ...lKeys]);

tt.sep('-');

flag = (bool) => {
  if (bool) {
    return 'YES';
  } else {
    return 'NO';
  }
};

// ---------------------------------------------------------------------------
addObj = (obj, label) => {
  var h, i, key, lValues, len, value;
  h = analyzeObj(obj);
  lValues = [label];
  for (i = 0, len = lKeys.length; i < len; i++) {
    key = lKeys[i];
    value = h[key];
    if (notdefined(value)) {
      lValues.push('');
    } else if (isString(value)) {
      lValues.push(value);
    } else if (isBoolean(value)) {
      lValues.push(flag(value));
    } else {
      throw new Error("Bad object");
    }
  }
  tt.data(lValues);
};

// ---------------------------------------------------------------------------
NewClass = class NewClass {
  constructor(name = 'bob') {
    this.name = name;
    this.doIt = pass();
  }

  meth(x) {
    return 2 * x;
  }

};

func = function() {
  return 42;
};

arrow = () => {
  return 42;
};

gen = function*() {
  yield 1;
  yield 2;
  yield 3;
};

addObj(undef, 'undef');

addObj(null, 'null');

addObj(true, 'true');

addObj(false, 'false');

addObj(42, '42');

addObj(3.14, '3.14');

addObj(BigInt(42), 'BigInt(42)');

addObj('abc', "'abc'");

addObj(NewClass, 'NewClass');

addObj((function() {
  return 3;
}), "() -> return 3");

addObj(function func2(x) {return 42;}, "function func2(x) {return 42;}");

addObj((() => {
  return 3;
}), "() => return 3");

addObj(func, "func");

addObj(arrow, "arrow");

addObj(gen, 'gen');

addObj({}, '{}');

addObj([], '[]');

addObj({
  a: 1
}, '{a:1}');

addObj([1, 2], '[1,2]');

addObj(new NewClass(), 'new NewClass()');

addObj(new Number(42), 'new Number(42)');

addObj(new String('abc'), "new String('abc')");

addObj(/^ab$/, "/^ab$/");

addObj(new Promise((x) => {
  return 42;
}), "new Promise((x) => 42)");

addObj(gen(), 'gen()');

console.log(tt.asString());