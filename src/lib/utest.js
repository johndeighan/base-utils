// utest.coffee
var SimpleUnitTester;

import test from 'ava';

import {
  isInteger
} from '@jdeighan/base-utils';

import {
  assert
} from '@jdeighan/base-utils/exceptions';

// ---------------------------------------------------------------------------
SimpleUnitTester = class SimpleUnitTester {
  constructor() {
    this.hFound = {}; // used line numbers
  }

  
    // ..........................................................
  getLineNum(lineNum) {
    assert(isInteger(lineNum), `${lineNum} is not an integer`);
    // --- patch lineNum to avoid duplicates
    while (this.hFound[lineNum]) {
      lineNum += 1000;
    }
    this.hFound[lineNum] = true;
    return lineNum;
  }

  // ..........................................................
  truthy(lineNum, bool) {
    lineNum = this.getLineNum(lineNum);
    return test(`line ${lineNum}`, (t) => {
      return t.truthy(bool);
    });
  }

  // ..........................................................
  falsy(lineNum, bool) {
    lineNum = this.getLineNum(lineNum);
    return test(`line ${lineNum}`, (t) => {
      return t.falsy(bool);
    });
  }

  // ..........................................................
  equal(lineNum, val1, val2) {
    lineNum = this.getLineNum(lineNum);
    return test(`line ${lineNum}`, (t) => {
      return t.deepEqual(val1, val2);
    });
  }

  // ..........................................................
  fails(lineNum, func) {
    var err, ok;
    lineNum = this.getLineNum(lineNum);
    if (typeof func !== 'function') {
      throw new Error("SimpleUnitTester.fails(): function expected");
    }
    try {
      func();
      ok = true;
    } catch (error) {
      err = error;
      ok = false;
    }
    return test(`line ${lineNum}`, (t) => {
      return t.falsy(ok);
    });
  }

  // ..........................................................
  succeeds(lineNum, func) {
    var err, ok;
    lineNum = this.getLineNum(lineNum);
    if (typeof func !== 'function') {
      throw new Error("SimpleUnitTester.fails(): function expected");
    }
    try {
      func();
      ok = true;
    } catch (error) {
      err = error;
      ok = false;
    }
    return test(`line ${lineNum}`, (t) => {
      return t.truthy(ok);
    });
  }

};

export var utest = new SimpleUnitTester();

//# sourceMappingURL=utest.js.map
