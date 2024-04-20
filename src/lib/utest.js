// utest.coffee
import test from 'ava';

import {
  undef,
  defined,
  pass,
  OL,
  jsType,
  rtrim,
  isString,
  isInteger,
  isRegExp,
  nonEmpty,
  isClass,
  isFunction,
  toArray,
  fileExt
} from '@jdeighan/base-utils';

import {
  assert,
  croak,
  exReset,
  exGetLog
} from '@jdeighan/base-utils/exceptions';

import {
  isFile,
  parsePath
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
//        fails 1 (a function)
//        succeeds 1 (a function)
// ---------------------------------------------------------------------------
export var UnitTester = class UnitTester {
  constructor() {
    
    // ........................................................................
    this.doDebug = this.doDebug.bind(this);
    // ........................................................................
    // --- returns, e.g. "line 42"
    this.getTestName = this.getTestName.bind(this);
    this.debug = false;
    this.hFound = {}; // used line numbers
  }

  doDebug() {
    this.debug = true;
  }

  getTestName() {
    var column, filePath, line;
    // --- We need to figure out the line number of the caller
    ({filePath, line, column} = getMyOutsideCaller());
    if (this.debug) {
      console.log("getTestName()");
      console.log(`   filePath = '${filePath}'`);
      console.log(`   line = ${line}, col = ${column}`);
    }
    assert(isInteger(line), `getMyOutsideCaller() line = ${OL(line)}`);
    assert((fileExt(filePath) === '.js') || (fileExt(filePath) === '.coffee'), `caller not a JS or Coffee file: ${OL(filePath)}`);
    // 		# --- Attempt to use source map to get true line number
    // 		mapFile = "#{filePath}.map"
    // 		if isFile(mapFile)
    // 			try
    // 				mline = mapLineNum filePath, line, column, {debug: @debug}
    // 				if @debug
    // 					console.log "   mapped to #{mline}"
    // 				assert isInteger(mline), "not an integer: #{mline}"
    // 				line = mline
    // 			catch err
    // 				pass()
    while (this.hFound[line]) {
      line += 1000;
    }
    this.hFound[line] = true;
    return `line ${line}`;
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
    val = this.transformValue(val);
    expected = this.transformExpected(expected);
    test(this.getTestName(), (t) => {
      return t.deepEqual(val, expected);
    });
  }

  // ..........................................................
  like(val, expected) {
    val = this.transformValue(val);
    expected = this.transformExpected(expected);
    if (isString(val) && isString(expected)) {
      val = rtrim(val).replaceAll("\r", "");
      expected = rtrim(expected).replaceAll("\r", "");
      test(this.getTestName(), (t) => {
        return t.deepEqual(val, expected);
      });
    } else {
      test(this.getTestName(), (t) => {
        return t.like(val, expected);
      });
    }
  }

  // ..........................................................
  samelines(val, expected) {
    var lExpLines, lValLines;
    val = this.transformValue(val);
    expected = this.transformExpected(expected);
    assert(isString(val), `not a string: ${OL(val)}`);
    assert(isString(expected), `not a string: ${OL(expected)}`);
    lValLines = toArray(val).filter((line) => {
      return nonEmpty(line);
    }).sort();
    lExpLines = toArray(expected).filter((line) => {
      return nonEmpty(line);
    }).sort();
    test(this.getTestName(), (t) => {
      return t.deepEqual(lValLines, lExpLines);
    });
  }

  // ..........................................................
  notequal(val, expected) {
    val = this.transformValue(val);
    expected = this.transformExpected(expected);
    test(this.getTestName(), (t) => {
      return t.notDeepEqual(val, expected);
    });
  }

  // ..........................................................
  truthy(bool) {
    test(this.getTestName(), (t) => {
      return t.truthy(bool);
    });
  }

  // ..........................................................
  falsy(bool) {
    test(this.getTestName(), (t) => {
      return t.falsy(bool);
    });
  }

  // ..........................................................
  includes(val, expected) {
    val = this.transformValue(val);
    expected = this.transformExpected(expected);
    switch (jsType(val)[0]) {
      case 'string':
        test(this.getTestName(), (t) => {
          return t.truthy(val.includes(expected));
        });
        break;
      case 'array':
        test(this.getTestName(), (t) => {
          return t.truthy(val.includes(expected));
        });
        break;
      default:
        croak(`Bad arg to includes: ${OL(val)}`);
    }
  }

  // ..........................................................
  matches(val, regexp) {
    assert(isString(val), `Not a string: ${OL(val)}`);
    // --- convert strings to regular expressions
    if (isString(regexp)) {
      regexp = new RegExp(regexp);
    }
    assert(isRegExp(regexp), `Not a string or regexp: ${OL(regexp)}`);
    test(this.getTestName(), (t) => {
      return t.truthy(defined(val.match(regexp)));
    });
  }

  // ..........................................................
  fails(func) {
    var err, failed, log;
    assert(typeof func === 'function', "function expected");
    try {
      exReset(); // suppress logging of errors
      func();
      failed = false;
    } catch (error) {
      err = error;
      failed = true;
    }
    log = exGetLog(); // we really don't care about log
    test(this.getTestName(), (t) => {
      return t.truthy(failed);
    });
  }

  // ..........................................................
  throws(func, errClass) {
    var err, errObj, failed, log;
    assert(typeof func === 'function', `Not a function: ${OL(func)}`);
    assert(isClass(errClass) || isFunction(errClass), `Not a class or function: ${OL(errClass)}`);
    errObj = undef;
    try {
      exReset(); // suppress logging of errors
      func();
      failed = false;
    } catch (error) {
      err = error;
      errObj = err;
      failed = true;
    }
    log = exGetLog(); // we really don't care about log
    test(this.getTestName(), (t) => {
      return t.truthy(failed && errObj instanceof errClass);
    });
  }

  // ..........................................................
  succeeds(func) {
    var err, ok;
    assert(typeof func === 'function', "function expected");
    try {
      func();
      ok = true;
    } catch (error) {
      err = error;
      console.error(err);
      ok = false;
    }
    test(this.getTestName(), (t) => {
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

export var samelines = (arg1, arg2) => {
  return u.samelines(arg1, arg2);
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

export var succeeds = (func) => {
  return u.succeeds(func);
};

export var fails = (func) => {
  return u.fails(func);
};

export var throws = (func, errClass) => {
  return u.throws(func, errClass);
};
