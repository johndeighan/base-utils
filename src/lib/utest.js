// utest.coffee
import test from 'ava';

import {
  undef,
  defined,
  pass,
  OL,
  LOG,
  jsType,
  rtrim,
  isString,
  isInteger,
  isRegExp
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
// --- Available tests w/num required params
//        equal 2
//        truthy 1
//        falsy 1
//        includes 2
//        matches 2
//        like 2
//        throws 1 (a function)
//        succeeds 1 (a function)
// ---------------------------------------------------------------------------
export var UnitTester = class UnitTester {
  constructor() {
    
    // ........................................................................
    this.doDebug = this.doDebug.bind(this);
    // ........................................................................
    this.getLineNum = this.getLineNum.bind(this);
    this.debug = false;
    this.hFound = {}; // used line numbers
  }

  doDebug() {
    this.debug = true;
  }

  getLineNum() {
    var column, err, filePath, line, mapFile, mline;
    // --- We need to figure out the line number of the caller
    ({filePath, line, column} = getMyOutsideCaller());
    if (this.debug) {
      LOG("getLineNum()");
      LOG(`   filePath = '${filePath}'`);
      LOG(`   line = ${line}, col = ${column}`);
    }
    assert(isInteger(line), `getMyOutsideCaller() line = ${OL(line)}`);
    assert(fileExt(filePath) === '.js', `caller not a JS file: ${OL(filePath)}`);
    // --- Attempt to use source map to get true line number
    mapFile = `${filePath}.map`;
    if (isFile(mapFile)) {
      try {
        mline = mapLineNum(filePath, line, column, {
          debug: this.debug
        });
        if (this.debug) {
          LOG(`   mapped to ${mline}`);
        }
        assert(isInteger(mline), `not an integer: ${mline}`);
        line = mline;
      } catch (error) {
        err = error;
        pass();
      }
    }
    while (this.hFound[line]) {
      line += 1000;
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
  equal(val, expected) {
    var lineNum;
    lineNum = this.getLineNum();
    val = this.transformValue(val);
    expected = this.transformExpected(expected);
    test(`line ${lineNum}`, (t) => {
      return t.deepEqual(val, expected);
    });
  }

  // ..........................................................
  like(val, expected) {
    var lineNum;
    lineNum = this.getLineNum();
    val = this.transformValue(val);
    expected = this.transformExpected(expected);
    if (isString(val) && isString(expected)) {
      val = rtrim(val).replaceAll("\r", "");
      expected = rtrim(expected).replaceAll("\r", "");
      test(`line ${lineNum}`, (t) => {
        return t.deepEqual(val, expected);
      });
    } else {
      test(`line ${lineNum}`, (t) => {
        return t.like(val, expected);
      });
    }
  }

  // ..........................................................
  notequal(val, expected) {
    var lineNum;
    lineNum = this.getLineNum();
    val = this.transformValue(val);
    expected = this.transformExpected(expected);
    test(`line ${lineNum}`, (t) => {
      return t.notDeepEqual(val, expected);
    });
  }

  // ..........................................................
  truthy(bool) {
    var lineNum;
    lineNum = this.getLineNum();
    test(`line ${lineNum}`, (t) => {
      return t.truthy(bool);
    });
  }

  // ..........................................................
  falsy(bool) {
    var lineNum;
    lineNum = this.getLineNum();
    test(`line ${lineNum}`, (t) => {
      return t.falsy(bool);
    });
  }

  // ..........................................................
  includes(val, expected) {
    var lineNum;
    lineNum = this.getLineNum();
    val = this.transformValue(val);
    expected = this.transformExpected(expected);
    switch (jsType(val)[0]) {
      case 'string':
        test(`line ${lineNum}`, (t) => {
          return t.truthy(val.includes(expected));
        });
        break;
      case 'array':
        test(`line ${lineNum}`, (t) => {
          return t.truthy(val.includes(expected));
        });
        break;
      default:
        croak(`Bad arg to includes: ${OL(val)}`);
    }
  }

  // ..........................................................
  matches(val, regexp) {
    var lineNum;
    assert(isString(val), `Not a string: ${OL(val)}`);
    assert(isRegExp(regexp), `Not a regular expression: ${OL(regexp)}`);
    lineNum = this.getLineNum();
    test(`line ${lineNum}`, (t) => {
      return t.truthy(defined(val.match(regexp)));
    });
  }

  // ..........................................................
  throws(func) {
    var err, lineNum, log, ok;
    lineNum = this.getLineNum();
    assert(typeof func === 'function', "function expected");
    try {
      exReset(); // suppress logging of errors
      func();
      ok = true;
    } catch (error) {
      err = error;
      ok = false;
    }
    log = exGetLog(); // we really don't care about log
    test(`line ${lineNum}`, (t) => {
      return t.falsy(ok);
    });
  }

  // ..........................................................
  succeeds(func) {
    var err, lineNum, ok;
    lineNum = this.getLineNum();
    assert(typeof func === 'function', "function expected");
    try {
      func();
      ok = true;
    } catch (error) {
      err = error;
      console.error(err);
      ok = false;
    }
    test(`line ${lineNum}`, (t) => {
      return t.truthy(ok);
    });
  }

};

// ---------------------------------------------------------------------------
export var u = new UnitTester();

export var transformValue = (func) => {
  return u.transformValue = func;
};

export var transformExpected = (func) => {
  return u.transformExpected = func;
};

export var equal = (arg1, arg2) => {
  return u.equal(arg1, arg2);
};

export var like = (arg1, arg2) => {
  return u.like(arg1, arg2);
};

export var notequal = (arg1, arg2) => {
  return u.notequal(arg1, arg2);
};

export var truthy = (arg) => {
  return u.truthy(arg);
};

export var falsy = (arg) => {
  return u.falsy(arg);
};

export var includes = (arg1, arg2) => {
  return u.includes(arg1, arg2);
};

export var matches = (str, regexp) => {
  return u.matches(str, regexp);
};

export var throws = (func) => {
  return u.throws(func);
};

export var succeeds = (func) => {
  return u.succeeds(func);
};

//# sourceMappingURL=utest.js.map
