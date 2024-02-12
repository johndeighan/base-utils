// base-utils.test.coffee
var dateStr, gen, h, hEsc, hProc, lItems, lShuffled;

import test from 'ava';

import {
  utest
} from '@jdeighan/base-utils/utest';

import {
  undef,
  pass,
  defined,
  notdefined,
  keys,
  hasKey,
  hasAllKeys,
  hasAnyKey,
  subkeys,
  tabify,
  untabify,
  prefixBlock,
  escapeStr,
  OL,
  OLS,
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
  rev_range,
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
  schedule,
  eachCharInString,
  runCmd,
  hit,
  choose,
  shuffle,
  deepCopy,
  timestamp,
  msSinceEpoch,
  formatDate,
  pad
} from '@jdeighan/base-utils';

// ---------------------------------------------------------------------------
test("line 27", (t) => {
  return t.truthy(deepEqual({
    a: 1,
    b: 2
  }, {
    a: 1,
    b: 2
  }));
});

test("line 28", (t) => {
  return t.falsy(deepEqual({
    a: 1,
    b: 2
  }, {
    a: 1,
    b: 3
  }));
});

// ---------------------------------------------------------------------------
test("line 32", (t) => {
  return t.truthy(isHashComment('   # something'));
});

test("line 33", (t) => {
  return t.truthy(isHashComment('   #'));
});

test("line 34", (t) => {
  return t.falsy(isHashComment('   abc'));
});

test("line 35", (t) => {
  return t.falsy(isHashComment('#abc'));
});

test("line 37", (t) => {
  return t.is(undef, void 0);
});

test("line 39", (t) => {
  return t.truthy(isFunction(pass));
});

(function() {
  var passTest;
  passTest = () => {
    return pass();
  };
  return test("line 44", (t) => {
    return t.notThrows(passTest, "pass fails");
  });
})();

test("line 47", (t) => {
  return t.truthy(defined(''));
});

test("line 48", (t) => {
  return t.truthy(defined(5));
});

test("line 49", (t) => {
  return t.truthy(defined([]));
});

test("line 50", (t) => {
  return t.truthy(defined({}));
});

test("line 51", (t) => {
  return t.falsy(defined(undef));
});

test("line 52", (t) => {
  return t.falsy(defined(null));
});

test("line 54", (t) => {
  return t.truthy(notdefined(undef));
});

test("line 55", (t) => {
  return t.truthy(notdefined(null));
});

test("line 56", (t) => {
  return t.falsy(notdefined(''));
});

test("line 57", (t) => {
  return t.falsy(notdefined(5));
});

test("line 58", (t) => {
  return t.falsy(notdefined([]));
});

test("line 59", (t) => {
  return t.falsy(notdefined({}));
});

// ---------------------------------------------------------------------------
test("line 63", (t) => {
  return t.deepEqual(splitPrefix("abc"), ["", "abc"]);
});

test("line 64", (t) => {
  return t.deepEqual(splitPrefix("\tabc"), ["\t", "abc"]);
});

test("line 65", (t) => {
  return t.deepEqual(splitPrefix("\t\tabc"), ["\t\t", "abc"]);
});

test("line 66", (t) => {
  return t.deepEqual(splitPrefix(""), ["", ""]);
});

test("line 67", (t) => {
  return t.deepEqual(splitPrefix("\t\t\t"), ["", ""]);
});

test("line 68", (t) => {
  return t.deepEqual(splitPrefix("\t \t"), ["", ""]);
});

test("line 69", (t) => {
  return t.deepEqual(splitPrefix("   "), ["", ""]);
});

// ---------------------------------------------------------------------------
test("line 73", (t) => {
  return t.falsy(hasPrefix("abc"));
});

test("line 74", (t) => {
  return t.truthy(hasPrefix("   abc"));
});

// ---------------------------------------------------------------------------
(function() {
  var prefix;
  prefix = '   '; // 3 spaces
  return test("line 81", (t) => {
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
  return utest.equal(97, tabify(`first line
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
  return utest.equal(114, tabify(`first line
${prefix}second line
${prefix}${prefix}third line`), `first line
\tsecond line
\t\tthird line`);
})();

// ---------------------------------------------------------------------------
(function() {
  var prefix;
  prefix = '   '; // 3 spaces
  return utest.equal(130, untabify(`first line
\tsecond line
\t\tthird line`, 3), `first line
${prefix}second line
${prefix}${prefix}third line`);
})();

// ---------------------------------------------------------------------------
test("line 143", (t) => {
  return t.is(prefixBlock(`abc
def`, '--'), `--abc
--def`);
});

// ---------------------------------------------------------------------------
test("line 153", (t) => {
  return t.is(escapeStr("\t\tXXX\n"), "→→XXX▼");
});

hEsc = {
  "\n": "\\n",
  "\t": "\\t",
  "\"": "\\\""
};

test("line 161", (t) => {
  return t.is(escapeStr("\thas quote: \"\nnext line", hEsc), "\\thas quote: \\\"\\nnext line");
});

// ---------------------------------------------------------------------------
test("line 166", (t) => {
  return t.is(OL(undef), "undef");
});

test("line 167", (t) => {
  return t.is(OL("\t\tabc\nxyz"), "'→→abc▼xyz'");
});

test("line 168", (t) => {
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

test("line 176", (t) => {
  return t.is(OL(hProc), '{"code":"[Function: code]","html":"[Function: html]","Script":"[Function: Script]"}');
});

// ---------------------------------------------------------------------------
test("line 180", (t) => {
  return t.is(OLS(['abc', 3]), "'abc',3");
});

test("line 181", (t) => {
  return t.is(OLS([]), "");
});

test("line 182", (t) => {
  return t.is(OLS([
    undef,
    {
      a: 1
    }
  ]), 'undef,{"a":1}');
});

// ---------------------------------------------------------------------------
test("line 99", (t) => {
  return t.truthy(oneof('a', 'b', 'a', 'c'));
});

test("line 187", (t) => {
  return t.falsy(oneof('a', 'b', 'c'));
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
  test("line 207", (t) => {
    return t.falsy(isString(undef));
  });
  test("line 208", (t) => {
    return t.falsy(isString(h));
  });
  test("line 209", (t) => {
    return t.falsy(isString(l));
  });
  test("line 210", (t) => {
    return t.falsy(isString(o));
  });
  test("line 211", (t) => {
    return t.falsy(isString(n));
  });
  test("line 212", (t) => {
    return t.falsy(isString(n2));
  });
  test("line 214", (t) => {
    return t.truthy(isString(s));
  });
  test("line 215", (t) => {
    return t.truthy(isString(s2));
  });
  test("line 217", (t) => {
    return t.truthy(isNonEmptyString('abc'));
  });
  test("line 218", (t) => {
    return t.truthy(isNonEmptyString('abc def'));
  });
  test("line 219", (t) => {
    return t.falsy(isNonEmptyString(''));
  });
  test("line 220", (t) => {
    return t.falsy(isNonEmptyString('  '));
  });
  test("line 222", (t) => {
    return t.truthy(isIdentifier('abc'));
  });
  test("line 223", (t) => {
    return t.truthy(isIdentifier('_Abc'));
  });
  test("line 224", (t) => {
    return t.falsy(isIdentifier('abc def'));
  });
  test("line 225", (t) => {
    return t.falsy(isIdentifier('abc-def'));
  });
  test("line 226", (t) => {
    return t.falsy(isIdentifier('class.method'));
  });
  test("line 228", (t) => {
    return t.truthy(isFunctionName('abc'));
  });
  test("line 229", (t) => {
    return t.truthy(isFunctionName('_Abc'));
  });
  test("line 230", (t) => {
    return t.falsy(isFunctionName('abc def'));
  });
  test("line 231", (t) => {
    return t.falsy(isFunctionName('abc-def'));
  });
  test("line 232", (t) => {
    return t.falsy(isFunctionName('D()'));
  });
  test("line 233", (t) => {
    return t.truthy(isFunctionName('class.method'));
  });
  generatorFunc = function*() {
    yield 1;
    yield 2;
    yield 3;
  };
  test("line 241", (t) => {
    return t.truthy(isIterable(generatorFunc()));
  });
  test("line 243", (t) => {
    return t.falsy(isNumber(undef));
  });
  test("line 244", (t) => {
    return t.falsy(isNumber(null));
  });
  test("line 245", (t) => {
    return t.truthy(isNumber(0/0));
  });
  test("line 246", (t) => {
    return t.falsy(isNumber(h));
  });
  test("line 247", (t) => {
    return t.falsy(isNumber(l));
  });
  test("line 248", (t) => {
    return t.falsy(isNumber(o));
  });
  test("line 249", (t) => {
    return t.truthy(isNumber(n));
  });
  test("line 250", (t) => {
    return t.truthy(isNumber(n2));
  });
  test("line 251", (t) => {
    return t.falsy(isNumber(s));
  });
  test("line 252", (t) => {
    return t.falsy(isNumber(s2));
  });
  test("line 254", (t) => {
    return t.truthy(isNumber(42.0, {
      min: 42.0
    }));
  });
  test("line 255", (t) => {
    return t.falsy(isNumber(42.0, {
      min: 42.1
    }));
  });
  test("line 256", (t) => {
    return t.truthy(isNumber(42.0, {
      max: 42.0
    }));
  });
  test("line 257", (t) => {
    return t.falsy(isNumber(42.0, {
      max: 41.9
    }));
  });
  test("line 259", (t) => {
    return t.truthy(isInteger(42));
  });
  test("line 260", (t) => {
    return t.truthy(isInteger(new Number(42)));
  });
  test("line 261", (t) => {
    return t.falsy(isInteger('abc'));
  });
  test("line 262", (t) => {
    return t.falsy(isInteger({}));
  });
  test("line 263", (t) => {
    return t.falsy(isInteger([]));
  });
  test("line 264", (t) => {
    return t.truthy(isInteger(42, {
      min: 0
    }));
  });
  test("line 265", (t) => {
    return t.falsy(isInteger(42, {
      min: 50
    }));
  });
  test("line 266", (t) => {
    return t.truthy(isInteger(42, {
      max: 50
    }));
  });
  test("line 267", (t) => {
    return t.falsy(isInteger(42, {
      max: 0
    }));
  });
  test("line 269", (t) => {
    return t.truthy(isHash(h));
  });
  test("line 270", (t) => {
    return t.falsy(isHash(l));
  });
  test("line 271", (t) => {
    return t.falsy(isHash(o));
  });
  test("line 272", (t) => {
    return t.falsy(isHash(n));
  });
  test("line 273", (t) => {
    return t.falsy(isHash(n2));
  });
  test("line 274", (t) => {
    return t.falsy(isHash(s));
  });
  test("line 275", (t) => {
    return t.falsy(isHash(s2));
  });
  test("line 277", (t) => {
    return t.falsy(isArray(h));
  });
  test("line 278", (t) => {
    return t.truthy(isArray(l));
  });
  test("line 279", (t) => {
    return t.falsy(isArray(o));
  });
  test("line 280", (t) => {
    return t.falsy(isArray(n));
  });
  test("line 281", (t) => {
    return t.falsy(isArray(n2));
  });
  test("line 282", (t) => {
    return t.falsy(isArray(s));
  });
  test("line 283", (t) => {
    return t.falsy(isArray(s2));
  });
  test("line 285", (t) => {
    return t.truthy(isBoolean(true));
  });
  test("line 286", (t) => {
    return t.truthy(isBoolean(false));
  });
  test("line 287", (t) => {
    return t.falsy(isBoolean(42));
  });
  test("line 288", (t) => {
    return t.falsy(isBoolean("true"));
  });
  test("line 290", (t) => {
    return t.truthy(isClass(NewClass));
  });
  test("line 291", (t) => {
    return t.falsy(isClass(o));
  });
  test("line 293", (t) => {
    return t.truthy(isConstructor(NewClass));
  });
  test("line 294", (t) => {
    return t.falsy(isConstructor(o));
  });
  test("line 296", (t) => {
    return t.truthy(isFunction(function() {
      return 42;
    }));
  });
  test("line 297", (t) => {
    return t.truthy(isFunction(() => {
      return 42;
    }));
  });
  test("line 298", (t) => {
    return t.falsy(isFunction(undef));
  });
  test("line 299", (t) => {
    return t.falsy(isFunction(null));
  });
  test("line 300", (t) => {
    return t.falsy(isFunction(42));
  });
  test("line 301", (t) => {
    return t.falsy(isFunction(n));
  });
  test("line 303", (t) => {
    return t.truthy(isRegExp(/^abc$/));
  });
  test("line 304", (t) => {
    return t.truthy(isRegExp(/^\s*where\s+areyou$/));
  });
  test("line 305", (t) => {
    return t.falsy(isRegExp(42));
  });
  test("line 306", (t) => {
    return t.falsy(isRegExp('abc'));
  });
  test("line 307", (t) => {
    return t.falsy(isRegExp([1, 'a']));
  });
  test("line 308", (t) => {
    return t.falsy(isRegExp({
      a: 1,
      b: 'ccc'
    }));
  });
  test("line 309", (t) => {
    return t.falsy(isRegExp(undef));
  });
  test("line 310", (t) => {
    return t.truthy(isRegExp(/\.coffee/));
  });
  test("line 312", (t) => {
    return t.falsy(isObject(h));
  });
  test("line 313", (t) => {
    return t.falsy(isObject(l));
  });
  test("line 314", (t) => {
    return t.truthy(isObject(o));
  });
  test("line 315", (t) => {
    return t.truthy(isObject(o, ['name', 'doIt']));
  });
  test("line 316", (t) => {
    return t.truthy(isObject(o, "name doIt"));
  });
  test("line 317", (t) => {
    return t.falsy(isObject(o, ['name', 'doIt', 'missing']));
  });
  test("line 318", (t) => {
    return t.falsy(isObject(o, "name doIt missing"));
  });
  test("line 319", (t) => {
    return t.falsy(isObject(n));
  });
  test("line 320", (t) => {
    return t.falsy(isObject(n2));
  });
  test("line 321", (t) => {
    return t.falsy(isObject(s));
  });
  test("line 322", (t) => {
    return t.falsy(isObject(s2));
  });
  test("line 323", (t) => {
    return t.truthy(isObject(o, "name doIt"));
  });
  test("line 324", (t) => {
    return t.truthy(isObject(o, "name doIt meth"));
  });
  test("line 325", (t) => {
    return t.truthy(isObject(o, "name &doIt &meth"));
  });
  test("line 326", (t) => {
    return t.falsy(isObject(o, "&name"));
  });
  test("line 328", (t) => {
    return t.deepEqual(jsType(undef), [undef, undef]);
  });
  test("line 329", (t) => {
    return t.deepEqual(jsType(null), [undef, 'null']);
  });
  test("line 330", (t) => {
    return t.deepEqual(jsType(s), ['string', undef]);
  });
  test("line 331", (t) => {
    return t.deepEqual(jsType(''), ['string', 'empty']);
  });
  test("line 332", (t) => {
    return t.deepEqual(jsType("\t\t"), ['string', 'empty']);
  });
  test("line 333", (t) => {
    return t.deepEqual(jsType("  "), ['string', 'empty']);
  });
  test("line 334", (t) => {
    return t.deepEqual(jsType(h), ['hash', undef]);
  });
  test("line 335", (t) => {
    return t.deepEqual(jsType({}), ['hash', 'empty']);
  });
  test("line 336", (t) => {
    return t.deepEqual(jsType(3.14159), ['number', undef]);
  });
  test("line 337", (t) => {
    return t.deepEqual(jsType(42), ['number', 'integer']);
  });
  test("line 338", (t) => {
    return t.deepEqual(jsType(true), ['boolean', undef]);
  });
  test("line 339", (t) => {
    return t.deepEqual(jsType(false), ['boolean', undef]);
  });
  test("line 340", (t) => {
    return t.deepEqual(jsType(h), ['hash', undef]);
  });
  test("line 341", (t) => {
    return t.deepEqual(jsType({}), ['hash', 'empty']);
  });
  test("line 342", (t) => {
    return t.deepEqual(jsType(l), ['array', undef]);
  });
  test("line 343", (t) => {
    return t.deepEqual(jsType([]), ['array', 'empty']);
  });
  test("line 344", (t) => {
    return t.deepEqual(jsType(/abc/), ['regexp', undef]);
  });
  func1 = function(x) {};
  func2 = (x) => {};
  // --- NOTE: regular functions can't be distinguished from constructors
  test("line 353", (t) => {
    return t.deepEqual(jsType(func1), ['class', undef]);
  });
  test("line 355", (t) => {
    return t.deepEqual(jsType(func2), ['function', undef]);
  });
  test("line 356", (t) => {
    return t.deepEqual(jsType(NewClass), ['class', undef]);
  });
  return test("line 357", (t) => {
    return t.deepEqual(jsType(o), ['object', undef]);
  });
})();

// ---------------------------------------------------------------------------
test("line 362", (t) => {
  return t.deepEqual(blockToArray(undef), []);
});

test("line 363", (t) => {
  return t.deepEqual(blockToArray(''), []);
});

test("line 364", (t) => {
  return t.deepEqual(blockToArray('a'), ['a']);
});

test("line 365", (t) => {
  return t.deepEqual(blockToArray("a\nb"), ['a', 'b']);
});

test("line 366", (t) => {
  return t.deepEqual(blockToArray("a\r\nb"), ['a', 'b']);
});

test("line 367", (t) => {
  return t.deepEqual(blockToArray("abc\nxyz"), ['abc', 'xyz']);
});

test("line 372", (t) => {
  return t.deepEqual(blockToArray("abc\nxyz"), ['abc', 'xyz']);
});

test("line 377", (t) => {
  return t.deepEqual(blockToArray("abc\n\nxyz"), ['abc', '', 'xyz']);
});

// ---------------------------------------------------------------------------
test("line 385", (t) => {
  return t.deepEqual(toArray("abc\ndef"), ['abc', 'def']);
});

test("line 386", (t) => {
  return t.deepEqual(toArray(['a', 'b']), ['a', 'b']);
});

test("line 388", (t) => {
  return t.deepEqual(toArray(["a\nb", "c\nd"]), ['a', 'b', 'c', 'd']);
});

// ---------------------------------------------------------------------------
test("line 392", (t) => {
  return t.deepEqual(arrayToBlock(undef), '');
});

test("line 393", (t) => {
  return t.deepEqual(arrayToBlock([]), '');
});

test("line 394", (t) => {
  return t.deepEqual(arrayToBlock([undef]), '');
});

test("line 395", (t) => {
  return t.deepEqual(arrayToBlock(['a  ', 'b\t\t']), "a\nb");
});

test("line 396", (t) => {
  return t.deepEqual(arrayToBlock(['a', 'b', 'c']), "a\nb\nc");
});

test("line 397", (t) => {
  return t.deepEqual(arrayToBlock(['a', undef, 'b', 'c']), "a\nb\nc");
});

test("line 398", (t) => {
  return t.deepEqual(arrayToBlock([undef, 'a', 'b', 'c', undef]), "a\nb\nc");
});

// ---------------------------------------------------------------------------
test("line 402", (t) => {
  return t.deepEqual(toBlock(['abc', 'def']), "abc\ndef");
});

test("line 403", (t) => {
  return t.deepEqual(toBlock("abc\ndef"), "abc\ndef");
});

// ---------------------------------------------------------------------------
test("line 407", (t) => {
  return t.is(rtrim("abc"), "abc");
});

test("line 408", (t) => {
  return t.is(rtrim("  abc"), "  abc");
});

test("line 409", (t) => {
  return t.is(rtrim("abc  "), "abc");
});

test("line 410", (t) => {
  return t.is(rtrim("  abc  "), "  abc");
});

// ---------------------------------------------------------------------------
test("line 414", (t) => {
  return t.deepEqual(words(''), []);
});

test("line 415", (t) => {
  return t.deepEqual(words('  \t\t'), []);
});

test("line 416", (t) => {
  return t.deepEqual(words('a b c'), ['a', 'b', 'c']);
});

test("line 417", (t) => {
  return t.deepEqual(words('  a   b   c  '), ['a', 'b', 'c']);
});

test("line 418", (t) => {
  return t.deepEqual(words('a b', 'c d'), ['a', 'b', 'c', 'd']);
});

test("line 419", (t) => {
  return t.deepEqual(words(' my word ', ' is  word  '), ['my', 'word', 'is', 'word']);
});

test("line 421", (t) => {
  return t.truthy(hasChar('abc', 'b'));
});

test("line 422", (t) => {
  return t.falsy(hasChar('abc', 'x'));
});

test("line 423", (t) => {
  return t.falsy(hasChar("\t\t", ' '));
});

// ---------------------------------------------------------------------------
test("line 427", (t) => {
  return t.is(quoted('abc'), "'abc'");
});

test("line 428", (t) => {
  return t.is(quoted('"abc"'), "'\"abc\"'");
});

test("line 429", (t) => {
  return t.is(quoted("'abc'"), "\"'abc'\"");
});

test("line 430", (t) => {
  return t.is(quoted("'\"abc\"'"), "<'\"abc\"'>");
});

test("line 431", (t) => {
  return t.is(quoted("'\"<abc>\"'"), "<'\"<abc>\"'>");
});

// ---------------------------------------------------------------------------
test("line 435", (t) => {
  return t.deepEqual(getOptions(), {});
});

test("line 436", (t) => {
  return t.deepEqual(getOptions(undef, {
    x: 1
  }), {
    x: 1
  });
});

test("line 437", (t) => {
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

test("line 438", (t) => {
  return t.deepEqual(getOptions('asText'), {
    asText: true
  });
});

test("line 439", (t) => {
  return t.deepEqual(getOptions('!binary'), {
    binary: false
  });
});

test("line 440", (t) => {
  return t.deepEqual(getOptions('label=this'), {
    label: 'this'
  });
});

test("line 441", (t) => {
  return t.deepEqual(getOptions('width=42'), {
    width: 42
  });
});

test("line 442", (t) => {
  return t.deepEqual(getOptions('asText !binary label=this'), {
    asText: true,
    binary: false,
    label: 'this'
  });
});

// ---------------------------------------------------------------------------
test("line 450", (t) => {
  return t.deepEqual(range(3), [0, 1, 2]);
});

test("line 451", (t) => {
  return t.deepEqual(rev_range(3), [2, 1, 0]);
});

// ---------------------------------------------------------------------------
utest.truthy(455, isHashComment('#'));

utest.truthy(456, isHashComment('# a comment'));

utest.truthy(457, isHashComment('#\ta comment'));

utest.falsy(458, isHashComment('#comment'));

utest.falsy(459, isHashComment(''));

utest.falsy(460, isHashComment('a comment'));

// ---------------------------------------------------------------------------
utest.truthy(464, isEmpty(''));

utest.truthy(465, isEmpty('  \t\t'));

utest.truthy(466, isEmpty([]));

utest.truthy(467, isEmpty({}));

utest.truthy(469, nonEmpty('a'));

utest.truthy(470, nonEmpty('.'));

utest.truthy(471, nonEmpty([2]));

utest.truthy(472, nonEmpty({
  width: 2
}));

utest.truthy(474, isNonEmptyString('abc'));

utest.falsy(475, isNonEmptyString(undef));

utest.falsy(476, isNonEmptyString(''));

utest.falsy(477, isNonEmptyString('   '));

utest.falsy(478, isNonEmptyString("\t\t\t"));

utest.falsy(479, isNonEmptyString(5));

// ---------------------------------------------------------------------------
utest.truthy(483, oneof('a', 'a', 'b', 'c'));

utest.truthy(484, oneof('b', 'a', 'b', 'c'));

utest.truthy(485, oneof('c', 'a', 'b', 'c'));

utest.falsy(486, oneof('d', 'a', 'b', 'c'));

utest.falsy(487, oneof('x'));

// ---------------------------------------------------------------------------
utest.equal(491, uniq([1, 2, 2, 3, 3]), [1, 2, 3]);

utest.equal(492, uniq(['a', 'b', 'b', 'c', 'c']), ['a', 'b', 'c']);

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
utest.equal(507, rtrim("abc"), "abc");

utest.equal(508, rtrim("  abc"), "  abc");

utest.equal(509, rtrim("abc  "), "abc");

utest.equal(510, rtrim("  abc  "), "  abc");

// ---------------------------------------------------------------------------
utest.equal(514, words('a b c'), ['a', 'b', 'c']);

utest.equal(515, words('  a   b   c  '), ['a', 'b', 'c']);

// ---------------------------------------------------------------------------
utest.equal(519, escapeStr("\t\tXXX\n"), "→→XXX▼");

hEsc = {
  "\n": "\\n",
  "\t": "\\t",
  "\"": "\\\""
};

utest.equal(525, escapeStr("\thas quote: \"\nnext line", hEsc), "\\thas quote: \\\"\\nnext line");

// ---------------------------------------------------------------------------
utest.equal(530, rtrunc('/user/lib/.env', 5), '/user/lib');

utest.equal(531, ltrunc('abcdefg', 3), 'defg');

utest.equal(533, CWS(`abc
def
		ghi`), "abc def ghi");

// ---------------------------------------------------------------------------
utest.truthy(541, isArrayOfStrings([]));

utest.truthy(542, isArrayOfStrings(['a', 'b', 'c']));

utest.truthy(543, isArrayOfStrings(['a', undef, null, 'b']));

// ---------------------------------------------------------------------------
utest.truthy(547, isArrayOfArrays([]));

utest.truthy(548, isArrayOfArrays([[], []]));

utest.truthy(549, isArrayOfArrays([[1, 2], []]));

utest.truthy(550, isArrayOfArrays([[1, 2, [1, 2, 3]], []]));

utest.truthy(551, isArrayOfArrays([[1, 2], undef, null, []]));

utest.falsy(553, isArrayOfArrays({}));

utest.falsy(554, isArrayOfArrays([1, 2, 3]));

utest.falsy(555, isArrayOfArrays([[1, 2, [3, 4]], 4]));

utest.falsy(556, isArrayOfArrays([
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

utest.truthy(558, isArrayOfArrays([[1, 2], [3, 4], [4, 5]], 2));

utest.falsy(559, isArrayOfArrays([[1, 2], [3], [4, 5]], 2));

utest.falsy(560, isArrayOfArrays([[1, 2], [3, 4, 5], [4, 5]], 2));

// ---------------------------------------------------------------------------
utest.truthy(564, isArrayOfHashes([]));

utest.truthy(565, isArrayOfHashes([{}, {}]));

utest.truthy(566, isArrayOfHashes([
  {
    a: 1,
    b: 2
  },
  {}
]));

utest.truthy(567, isArrayOfHashes([
  {
    a: 1,
    b: 2,
    c: [1,
  2,
  3]
  },
  {}
]));

utest.truthy(568, isArrayOfHashes([
  {
    a: 1,
    b: 2
  },
  undef,
  null,
  {}
]));

utest.falsy(570, isArrayOfHashes({}));

utest.falsy(571, isArrayOfHashes([1, 2, 3]));

utest.falsy(572, isArrayOfHashes([
  {
    a: 1,
    b: 2,
    c: [1,
  2,
  3]
  },
  4
]));

utest.falsy(573, isArrayOfHashes([
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
  utest.truthy(592, isHash(h));
  utest.falsy(593, isHash(l));
  utest.falsy(594, isHash(o));
  utest.falsy(595, isHash(n));
  utest.falsy(596, isHash(n2));
  utest.falsy(597, isHash(s));
  utest.falsy(598, isHash(s2));
  utest.falsy(600, isArray(h));
  utest.truthy(601, isArray(l));
  utest.falsy(602, isArray(o));
  utest.falsy(603, isArray(n));
  utest.falsy(604, isArray(n2));
  utest.falsy(605, isArray(s));
  utest.falsy(606, isArray(s2));
  utest.falsy(608, isString(undef));
  utest.falsy(609, isString(h));
  utest.falsy(610, isString(l));
  utest.falsy(611, isString(o));
  utest.falsy(612, isString(n));
  utest.falsy(613, isString(n2));
  utest.truthy(614, isString(s));
  utest.truthy(615, isString(s2));
  utest.falsy(617, isObject(h));
  utest.falsy(618, isObject(l));
  utest.truthy(619, isObject(o));
  utest.truthy(620, isObject(o, ['name', 'doIt']));
  utest.falsy(621, isObject(o, ['name', 'doIt', 'missing']));
  utest.falsy(622, isObject(n));
  utest.falsy(623, isObject(n2));
  utest.falsy(624, isObject(s));
  utest.falsy(625, isObject(s2));
  utest.falsy(627, isNumber(h));
  utest.falsy(628, isNumber(l));
  utest.falsy(629, isNumber(o));
  utest.truthy(630, isNumber(n));
  utest.truthy(631, isNumber(n2));
  utest.falsy(632, isNumber(s));
  utest.falsy(633, isNumber(s2));
  utest.truthy(635, isNumber(42.0, {
    min: 42.0
  }));
  utest.falsy(636, isNumber(42.0, {
    min: 42.1
  }));
  utest.truthy(637, isNumber(42.0, {
    max: 42.0
  }));
  return utest.falsy(638, isNumber(42.0, {
    max: 41.9
  }));
})();

// ---------------------------------------------------------------------------
utest.truthy(643, isFunction(function() {
  return pass;
}));

utest.falsy(644, isFunction(23));

utest.truthy(646, isInteger(42));

utest.truthy(647, isInteger(new Number(42)));

utest.falsy(648, isInteger('abc'));

utest.falsy(649, isInteger({}));

utest.falsy(650, isInteger([]));

utest.truthy(651, isInteger(42, {
  min: 0
}));

utest.falsy(652, isInteger(42, {
  min: 50
}));

utest.truthy(653, isInteger(42, {
  max: 50
}));

utest.falsy(654, isInteger(42, {
  max: 0
}));

// ---------------------------------------------------------------------------
utest.equal(658, OL(undef), "undef");

utest.equal(659, OL("\t\tabc\nxyz"), "'→→abc▼xyz'");

utest.equal(660, OL({
  a: 1,
  b: 'xyz'
}), '{"a":1,"b":"xyz"}');

// ---------------------------------------------------------------------------
utest.equal(664, CWS(`a utest
error message`), "a utest error message");

// ---------------------------------------------------------------------------
// test isRegExp()
utest.truthy(672, isRegExp(/^abc$/));

utest.truthy(673, isRegExp(/^\s*where\s+areyou$/));

utest.falsy(679, isRegExp(42));

utest.falsy(680, isRegExp('abc'));

utest.falsy(681, isRegExp([1, 'a']));

utest.falsy(682, isRegExp({
  a: 1,
  b: 'ccc'
}));

utest.falsy(683, isRegExp(undef));

utest.truthy(685, isRegExp(/\.coffee/));

// ---------------------------------------------------------------------------
utest.equal(689, extractMatches("..3 and 4 plus 5", /\d+/g, parseInt), [3, 4, 5]);

utest.equal(691, extractMatches("And This Is A String", /A/g), ['A', 'A']);

// ---------------------------------------------------------------------------
utest.truthy(695, notdefined(undef));

utest.truthy(696, notdefined(null));

utest.truthy(697, defined(''));

utest.truthy(698, defined(5));

utest.truthy(699, defined([]));

utest.truthy(700, defined({}));

utest.falsy(702, defined(undef));

utest.falsy(703, defined(null));

utest.falsy(704, notdefined(''));

utest.falsy(705, notdefined(5));

utest.falsy(706, notdefined([]));

utest.falsy(707, notdefined({}));

// ---------------------------------------------------------------------------
utest.truthy(711, isIterable([]));

utest.truthy(712, isIterable(['a', 'b']));

gen = function*() {
  yield 1;
  yield 2;
  yield 3;
};

utest.truthy(720, isIterable(gen()));

// ---------------------------------------------------------------------------
(function() {
  var MyClass;
  MyClass = class MyClass {
    constructor(str) {
      this.mystr = str;
    }

  };
  return utest.equal(729, className(MyClass), 'MyClass');
})();

// ---------------------------------------------------------------------------
utest.equal(735, getOptions('a b c'), {
  'a': true,
  'b': true,
  'c': true
});

utest.equal(736, getOptions('abc'), {
  'abc': true
});

utest.equal(737, getOptions({
  'a': true,
  'b': false,
  'c': 42
}), {
  'a': true,
  'b': false,
  'c': 42
});

utest.equal(738, getOptions(), {});

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
  return utest.equal(753, lResult, ['ABC', 'DEF', 'GHI']);
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
  return utest.equal(769, lResult, ['ABC', 'DEF']);
})();

(() => {
  var item, lResult;
  lResult = [];
  item = ['abc', 'def', 'ghi'];
  forEachLine(item, (line) => {
    lResult.push(line.toUpperCase());
    return false;
  });
  return utest.equal(778, lResult, ['ABC', 'DEF', 'GHI']);
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
  return utest.equal(790, lResult, ['ABC', 'DEF']);
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
  return utest.equal(802, lResult, ['1 ABC def', '2 DEF ghi']);
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
  return utest.equal(816, newblock, `ABC
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
  return utest.equal(834, newblock, `ABC
GHI`);
})();

(() => {
  var item, newblock;
  item = ['abc', 'def', 'ghi'];
  newblock = mapEachLine(item, (line) => {
    return line.toUpperCase();
  });
  return utest.equal(844, newblock, ['ABC', 'DEF', 'GHI']);
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
  return utest.equal(858, newblock, ['ABC', 'GHI']);
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
  return utest.equal(873, newblock, ['1 ABC def', '3 GHI']);
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
  return utest.equal(899, removeKeys(hAST, ['start', 'end']), {
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
  return utest.equal(930, removeKeys(hAST, ['start', 'end']), {
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
  utest.equal(970, hToDo.task, 'go shopping');
  utest.equal(971, h.task, 'GO SHOPPING');
  h.task = 'do something';
  utest.equal(974, hToDo.task, 'do something');
  utest.equal(975, h.task, 'DO SOMETHING');
  h.task = 'nothing';
  utest.equal(978, hToDo.task, 'do something');
  return utest.equal(979, h.task, 'DO SOMETHING');
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
  return utest.equal(1000, (await run1()), 'abc,def,ghi');
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
  return utest.equal(1017, (await run2()), 'def,ghi');
})();

// ---------------------------------------------------------------------------
// test eachCharInString()
utest.truthy(1023, eachCharInString('ABC', (ch) => {
  return ch === ch.toUpperCase();
}));

utest.falsy(1024, eachCharInString('abc', (ch) => {
  return ch === ch.toUpperCase();
}));

utest.falsy(1025, eachCharInString('AbC', (ch) => {
  return ch === ch.toUpperCase();
}));

// ---------------------------------------------------------------------------
// test runCmd()
utest.equal(1030, runCmd("echo abc"), "abc\r\n");

utest.equal(1031, runCmd("noSuchCmd"), undef);

// ---------------------------------------------------------------------------
// test choose()
lItems = ['apple', 'orange', 'pear'];

utest.truthy(1037, lItems.includes(choose(lItems)));

utest.truthy(1038, lItems.includes(choose(lItems)));

utest.truthy(1039, lItems.includes(choose(lItems)));

// ---------------------------------------------------------------------------
// test shuffle()
lShuffled = deepCopy(lItems);

shuffle(lShuffled);

utest.truthy(1046, lShuffled.includes('apple'));

utest.truthy(1047, lShuffled.includes('orange'));

utest.truthy(1048, lShuffled.includes('pear'));

utest.truthy(1049, lShuffled.length === lItems.length);

// ---------------------------------------------------------------------------
// test some date functions
dateStr = '2023-01-01 05:00:00';

utest.equal(1055, timestamp(dateStr), "1/1/2023 5:00:00 AM");

utest.equal(1056, msSinceEpoch(dateStr), 1672567200000);

utest.equal(1057, formatDate(dateStr), "Jan 1, 2023");

// ---------------------------------------------------------------------------
// test pad()
utest.equal(1063, pad(23, 5), "   23");

utest.equal(1064, pad(23, 5, 'justify=left'), '23   ');

utest.equal(1065, pad('abc', 6), 'abc   ');

utest.equal(1066, pad('abc', 6, 'justify=center'), ' abc  ');

utest.equal(1067, pad(true, 3), 'true');

utest.equal(1068, pad(false, 3, 'truncate'), 'fal');

// ---------------------------------------------------------------------------
// test keys(), hasKey(), hasAllKeys(), hasAnyKey(), subkeys()
h = {
  '2023-Nov': {
    Dining: {
      amt: 200
    },
    Hardware: {
      amt: 50
    }
  },
  '2023-Dec': {
    Dining: {
      amt: 300
    },
    Insurance: {
      amt: 150
    }
  }
};

utest.equal(1092, keys(h), ['2023-Nov', '2023-Dec']);

utest.truthy(1093, hasKey(h, '2023-Nov'));

utest.falsy(1094, hasKey(h, '2023-Oct'));

utest.equal(1095, subkeys(h), ['Dining', 'Hardware', 'Insurance']);

utest.truthy(1097, hasAllKeys(h, '2023-Nov', '2023-Dec'));

utest.truthy(1098, hasAllKeys(h, '2023-Nov'));

utest.falsy(1099, hasAllKeys(h, '2023-Oct', '2023-Nov', '2023-Dec'));

utest.truthy(1101, hasAnyKey(h, '2023-Oct', '2023-Nov', '2023-Dec'));

utest.truthy(1102, hasAnyKey(h, '2023-Oct', '2023-Nov'));

utest.falsy(1103, hasAnyKey(h, '2023-Jan', '2023-Feb', '2023-Mar'));

//# sourceMappingURL=base-utils.test.js.map
