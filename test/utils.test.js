// Generated by CoffeeScript 2.7.0
// utils.test.coffee
var hEsc;

import test from 'ava';

import {
  undef,
  pass,
  defined,
  notdefined,
  untabify,
  toTAML,
  escapeStr,
  unescapeStr,
  OL,
  isString,
  isNumber,
  isInteger,
  isHash,
  isArray,
  isBoolean,
  isConstructor,
  isFunction,
  isRegExp,
  isObject,
  jsType,
  isEmpty,
  nonEmpty,
  blockToArray,
  arrayToBlock,
  chomp,
  rtrim,
  setCharsAt,
  words,
  hasChar,
  quoted
} from '@jdeighan/exceptions/utils';

// ---------------------------------------------------------------------------
test("line 18", (t) => {
  return t.is(undef, void 0);
});

test("line 20", (t) => {
  return t.truthy(isFunction(pass));
});

(function() {
  var passTest;
  passTest = () => {
    return pass();
  };
  return test("line 25", (t) => {
    return t.notThrows(passTest, "pass fails");
  });
})();

test("line 28", (t) => {
  return t.truthy(defined(''));
});

test("line 29", (t) => {
  return t.truthy(defined(5));
});

test("line 30", (t) => {
  return t.truthy(defined([]));
});

test("line 31", (t) => {
  return t.truthy(defined({}));
});

test("line 32", (t) => {
  return t.falsy(defined(undef));
});

test("line 33", (t) => {
  return t.falsy(defined(null));
});

test("line 35", (t) => {
  return t.truthy(notdefined(undef));
});

test("line 36", (t) => {
  return t.truthy(notdefined(null));
});

test("line 37", (t) => {
  return t.falsy(notdefined(''));
});

test("line 38", (t) => {
  return t.falsy(notdefined(5));
});

test("line 39", (t) => {
  return t.falsy(notdefined([]));
});

test("line 40", (t) => {
  return t.falsy(notdefined({}));
});

(function() {
  var prefix;
  prefix = '   '; // 3 spaces
  return test("line 45", (t) => {
    return t.is(untabify(`first line
\tsecond line
\t\tthird line`, 3), `first line
${prefix}second line
${prefix}${prefix}third line`);
  });
})();

// ---------------------------------------------------------------------------
test("line 58", (t) => {
  return t.is(toTAML(undef), "---\nundef");
});

test("line 59", (t) => {
  return t.is(toTAML(null), "---\nnull");
});

test("line 60", (t) => {
  return t.is(toTAML({
    a: 1
  }), "---\na: 1");
});

test("line 61", (t) => {
  return t.is(toTAML({
    a: 1,
    b: 2
  }), "---\na: 1\nb: 2");
});

test("line 62", (t) => {
  return t.is(toTAML([
    1,
    'abc',
    {
      a: 1
    }
  ]), "---\n- 1\n- abc\n-\n   a: 1");
});

test("line 64", (t) => {
  return t.is(toTAML({
    a: 1,
    b: 2
  }), `---
a: 1
b: 2`);
});

test("line 70", (t) => {
  return t.is(toTAML(['a', 'b']), `---
- a
- b`);
});

test("line 76", (t) => {
  return t.is(toTAML([
    'a',
    'b',
    {
      a: 1
    },
    ['x']
  ]), untabify(`---
- a
- b
-
	a: 1
-
	- x`));
});

// ---------------------------------------------------------------------------
test("line 88", (t) => {
  return t.is(escapeStr("\t\tXXX\n"), "→→XXX®");
});

hEsc = {
  "\n": "\\n",
  "\t": "\\t",
  "\"": "\\\""
};

test("line 96", (t) => {
  return t.is(escapeStr("\thas quote: \"\nnext line", hEsc), "\\thas quote: \\\"\\nnext line");
});

test("line 99", (t) => {
  return t.is(unescapeStr("˳˳˳"), "   ");
});

test("line 100", (t) => {
  return t.is(unescapeStr("®®®"), "\n\n\n");
});

test("line 101", (t) => {
  return t.is(unescapeStr("→→→"), "\t\t\t");
});

// ---------------------------------------------------------------------------
test("line 105", (t) => {
  return t.is(OL(undef), "undef");
});

test("line 106", (t) => {
  return t.is(OL("\t\tabc\nxyz"), "'→→abc®xyz'");
});

test("line 107", (t) => {
  return t.is(OL({
    a: 1,
    b: 'xyz'
  }), '{"a":1,"b":"xyz"}');
});

// ---------------------------------------------------------------------------
//        jsTypes:
(function() {
  var NewClass, func1, func2, h, l, n, n2, o, s, s2;
  NewClass = class NewClass {
    constructor(name = 'bob') {
      this.name = name;
      this.doIt = pass;
    }

  };
  h = {
    a: 1,
    b: 2
  };
  l = [1, 2, 2];
  o = new NewClass();
  n = 42;
  n2 = new Number(42);
  s = 'simple';
  s2 = new String('abc');
  test("line 125", (t) => {
    return t.falsy(isString(undef));
  });
  test("line 126", (t) => {
    return t.falsy(isString(h));
  });
  test("line 127", (t) => {
    return t.falsy(isString(l));
  });
  test("line 128", (t) => {
    return t.falsy(isString(o));
  });
  test("line 129", (t) => {
    return t.falsy(isString(n));
  });
  test("line 130", (t) => {
    return t.falsy(isString(n2));
  });
  test("line 132", (t) => {
    return t.truthy(isString(s));
  });
  test("line 133", (t) => {
    return t.truthy(isString(s2));
  });
  test("line 135", (t) => {
    return t.falsy(isNumber(h));
  });
  test("line 136", (t) => {
    return t.falsy(isNumber(l));
  });
  test("line 137", (t) => {
    return t.falsy(isNumber(o));
  });
  test("line 138", (t) => {
    return t.truthy(isNumber(n));
  });
  test("line 139", (t) => {
    return t.truthy(isNumber(n2));
  });
  test("line 140", (t) => {
    return t.falsy(isNumber(s));
  });
  test("line 141", (t) => {
    return t.falsy(isNumber(s2));
  });
  test("line 143", (t) => {
    return t.truthy(isNumber(42.0, {
      min: 42.0
    }));
  });
  test("line 144", (t) => {
    return t.falsy(isNumber(42.0, {
      min: 42.1
    }));
  });
  test("line 145", (t) => {
    return t.truthy(isNumber(42.0, {
      max: 42.0
    }));
  });
  test("line 146", (t) => {
    return t.falsy(isNumber(42.0, {
      max: 41.9
    }));
  });
  test("line 148", (t) => {
    return t.truthy(isInteger(42));
  });
  test("line 149", (t) => {
    return t.truthy(isInteger(new Number(42)));
  });
  test("line 150", (t) => {
    return t.falsy(isInteger('abc'));
  });
  test("line 151", (t) => {
    return t.falsy(isInteger({}));
  });
  test("line 152", (t) => {
    return t.falsy(isInteger([]));
  });
  test("line 153", (t) => {
    return t.truthy(isInteger(42, {
      min: 0
    }));
  });
  test("line 154", (t) => {
    return t.falsy(isInteger(42, {
      min: 50
    }));
  });
  test("line 155", (t) => {
    return t.truthy(isInteger(42, {
      max: 50
    }));
  });
  test("line 156", (t) => {
    return t.falsy(isInteger(42, {
      max: 0
    }));
  });
  test("line 158", (t) => {
    return t.truthy(isHash(h));
  });
  test("line 159", (t) => {
    return t.falsy(isHash(l));
  });
  test("line 160", (t) => {
    return t.falsy(isHash(o));
  });
  test("line 161", (t) => {
    return t.falsy(isHash(n));
  });
  test("line 162", (t) => {
    return t.falsy(isHash(n2));
  });
  test("line 163", (t) => {
    return t.falsy(isHash(s));
  });
  test("line 164", (t) => {
    return t.falsy(isHash(s2));
  });
  test("line 166", (t) => {
    return t.falsy(isArray(h));
  });
  test("line 167", (t) => {
    return t.truthy(isArray(l));
  });
  test("line 168", (t) => {
    return t.falsy(isArray(o));
  });
  test("line 169", (t) => {
    return t.falsy(isArray(n));
  });
  test("line 170", (t) => {
    return t.falsy(isArray(n2));
  });
  test("line 171", (t) => {
    return t.falsy(isArray(s));
  });
  test("line 172", (t) => {
    return t.falsy(isArray(s2));
  });
  test("line 174", (t) => {
    return t.truthy(isBoolean(true));
  });
  test("line 175", (t) => {
    return t.truthy(isBoolean(false));
  });
  test("line 176", (t) => {
    return t.falsy(isBoolean(42));
  });
  test("line 177", (t) => {
    return t.falsy(isBoolean("true"));
  });
  test("line 179", (t) => {
    return t.truthy(isConstructor(NewClass));
  });
  test("line 180", (t) => {
    return t.falsy(isConstructor(o));
  });
  test("line 182", (t) => {
    return t.truthy(isFunction(function() {
      return 42;
    }));
  });
  test("line 183", (t) => {
    return t.truthy(isFunction(() => {
      return 42;
    }));
  });
  test("line 184", (t) => {
    return t.falsy(isFunction(42));
  });
  test("line 185", (t) => {
    return t.falsy(isFunction(n));
  });
  test("line 187", (t) => {
    return t.truthy(isRegExp(/^abc$/));
  });
  test("line 188", (t) => {
    return t.truthy(isRegExp(/^\s*where\s+areyou$/));
  });
  test("line 189", (t) => {
    return t.falsy(isRegExp(42));
  });
  test("line 190", (t) => {
    return t.falsy(isRegExp('abc'));
  });
  test("line 191", (t) => {
    return t.falsy(isRegExp([1, 'a']));
  });
  test("line 192", (t) => {
    return t.falsy(isRegExp({
      a: 1,
      b: 'ccc'
    }));
  });
  test("line 193", (t) => {
    return t.falsy(isRegExp(undef));
  });
  test("line 194", (t) => {
    return t.truthy(isRegExp(/\.coffee/));
  });
  test("line 196", (t) => {
    return t.falsy(isObject(h));
  });
  test("line 197", (t) => {
    return t.falsy(isObject(l));
  });
  test("line 198", (t) => {
    return t.truthy(isObject(o));
  });
  test("line 199", (t) => {
    return t.truthy(isObject(o, ['name', 'doIt']));
  });
  test("line 200", (t) => {
    return t.falsy(isObject(o, ['name', 'doIt', 'missing']));
  });
  test("line 201", (t) => {
    return t.falsy(isObject(n));
  });
  test("line 202", (t) => {
    return t.falsy(isObject(n2));
  });
  test("line 203", (t) => {
    return t.falsy(isObject(s));
  });
  test("line 204", (t) => {
    return t.falsy(isObject(s2));
  });
  test("line 206", (t) => {
    return t.deepEqual(jsType(undef), [undef, 'undef']);
  });
  test("line 207", (t) => {
    return t.deepEqual(jsType(null), [undef, 'null']);
  });
  test("line 208", (t) => {
    return t.deepEqual(jsType(s), ['string', undef]);
  });
  test("line 209", (t) => {
    return t.deepEqual(jsType(''), ['string', 'empty']);
  });
  test("line 210", (t) => {
    return t.deepEqual(jsType("\t\t"), ['string', 'empty']);
  });
  test("line 211", (t) => {
    return t.deepEqual(jsType("  "), ['string', 'empty']);
  });
  test("line 212", (t) => {
    return t.deepEqual(jsType(h), ['hash', undef]);
  });
  test("line 213", (t) => {
    return t.deepEqual(jsType({}), ['hash', 'empty']);
  });
  test("line 214", (t) => {
    return t.deepEqual(jsType(3.14159), ['number', undef]);
  });
  test("line 215", (t) => {
    return t.deepEqual(jsType(42), ['number', 'integer']);
  });
  test("line 216", (t) => {
    return t.deepEqual(jsType(true), ['boolean', 'true']);
  });
  test("line 217", (t) => {
    return t.deepEqual(jsType(false), ['boolean', 'false']);
  });
  test("line 218", (t) => {
    return t.deepEqual(jsType(h), ['hash', undef]);
  });
  test("line 219", (t) => {
    return t.deepEqual(jsType({}), ['hash', 'empty']);
  });
  test("line 220", (t) => {
    return t.deepEqual(jsType(l), ['array', undef]);
  });
  test("line 221", (t) => {
    return t.deepEqual(jsType([]), ['array', 'empty']);
  });
  test("line 222", (t) => {
    return t.deepEqual(jsType(/abc/), ['regexp', undef]);
  });
  func1 = function(x) {};
  func2 = (x) => {};
  // --- NOTE: regular functions can't be distinguished from constructors
  test("line 229", (t) => {
    return t.deepEqual(jsType(func1), ['function', 'constructor']);
  });
  test("line 231", (t) => {
    return t.deepEqual(jsType(func2), ['function', undef]);
  });
  test("line 232", (t) => {
    return t.deepEqual(jsType(NewClass), ['function', 'constructor']);
  });
  return test("line 233", (t) => {
    return t.deepEqual(jsType(o), ['object', undef]);
  });
})();

// ---------------------------------------------------------------------------
test("line 238", (t) => {
  return t.truthy(isEmpty(''));
});

test("line 239", (t) => {
  return t.truthy(isEmpty('  \t\t'));
});

test("line 240", (t) => {
  return t.truthy(isEmpty([]));
});

test("line 241", (t) => {
  return t.truthy(isEmpty({}));
});

test("line 243", (t) => {
  return t.truthy(nonEmpty('a'));
});

test("line 244", (t) => {
  return t.truthy(nonEmpty('.'));
});

test("line 245", (t) => {
  return t.truthy(nonEmpty([2]));
});

test("line 246", (t) => {
  return t.truthy(nonEmpty({
    width: 2
  }));
});

// ---------------------------------------------------------------------------
test("line 250", (t) => {
  return t.deepEqual(blockToArray("abc\nxyz\n"), ['abc', 'xyz']);
});

test("line 255", (t) => {
  return t.deepEqual(blockToArray("abc\nxyz\n\n\n\n"), ['abc', 'xyz']);
});

test("line 260", (t) => {
  return t.deepEqual(blockToArray("abc\n\nxyz\n"), ['abc', '', 'xyz']);
});

// ---------------------------------------------------------------------------
test("line 268", (t) => {
  return t.deepEqual(arrayToBlock(['a', 'b', 'c']), "a\nb\nc");
});

test("line 269", (t) => {
  return t.deepEqual(arrayToBlock(['a', undef, 'b', 'c']), "a\nb\nc");
});

test("line 270", (t) => {
  return t.deepEqual(arrayToBlock([undef, 'a', 'b', 'c', undef]), "a\nb\nc");
});

// ---------------------------------------------------------------------------
test("line 274", (t) => {
  return t.is(chomp('abc'), 'abc');
});

test("line 275", (t) => {
  return t.is(chomp('abc\n'), 'abc');
});

test("line 276", (t) => {
  return t.is(chomp('abc\r\n'), 'abc');
});

test("line 278", (t) => {
  return t.is(chomp('abc\ndef'), 'abc\ndef');
});

test("line 279", (t) => {
  return t.is(chomp('abc\ndef\n'), 'abc\ndef');
});

test("line 280", (t) => {
  return t.is(chomp('abc\ndef\r\n'), 'abc\ndef');
});

test("line 282", (t) => {
  return t.is(chomp('abc\r\ndef'), 'abc\r\ndef');
});

test("line 283", (t) => {
  return t.is(chomp('abc\r\ndef\n'), 'abc\r\ndef');
});

test("line 284", (t) => {
  return t.is(chomp('abc\r\ndef\r\n'), 'abc\r\ndef');
});

// ---------------------------------------------------------------------------
test("line 288", (t) => {
  return t.is(rtrim("abc"), "abc");
});

test("line 289", (t) => {
  return t.is(rtrim("  abc"), "  abc");
});

test("line 290", (t) => {
  return t.is(rtrim("abc  "), "abc");
});

test("line 291", (t) => {
  return t.is(rtrim("  abc  "), "  abc");
});

// ---------------------------------------------------------------------------
test("line 295", (t) => {
  return t.is(setCharsAt('abc', 1, 'x'), 'axc');
});

test("line 296", (t) => {
  return t.is(setCharsAt('abc', 1, 'xy'), 'axy');
});

test("line 297", (t) => {
  return t.is(setCharsAt('abc', 1, 'xyz'), 'axyz');
});

// ---------------------------------------------------------------------------
test("line 301", (t) => {
  return t.deepEqual(words('a b c'), ['a', 'b', 'c']);
});

test("line 302", (t) => {
  return t.deepEqual(words('  a   b   c  '), ['a', 'b', 'c']);
});

test("line 304", (t) => {
  return t.truthy(hasChar('abc', 'b'));
});

test("line 305", (t) => {
  return t.falsy(hasChar('abc', 'x'));
});

// ---------------------------------------------------------------------------
test("line 309", (t) => {
  return t.is(quoted('abc'), "'abc'");
});

test("line 310", (t) => {
  return t.is(quoted('"abc"'), "'\"abc\"'");
});

test("line 311", (t) => {
  return t.is(quoted("'abc'"), "\"'abc'\"");
});

test("line 312", (t) => {
  return t.is(quoted("'\"abc\"'"), "<'\"abc\"'>");
});

test("line 313", (t) => {
  return t.is(quoted("'\"<abc>\"'"), "<'\"<abc>\"'>");
});