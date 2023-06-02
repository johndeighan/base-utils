// SimpleUnitTester.coffee
var SimpleUnitTester;

import test from 'ava';

// ---------------------------------------------------------------------------
SimpleUnitTester = class SimpleUnitTester {
  constructor() {
    this.hFound = {}; // used line numbers
  }

  
    // ..........................................................
  getLineNum(lineNum) {
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

};

export var utest = new SimpleUnitTester();
