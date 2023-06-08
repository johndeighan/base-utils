// base-utils.test.coffee
var gen, hEsc, hProc;

import test from 'ava';

import {
  utest
} from '@jdeighan/base-utils/utest';

import {
  assert,
  croak
} from '@jdeighan/base-utils/exceptions';

import {
  undef,
  pass,
  defined,
  notdefined,
  tabify,
  untabify,
  prefixBlock,
  escapeStr,
  OL,
  OLS,
  inList,
  isHashComment,
  splitPrefix,
  hasPrefix,
  isString,
  isNumber,
  isInteger,
  isHash,
  isArray,
  isBoolean,
  isClass,
  isConstructor,
  removeKeys,
  extractMatches,
  isFunction,
  isRegExp,
  isObject,
  jsType,
  deepEqual,
  isEmpty,
  nonEmpty,
  isNonEmptyString,
  isIdentifier,
  isFunctionName,
  isIterable,
  hashFromString,
  blockToArray,
  arrayToBlock,
  toArray,
  toBlock,
  rtrim,
  words,
  hasChar,
  quoted,
  getOptions,
  range,
  oneof,
  uniq,
  rtrunc,
  ltrunc,
  CWS,
  className,
  isArrayOfStrings,
  isArrayOfHashes,
  isArrayOfArrays,
  forEachLine,
  mapEachLine,
  getProxy,
  sleep,
  schedule
} from '@jdeighan/base-utils';

// ---------------------------------------------------------------------------
test("line 24", (t) => {
  return t.truthy(deepEqual({
    a: 1,
    b: 2
  }, {
    a: 1,
    b: 2
  }));
});

test("line 25", (t) => {
  return t.falsy(deepEqual({
    a: 1,
    b: 2
  }, {
    a: 1,
    b: 3
  }));
});

// ---------------------------------------------------------------------------
test("line 29", (t) => {
  return t.truthy(isHashComment('   # something'));
});

test("line 30", (t) => {
  return t.truthy(isHashComment('   #'));
});

test("line 31", (t) => {
  return t.falsy(isHashComment('   abc'));
});

test("line 32", (t) => {
  return t.falsy(isHashComment('#abc'));
});

test("line 34", (t) => {
  return t.is(undef, void 0);
});

test("line 36", (t) => {
  return t.truthy(isFunction(pass));
});

(function() {
  var passTest;
  passTest = () => {
    return pass();
  };
  return test("line 41", (t) => {
    return t.notThrows(passTest, "pass fails");
  });
})();

test("line 44", (t) => {
  return t.truthy(defined(''));
});

test("line 45", (t) => {
  return t.truthy(defined(5));
});

test("line 46", (t) => {
  return t.truthy(defined([]));
});

test("line 47", (t) => {
  return t.truthy(defined({}));
});

test("line 48", (t) => {
  return t.falsy(defined(undef));
});

test("line 49", (t) => {
  return t.falsy(defined(null));
});

test("line 51", (t) => {
  return t.truthy(notdefined(undef));
});

test("line 52", (t) => {
  return t.truthy(notdefined(null));
});

test("line 53", (t) => {
  return t.falsy(notdefined(''));
});

test("line 54", (t) => {
  return t.falsy(notdefined(5));
});

test("line 55", (t) => {
  return t.falsy(notdefined([]));
});

test("line 56", (t) => {
  return t.falsy(notdefined({}));
});

// ---------------------------------------------------------------------------
test("line 60", (t) => {
  return t.deepEqual(splitPrefix("abc"), ["", "abc"]);
});

test("line 61", (t) => {
  return t.deepEqual(splitPrefix("\tabc"), ["\t", "abc"]);
});

test("line 62", (t) => {
  return t.deepEqual(splitPrefix("\t\tabc"), ["\t\t", "abc"]);
});

test("line 63", (t) => {
  return t.deepEqual(splitPrefix(""), ["", ""]);
});

test("line 64", (t) => {
  return t.deepEqual(splitPrefix("\t\t\t"), ["", ""]);
});

test("line 65", (t) => {
  return t.deepEqual(splitPrefix("\t \t"), ["", ""]);
});

test("line 66", (t) => {
  return t.deepEqual(splitPrefix("   "), ["", ""]);
});

// ---------------------------------------------------------------------------
test("line 70", (t) => {
  return t.falsy(hasPrefix("abc"));
});

test("line 71", (t) => {
  return t.truthy(hasPrefix("   abc"));
});

// ---------------------------------------------------------------------------
(function() {
  var prefix;
  prefix = '   '; // 3 spaces
  return test("line 78", (t) => {
    return t.is(untabify(`first line
\tsecond line
\t\tthird line`, 3), `first line
${prefix}second line
${prefix}${prefix}third line`);
  });
})();

// ---------------------------------------------------------------------------
(function() {
  var prefix;
  prefix = '   '; // 3 spaces
  return utest.equal(94, tabify(`first line
${prefix}second line
${prefix}${prefix}third line`, 3), `first line
\tsecond line
\t\tthird line`);
})();

// ---------------------------------------------------------------------------
// you don't need to tell it number of spaces
(function() {
  var prefix;
  prefix = '   '; // 3 spaces
  return utest.equal(111, tabify(`first line
${prefix}second line
${prefix}${prefix}third line`), `first line
\tsecond line
\t\tthird line`);
})();

// ---------------------------------------------------------------------------
(function() {
  var prefix;
  prefix = '   '; // 3 spaces
  return utest.equal(127, untabify(`first line
\tsecond line
\t\tthird line`, 3), `first line
${prefix}second line
${prefix}${prefix}third line`);
})();

// ---------------------------------------------------------------------------
test("line 140", (t) => {
  return t.is(prefixBlock(`abc
def`, '--'), `--abc
--def`);
});

// ---------------------------------------------------------------------------
test("line 150", (t) => {
  return t.is(escapeStr("\t\tXXX\n"), "→→XXX®");
});

hEsc = {
  "\n": "\\n",
  "\t": "\\t",
  "\"": "\\\""
};

test("line 158", (t) => {
  return t.is(escapeStr("\thas quote: \"\nnext line", hEsc), "\\thas quote: \\\"\\nnext line");
});

// ---------------------------------------------------------------------------
test("line 163", (t) => {
  return t.is(OL(undef), "undef");
});

test("line 164", (t) => {
  return t.is(OL("\t\tabc\nxyz"), "'→→abc®xyz'");
});

test("line 165", (t) => {
  return t.is(OL({
    a: 1,
    b: 'xyz'
  }), '{"a":1,"b":"xyz"}');
});

hProc = {
  code: function(block) {
    return `${block};`;
  },
  html: function(block) {
    return block.replace('<p>', '<p> ').replace('</p>', ' </p>');
  },
  Script: function(block) {
    return elem('script', undef, block, "\t");
  }
};

test("line 173", (t) => {
  return t.is(OL(hProc), '{"code":"[Function: code]","html":"[Function: html]","Script":"[Function: Script]"}');
});

// ---------------------------------------------------------------------------
test("line 177", (t) => {
  return t.is(OLS(['abc', 3]), "'abc',3");
});

test("line 178", (t) => {
  return t.is(OLS([]), "");
});

test("line 179", (t) => {
  return t.is(OLS([
    undef,
    {
      a: 1
    }
  ]), 'undef,{"a":1}');
});

// ---------------------------------------------------------------------------
test("line 99", (t) => {
  return t.truthy(inList('a', 'b', 'a', 'c'));
});

test("line 184", (t) => {
  return t.falsy(inList('a', 'b', 'c'));
});

// ---------------------------------------------------------------------------
//        jsTypes:
(function() {
  var NewClass, func1, func2, generatorFunc, h, l, n, n2, o, s, s2;
  NewClass = class NewClass {
    constructor(name = 'bob') {
      this.name = name;
      this.doIt = pass;
    }

    meth(x) {
      return 2 * x;
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
  test("line 204", (t) => {
    return t.falsy(isString(undef));
  });
  test("line 205", (t) => {
    return t.falsy(isString(h));
  });
  test("line 206", (t) => {
    return t.falsy(isString(l));
  });
  test("line 207", (t) => {
    return t.falsy(isString(o));
  });
  test("line 208", (t) => {
    return t.falsy(isString(n));
  });
  test("line 209", (t) => {
    return t.falsy(isString(n2));
  });
  test("line 211", (t) => {
    return t.truthy(isString(s));
  });
  test("line 212", (t) => {
    return t.truthy(isString(s2));
  });
  test("line 214", (t) => {
    return t.truthy(isNonEmptyString('abc'));
  });
  test("line 215", (t) => {
    return t.truthy(isNonEmptyString('abc def'));
  });
  test("line 216", (t) => {
    return t.falsy(isNonEmptyString(''));
  });
  test("line 217", (t) => {
    return t.falsy(isNonEmptyString('  '));
  });
  test("line 219", (t) => {
    return t.truthy(isIdentifier('abc'));
  });
  test("line 220", (t) => {
    return t.truthy(isIdentifier('_Abc'));
  });
  test("line 221", (t) => {
    return t.falsy(isIdentifier('abc def'));
  });
  test("line 222", (t) => {
    return t.falsy(isIdentifier('abc-def'));
  });
  test("line 223", (t) => {
    return t.falsy(isIdentifier('class.method'));
  });
  test("line 225", (t) => {
    return t.truthy(isFunctionName('abc'));
  });
  test("line 226", (t) => {
    return t.truthy(isFunctionName('_Abc'));
  });
  test("line 227", (t) => {
    return t.falsy(isFunctionName('abc def'));
  });
  test("line 228", (t) => {
    return t.falsy(isFunctionName('abc-def'));
  });
  test("line 229", (t) => {
    return t.falsy(isFunctionName('D()'));
  });
  test("line 230", (t) => {
    return t.truthy(isFunctionName('class.method'));
  });
  generatorFunc = function*() {
    yield 1;
    yield 2;
    yield 3;
  };
  test("line 238", (t) => {
    return t.truthy(isIterable(generatorFunc()));
  });
  test("line 240", (t) => {
    return t.falsy(isNumber(undef));
  });
  test("line 241", (t) => {
    return t.falsy(isNumber(null));
  });
  test("line 242", (t) => {
    return t.falsy(isNumber(0/0));
  });
  test("line 243", (t) => {
    return t.falsy(isNumber(h));
  });
  test("line 244", (t) => {
    return t.falsy(isNumber(l));
  });
  test("line 245", (t) => {
    return t.falsy(isNumber(o));
  });
  test("line 246", (t) => {
    return t.truthy(isNumber(n));
  });
  test("line 247", (t) => {
    return t.truthy(isNumber(n2));
  });
  test("line 248", (t) => {
    return t.falsy(isNumber(s));
  });
  test("line 249", (t) => {
    return t.falsy(isNumber(s2));
  });
  test("line 251", (t) => {
    return t.truthy(isNumber(42.0, {
      min: 42.0
    }));
  });
  test("line 252", (t) => {
    return t.falsy(isNumber(42.0, {
      min: 42.1
    }));
  });
  test("line 253", (t) => {
    return t.truthy(isNumber(42.0, {
      max: 42.0
    }));
  });
  test("line 254", (t) => {
    return t.falsy(isNumber(42.0, {
      max: 41.9
    }));
  });
  test("line 256", (t) => {
    return t.truthy(isInteger(42));
  });
  test("line 257", (t) => {
    return t.truthy(isInteger(new Number(42)));
  });
  test("line 258", (t) => {
    return t.falsy(isInteger('abc'));
  });
  test("line 259", (t) => {
    return t.falsy(isInteger({}));
  });
  test("line 260", (t) => {
    return t.falsy(isInteger([]));
  });
  test("line 261", (t) => {
    return t.truthy(isInteger(42, {
      min: 0
    }));
  });
  test("line 262", (t) => {
    return t.falsy(isInteger(42, {
      min: 50
    }));
  });
  test("line 263", (t) => {
    return t.truthy(isInteger(42, {
      max: 50
    }));
  });
  test("line 264", (t) => {
    return t.falsy(isInteger(42, {
      max: 0
    }));
  });
  test("line 266", (t) => {
    return t.truthy(isHash(h));
  });
  test("line 267", (t) => {
    return t.falsy(isHash(l));
  });
  test("line 268", (t) => {
    return t.falsy(isHash(o));
  });
  test("line 269", (t) => {
    return t.falsy(isHash(n));
  });
  test("line 270", (t) => {
    return t.falsy(isHash(n2));
  });
  test("line 271", (t) => {
    return t.falsy(isHash(s));
  });
  test("line 272", (t) => {
    return t.falsy(isHash(s2));
  });
  test("line 274", (t) => {
    return t.falsy(isArray(h));
  });
  test("line 275", (t) => {
    return t.truthy(isArray(l));
  });
  test("line 276", (t) => {
    return t.falsy(isArray(o));
  });
  test("line 277", (t) => {
    return t.falsy(isArray(n));
  });
  test("line 278", (t) => {
    return t.falsy(isArray(n2));
  });
  test("line 279", (t) => {
    return t.falsy(isArray(s));
  });
  test("line 280", (t) => {
    return t.falsy(isArray(s2));
  });
  test("line 282", (t) => {
    return t.truthy(isBoolean(true));
  });
  test("line 283", (t) => {
    return t.truthy(isBoolean(false));
  });
  test("line 284", (t) => {
    return t.falsy(isBoolean(42));
  });
  test("line 285", (t) => {
    return t.falsy(isBoolean("true"));
  });
  test("line 287", (t) => {
    return t.truthy(isClass(NewClass));
  });
  test("line 288", (t) => {
    return t.falsy(isClass(o));
  });
  test("line 290", (t) => {
    return t.truthy(isConstructor(NewClass));
  });
  test("line 291", (t) => {
    return t.falsy(isConstructor(o));
  });
  test("line 293", (t) => {
    return t.truthy(isFunction(function() {
      return 42;
    }));
  });
  test("line 294", (t) => {
    return t.truthy(isFunction(() => {
      return 42;
    }));
  });
  test("line 295", (t) => {
    return t.falsy(isFunction(42));
  });
  test("line 296", (t) => {
    return t.falsy(isFunction(n));
  });
  test("line 298", (t) => {
    return t.truthy(isRegExp(/^abc$/));
  });
  test("line 299", (t) => {
    return t.truthy(isRegExp(/^\s*where\s+areyou$/));
  });
  test("line 300", (t) => {
    return t.falsy(isRegExp(42));
  });
  test("line 301", (t) => {
    return t.falsy(isRegExp('abc'));
  });
  test("line 302", (t) => {
    return t.falsy(isRegExp([1, 'a']));
  });
  test("line 303", (t) => {
    return t.falsy(isRegExp({
      a: 1,
      b: 'ccc'
    }));
  });
  test("line 304", (t) => {
    return t.falsy(isRegExp(undef));
  });
  test("line 305", (t) => {
    return t.truthy(isRegExp(/\.coffee/));
  });
  test("line 307", (t) => {
    return t.falsy(isObject(h));
  });
  test("line 308", (t) => {
    return t.falsy(isObject(l));
  });
  test("line 309", (t) => {
    return t.truthy(isObject(o));
  });
  test("line 310", (t) => {
    return t.truthy(isObject(o, ['name', 'doIt']));
  });
  test("line 311", (t) => {
    return t.truthy(isObject(o, "name doIt"));
  });
  test("line 312", (t) => {
    return t.falsy(isObject(o, ['name', 'doIt', 'missing']));
  });
  test("line 313", (t) => {
    return t.falsy(isObject(o, "name doIt missing"));
  });
  test("line 314", (t) => {
    return t.falsy(isObject(n));
  });
  test("line 315", (t) => {
    return t.falsy(isObject(n2));
  });
  test("line 316", (t) => {
    return t.falsy(isObject(s));
  });
  test("line 317", (t) => {
    return t.falsy(isObject(s2));
  });
  test("line 318", (t) => {
    return t.truthy(isObject(o, "name doIt"));
  });
  test("line 319", (t) => {
    return t.truthy(isObject(o, "name doIt meth"));
  });
  test("line 320", (t) => {
    return t.truthy(isObject(o, "name &doIt &meth"));
  });
  test("line 321", (t) => {
    return t.falsy(isObject(o, "&name"));
  });
  test("line 323", (t) => {
    return t.deepEqual(jsType(undef), [undef, 'undef']);
  });
  test("line 324", (t) => {
    return t.deepEqual(jsType(null), [undef, 'null']);
  });
  test("line 325", (t) => {
    return t.deepEqual(jsType(s), ['string', undef]);
  });
  test("line 326", (t) => {
    return t.deepEqual(jsType(''), ['string', 'empty']);
  });
  test("line 327", (t) => {
    return t.deepEqual(jsType("\t\t"), ['string', 'empty']);
  });
  test("line 328", (t) => {
    return t.deepEqual(jsType("  "), ['string', 'empty']);
  });
  test("line 329", (t) => {
    return t.deepEqual(jsType(h), ['hash', undef]);
  });
  test("line 330", (t) => {
    return t.deepEqual(jsType({}), ['hash', 'empty']);
  });
  test("line 331", (t) => {
    return t.deepEqual(jsType(3.14159), ['number', undef]);
  });
  test("line 332", (t) => {
    return t.deepEqual(jsType(42), ['number', 'integer']);
  });
  test("line 333", (t) => {
    return t.deepEqual(jsType(true), ['boolean', undef]);
  });
  test("line 334", (t) => {
    return t.deepEqual(jsType(false), ['boolean', undef]);
  });
  test("line 335", (t) => {
    return t.deepEqual(jsType(h), ['hash', undef]);
  });
  test("line 336", (t) => {
    return t.deepEqual(jsType({}), ['hash', 'empty']);
  });
  test("line 337", (t) => {
    return t.deepEqual(jsType(l), ['array', undef]);
  });
  test("line 338", (t) => {
    return t.deepEqual(jsType([]), ['array', 'empty']);
  });
  test("line 339", (t) => {
    return t.deepEqual(jsType(/abc/), ['regexp', undef]);
  });
  func1 = function(x) {};
  func2 = (x) => {};
  // --- NOTE: regular functions can't be distinguished from constructors
  test("line 348", (t) => {
    return t.deepEqual(jsType(func1), ['class', undef]);
  });
  test("line 350", (t) => {
    return t.deepEqual(jsType(func2), ['function', undef]);
  });
  test("line 351", (t) => {
    return t.deepEqual(jsType(NewClass), ['class', undef]);
  });
  return test("line 352", (t) => {
    return t.deepEqual(jsType(o), ['object', undef]);
  });
})();

// ---------------------------------------------------------------------------
test("line 357", (t) => {
  return t.truthy(isEmpty(''));
});

test("line 358", (t) => {
  return t.truthy(isEmpty('  \t\t'));
});

test("line 359", (t) => {
  return t.truthy(isEmpty([]));
});

test("line 360", (t) => {
  return t.truthy(isEmpty({}));
});

test("line 362", (t) => {
  return t.truthy(nonEmpty('a'));
});

test("line 363", (t) => {
  return t.truthy(nonEmpty('.'));
});

test("line 364", (t) => {
  return t.truthy(nonEmpty([2]));
});

test("line 365", (t) => {
  return t.truthy(nonEmpty({
    width: 2
  }));
});

// ---------------------------------------------------------------------------
test("line 369", (t) => {
  return t.deepEqual(blockToArray(undef), []);
});

test("line 370", (t) => {
  return t.deepEqual(blockToArray(''), []);
});

test("line 371", (t) => {
  return t.deepEqual(blockToArray('a'), ['a']);
});

test("line 372", (t) => {
  return t.deepEqual(blockToArray("a\nb"), ['a', 'b']);
});

test("line 373", (t) => {
  return t.deepEqual(blockToArray("a\r\nb"), ['a', 'b']);
});

test("line 374", (t) => {
  return t.deepEqual(blockToArray("abc\nxyz"), ['abc', 'xyz']);
});

test("line 379", (t) => {
  return t.deepEqual(blockToArray("abc\nxyz"), ['abc', 'xyz']);
});

test("line 384", (t) => {
  return t.deepEqual(blockToArray("abc\n\nxyz"), ['abc', '', 'xyz']);
});

// ---------------------------------------------------------------------------
test("line 392", (t) => {
  return t.deepEqual(toArray("abc\ndef"), ['abc', 'def']);
});

test("line 393", (t) => {
  return t.deepEqual(toArray(['a', 'b']), ['a', 'b']);
});

test("line 395", (t) => {
  return t.deepEqual(toArray(["a\nb", "c\nd"]), ['a', 'b', 'c', 'd']);
});

// ---------------------------------------------------------------------------
test("line 399", (t) => {
  return t.deepEqual(arrayToBlock(undef), '');
});

test("line 400", (t) => {
  return t.deepEqual(arrayToBlock([]), '');
});

test("line 401", (t) => {
  return t.deepEqual(arrayToBlock([undef]), '');
});

test("line 402", (t) => {
  return t.deepEqual(arrayToBlock(['a  ', 'b\t\t']), "a\nb");
});

test("line 403", (t) => {
  return t.deepEqual(arrayToBlock(['a', 'b', 'c']), "a\nb\nc");
});

test("line 404", (t) => {
  return t.deepEqual(arrayToBlock(['a', undef, 'b', 'c']), "a\nb\nc");
});

test("line 405", (t) => {
  return t.deepEqual(arrayToBlock([undef, 'a', 'b', 'c', undef]), "a\nb\nc");
});

// ---------------------------------------------------------------------------
test("line 409", (t) => {
  return t.deepEqual(toBlock(['abc', 'def']), "abc\ndef");
});

test("line 410", (t) => {
  return t.deepEqual(toBlock("abc\ndef"), "abc\ndef");
});

// ---------------------------------------------------------------------------
test("line 414", (t) => {
  return t.is(rtrim("abc"), "abc");
});

test("line 415", (t) => {
  return t.is(rtrim("  abc"), "  abc");
});

test("line 416", (t) => {
  return t.is(rtrim("abc  "), "abc");
});

test("line 417", (t) => {
  return t.is(rtrim("  abc  "), "  abc");
});

// ---------------------------------------------------------------------------
test("line 421", (t) => {
  return t.deepEqual(words(''), []);
});

test("line 422", (t) => {
  return t.deepEqual(words('  \t\t'), []);
});

test("line 423", (t) => {
  return t.deepEqual(words('a b c'), ['a', 'b', 'c']);
});

test("line 424", (t) => {
  return t.deepEqual(words('  a   b   c  '), ['a', 'b', 'c']);
});

test("line 425", (t) => {
  return t.deepEqual(words('a b', 'c d'), ['a', 'b', 'c', 'd']);
});

test("line 426", (t) => {
  return t.deepEqual(words(' my word ', ' is  word  '), ['my', 'word', 'is', 'word']);
});

test("line 428", (t) => {
  return t.truthy(hasChar('abc', 'b'));
});

test("line 429", (t) => {
  return t.falsy(hasChar('abc', 'x'));
});

test("line 430", (t) => {
  return t.falsy(hasChar("\t\t", ' '));
});

// ---------------------------------------------------------------------------
test("line 434", (t) => {
  return t.is(quoted('abc'), "'abc'");
});

test("line 435", (t) => {
  return t.is(quoted('"abc"'), "'\"abc\"'");
});

test("line 436", (t) => {
  return t.is(quoted("'abc'"), "\"'abc'\"");
});

test("line 437", (t) => {
  return t.is(quoted("'\"abc\"'"), "<'\"abc\"'>");
});

test("line 438", (t) => {
  return t.is(quoted("'\"<abc>\"'"), "<'\"<abc>\"'>");
});

// ---------------------------------------------------------------------------
test("line 442", (t) => {
  return t.deepEqual(getOptions(), {});
});

test("line 443", (t) => {
  return t.deepEqual(getOptions(undef, {
    x: 1
  }), {
    x: 1
  });
});

test("line 444", (t) => {
  return t.deepEqual(getOptions({
    x: 1
  }, {
    x: 3,
    y: 4
  }), {
    x: 1,
    y: 4
  });
});

test("line 445", (t) => {
  return t.deepEqual(getOptions('asText'), {
    asText: true
  });
});

test("line 446", (t) => {
  return t.deepEqual(getOptions('!binary'), {
    binary: false
  });
});

test("line 447", (t) => {
  return t.deepEqual(getOptions('label=this'), {
    label: 'this'
  });
});

test("line 448", (t) => {
  return t.deepEqual(getOptions('width=42'), {
    width: 42
  });
});

test("line 449", (t) => {
  return t.deepEqual(getOptions('asText !binary label=this'), {
    asText: true,
    binary: false,
    label: 'this'
  });
});

// ---------------------------------------------------------------------------
test("line 457", (t) => {
  return t.deepEqual(range(3), [0, 1, 2]);
});

// ---------------------------------------------------------------------------
utest.truthy(461, isHashComment('#'));

utest.truthy(462, isHashComment('# a comment'));

utest.truthy(463, isHashComment('#\ta comment'));

utest.falsy(464, isHashComment('#comment'));

utest.falsy(465, isHashComment(''));

utest.falsy(466, isHashComment('a comment'));

// ---------------------------------------------------------------------------
utest.truthy(470, isEmpty(''));

utest.truthy(471, isEmpty('  \t\t'));

utest.truthy(472, isEmpty([]));

utest.truthy(473, isEmpty({}));

utest.truthy(475, nonEmpty('a'));

utest.truthy(476, nonEmpty('.'));

utest.truthy(477, nonEmpty([2]));

utest.truthy(478, nonEmpty({
  width: 2
}));

utest.truthy(480, isNonEmptyString('abc'));

utest.falsy(481, isNonEmptyString(undef));

utest.falsy(482, isNonEmptyString(''));

utest.falsy(483, isNonEmptyString('   '));

utest.falsy(484, isNonEmptyString("\t\t\t"));

utest.falsy(485, isNonEmptyString(5));

// ---------------------------------------------------------------------------
utest.truthy(489, oneof('a', 'a', 'b', 'c'));

utest.truthy(490, oneof('b', 'a', 'b', 'c'));

utest.truthy(491, oneof('c', 'a', 'b', 'c'));

utest.falsy(492, oneof('d', 'a', 'b', 'c'));

utest.falsy(493, oneof('x'));

// ---------------------------------------------------------------------------
utest.equal(497, uniq([1, 2, 2, 3, 3]), [1, 2, 3]);

utest.equal(498, uniq(['a', 'b', 'b', 'c', 'c']), ['a', 'b', 'c']);

// ---------------------------------------------------------------------------
// CURRENTLY DOES NOT PASS

// utest.equal {{LINE}}, hashToStr({c:3, b:2, a:1}), """
// 		{
// 		   "a": 1,
// 		   "b": 2,
// 		   "c": 3
// 		}
// 		"""

// ---------------------------------------------------------------------------
utest.equal(513, rtrim("abc"), "abc");

utest.equal(514, rtrim("  abc"), "  abc");

utest.equal(515, rtrim("abc  "), "abc");

utest.equal(516, rtrim("  abc  "), "  abc");

// ---------------------------------------------------------------------------
utest.equal(520, words('a b c'), ['a', 'b', 'c']);

utest.equal(521, words('  a   b   c  '), ['a', 'b', 'c']);

// ---------------------------------------------------------------------------
utest.equal(525, escapeStr("\t\tXXX\n"), "→→XXX®");

hEsc = {
  "\n": "\\n",
  "\t": "\\t",
  "\"": "\\\""
};

utest.equal(531, escapeStr("\thas quote: \"\nnext line", hEsc), "\\thas quote: \\\"\\nnext line");

// ---------------------------------------------------------------------------
utest.equal(536, rtrunc('/user/lib/.env', 5), '/user/lib');

utest.equal(537, ltrunc('abcdefg', 3), 'defg');

utest.equal(539, CWS(`abc
def
		ghi`), "abc def ghi");

// ---------------------------------------------------------------------------
utest.truthy(547, isArrayOfStrings([]));

utest.truthy(548, isArrayOfStrings(['a', 'b', 'c']));

utest.truthy(549, isArrayOfStrings(['a', undef, null, 'b']));

// ---------------------------------------------------------------------------
utest.truthy(553, isArrayOfArrays([]));

utest.truthy(554, isArrayOfArrays([[], []]));

utest.truthy(555, isArrayOfArrays([[1, 2], []]));

utest.truthy(556, isArrayOfArrays([[1, 2, [1, 2, 3]], []]));

utest.truthy(557, isArrayOfArrays([[1, 2], undef, null, []]));

utest.falsy(559, isArrayOfArrays({}));

utest.falsy(560, isArrayOfArrays([1, 2, 3]));

utest.falsy(561, isArrayOfArrays([[1, 2, [3, 4]], 4]));

utest.falsy(562, isArrayOfArrays([
  [1,
  2,
  [3,
  4]],
  [],
  {
    a: 1,
    b: 2
  }
]));

utest.truthy(564, isArrayOfArrays([[1, 2], [3, 4], [4, 5]], 2));

utest.falsy(565, isArrayOfArrays([[1, 2], [3], [4, 5]], 2));

utest.falsy(566, isArrayOfArrays([[1, 2], [3, 4, 5], [4, 5]], 2));

// ---------------------------------------------------------------------------
utest.truthy(570, isArrayOfHashes([]));

utest.truthy(571, isArrayOfHashes([{}, {}]));

utest.truthy(572, isArrayOfHashes([
  {
    a: 1,
    b: 2
  },
  {}
]));

utest.truthy(573, isArrayOfHashes([
  {
    a: 1,
    b: 2,
    c: [1,
  2,
  3]
  },
  {}
]));

utest.truthy(574, isArrayOfHashes([
  {
    a: 1,
    b: 2
  },
  undef,
  null,
  {}
]));

utest.falsy(576, isArrayOfHashes({}));

utest.falsy(577, isArrayOfHashes([1, 2, 3]));

utest.falsy(578, isArrayOfHashes([
  {
    a: 1,
    b: 2,
    c: [1,
  2,
  3]
  },
  4
]));

utest.falsy(579, isArrayOfHashes([
  {
    a: 1,
    b: 2,
    c: [1,
  2,
  3]
  },
  {},
  [1,
  2]
]));

// ---------------------------------------------------------------------------
(function() {
  var NewClass, h, l, n, n2, o, s, s2;
  NewClass = class NewClass {
    constructor(name = 'bob') {
      this.name = name;
      pass;
    }

    doIt() {
      return pass;
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
  s = 'utest';
  s2 = new String('abc');
  utest.truthy(598, isHash(h));
  utest.falsy(599, isHash(l));
  utest.falsy(600, isHash(o));
  utest.falsy(601, isHash(n));
  utest.falsy(602, isHash(n2));
  utest.falsy(603, isHash(s));
  utest.falsy(604, isHash(s2));
  utest.falsy(606, isArray(h));
  utest.truthy(607, isArray(l));
  utest.falsy(608, isArray(o));
  utest.falsy(609, isArray(n));
  utest.falsy(610, isArray(n2));
  utest.falsy(611, isArray(s));
  utest.falsy(612, isArray(s2));
  utest.falsy(614, isString(undef));
  utest.falsy(615, isString(h));
  utest.falsy(616, isString(l));
  utest.falsy(617, isString(o));
  utest.falsy(618, isString(n));
  utest.falsy(619, isString(n2));
  utest.truthy(620, isString(s));
  utest.truthy(621, isString(s2));
  utest.falsy(623, isObject(h));
  utest.falsy(624, isObject(l));
  utest.truthy(625, isObject(o));
  utest.truthy(626, isObject(o, ['name', 'doIt']));
  utest.falsy(627, isObject(o, ['name', 'doIt', 'missing']));
  utest.falsy(628, isObject(n));
  utest.falsy(629, isObject(n2));
  utest.falsy(630, isObject(s));
  utest.falsy(631, isObject(s2));
  utest.falsy(633, isNumber(h));
  utest.falsy(634, isNumber(l));
  utest.falsy(635, isNumber(o));
  utest.truthy(636, isNumber(n));
  utest.truthy(637, isNumber(n2));
  utest.falsy(638, isNumber(s));
  utest.falsy(639, isNumber(s2));
  utest.truthy(641, isNumber(42.0, {
    min: 42.0
  }));
  utest.falsy(642, isNumber(42.0, {
    min: 42.1
  }));
  utest.truthy(643, isNumber(42.0, {
    max: 42.0
  }));
  return utest.falsy(644, isNumber(42.0, {
    max: 41.9
  }));
})();

// ---------------------------------------------------------------------------
utest.truthy(649, isFunction(function() {
  return pass;
}));

utest.falsy(650, isFunction(23));

utest.truthy(652, isInteger(42));

utest.truthy(653, isInteger(new Number(42)));

utest.falsy(654, isInteger('abc'));

utest.falsy(655, isInteger({}));

utest.falsy(656, isInteger([]));

utest.truthy(657, isInteger(42, {
  min: 0
}));

utest.falsy(658, isInteger(42, {
  min: 50
}));

utest.truthy(659, isInteger(42, {
  max: 50
}));

utest.falsy(660, isInteger(42, {
  max: 0
}));

// ---------------------------------------------------------------------------
utest.equal(664, OL(undef), "undef");

utest.equal(665, OL("\t\tabc\nxyz"), "'→→abc®xyz'");

utest.equal(666, OL({
  a: 1,
  b: 'xyz'
}), '{"a":1,"b":"xyz"}');

// ---------------------------------------------------------------------------
utest.equal(670, CWS(`a utest
error message`), "a utest error message");

// ---------------------------------------------------------------------------
// test isRegExp()
utest.truthy(678, isRegExp(/^abc$/));

utest.truthy(679, isRegExp(/^\s*where\s+areyou$/));

utest.falsy(685, isRegExp(42));

utest.falsy(686, isRegExp('abc'));

utest.falsy(687, isRegExp([1, 'a']));

utest.falsy(688, isRegExp({
  a: 1,
  b: 'ccc'
}));

utest.falsy(689, isRegExp(undef));

utest.truthy(691, isRegExp(/\.coffee/));

// ---------------------------------------------------------------------------
utest.equal(695, extractMatches("..3 and 4 plus 5", /\d+/g, parseInt), [3, 4, 5]);

utest.equal(697, extractMatches("And This Is A String", /A/g), ['A', 'A']);

// ---------------------------------------------------------------------------
utest.truthy(701, notdefined(undef));

utest.truthy(702, notdefined(null));

utest.truthy(703, defined(''));

utest.truthy(704, defined(5));

utest.truthy(705, defined([]));

utest.truthy(706, defined({}));

utest.falsy(708, defined(undef));

utest.falsy(709, defined(null));

utest.falsy(710, notdefined(''));

utest.falsy(711, notdefined(5));

utest.falsy(712, notdefined([]));

utest.falsy(713, notdefined({}));

// ---------------------------------------------------------------------------
utest.truthy(717, isIterable([]));

utest.truthy(718, isIterable(['a', 'b']));

gen = function*() {
  yield 1;
  yield 2;
  yield 3;
};

utest.truthy(726, isIterable(gen()));

// ---------------------------------------------------------------------------
(function() {
  var MyClass;
  MyClass = class MyClass {
    constructor(str) {
      this.mystr = str;
    }

  };
  return utest.equal(735, className(MyClass), 'MyClass');
})();

// ---------------------------------------------------------------------------
utest.equal(741, getOptions('a b c'), {
  'a': true,
  'b': true,
  'c': true
});

utest.equal(742, getOptions('abc'), {
  'abc': true
});

utest.equal(743, getOptions({
  'a': true,
  'b': false,
  'c': 42
}), {
  'a': true,
  'b': false,
  'c': 42
});

utest.equal(744, getOptions(), {});

// ---------------------------------------------------------------------------
// --- test forEachLine
(() => {
  var block, lResult;
  lResult = [];
  block = `abc
def
ghi`;
  forEachLine(block, (line) => {
    lResult.push(line.toUpperCase());
    return false;
  });
  return utest.equal(759, lResult, ['ABC', 'DEF', 'GHI']);
})();

(() => {
  var block, lResult;
  lResult = [];
  block = `abc
def
ghi`;
  forEachLine(block, (line) => {
    if (line === 'ghi') {
      return true;
    }
    lResult.push(line.toUpperCase());
    return false;
  });
  return utest.equal(775, lResult, ['ABC', 'DEF']);
})();

(() => {
  var item, lResult;
  lResult = [];
  item = ['abc', 'def', 'ghi'];
  forEachLine(item, (line) => {
    lResult.push(line.toUpperCase());
    return false;
  });
  return utest.equal(784, lResult, ['ABC', 'DEF', 'GHI']);
})();

(() => {
  var item, lResult;
  lResult = [];
  item = ['abc', 'def', 'ghi'];
  forEachLine(item, (line) => {
    if (line === 'ghi') {
      return true;
    }
    lResult.push(line.toUpperCase());
    return false;
  });
  return utest.equal(796, lResult, ['ABC', 'DEF']);
})();

(() => {
  var item, lResult;
  lResult = [];
  item = ['abc', 'def', 'ghi'];
  forEachLine(item, (line, hInfo) => {
    if (line === 'ghi') {
      return true;
    }
    lResult.push(`${hInfo.lineNum} ${line.toUpperCase()} ${hInfo.nextLine}`);
    return false;
  });
  return utest.equal(808, lResult, ['1 ABC def', '2 DEF ghi']);
})();

// ---------------------------------------------------------------------------
// --- test mapEachLine
(() => {
  var block, newblock;
  block = `abc
def
ghi`;
  newblock = mapEachLine(block, (line) => {
    return line.toUpperCase();
  });
  return utest.equal(822, newblock, `ABC
DEF
GHI`);
})();

(() => {
  var block, newblock;
  block = `abc
def
ghi`;
  newblock = mapEachLine(block, (line) => {
    if (line === 'def') {
      return undef;
    } else {
      return line.toUpperCase();
    }
  });
  return utest.equal(840, newblock, `ABC
GHI`);
})();

(() => {
  var item, newblock;
  item = ['abc', 'def', 'ghi'];
  newblock = mapEachLine(item, (line) => {
    return line.toUpperCase();
  });
  return utest.equal(850, newblock, ['ABC', 'DEF', 'GHI']);
})();

(() => {
  var item, newblock;
  item = ['abc', 'def', 'ghi'];
  newblock = mapEachLine(item, (line) => {
    if (line === 'def') {
      return undef;
    } else {
      return line.toUpperCase();
    }
  });
  return utest.equal(864, newblock, ['ABC', 'GHI']);
})();

(() => {
  var item, newblock;
  item = ['abc', 'def', 'ghi'];
  newblock = mapEachLine(item, (line, hInfo) => {
    if (line === 'def') {
      return undef;
    } else if (defined(hInfo.nextLine)) {
      return `${hInfo.lineNum} ${line.toUpperCase()} ${hInfo.nextLine}`;
    } else {
      return `${hInfo.lineNum} ${line.toUpperCase()}`;
    }
  });
  return utest.equal(879, newblock, ['1 ABC def', '3 GHI']);
})();

// ---------------------------------------------------------------------------
// --- test removeKeys
(() => {
  var hAST;
  hAST = {
    body: [
      {
        declarations: Array([
          {
            start: 0
          }
        ],
      {
          end: 11,
          kind: 'let',
          start: 0,
          type: 'VariableDeclaration'
        })
      }
    ],
    end: 11,
    sourceType: 'script',
    start: 0,
    type: 'Program'
  };
  return utest.equal(905, removeKeys(hAST, ['start', 'end']), {
    body: [
      {
        declarations: Array([{}],
      {
          kind: 'let',
          type: 'VariableDeclaration'
        })
      }
    ],
    sourceType: 'script',
    type: 'Program'
  });
})();

(() => {
  var hAST;
  hAST = {
    body: [
      {
        declarations: Array([
          {
            start: 0
          }
        ],
      {
          end: 12,
          kind: 'let',
          start: 0,
          type: 'VariableDeclaration'
        })
      }
    ],
    end: 12,
    sourceType: 'script',
    start: 0,
    type: 'Program'
  };
  return utest.equal(936, removeKeys(hAST, ['start', 'end']), {
    body: [
      {
        declarations: Array([{}],
      {
          kind: 'let',
          type: 'VariableDeclaration'
        })
      }
    ],
    sourceType: 'script',
    type: 'Program'
  });
})();

// ---------------------------------------------------------------------------
// test getProxy()
(() => {
  var h, hToDo;
  hToDo = {
    task: 'go shopping',
    notes: 'broccoli, milk'
  };
  // ..........................................................
  h = getProxy(hToDo, {
    get: function(obj, prop, value) {
      return value.toUpperCase(); // return in upper case
    },
    set: function(obj, prop, value) {
      // --- only allow setting tasks to 'do <something>'
      if ((prop === 'task') && (value.indexOf('do ') !== 0)) {
        return undef;
      } else {
        return value;
      }
    }
  });
  utest.equal(976, hToDo.task, 'go shopping');
  utest.equal(977, h.task, 'GO SHOPPING');
  h.task = 'do something';
  utest.equal(980, hToDo.task, 'do something');
  utest.equal(981, h.task, 'DO SOMETHING');
  h.task = 'nothing';
  utest.equal(984, hToDo.task, 'do something');
  return utest.equal(985, h.task, 'DO SOMETHING');
})();

// ---------------------------------------------------------------------------
// test doDelayed()
(async() => {
  var LOG, lLines, run1;
  lLines = undef;
  LOG = (str) => {
    return lLines.push(str);
  };
  run1 = async() => {
    lLines = [];
    schedule(1, 1, LOG, 'abc');
    schedule(2, 2, LOG, 'def');
    await sleep(5);
    schedule(3, 1, LOG, 'ghi');
    await sleep(5);
    return lLines.join(',');
  };
  return utest.equal(1006, (await run1()), 'abc,def,ghi');
})();

(async() => {
  var LOG, lLines, run2;
  lLines = undef;
  LOG = (str) => {
    return lLines.push(str);
  };
  run2 = async() => {
    lLines = [];
    schedule(1, 1, LOG, 'abc');
    schedule(2, 2, LOG, 'def');
    schedule(3, 1, LOG, 'ghi');
    await sleep(5);
    return lLines.join(',');
  };
  return utest.equal(1023, (await run2()), 'def,ghi');
})();
