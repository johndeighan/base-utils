// utest.coffee
var u_private;

import test from 'ava';

import {
  defined,
  isInteger
} from '@jdeighan/base-utils';

import {
  assert,
  croak,
  exReset,
  exGetLog
} from '@jdeighan/base-utils/exceptions';

import {
  isFile,
  parsePath,
  fileExt
} from '@jdeighan/base-utils/ll-fs';

import {
  mapLineNum
} from '@jdeighan/base-utils/source-map';

import {
  getMyOutsideCaller
} from '@jdeighan/base-utils/v8-stack';

// ---------------------------------------------------------------------------
// --- Available tests w/num required params (aside from line num)
//        equal 2
//        truthy 1
//        falsy 1
//        like 2
//        throws 1 (a function)
//        succeeds 1 (a function)
// ---------------------------------------------------------------------------
export var UnitTester = class UnitTester {
  constructor() {
    
    // ........................................................................
    this.doDebug = this.doDebug.bind(this);
    // ........................................................................
    this.getParms = this.getParms.bind(this);
    this.debug = false;
    this.hFound = {}; // used line numbers
  }

  doDebug() {
    this.debug = true;
  }

  getParms(lParms, nExpected) {
    var column, err, filePath, line, mapFile, mline, nParms;
    nParms = lParms.length;
    if (this.debug) {
      console.log(`getParms(): ${nParms} parameters`);
    }
    if (nParms === nExpected) {
      if (this.debug) {
        console.log("   find correct line number");
      }
      // --- We need to figure out the line number of the caller
      ({filePath, line, column} = getMyOutsideCaller());
      if (this.debug) {
        console.log(`   filePath = '${filePath}'`);
        console.log(`   line = ${line}, col = ${column}`);
      }
      if (!isInteger(line)) {
        console.log("getMyOutsideCaller() returned non-integer");
        console.log({filePath, line, column});
      }
      assert(fileExt(filePath) === '.js', "caller not a JS file", "fileExt(filePath) == '.js'");
      // --- Attempt to use source map to get true line number
      mapFile = `${filePath}.map`;
      try {
        assert(isFile(mapFile), `Missing map file for ${filePath}`, "isFile(mapFile)");
        mline = mapLineNum(filePath, line, column, {
          debug: this.debug
        });
        if (this.debug) {
          console.log(`   mapped to ${mline}`);
        }
        assert(isInteger(mline), `not an integer: ${mline}`, "isInteger(mline)");
        return [this.dedupLine(mline), ...lParms];
      } catch (error) {
        err = error;
        return [this.dedupLine(line), ...lParms];
      }
    } else if ((nParms = nExpected + 1)) {
      line = lParms[0];
      assert(isInteger(line), `not an integer ${line}`, "isInteger(line)");
      lParms[0] = this.dedupLine(lParms[0]);
      return lParms;
    } else {
      return croak("Bad parameters to utest function");
    }
  }

  // ..........................................................
  dedupLine(line) {
    assert(isInteger(line), `${line} is not an integer`);
    // --- patch line to avoid duplicates
    while (this.hFound[line]) {
      line += 10000;
    }
    this.hFound[line] = true;
    return line;
  }

  // ........................................................................
  transformValue(val) {
    return val;
  }

  // ........................................................................
  transformExpected(expected) {
    return expected;
  }

  // ..........................................................
  // ..........................................................
  equal(...lParms) {
    var expected, lineNum, val;
    [lineNum, val, expected] = this.getParms(lParms, 2);
    return test(`line ${lineNum}`, (t) => {
      return t.deepEqual(this.transformValue(val), this.transformExpected(expected));
    });
  }

  // ..........................................................
  notequal(...lParms) {
    var expected, lineNum, val;
    [lineNum, val, expected] = this.getParms(lParms, 2);
    return test(`line ${lineNum}`, (t) => {
      return t.notDeepEqual(this.transformValue(val), this.transformExpected(expected));
    });
  }

  // ..........................................................
  truthy(...lParms) {
    var bool, lineNum;
    [lineNum, bool] = this.getParms(lParms, 1);
    return test(`line ${lineNum}`, (t) => {
      return t.truthy(this.transformValue(bool));
    });
  }

  // ..........................................................
  falsy(...lParms) {
    var bool, lineNum;
    [lineNum, bool] = this.getParms(lParms, 1);
    return test(`line ${lineNum}`, (t) => {
      return t.falsy(this.transformValue(bool));
    });
  }

  // ..........................................................
  like(...lParms) {
    var expected, lineNum, val;
    [lineNum, val, expected] = this.getParms(lParms, 2);
    return test(`line ${lineNum}`, (t) => {
      return t.like(this.transformValue(val), this.transformExpected(expected));
    });
  }

  // ..........................................................
  throws(...lParams) {
    var err, func, lineNum, log, ok;
    [lineNum, func] = this.getParms(lParams, 1);
    if (typeof func !== 'function') {
      throw new Error("function expected");
    }
    try {
      exReset(); // suppress logging of errors
      func();
      ok = true;
    } catch (error) {
      err = error;
      ok = false;
    }
    log = exGetLog(); // we really don't care about log
    return test(`line ${lineNum}`, (t) => {
      return t.falsy(ok);
    });
  }

  // ..........................................................
  succeeds(...lParams) {
    var err, func, lineNum, ok;
    [lineNum, func] = this.getParms(lParams, 1);
    if (typeof func !== 'function') {
      throw new Error("function expected");
    }
    try {
      func();
      ok = true;
    } catch (error) {
      err = error;
      console.error(err);
      ok = false;
    }
    return test(`line ${lineNum}`, (t) => {
      return t.truthy(ok);
    });
  }

};

export var utest = new UnitTester();

export var u = new UnitTester();

u_private = new UnitTester();

export var equal = (arg1, arg2) => {
  return u_private.equal(arg1, arg2);
};

export var like = (arg1, arg2) => {
  return u_private.like(arg1, arg2);
};

export var notequal = (arg1, arg2) => {
  return u_private.notequal(arg1, arg2);
};

export var truthy = (arg) => {
  return u_private.truthy(arg);
};

export var falsy = (arg) => {
  return u_private.falsy(arg);
};

export var throws = (func) => {
  return u_private.throws(func);
};

export var succeeds = (func) => {
  return u_private.succeeds(func);
};

//# sourceMappingURL=utest.js.map
