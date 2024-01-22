// utest.coffee
var SimpleUnitTester, getParms;

import test from 'ava';

import {
  defined,
  isInteger
} from '@jdeighan/base-utils';

import {
  assert,
  croak
} from '@jdeighan/base-utils/exceptions';

import {
  isFile,
  parsePath,
  fileExt,
  withExt
} from '@jdeighan/base-utils/ll-fs';

import {
  mapLineNum
} from '@jdeighan/base-utils/source-map';

import {
  getMyOutsideCaller
} from '@jdeighan/base-utils/ll-v8-stack';

// ---------------------------------------------------------------------------
getParms = (lParms, nExpected) => {
  var col, filePath, line, mapFile, nParms;
  nParms = lParms.length;
  if (nParms === nExpected) {
    // --- Disable this feature for now
    throw new Error('Currently you must provide a line number in unit tests');
    // --- We need to figure out the line number of the caller
    ({filePath, line, col} = getMyOutsideCaller());
    if (fileExt(filePath) === '.js') {
      console.log("file is a JS file");
      mapFile = `${filePath}.map`;
      console.log(`map file is ${mapFile}`);
      if (isFile(mapFile)) {
        console.log("map file exists");
        // --- Attempt to use source map to get true line number
        line = mapLineNum(filePath, line);
        if (defined(line)) {
          console.log(`SOURCE MAP: ${line}`);
        }
      } else {
        console.log("map file does not exist");
      }
    }
    assert(isInteger(line), "line number not an integer");
    console.log(`AUTO LINE NUM: ${line}`);
    return [line, ...lParms];
  } else if ((nParms = nExpected + 1)) {
    return lParms;
  } else {
    return croak("Bad parameters to utest function");
  }
};

// ---------------------------------------------------------------------------
// --- Available tests w/num required params (aside from line num)
//        equal 2
//        truthy 1
//        falsy 1
//        like 2
//        throws/fails 1 (a function)
//        succeeds 1 (a function)
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
  equal(...lParms) {
    var lineNum, val1, val2;
    [lineNum, val1, val2] = getParms(lParms, 2);
    lineNum = this.getLineNum(lineNum);
    return test(`line ${lineNum}`, (t) => {
      return t.deepEqual(val1, val2);
    });
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
  like(lineNum, val1, val2) {
    lineNum = this.getLineNum(lineNum);
    return test(`line ${lineNum}`, (t) => {
      return t.like(val1, val2);
    });
  }

  // ..........................................................
  throws(lineNum, func) {
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

  fails(lineNum, func) {
    return this.throws(lineNum, func);
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
