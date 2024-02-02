// base-utils.test.coffee
var a, b, c, d, dateStr, e, fourSpaces, gen, h, hEsc, hProc, lItems, lShuffled, passTest, threeSpaces;

import {
  u,
  UnitTester
} from '@jdeighan/base-utils/utest';

import {
  undef,
  pass,
  defined,
  notdefined,
  alldefined,
  ll_assert,
  ll_croak,
  spaces,
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
  pad,
  forEachItem,
  addToHash,
  chomp
} from '@jdeighan/base-utils';

import {
  assert
} from '@jdeighan/base-utils/exceptions';

u.equal(undef, void 0);

u.succeeds(function() {
  return pass();
});

u.truthy(pass());

u.truthy(defined(1));

u.falsy(defined(void 0));

u.truthy(notdefined(void 0));

u.falsy(notdefined(12));

u.succeeds(() => {
  return pass();
});

u.succeeds(() => {
  return assert(12 === 12, "BAD");
});

// ---------------------------------------------------------------------------
u.truthy(isEmpty(''));

u.truthy(isEmpty('  \t\t'));

u.truthy(isEmpty([]));

u.truthy(isEmpty({}));

u.truthy(nonEmpty('a'));

u.truthy(nonEmpty('.'));

u.truthy(nonEmpty([2]));

u.truthy(nonEmpty({
  width: 2
}));

// ---------------------------------------------------------------------------
a = undef;

b = null;

c = 42;

d = 'dog';

e = {
  a: 42
};

u.truthy(alldefined(c, d, e));

u.falsy(alldefined(a, b, c, d, e));

u.falsy(alldefined(a, c, d, e));

u.falsy(alldefined(b, c, d, e));

u.equal(deepCopy(e), {
  a: 42
});

// ---------------------------------------------------------------------------
u.equal({
  a: 1,
  b: 2
}, {
  a: 1,
  b: 2
});

u.notequal({
  a: 1,
  b: 2
}, {
  a: 1,
  b: 3
});

// ---------------------------------------------------------------------------
u.truthy(isHashComment('   # something'));

u.truthy(isHashComment('   #'));

u.falsy(isHashComment('   abc'));

u.falsy(isHashComment('#abc'));

u.truthy(isFunction(pass));

passTest = () => {
  return pass();
};

u.succeeds(passTest);

u.truthy(defined(''));

u.truthy(defined(5));

u.truthy(defined([]));

u.truthy(defined({}));

u.falsy(defined(undef));

u.falsy(defined(null));

u.truthy(notdefined(undef));

u.truthy(notdefined(null));

u.falsy(notdefined(''));

u.falsy(notdefined(5));

u.falsy(notdefined([]));

u.falsy(notdefined({}));

// ---------------------------------------------------------------------------
u.equal(splitPrefix("abc"), ["", "abc"]);

u.equal(splitPrefix("\tabc"), ["\t", "abc"]);

u.equal(splitPrefix("\t\tabc"), ["\t\t", "abc"]);

u.equal(splitPrefix(""), ["", ""]);

u.equal(splitPrefix("\t\t\t"), ["", ""]);

u.equal(splitPrefix("\t \t"), ["", ""]);

u.equal(splitPrefix("   "), ["", ""]);

// ---------------------------------------------------------------------------
u.falsy(hasPrefix("abc"));

u.truthy(hasPrefix("   abc"));

// ---------------------------------------------------------------------------
threeSpaces = spaces(3);

fourSpaces = spaces(4);

u.equal(tabify(`first line
${threeSpaces}second line
${threeSpaces}${threeSpaces}third line`, 3), `first line
\tsecond line
\t\tthird line`);

// ---------------------------------------------------------------------------
// you don't need to tell it number of spaces
// it knows from the 1st line that contains spaces
u.equal(tabify(`first line
${threeSpaces}second line
${threeSpaces}${threeSpaces}third line`), `first line
\tsecond line
\t\tthird line`);

u.equal(tabify(`first line
${fourSpaces}second line
${fourSpaces}${fourSpaces}third line`), `first line
\tsecond line
\t\tthird line`);

// ---------------------------------------------------------------------------
u.equal(untabify(`first line
\tsecond line
\t\tthird line`, 3), `first line
${threeSpaces}second line
${threeSpaces}${threeSpaces}third line`);

// ---------------------------------------------------------------------------
u.equal(untabify(`first line
\tsecond line
\t\tthird line`, 4), `first line
${fourSpaces}second line
${fourSpaces}${fourSpaces}third line`);

// ---------------------------------------------------------------------------
u.equal(prefixBlock(`abc
def`, '--'), `--abc
--def`);

// ---------------------------------------------------------------------------
u.equal(escapeStr("   XXX\n"), "˳˳˳XXX®");

u.equal(escapeStr("\t ABC\n"), "→˳ABC®");

u.equal(escapeStr("X\nX\nX\n"), "X®X®X®");

u.equal(escapeStr("XXX\n\t\t"), "XXX®→→");

u.equal(escapeStr("XXX\n  "), "XXX®˳˳");

(() => {
  var t;
  t = new UnitTester();
  t.transformValue = (str) => {
    return escapeStr(str);
  };
  t.equal("   XXX\n", "˳˳˳XXX®");
  t.equal("\t ABC\n", "→˳ABC®");
  t.equal("X\nX\nX\n", "X®X®X®");
  t.equal("XXX\n\t\t", "XXX®→→");
  return t.equal("XXX\n  ", "XXX®˳˳");
})();

hEsc = {
  "\n": "\\n",
  "\t": "\\t",
  "\"": "\\\""
};

u.equal(escapeStr("\thas quote: \"\nnext line", hEsc), "\\thas quote: \\\"\\nnext line");

// ---------------------------------------------------------------------------
u.equal(OL(undef), "undef");

u.equal(OL("\t\tabc\nxyz"), "'→→abc®xyz'");

u.equal(OL({
  a: 1,
  b: 'xyz'
}), '{"a":1,"b":"xyz"}');

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

u.equal(OL(hProc), '{"code":"[Function: code]","html":"[Function: html]","Script":"[Function: Script]"}');

// ---------------------------------------------------------------------------
u.equal(OLS(['abc', 3]), "'abc',3");

u.equal(OLS([]), "");

u.equal(OLS([
  undef,
  {
    a: 1
  }
]), 'undef,{"a":1}');

// ---------------------------------------------------------------------------
u.truthy(oneof('a', 'b', 'a', 'c'));

u.falsy(oneof('a', 'b', 'c'));

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
  u.falsy(isString(undef));
  u.falsy(isString(h));
  u.falsy(isString(l));
  u.falsy(isString(o));
  u.falsy(isString(n));
  u.falsy(isString(n2));
  u.truthy(isString(s));
  u.truthy(isString(s2));
  u.truthy(isNonEmptyString('abc'));
  u.truthy(isNonEmptyString('abc def'));
  u.falsy(isNonEmptyString(''));
  u.falsy(isNonEmptyString('  '));
  u.truthy(isIdentifier('abc'));
  u.truthy(isIdentifier('_Abc'));
  u.falsy(isIdentifier('abc def'));
  u.falsy(isIdentifier('abc-def'));
  u.falsy(isIdentifier('class.method'));
  u.truthy(isFunctionName('abc'));
  u.truthy(isFunctionName('_Abc'));
  u.falsy(isFunctionName('abc def'));
  u.falsy(isFunctionName('abc-def'));
  u.falsy(isFunctionName('D()'));
  u.truthy(isFunctionName('class.method'));
  generatorFunc = function*() {
    yield 1;
    yield 2;
    yield 3;
  };
  u.truthy(isIterable(generatorFunc()));
  u.falsy(isNumber(undef));
  u.falsy(isNumber(null));
  u.truthy(isNumber(0/0));
  u.falsy(isNumber(h));
  u.falsy(isNumber(l));
  u.falsy(isNumber(o));
  u.truthy(isNumber(n));
  u.truthy(isNumber(n2));
  u.falsy(isNumber(s));
  u.falsy(isNumber(s2));
  u.truthy(isNumber(42.0, {
    min: 42.0
  }));
  u.falsy(isNumber(42.0, {
    min: 42.1
  }));
  u.truthy(isNumber(42.0, {
    max: 42.0
  }));
  u.falsy(isNumber(42.0, {
    max: 41.9
  }));
  u.truthy(isInteger(42));
  u.truthy(isInteger(new Number(42)));
  u.falsy(isInteger('abc'));
  u.falsy(isInteger({}));
  u.falsy(isInteger([]));
  u.truthy(isInteger(42, {
    min: 0
  }));
  u.falsy(isInteger(42, {
    min: 50
  }));
  u.truthy(isInteger(42, {
    max: 50
  }));
  u.falsy(isInteger(42, {
    max: 0
  }));
  u.truthy(isHash(h));
  u.falsy(isHash(l));
  u.falsy(isHash(o));
  u.falsy(isHash(n));
  u.falsy(isHash(n2));
  u.falsy(isHash(s));
  u.falsy(isHash(s2));
  u.falsy(isArray(h));
  u.truthy(isArray(l));
  u.falsy(isArray(o));
  u.falsy(isArray(n));
  u.falsy(isArray(n2));
  u.falsy(isArray(s));
  u.falsy(isArray(s2));
  u.truthy(isBoolean(true));
  u.truthy(isBoolean(false));
  u.falsy(isBoolean(42));
  u.falsy(isBoolean("true"));
  u.truthy(isClass(NewClass));
  u.falsy(isClass(o));
  u.truthy(isConstructor(NewClass));
  u.falsy(isConstructor(o));
  u.truthy(isFunction(function() {
    return 42;
  }));
  u.truthy(isFunction(() => {
    return 42;
  }));
  u.falsy(isFunction(undef));
  u.falsy(isFunction(null));
  u.falsy(isFunction(42));
  u.falsy(isFunction(n));
  u.truthy(isRegExp(/^abc$/));
  u.truthy(isRegExp(/^\s*where\s+areyou$/));
  u.falsy(isRegExp(42));
  u.falsy(isRegExp('abc'));
  u.falsy(isRegExp([1, 'a']));
  u.falsy(isRegExp({
    a: 1,
    b: 'ccc'
  }));
  u.falsy(isRegExp(undef));
  u.truthy(isRegExp(/\.coffee/));
  u.falsy(isObject(h));
  u.falsy(isObject(l));
  u.truthy(isObject(o));
  u.truthy(isObject(o, ['name', 'doIt']));
  u.truthy(isObject(o, "name doIt"));
  u.falsy(isObject(o, ['name', 'doIt', 'missing']));
  u.falsy(isObject(o, "name doIt missing"));
  u.falsy(isObject(n));
  u.falsy(isObject(n2));
  u.falsy(isObject(s));
  u.falsy(isObject(s2));
  u.truthy(isObject(o, "name doIt"));
  u.truthy(isObject(o, "name doIt meth"));
  u.truthy(isObject(o, "name &doIt &meth"));
  u.falsy(isObject(o, "&name"));
  u.equal(jsType(undef), [undef, undef]);
  u.equal(jsType(null), [undef, 'null']);
  u.equal(jsType(s), ['string', undef]);
  u.equal(jsType(''), ['string', 'empty']);
  u.equal(jsType("\t\t"), ['string', 'empty']);
  u.equal(jsType("  "), ['string', 'empty']);
  u.equal(jsType(h), ['hash', undef]);
  u.equal(jsType({}), ['hash', 'empty']);
  u.equal(jsType(3.14159), ['number', undef]);
  u.equal(jsType(42), ['number', 'integer']);
  u.equal(jsType(true), ['boolean', undef]);
  u.equal(jsType(false), ['boolean', undef]);
  u.equal(jsType(h), ['hash', undef]);
  u.equal(jsType({}), ['hash', 'empty']);
  u.equal(jsType(l), ['array', undef]);
  u.equal(jsType([]), ['array', 'empty']);
  u.equal(jsType(/abc/), ['regexp', undef]);
  func1 = function(x) {};
  func2 = (x) => {};
  // --- NOTE: regular functions can't be distinguished from constructors
  u.equal(jsType(func1), ['class', undef]);
  u.equal(jsType(func2), ['function', undef]);
  u.equal(jsType(NewClass), ['class', undef]);
  return u.equal(jsType(o), ['object', undef]);
})();

// ---------------------------------------------------------------------------
u.equal(blockToArray(undef), []);

u.equal(blockToArray(''), []);

u.equal(blockToArray('a'), ['a']);

u.equal(blockToArray("a\nb"), ['a', 'b']);

u.equal(blockToArray("a\r\nb"), ['a', 'b']);

u.equal(blockToArray("abc\nxyz"), ['abc', 'xyz']);

u.equal(blockToArray("abc\nxyz"), ['abc', 'xyz']);

u.equal(blockToArray("abc\n\nxyz"), ['abc', '', 'xyz']);

// ---------------------------------------------------------------------------
u.equal(toArray("abc\ndef"), ['abc', 'def']);

u.equal(toArray(['a', 'b']), ['a', 'b']);

u.equal(toArray(["a\nb", "c\nd"]), ['a', 'b', 'c', 'd']);

// ---------------------------------------------------------------------------
u.equal(arrayToBlock(undef), '');

u.equal(arrayToBlock([]), '');

u.equal(arrayToBlock([undef]), '');

u.equal(arrayToBlock(['a  ', 'b\t\t']), "a\nb");

u.equal(arrayToBlock(['a', 'b', 'c']), "a\nb\nc");

u.equal(arrayToBlock(['a', undef, 'b', 'c']), "a\nb\nc");

u.equal(arrayToBlock([undef, 'a', 'b', 'c', undef]), "a\nb\nc");

// ---------------------------------------------------------------------------
u.equal(toBlock(['abc', 'def']), "abc\ndef");

u.equal(toBlock("abc\ndef"), "abc\ndef");

// ---------------------------------------------------------------------------
u.equal(rtrim("abc"), "abc");

u.equal(rtrim("  abc"), "  abc");

u.equal(rtrim("abc  "), "abc");

u.equal(rtrim("  abc  "), "  abc");

// ---------------------------------------------------------------------------
u.equal(words(''), []);

u.equal(words('  \t\t'), []);

u.equal(words('a b c'), ['a', 'b', 'c']);

u.equal(words('  a   b   c  '), ['a', 'b', 'c']);

u.equal(words('a b', 'c d'), ['a', 'b', 'c', 'd']);

u.equal(words(' my word ', ' is  word  '), ['my', 'word', 'is', 'word']);

u.truthy(hasChar('abc', 'b'));

u.falsy(hasChar('abc', 'x'));

u.falsy(hasChar("\t\t", ' '));

// ---------------------------------------------------------------------------
u.equal(quoted('abc'), "'abc'");

u.equal(quoted('"abc"'), "'\"abc\"'");

u.equal(quoted("'abc'"), "\"'abc'\"");

u.equal(quoted("'\"abc\"'"), "<'\"abc\"'>");

u.equal(quoted("'\"<abc>\"'"), "<'\"<abc>\"'>");

// ---------------------------------------------------------------------------
u.equal(getOptions(), {});

u.equal(getOptions(undef, {
  x: 1
}), {
  x: 1
});

u.equal(getOptions({
  x: 1
}, {
  x: 3,
  y: 4
}), {
  x: 1,
  y: 4
});

u.equal(getOptions('asText'), {
  asText: true
});

u.equal(getOptions('!binary'), {
  binary: false
});

u.equal(getOptions('label=this'), {
  label: 'this'
});

u.equal(getOptions('width=42'), {
  width: 42
});

u.equal(getOptions('asText !binary label=this'), {
  asText: true,
  binary: false,
  label: 'this'
});

// ---------------------------------------------------------------------------
u.equal(range(3), [0, 1, 2]);

u.equal(rev_range(3), [2, 1, 0]);

// ---------------------------------------------------------------------------
u.truthy(isHashComment('#'));

u.truthy(isHashComment('# a comment'));

u.truthy(isHashComment('#\ta comment'));

u.falsy(isHashComment('#comment'));

u.falsy(isHashComment(''));

u.falsy(isHashComment('a comment'));

// ---------------------------------------------------------------------------
u.truthy(isEmpty(''));

u.truthy(isEmpty('  \t\t'));

u.truthy(isEmpty([]));

u.truthy(isEmpty({}));

u.truthy(nonEmpty('a'));

u.truthy(nonEmpty('.'));

u.truthy(nonEmpty([2]));

u.truthy(nonEmpty({
  width: 2
}));

u.truthy(isNonEmptyString('abc'));

u.falsy(isNonEmptyString(undef));

u.falsy(isNonEmptyString(''));

u.falsy(isNonEmptyString('   '));

u.falsy(isNonEmptyString("\t\t\t"));

u.falsy(isNonEmptyString(5));

// ---------------------------------------------------------------------------
u.truthy(oneof('a', 'a', 'b', 'c'));

u.truthy(oneof('b', 'a', 'b', 'c'));

u.truthy(oneof('c', 'a', 'b', 'c'));

u.falsy(oneof('d', 'a', 'b', 'c'));

u.falsy(oneof('x'));

// ---------------------------------------------------------------------------
u.equal(uniq([1, 2, 2, 3, 3]), [1, 2, 3]);

u.equal(uniq(['a', 'b', 'b', 'c', 'c']), ['a', 'b', 'c']);

// ---------------------------------------------------------------------------
u.equal(rtrim("abc"), "abc");

u.equal(rtrim("  abc"), "  abc");

u.equal(rtrim("abc  "), "abc");

u.equal(rtrim("  abc  "), "  abc");

// ---------------------------------------------------------------------------
u.equal(words('a b c'), ['a', 'b', 'c']);

u.equal(words('  a   b   c  '), ['a', 'b', 'c']);

// ---------------------------------------------------------------------------
u.equal(escapeStr("\t\tXXX\n"), "→→XXX®");

hEsc = {
  "\n": "\\n",
  "\t": "\\t",
  "\"": "\\\""
};

u.equal(escapeStr("\thas quote: \"\nnext line", hEsc), "\\thas quote: \\\"\\nnext line");

// ---------------------------------------------------------------------------
u.equal(rtrunc('/user/lib/.env', 5), '/user/lib');

u.equal(ltrunc('abcdefg', 3), 'defg');

u.equal(CWS(`abc
def
		ghi`), "abc def ghi");

// ---------------------------------------------------------------------------
u.truthy(isArrayOfStrings([]));

u.truthy(isArrayOfStrings(['a', 'b', 'c']));

u.truthy(isArrayOfStrings(['a', undef, null, 'b']));

// ---------------------------------------------------------------------------
u.truthy(isArrayOfArrays([]));

u.truthy(isArrayOfArrays([[], []]));

u.truthy(isArrayOfArrays([[1, 2], []]));

u.truthy(isArrayOfArrays([[1, 2, [1, 2, 3]], []]));

u.truthy(isArrayOfArrays([[1, 2], undef, null, []]));

u.falsy(isArrayOfArrays({}));

u.falsy(isArrayOfArrays([1, 2, 3]));

u.falsy(isArrayOfArrays([[1, 2, [3, 4]], 4]));

u.falsy(isArrayOfArrays([
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

u.truthy(isArrayOfArrays([[1, 2], [3, 4], [4, 5]], 2));

u.falsy(isArrayOfArrays([[1, 2], [3], [4, 5]], 2));

u.falsy(isArrayOfArrays([[1, 2], [3, 4, 5], [4, 5]], 2));

// ---------------------------------------------------------------------------
u.truthy(isArrayOfHashes([]));

u.truthy(isArrayOfHashes([{}, {}]));

u.truthy(isArrayOfHashes([
  {
    a: 1,
    b: 2
  },
  {}
]));

u.truthy(isArrayOfHashes([
  {
    a: 1,
    b: 2,
    c: [1,
  2,
  3]
  },
  {}
]));

u.truthy(isArrayOfHashes([
  {
    a: 1,
    b: 2
  },
  undef,
  null,
  {}
]));

u.falsy(isArrayOfHashes({}));

u.falsy(isArrayOfHashes([1, 2, 3]));

u.falsy(isArrayOfHashes([
  {
    a: 1,
    b: 2,
    c: [1,
  2,
  3]
  },
  4
]));

u.falsy(isArrayOfHashes([
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
  s = 'u';
  s2 = new String('abc');
  u.truthy(isHash(h));
  u.falsy(isHash(l));
  u.falsy(isHash(o));
  u.falsy(isHash(n));
  u.falsy(isHash(n2));
  u.falsy(isHash(s));
  u.falsy(isHash(s2));
  u.falsy(isArray(h));
  u.truthy(isArray(l));
  u.falsy(isArray(o));
  u.falsy(isArray(n));
  u.falsy(isArray(n2));
  u.falsy(isArray(s));
  u.falsy(isArray(s2));
  u.falsy(isString(undef));
  u.falsy(isString(h));
  u.falsy(isString(l));
  u.falsy(isString(o));
  u.falsy(isString(n));
  u.falsy(isString(n2));
  u.truthy(isString(s));
  u.truthy(isString(s2));
  u.falsy(isObject(h));
  u.falsy(isObject(l));
  u.truthy(isObject(o));
  u.truthy(isObject(o, ['name', 'doIt']));
  u.falsy(isObject(o, ['name', 'doIt', 'missing']));
  u.falsy(isObject(n));
  u.falsy(isObject(n2));
  u.falsy(isObject(s));
  u.falsy(isObject(s2));
  u.falsy(isNumber(h));
  u.falsy(isNumber(l));
  u.falsy(isNumber(o));
  u.truthy(isNumber(n));
  u.truthy(isNumber(n2));
  u.falsy(isNumber(s));
  u.falsy(isNumber(s2));
  u.truthy(isNumber(42.0, {
    min: 42.0
  }));
  u.falsy(isNumber(42.0, {
    min: 42.1
  }));
  u.truthy(isNumber(42.0, {
    max: 42.0
  }));
  return u.falsy(isNumber(42.0, {
    max: 41.9
  }));
})();

// ---------------------------------------------------------------------------
u.truthy(isFunction(function() {
  return pass;
}));

u.falsy(isFunction(23));

u.truthy(isInteger(42));

u.truthy(isInteger(new Number(42)));

u.falsy(isInteger('abc'));

u.falsy(isInteger({}));

u.falsy(isInteger([]));

u.truthy(isInteger(42, {
  min: 0
}));

u.falsy(isInteger(42, {
  min: 50
}));

u.truthy(isInteger(42, {
  max: 50
}));

u.falsy(isInteger(42, {
  max: 0
}));

// ---------------------------------------------------------------------------
u.equal(OL(undef), "undef");

u.equal(OL("\t\tabc\nxyz"), "'→→abc®xyz'");

u.equal(OL({
  a: 1,
  b: 'xyz'
}), '{"a":1,"b":"xyz"}');

// ---------------------------------------------------------------------------
u.equal(CWS(`a u
error message`), "a u error message");

// ---------------------------------------------------------------------------
// test isRegExp()
u.truthy(isRegExp(/^abc$/));

u.truthy(isRegExp(/^\s*where\s+areyou$/));

u.falsy(isRegExp(42));

u.falsy(isRegExp('abc'));

u.falsy(isRegExp([1, 'a']));

u.falsy(isRegExp({
  a: 1,
  b: 'ccc'
}));

u.falsy(isRegExp(undef));

u.truthy(isRegExp(/\.coffee/));

// ---------------------------------------------------------------------------
u.equal(extractMatches("..3 and 4 plus 5", /\d+/g, parseInt), [3, 4, 5]);

u.equal(extractMatches("And This Is A String", /A/g), ['A', 'A']);

// ---------------------------------------------------------------------------
u.truthy(notdefined(undef));

u.truthy(notdefined(null));

u.truthy(defined(''));

u.truthy(defined(5));

u.truthy(defined([]));

u.truthy(defined({}));

u.falsy(defined(undef));

u.falsy(defined(null));

u.falsy(notdefined(''));

u.falsy(notdefined(5));

u.falsy(notdefined([]));

u.falsy(notdefined({}));

// ---------------------------------------------------------------------------
u.truthy(isIterable([]));

u.truthy(isIterable(['a', 'b']));

gen = function*() {
  yield 1;
  yield 2;
  yield 3;
};

u.truthy(isIterable(gen()));

// ---------------------------------------------------------------------------
(function() {
  var MyClass;
  MyClass = class MyClass {
    constructor(str) {
      this.mystr = str;
    }

  };
  return u.equal(className(MyClass), 'MyClass');
})();

// ---------------------------------------------------------------------------
u.equal(getOptions('a b c'), {
  'a': true,
  'b': true,
  'c': true
});

u.equal(getOptions('abc'), {
  'abc': true
});

u.equal(getOptions({
  'a': true,
  'b': false,
  'c': 42
}), {
  'a': true,
  'b': false,
  'c': 42
});

u.equal(getOptions(), {});

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
  return u.equal(lResult, ['ABC', 'DEF', 'GHI']);
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
  return u.equal(lResult, ['ABC', 'DEF']);
})();

(() => {
  var item, lResult;
  lResult = [];
  item = ['abc', 'def', 'ghi'];
  forEachLine(item, (line) => {
    lResult.push(line.toUpperCase());
    return false;
  });
  return u.equal(lResult, ['ABC', 'DEF', 'GHI']);
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
  return u.equal(lResult, ['ABC', 'DEF']);
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
  return u.equal(lResult, ['1 ABC def', '2 DEF ghi']);
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
  return u.equal(newblock, `ABC
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
  return u.equal(newblock, `ABC
GHI`);
})();

(() => {
  var item, newblock;
  item = ['abc', 'def', 'ghi'];
  newblock = mapEachLine(item, (line) => {
    return line.toUpperCase();
  });
  return u.equal(newblock, ['ABC', 'DEF', 'GHI']);
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
  return u.equal(newblock, ['ABC', 'GHI']);
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
  return u.equal(newblock, ['1 ABC def', '3 GHI']);
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
  return u.equal(removeKeys(hAST, ['start', 'end']), {
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
  return u.equal(removeKeys(hAST, ['start', 'end']), {
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
  u.equal(hToDo.task, 'go shopping');
  u.equal(h.task, 'GO SHOPPING');
  h.task = 'do something';
  u.equal(hToDo.task, 'do something');
  u.equal(h.task, 'DO SOMETHING');
  h.task = 'nothing';
  u.equal(hToDo.task, 'do something');
  return u.equal(h.task, 'DO SOMETHING');
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
  return u.equal((await run1()), 'abc,def,ghi');
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
  return u.equal((await run2()), 'def,ghi');
})();

// ---------------------------------------------------------------------------
// test eachCharInString()
u.truthy(eachCharInString('ABC', (ch) => {
  return ch === ch.toUpperCase();
}));

u.falsy(eachCharInString('abc', (ch) => {
  return ch === ch.toUpperCase();
}));

u.falsy(eachCharInString('AbC', (ch) => {
  return ch === ch.toUpperCase();
}));

// ---------------------------------------------------------------------------
// test runCmd()
u.equal(runCmd("echo abc"), "abc\r\n");

// ---------------------------------------------------------------------------
// test choose()
lItems = ['apple', 'orange', 'pear'];

u.truthy(lItems.includes(choose(lItems)));

u.truthy(lItems.includes(choose(lItems)));

u.truthy(lItems.includes(choose(lItems)));

// ---------------------------------------------------------------------------
// test shuffle()
lShuffled = deepCopy(lItems);

shuffle(lShuffled);

u.truthy(lShuffled.includes('apple'));

u.truthy(lShuffled.includes('orange'));

u.truthy(lShuffled.includes('pear'));

u.truthy(lShuffled.length === lItems.length);

// ---------------------------------------------------------------------------
// test some date functions
dateStr = '2023-01-01 05:00:00';

u.equal(timestamp(dateStr), "1/1/2023 5:00:00 AM");

u.equal(msSinceEpoch(dateStr), 1672567200000);

u.equal(formatDate(dateStr), "Jan 1, 2023");

// ---------------------------------------------------------------------------
// test pad()
u.equal(pad(23, 5), "   23");

u.equal(pad(23, 5, 'justify=left'), '23   ');

u.equal(pad('abc', 6), 'abc   ');

u.equal(pad('abc', 6, 'justify=center'), ' abc  ');

u.equal(pad(true, 3), 'true');

u.equal(pad(false, 3, 'truncate'), 'fal');

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

u.equal(keys(h), ['2023-Nov', '2023-Dec']);

u.truthy(hasKey(h, '2023-Nov'));

u.falsy(hasKey(h, '2023-Oct'));

u.equal(subkeys(h), ['Dining', 'Hardware', 'Insurance']);

u.truthy(hasAllKeys(h, '2023-Nov', '2023-Dec'));

u.truthy(hasAllKeys(h, '2023-Nov'));

u.falsy(hasAllKeys(h, '2023-Oct', '2023-Nov', '2023-Dec'));

u.truthy(hasAnyKey(h, '2023-Oct', '2023-Nov', '2023-Dec'));

u.truthy(hasAnyKey(h, '2023-Oct', '2023-Nov'));

u.falsy(hasAnyKey(h, '2023-Jan', '2023-Feb', '2023-Mar'));

// ---------------------------------------------------------------------------
u.equal(keys({
  a: 1,
  b: 2
}, {
  c: 3,
  b: 5
}), ['a', 'b', 'c']);

(() => {
  var hFeb, hJan, hMar;
  hJan = {
    Gas: 210,
    Dining: 345,
    Insurance: 910
  };
  hFeb = {
    Insurance: 450,
    Dining: 440
  };
  hMar = {
    Dining: 550,
    Gas: 200,
    Starbucks: 125
  };
  return u.equal(keys(hJan, hFeb, hMar), ['Gas', 'Dining', 'Insurance', 'Starbucks']);
})();

// ---------------------------------------------------------------------------
// --- test forEachItem()
(() => {
  var lWords, result;
  lWords = ['bridge', 'highway', 'garbage'];
  result = forEachItem(lWords, (item, h) => {
    return item;
  });
  return u.equal(result, lWords);
})();

(() => {
  var lWords, result;
  lWords = ['bridge', 'highway', 'garbage'];
  result = forEachItem(lWords, (item, h) => {
    if (item === 'highway') {
      return undef;
    } else {
      return item;
    }
  });
  return u.equal(result, ['bridge', 'garbage']);
})();

(() => {
  var lWords, result;
  lWords = ['bridge', 'highway', 'garbage'];
  result = forEachItem(lWords, (item, h) => {
    return item.toUpperCase();
  });
  return u.equal(result, ['BRIDGE', 'HIGHWAY', 'GARBAGE']);
})();

(() => {
  var lWords, result;
  lWords = ['bridge', 'highway', 'garbage'];
  result = forEachItem(lWords, (item, h) => {
    if (item === 'garbage') {
      throw 'stop';
    }
    return item;
  });
  return u.equal(result, ['bridge', 'highway']);
})();

(() => {
  var lWords, result;
  lWords = ['bridge', 'highway', 'garbage'];
  result = forEachItem(lWords, (item, h) => {
    if (h._index === 2) {
      throw 'stop';
    }
    return item;
  });
  return u.equal(result, ['bridge', 'highway']);
})();

(() => {
  var lWords;
  lWords = ['bridge', 'highway', 'garbage'];
  return u.throws(() => {
    var result;
    return result = forEachItem(lWords, (item, h) => {
      throw new Error("unknown error");
    });
  });
})();

(() => {
  var callback, countGenerator, result;
  countGenerator = function*() {
    yield 1;
    yield 2;
    yield 3;
    yield 4;
  };
  callback = (item, hContext) => {
    if (item > 2) {
      return `${hContext.label} ${item}`;
    } else {
      return undef;
    }
  };
  result = forEachItem(countGenerator(), callback, {
    label: 'X'
  });
  return u.equal(result, ['X 3', 'X 4']);
})();

// ---------------------------------------------------------------------------
(() => {
  var obj;
  obj = addToHash({}, [2024, 'Mar', 'Eat Out', 'Starbucks'], 23);
  u.equal(obj, {
    '2024': {
      Mar: {
        'Eat Out': {
          Starbucks: 23
        }
      }
    }
  });
  return u.equal(obj[2024]['Mar']['Eat Out']['Starbucks'], 23);
})();

(() => {
  var obj;
  obj = {};
  addToHash(obj, 'Mar', 23);
  return u.equal(obj, {
    Mar: 23
  });
})();

(() => {
  var obj;
  obj = {};
  addToHash(obj, 2, 23);
  return u.equal(obj, {
    '2': 23
  });
})();

// ---------------------------------------------------------------------------
// --- test chomp()
u.equal(chomp('abc'), 'abc');

u.equal(chomp('abc\n'), 'abc');

u.equal(chomp('abc\r\n'), 'abc');

//# sourceMappingURL=base-utils.test.js.map
