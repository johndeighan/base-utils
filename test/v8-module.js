// v8-module.coffee
var secondFunc, thirdFunc;

import {
  getMyDirectCaller,
  getMyOutsideCaller
} from '@jdeighan/base-utils/v8-stack';

// ---------------------------------------------------------------------------
export var getCallers = function() {
  return secondFunc();
};

// ---------------------------------------------------------------------------
secondFunc = function() {
  return thirdFunc();
};

// ---------------------------------------------------------------------------
thirdFunc = function() {
  // --- direct caller should be 'secondFunc'
  //     outside caller should be the function that called getCaller()
  return [getMyDirectCaller(), getMyOutsideCaller()];
};
