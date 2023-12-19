// testlib.coffee
var func1, func2;

import {
  undef
} from '@jdeighan/base-utils';

import {
  getMyOutsideCaller
} from '@jdeighan/base-utils/ll-v8-stack';

// ---------------------------------------------------------------------------
export var getMyCaller = () => {
  func1();
  return func2();
};

// ---------------------------------------------------------------------------
func1 = function() {};

// ---------------------------------------------------------------------------
func2 = function() {
  var hNode;
  hNode = getMyOutsideCaller();
  return hNode;
};

//# sourceMappingURL=testlib.js.map
