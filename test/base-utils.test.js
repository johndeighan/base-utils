// base-utils.test.coffee
var NewClass, a, b, c, d, dateStr, e, fourSpaces, gen, generatorFunc, hEsc, lItems, lShuffled, o, passTest, threeSpaces;

import * as ulib from '@jdeighan/base-utils/utest';

Object.assign(global, ulib);

import * as lib from '@jdeighan/base-utils';

Object.assign(global, lib);

// ---------------------------------------------------------------------------
//symbol undef - a synonym for JavaScript's undefined
equal(undef, void 0);

// ---------------------------------------------------------------------------
//symbol assert(cond, msg)

//   NOTE: There's a better assert in @jdeighan/base-utils/exceptions
succeeds(() => {
  return assert(2 + 2 === 4, "BAD");
});

fails(() => {
  return assert(2 + 3 === 4, "BAD");
});

// ---------------------------------------------------------------------------
//symbol croak(msg:string)

//   NOTE: There's a better croak in @jdeighan/base-utils/exceptions
fails(() => {
  return croak("BAD");
});

// ---------------------------------------------------------------------------
//symbol pass    - a function that does nothing
succeeds(() => {
  return pass();
});

succeeds(function() {
  return pass();
});

truthy(pass());

// ---------------------------------------------------------------------------
//symbol defined(obj: Any): boolean
truthy(defined(1));

falsy(defined(void 0));

falsy(defined(null));

// ---------------------------------------------------------------------------
//symbol notdefined(obj: Any): boolean
truthy(notdefined(void 0));

falsy(notdefined(12));

// ---------------------------------------------------------------------------
//symbol alldefined(lObj...): boolean
truthy(alldefined(13, 'abc', [], {}));

falsy(alldefined(13, 'abc', [], {}, undef));

// ---------------------------------------------------------------------------
//symbol truncateStr(str: string, maxLen: integer): string
equal(truncateStr('abc', 20), 'abc');

equal(truncateStr('abcdefg', 5), 'abcd…');

// ---------------------------------------------------------------------------
//symbol hEsc = {" ": '˳', "\t": '→', "\r": '◄', "\n": '▼'}
//symbol hEscNoNL{" ": '˳', "\t": '→'}
//symbol escapeStr(str: string, {<char>: string, ...): string
(() => {
  var hEsc1, hEsc2;
  equal(escapeStr("   XXX\n"), "˳˳˳XXX▼");
  equal(escapeStr("\t ABC\n"), "→˳ABC▼");
  equal(escapeStr("X\nX\nX\n"), "X▼X▼X▼");
  equal(escapeStr("XXX\n\t\t"), "XXX▼→→");
  equal(escapeStr("XXX\n  "), "XXX▼˳˳");
  hEsc1 = {
    "\n": "\\n",
    "\t": "\\t",
    "\"": "\\\""
  };
  equal(escapeStr("\thas quote: \"\nnext line", hEsc1), "\\thas quote: \\\"\\nnext line");
  hEsc2 = {
    "«": "\\«",
    "»": "\\»"
  };
  return equal(escapeStr("«abc»", hEsc2), "\\«abc\\»");
})();

// ---------------------------------------------------------------------------
//symbol quoted(str: string, {<sub>: <rep>, ...): string
equal(quoted('abc'), '"abc"');

equal(quoted("mary's"), '"mary\'s"');

equal(quoted("\"mary's lamb\", she said"), '«"mary\'s lamb", she said»');

equal(quoted("\"mary's «lamb»\", she said"), '«"mary\'s \\«lamb\\»", she said»');

// ---------------------------------------------------------------------------
//symbol userSetQuoteChars: boolean
//symbol lQuoteChars: array
(() => {
  return succeeds(() => {
    var result;
    setQuoteChars('<', '>');
    result = quoted('abc');
    assert(result === '<abc>', `was ${result}`);
    return resetQuoteChars();
  });
})();

// ---------------------------------------------------------------------------
//symbol setQuoteChars(start: char, end: char)
//symbol resetQuoteChars()

  // ---------------------------------------------------------------------------
//symbol OL(obj: Any): string
(() => {
  var NewClass, func1, func2, hProc, obj, promise;
  func1 = function(block) {
    return "why?";
  };
  func2 = (block) => {
    return "why?";
  };
  hProc = {
    code: func1,
    html: func2,
    Script: function(block) {
      return 'x';
    }
  };
  NewClass = class NewClass {
    constructor() {
      this.me = 'John';
    }

  };
  obj = new NewClass();
  promise = new Promise((resolve) => {
    return resolve('foo');
  });
  equal(OL(undef), "undef");
  equal(OL(null), "null");
  equal(OL(true), 'true');
  equal(OL(false), 'false');
  equal(OL(42), "42");
  equal(OL(3.14), "3.14");
  equal(OL(BigInt(42)), "«BigInt 42»");
  equal(OL(BigInt('100000000000000000000')), "«BigInt 100000000000000000000»");
  equal(OL('abc'), '"abc"');
  equal(OL({}), "{}");
  equal(OL([]), "[]");
  equal(OL({
    a: 1,
    b: "c"
  }), '{"a":1,"b":"c"}');
  equal(OL([1, "a"]), '[1,"a"]');
  equal(OL("\t\tabc\nxyz"), '"→→abc▼xyz"');
  equal(OL("  abc\nxyz"), '"˳˳abc▼xyz"');
  equal(OL({
    a: 1,
    b: 'xyz'
  }), '{"a":1,"b":"xyz"}');
  equal(OL(func1), '«Function func1»');
  equal(OL(func2), '«Function func2»');
  equal(OL(NewClass), '«Class NewClass»');
  equal(OL(promise), '«Promise»');
  equal(OL(obj), '{"me":"John"}');
  equal(OL(hProc), '{"code":«Function func1»,"html":«Function func2»,"Script":«Function Script»}');
  equal(OL({
    a: 'a b',
    b: 'a\tb'
  }), '{"a":"a˳b","b":"a→b"}');
  equal(OL(/^ab$/), '«RegExp /^ab$/»');
  equal(jsType(NewClass), ['class', 'NewClass']);
  return equal(jsType(obj), ['object', undef]);
})();

// ---------------------------------------------------------------------------
//symbol jsType - get type of a JavaScript value
(() => {
  var func1, func2;
  equal(jsType(undef), [undef, undef]);
  equal(jsType(null), [undef, 'null']);
  equal(jsType('abc'), ['string', undef]);
  equal(jsType(''), ['string', 'empty']);
  equal(jsType("\t\t"), ['string', 'empty']);
  equal(jsType("  "), ['string', 'empty']);
  equal(jsType({
    a: 1
  }), ['hash', undef]);
  equal(jsType({}), ['hash', 'empty']);
  equal(jsType(3.14159), ['number', undef]);
  equal(jsType(42), ['number', 'integer']);
  equal(jsType(true), ['boolean', undef]);
  equal(jsType(false), ['boolean', undef]);
  equal(jsType({}), ['hash', 'empty']);
  equal(jsType([1, 2]), ['array', undef]);
  equal(jsType([]), ['array', 'empty']);
  equal(jsType(/abc/), ['regexp', undef]);
  func1 = function(x) {};
  func2 = (x) => {};
  equal(jsType(func1), ['function', 'func1']);
  equal(jsType(function() {
    return 42;
  }), ['function', undef]);
  equal(jsType(func2), ['function', 'func2']);
  return equal(jsType(() => {
    return 42;
  }), ['function', undef]);
})();

// ---------------------------------------------------------------------------
truthy(deepEqual({
  a: 1,
  b: 2
}, {
  a: 1,
  b: 2
}));

falsy(deepEqual({
  a: 1,
  b: 2
}, {
  a: 1,
  b: 3
}));

// ---------------------------------------------------------------------------
truthy(isEmpty(''));

truthy(isEmpty('  \t\t'));

truthy(isEmpty([]));

truthy(isEmpty({}));

truthy(nonEmpty('a'));

truthy(nonEmpty('.'));

truthy(nonEmpty([2]));

truthy(nonEmpty({
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

truthy(alldefined(c, d, e));

falsy(alldefined(a, b, c, d, e));

falsy(alldefined(a, c, d, e));

falsy(alldefined(b, c, d, e));

equal(deepCopy(e), {
  a: 42
});

// ---------------------------------------------------------------------------
equal({
  a: 1,
  b: 2
}, {
  a: 1,
  b: 2
});

notequal({
  a: 1,
  b: 2
}, {
  a: 1,
  b: 3
});

// ---------------------------------------------------------------------------
truthy(isHashComment('   # something'));

truthy(isHashComment('   #'));

falsy(isHashComment('   abc'));

falsy(isHashComment('#abc'));

truthy(isFunction(pass));

passTest = () => {
  return pass();
};

succeeds(passTest);

truthy(defined(''));

truthy(defined(5));

truthy(defined([]));

truthy(defined({}));

falsy(defined(undef));

falsy(defined(null));

truthy(notdefined(undef));

truthy(notdefined(null));

falsy(notdefined(''));

falsy(notdefined(5));

falsy(notdefined([]));

falsy(notdefined({}));

// ---------------------------------------------------------------------------
equal(splitPrefix("abc"), ["", "abc"]);

equal(splitPrefix("\tabc"), ["\t", "abc"]);

equal(splitPrefix("\t\tabc"), ["\t\t", "abc"]);

equal(splitPrefix(""), ["", ""]);

equal(splitPrefix("\t\t\t"), ["", ""]);

equal(splitPrefix("\t \t"), ["", ""]);

equal(splitPrefix("   "), ["", ""]);

// ---------------------------------------------------------------------------
//symbol hasPrefix
falsy(hasPrefix("abc"));

truthy(hasPrefix("   abc"));

// ---------------------------------------------------------------------------
//symbol spaces
equal(spaces(3), '   ');

// ---------------------------------------------------------------------------
//symbol tabs
equal(tabs(3), "\t\t\t");

// ---------------------------------------------------------------------------
//symbol centeredText
equal(centeredText('abc', 7), '  abc  ');

equal(centeredText('xyz', 11, 'char=-'), '--  xyz  --');

// ---------------------------------------------------------------------------
//symbol delimitBlock
equal(delimitBlock(`some text
without context`, 'label=BLOCK width=20'), `-----  BLOCK  ------
some text
without context
--------------------`);

// ---------------------------------------------------------------------------
threeSpaces = spaces(3);

fourSpaces = spaces(4);

equal(tabify(`first line
${threeSpaces}second line
${threeSpaces}${threeSpaces}third line`, 3), `first line
\tsecond line
\t\tthird line`);

// ---------------------------------------------------------------------------
// you don't need to tell it number of spaces
// it knows from the 1st line that contains spaces
equal(tabify(`first line
${threeSpaces}second line
${threeSpaces}${threeSpaces}third line`), `first line
\tsecond line
\t\tthird line`);

equal(tabify(`first line
${fourSpaces}second line
${fourSpaces}${fourSpaces}third line`), `first line
\tsecond line
\t\tthird line`);

// ---------------------------------------------------------------------------
equal(untabify(`first line
\tsecond line
\t\tthird line`, 3), `first line
${threeSpaces}second line
${threeSpaces}${threeSpaces}third line`);

// ---------------------------------------------------------------------------
equal(untabify(`first line
\tsecond line
\t\tthird line`, 4), `first line
${fourSpaces}second line
${fourSpaces}${fourSpaces}third line`);

// ---------------------------------------------------------------------------
equal(prefixBlock(`abc
def`, '--'), `--abc
--def`);

// ---------------------------------------------------------------------------
equal(escapeStr("   XXX\n"), "˳˳˳XXX▼");

equal(escapeStr("\t ABC\n"), "→˳ABC▼");

equal(escapeStr("X\nX\nX\n"), "X▼X▼X▼");

equal(escapeStr("XXX\n\t\t"), "XXX▼→→");

equal(escapeStr("XXX\n  "), "XXX▼˳˳");

(() => {
  var t;
  t = new UnitTester();
  t.transformValue = (str) => {
    return escapeStr(str);
  };
  t.equal("   XXX\n", "˳˳˳XXX▼");
  t.equal("\t ABC\n", "→˳ABC▼");
  t.equal("X\nX\nX\n", "X▼X▼X▼");
  t.equal("XXX\n\t\t", "XXX▼→→");
  return t.equal("XXX\n  ", "XXX▼˳˳");
})();

hEsc = {
  "\n": "\\n",
  "\t": "\\t",
  "\"": "\\\""
};

equal(escapeStr("\thas quote: \"\nnext line", hEsc), "\\thas quote: \\\"\\nnext line");

// ---------------------------------------------------------------------------
equal(OLS(['abc', 3]), '"abc",3');

equal(OLS([]), "");

equal(OLS([
  undef,
  {
    a: 1
  }
]), 'undef,{"a":1}');

// ---------------------------------------------------------------------------
truthy(oneof('a', 'b', 'a', 'c'));

falsy(oneof('a', 'b', 'c'));

// ---------------------------------------------------------------------------
// define some things for later tests
NewClass = class NewClass {
  constructor(name = 'bob') {
    this.name = name;
    this.doIt = pass;
  }

  meth(x) {
    return 2 * x;
  }

};

o = new NewClass();

generatorFunc = function*() {
  yield 1;
  yield 2;
  yield 3;
};

// ---------------------------------------------------------------------------
//symbol isBoolean(x:Any): boolean
(() => {
  truthy(isBoolean(true));
  truthy(isBoolean(false));
  falsy(isBoolean(42));
  return falsy(isBoolean("true"));
})();

// ---------------------------------------------------------------------------
//symbol isString(x:Any): boolean
(() => {
  truthy(isString(''));
  truthy(isString('simple'));
  truthy(isString(new String('abc')));
  falsy(isString(undef));
  falsy(isString({
    a: 1
  }));
  falsy(isString([1, 2]));
  falsy(isString(new NewClass()));
  falsy(isString(42));
  return falsy(isString(3.14));
})();

// ---------------------------------------------------------------------------
//symbol isNonEmptyString(x:Any): boolean
(() => {
  truthy(isNonEmptyString('abc'));
  truthy(isNonEmptyString('abc def'));
  truthy(isNonEmptyString('  abc def'));
  falsy(isNonEmptyString(''));
  falsy(isNonEmptyString('  '));
  falsy(isNonEmptyString("\t\t\t"));
  falsy(isNonEmptyString(undef));
  falsy(isNonEmptyString(5));
  falsy(isNonEmptyString({
    a: 1
  }));
  return falsy(isNonEmptyString([1, 2]));
})();

// ---------------------------------------------------------------------------
//symbol isNumber(x:Any): boolean
(() => {
  truthy(isNumber(42));
  truthy(isNumber(3.14));
  truthy(isNumber(new Number(42)));
  truthy(isNumber(0/0));
  truthy(isNumber(42.0, {
    min: 42.0
  }));
  truthy(isNumber(42.0, {
    max: 42.0
  }));
  falsy(isNumber(undef));
  falsy(isNumber(null));
  falsy(isNumber({
    a: 1
  }));
  falsy(isNumber([1, 2]));
  falsy(isNumber(new NewClass()));
  falsy(isNumber('abc'));
  falsy(isNumber('13'));
  falsy(isNumber(42.0, {
    min: 42.1
  }));
  return falsy(isNumber(42.0, {
    max: 41.9
  }));
})();

// ---------------------------------------------------------------------------
//symbol isNumber(x:Any): boolean
(() => {
  truthy(isInteger(42));
  truthy(isInteger(new Number(42)));
  truthy(isInteger(42, {
    min: 0
  }));
  truthy(isInteger(42, {
    max: 50
  }));
  falsy(isInteger('abc'));
  falsy(isInteger({}));
  falsy(isInteger([]));
  falsy(isInteger(42, {
    min: 50
  }));
  return falsy(isInteger(42, {
    max: 0
  }));
})();

// ---------------------------------------------------------------------------
//symbol isHash(x:Any): boolean
(() => {
  truthy(isHash({}));
  truthy(isHash({
    a: 1
  }));
  falsy(isHash([1, 2]));
  falsy(isHash(new NewClass()));
  falsy(isHash(42));
  falsy(isHash(3.14));
  falsy(isHash('abc'));
  return falsy(isHash(new String('abc')));
})();

// ---------------------------------------------------------------------------
//symbol isArray(x:Any): boolean
(() => {
  truthy(isArray([]));
  truthy(isArray([1, 2]));
  falsy(isArray({
    a: 1
  }));
  falsy(isArray(new NewClass()));
  falsy(isArray(42));
  falsy(isArray(3.14));
  falsy(isArray('abc'));
  return falsy(isArray(new String('abc')));
})();

// ---------------------------------------------------------------------------
(() => {
  truthy(isIdentifier('abc'));
  truthy(isIdentifier('_Abc'));
  falsy(isIdentifier('abc def'));
  falsy(isIdentifier('abc-def'));
  falsy(isIdentifier('class.method'));
  truthy(isFunctionName('abc'));
  truthy(isFunctionName('_Abc'));
  falsy(isFunctionName('abc def'));
  falsy(isFunctionName('abc-def'));
  falsy(isFunctionName('D()'));
  truthy(isFunctionName('class.method'));
  truthy(isIterable(generatorFunc()));
  truthy(isClass(NewClass));
  falsy(isClass(o));
  truthy(isConstructor(NewClass));
  falsy(isConstructor(o));
  truthy(isFunction(function() {
    return 42;
  }));
  truthy(isFunction(() => {
    return 42;
  }));
  falsy(isFunction(undef));
  falsy(isFunction(null));
  falsy(isFunction(42));
  falsy(isFunction(3.14));
  truthy(isRegExp(/^abc$/));
  truthy(isRegExp(/^\s*where\s+areyou$/));
  falsy(isRegExp(42));
  falsy(isRegExp('abc'));
  falsy(isRegExp([1, 'a']));
  falsy(isRegExp({
    a: 1,
    b: 'ccc'
  }));
  falsy(isRegExp(undef));
  truthy(isRegExp(/\.coffee/));
  falsy(isObject({
    a: 1
  }));
  falsy(isObject([1, 2]));
  truthy(isObject(o));
  truthy(isObject(o, ['name', 'doIt']));
  truthy(isObject(o, "name doIt"));
  falsy(isObject(o, ['name', 'doIt', 'missing']));
  falsy(isObject(o, "name doIt missing"));
  falsy(isObject(42));
  falsy(isObject(3.14));
  falsy(isObject('abc'));
  falsy(isObject(new String('abc')));
  truthy(isObject(o, "name doIt"));
  truthy(isObject(o, "name doIt meth"));
  truthy(isObject(o, "name &doIt &meth"));
  return falsy(isObject(o, "&name"));
})();

// ---------------------------------------------------------------------------
equal(blockToArray(undef), []);

equal(blockToArray(''), []);

equal(blockToArray('a'), ['a']);

equal(blockToArray("a\nb"), ['a', 'b']);

equal(blockToArray("a\r\nb"), ['a', 'b']);

equal(blockToArray("abc\nxyz"), ['abc', 'xyz']);

equal(blockToArray("abc\nxyz"), ['abc', 'xyz']);

equal(blockToArray("abc\n\nxyz"), ['abc', '', 'xyz']);

// ---------------------------------------------------------------------------
equal(toArray("abc\ndef"), ['abc', 'def']);

equal(toArray(['a', 'b']), ['a', 'b']);

equal(toArray(["a\nb", "c\nd"]), ['a', 'b', 'c', 'd']);

// ---------------------------------------------------------------------------
equal(arrayToBlock(undef), '');

equal(arrayToBlock([]), '');

equal(arrayToBlock([undef]), '');

equal(arrayToBlock(['a  ', 'b\t\t']), "a\nb");

equal(arrayToBlock(['a', 'b', 'c']), "a\nb\nc");

equal(arrayToBlock(['a', undef, 'b', 'c']), "a\nb\nc");

equal(arrayToBlock([undef, 'a', 'b', 'c', undef]), "a\nb\nc");

// ---------------------------------------------------------------------------
equal(toBlock(['abc', 'def']), "abc\ndef");

equal(toBlock("abc\ndef"), "abc\ndef");

// ---------------------------------------------------------------------------
equal(rtrim("abc"), "abc");

equal(rtrim("  abc"), "  abc");

equal(rtrim("abc  "), "abc");

equal(rtrim("  abc  "), "  abc");

// ---------------------------------------------------------------------------
equal(words(''), []);

equal(words('  \t\t'), []);

equal(words('a b c'), ['a', 'b', 'c']);

equal(words('  a   b   c  '), ['a', 'b', 'c']);

equal(words('a b', 'c d'), ['a', 'b', 'c', 'd']);

equal(words(' my word ', ' is  word  '), ['my', 'word', 'is', 'word']);

// ---------------------------------------------------------------------------
equal(mkword('a', 'b', 'c'), 'abc');

equal(mkword(['a', 'b', 'c']), 'abc');

equal(mkword('a', ' ', 'c'), 'a c');

equal(mkword(['a', ' ', 'c']), 'a c');

equal(mkword([null, ['4', '2'], null]), '42');

// ---------------------------------------------------------------------------
truthy(hasChar('abc', 'b'));

falsy(hasChar('abc', 'x'));

falsy(hasChar("\t\t", ' '));

// ---------------------------------------------------------------------------
equal(quoted('abc'), '"abc"');

equal(quoted('"abc"'), "'\"abc\"'");

equal(quoted("'abc'"), "\"'abc'\"");

equal(quoted("'\"abc\"'"), "«'\"abc\"'»");

equal(quoted("'\"<abc>\"'"), "«'\"<abc>\"'»");

// ---------------------------------------------------------------------------
equal(getOptions(), {});

equal(getOptions(undef, {
  x: 1
}), {
  x: 1
});

equal(getOptions({
  x: 1
}, {
  x: 3,
  y: 4
}), {
  x: 1,
  y: 4
});

equal(getOptions('asText'), {
  asText: true
});

equal(getOptions('!binary'), {
  binary: false
});

equal(getOptions('label=this'), {
  label: 'this'
});

equal(getOptions('width=42'), {
  width: 42
});

equal(getOptions('asText !binary label=this'), {
  asText: true,
  binary: false,
  label: 'this'
});

// ---------------------------------------------------------------------------
equal(range(3), [0, 1, 2]);

equal(rev_range(3), [2, 1, 0]);

// ---------------------------------------------------------------------------
truthy(isHashComment('#'));

truthy(isHashComment('# a comment'));

truthy(isHashComment('#\ta comment'));

falsy(isHashComment('#comment'));

falsy(isHashComment(''));

falsy(isHashComment('a comment'));

// ---------------------------------------------------------------------------
truthy(isEmpty(''));

truthy(isEmpty('  \t\t'));

truthy(isEmpty([]));

truthy(isEmpty({}));

truthy(nonEmpty('a'));

truthy(nonEmpty('.'));

truthy(nonEmpty([2]));

truthy(nonEmpty({
  width: 2
}));

// ---------------------------------------------------------------------------
truthy(oneof('a', 'a', 'b', 'c'));

truthy(oneof('b', 'a', 'b', 'c'));

truthy(oneof('c', 'a', 'b', 'c'));

falsy(oneof('d', 'a', 'b', 'c'));

falsy(oneof('x'));

// ---------------------------------------------------------------------------
equal(uniq([1, 2, 2, 3, 3]), [1, 2, 3]);

equal(uniq(['a', 'b', 'b', 'c', 'c']), ['a', 'b', 'c']);

// ---------------------------------------------------------------------------
equal(rtrim("abc"), "abc");

equal(rtrim("  abc"), "  abc");

equal(rtrim("abc  "), "abc");

equal(rtrim("  abc  "), "  abc");

// ---------------------------------------------------------------------------
equal(words('a b c'), ['a', 'b', 'c']);

equal(words('  a   b   c  '), ['a', 'b', 'c']);

// ---------------------------------------------------------------------------
equal(escapeStr("\t\tXXX\n"), "→→XXX▼");

hEsc = {
  "\n": "\\n",
  "\t": "\\t",
  "\"": "\\\""
};

equal(escapeStr("\thas quote: \"\nnext line", hEsc), "\\thas quote: \\\"\\nnext line");

// ---------------------------------------------------------------------------
equal(rtrunc('/user/lib/.env', 5), '/user/lib');

equal(ltrunc('abcdefg', 3), 'defg');

// ---------------------------------------------------------------------------
equal(CWS(`abc
def
		ghi`), "abc def ghi");

// ---------------------------------------------------------------------------
equal(trimArray(['', 'abc']), ['abc']);

equal(trimArray(['abc', '']), ['abc']);

equal(trimArray(['', '   ', 'abc', '', "\t"]), ['abc']);

// ---------------------------------------------------------------------------
equal(removeEmptyLines(['', 'abc', '']), ['abc']);

equal(removeEmptyLines([' ', 'abc', ' ']), ['abc']);

equal(removeEmptyLines(['\t', 'abc', '\n']), ['abc']);

// ---------------------------------------------------------------------------
equal(CWSALL(`one    line
    second      line`), `one line
second line`);

equal(CWSALL(['one    line', '    second      line']), ['one line', 'second line']);

equal(CWSALL(`
one    line
    second      line
`), `one line
second line`);

equal(CWSALL(['', 'one    line', '    second      line', '']), ['one line', 'second line']);

// ---------------------------------------------------------------------------
truthy(isArrayOfStrings([]));

truthy(isArrayOfStrings(['a', 'b', 'c']));

truthy(isArrayOfStrings(['a', undef, null, 'b']));

// ---------------------------------------------------------------------------
truthy(isArrayOfArrays([]));

truthy(isArrayOfArrays([[], []]));

truthy(isArrayOfArrays([[1, 2], []]));

truthy(isArrayOfArrays([[1, 2, [1, 2, 3]], []]));

truthy(isArrayOfArrays([[1, 2], undef, null, []]));

falsy(isArrayOfArrays({}));

falsy(isArrayOfArrays([1, 2, 3]));

falsy(isArrayOfArrays([[1, 2, [3, 4]], 4]));

falsy(isArrayOfArrays([
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

truthy(isArrayOfArrays([[1, 2], [3, 4], [4, 5]], 2));

falsy(isArrayOfArrays([[1, 2], [3], [4, 5]], 2));

falsy(isArrayOfArrays([[1, 2], [3, 4, 5], [4, 5]], 2));

// ---------------------------------------------------------------------------
truthy(isArrayOfHashes([]));

truthy(isArrayOfHashes([{}, {}]));

truthy(isArrayOfHashes([
  {
    a: 1,
    b: 2
  },
  {}
]));

truthy(isArrayOfHashes([
  {
    a: 1,
    b: 2,
    c: [1,
  2,
  3]
  },
  {}
]));

truthy(isArrayOfHashes([
  {
    a: 1,
    b: 2
  },
  undef,
  null,
  {}
]));

falsy(isArrayOfHashes({}));

falsy(isArrayOfHashes([1, 2, 3]));

falsy(isArrayOfHashes([
  {
    a: 1,
    b: 2,
    c: [1,
  2,
  3]
  },
  4
]));

falsy(isArrayOfHashes([
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
  var h, l, n, n2, s, s2;
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
  truthy(isHash(h));
  falsy(isHash(l));
  falsy(isHash(o));
  falsy(isHash(n));
  falsy(isHash(n2));
  falsy(isHash(s));
  falsy(isHash(s2));
  falsy(isArray(h));
  truthy(isArray(l));
  falsy(isArray(o));
  falsy(isArray(n));
  falsy(isArray(n2));
  falsy(isArray(s));
  falsy(isArray(s2));
  falsy(isString(undef));
  falsy(isString(h));
  falsy(isString(l));
  falsy(isString(o));
  falsy(isString(n));
  falsy(isString(n2));
  truthy(isString(s));
  truthy(isString(s2));
  falsy(isObject(h));
  falsy(isObject(l));
  truthy(isObject(o));
  truthy(isObject(o, ['name', 'doIt']));
  falsy(isObject(o, ['name', 'doIt', 'missing']));
  falsy(isObject(n));
  falsy(isObject(n2));
  falsy(isObject(s));
  falsy(isObject(s2));
  falsy(isNumber(h));
  falsy(isNumber(l));
  falsy(isNumber(o));
  truthy(isNumber(n));
  truthy(isNumber(n2));
  falsy(isNumber(s));
  falsy(isNumber(s2));
  truthy(isNumber(42.0, {
    min: 42.0
  }));
  falsy(isNumber(42.0, {
    min: 42.1
  }));
  truthy(isNumber(42.0, {
    max: 42.0
  }));
  return falsy(isNumber(42.0, {
    max: 41.9
  }));
})();

// ---------------------------------------------------------------------------
truthy(isFunction(function() {
  return pass;
}));

falsy(isFunction(23));

truthy(isInteger(42));

truthy(isInteger(new Number(42)));

falsy(isInteger('abc'));

falsy(isInteger({}));

falsy(isInteger([]));

truthy(isInteger(42, {
  min: 0
}));

falsy(isInteger(42, {
  min: 50
}));

truthy(isInteger(42, {
  max: 50
}));

falsy(isInteger(42, {
  max: 0
}));

// ---------------------------------------------------------------------------
equal(OL(undef), "undef");

equal(OL("\t\tabc\nxyz"), '"→→abc▼xyz"');

equal(OL({
  a: 1,
  b: 'xyz'
}), '{"a":1,"b":"xyz"}');

// ---------------------------------------------------------------------------
equal(CWS(`a u
error message`), "a u error message");

// ---------------------------------------------------------------------------
// test isRegExp()
truthy(isRegExp(/^abc$/));

truthy(isRegExp(/^\s*where\s+areyou$/));

falsy(isRegExp(42));

falsy(isRegExp('abc'));

falsy(isRegExp([1, 'a']));

falsy(isRegExp({
  a: 1,
  b: 'ccc'
}));

falsy(isRegExp(undef));

truthy(isRegExp(/\.coffee/));

// ---------------------------------------------------------------------------
equal(extractMatches("..3 and 4 plus 5", /\d+/g, parseInt), [3, 4, 5]);

equal(extractMatches("And This Is A String", /A/g), ['A', 'A']);

// ---------------------------------------------------------------------------
truthy(notdefined(undef));

truthy(notdefined(null));

truthy(defined(''));

truthy(defined(5));

truthy(defined([]));

truthy(defined({}));

falsy(defined(undef));

falsy(defined(null));

falsy(notdefined(''));

falsy(notdefined(5));

falsy(notdefined([]));

falsy(notdefined({}));

// ---------------------------------------------------------------------------
truthy(isIterable([]));

truthy(isIterable(['a', 'b']));

gen = function*() {
  yield 1;
  yield 2;
  yield 3;
};

truthy(isIterable(gen()));

// ---------------------------------------------------------------------------
(function() {
  var MyClass;
  MyClass = class MyClass {
    constructor(str) {
      this.mystr = str;
    }

  };
  return equal(className(MyClass), 'MyClass');
})();

// ---------------------------------------------------------------------------
equal(getOptions('a b c'), {
  'a': true,
  'b': true,
  'c': true
});

equal(getOptions('abc'), {
  'abc': true
});

equal(getOptions({
  'a': true,
  'b': false,
  'c': 42
}), {
  'a': true,
  'b': false,
  'c': 42
});

equal(getOptions(), {});

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
  return equal(lResult, ['ABC', 'DEF', 'GHI']);
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
  return equal(lResult, ['ABC', 'DEF']);
})();

(() => {
  var item, lResult;
  lResult = [];
  item = ['abc', 'def', 'ghi'];
  forEachLine(item, (line) => {
    lResult.push(line.toUpperCase());
    return false;
  });
  return equal(lResult, ['ABC', 'DEF', 'GHI']);
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
  return equal(lResult, ['ABC', 'DEF']);
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
  return equal(lResult, ['1 ABC def', '2 DEF ghi']);
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
  return equal(newblock, `ABC
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
  return equal(newblock, `ABC
GHI`);
})();

(() => {
  var item, newblock;
  item = ['abc', 'def', 'ghi'];
  newblock = mapEachLine(item, (line) => {
    return line.toUpperCase();
  });
  return equal(newblock, ['ABC', 'DEF', 'GHI']);
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
  return equal(newblock, ['ABC', 'GHI']);
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
  return equal(newblock, ['1 ABC def', '3 GHI']);
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
  return equal(removeKeys(hAST, ['start', 'end']), {
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
  return equal(removeKeys(hAST, ['start', 'end']), {
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
  equal(hToDo.task, 'go shopping');
  equal(h.task, 'GO SHOPPING');
  h.task = 'do something';
  equal(hToDo.task, 'do something');
  equal(h.task, 'DO SOMETHING');
  h.task = 'nothing';
  equal(hToDo.task, 'do something');
  return equal(h.task, 'DO SOMETHING');
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
  return equal((await run1()), 'abc,def,ghi');
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
  return equal((await run2()), 'def,ghi');
})();

// ---------------------------------------------------------------------------
// test eachCharInString()
truthy(eachCharInString('ABC', (ch) => {
  return ch === ch.toUpperCase();
}));

falsy(eachCharInString('abc', (ch) => {
  return ch === ch.toUpperCase();
}));

falsy(eachCharInString('AbC', (ch) => {
  return ch === ch.toUpperCase();
}));

// ---------------------------------------------------------------------------
// test choose()
lItems = ['apple', 'orange', 'pear'];

truthy(lItems.includes(choose(lItems)));

truthy(lItems.includes(choose(lItems)));

truthy(lItems.includes(choose(lItems)));

// ---------------------------------------------------------------------------
// test shuffle()
lShuffled = deepCopy(lItems);

shuffle(lShuffled);

truthy(lShuffled.includes('apple'));

truthy(lShuffled.includes('orange'));

truthy(lShuffled.includes('pear'));

truthy(lShuffled.length === lItems.length);

// ---------------------------------------------------------------------------
// test some date functions
dateStr = '2023-01-01 05:00:00';

equal(timestamp(dateStr), "1/1/2023 5:00:00 AM");

equal(msSinceEpoch(dateStr), 1672578000000);

equal(formatDate(dateStr), "Jan 1, 2023");

// ---------------------------------------------------------------------------
// test pad()
equal(pad(23, 5), "   23");

equal(pad(23, 5, 'justify=left'), '23   ');

equal(pad('abc', 6), 'abc   ');

equal(pad('abc', 6, 'justify=center'), ' abc  ');

equal(pad(true, 3), 'true');

equal(pad(false, 3, 'truncate'), 'fal');

// ---------------------------------------------------------------------------
// test keys(), hasKey(), hasAllKeys(), hasAnyKey(), subkeys()
(() => {
  var h;
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
  equal(keys(h), ['2023-Nov', '2023-Dec']);
  truthy(hasKey(h, '2023-Nov'));
  falsy(hasKey(h, '2023-Oct'));
  equal(subkeys(h), ['Dining', 'Hardware', 'Insurance']);
  truthy(hasAllKeys(h, '2023-Nov', '2023-Dec'));
  truthy(hasAllKeys(h, '2023-Nov'));
  falsy(hasAllKeys(h, '2023-Oct', '2023-Nov', '2023-Dec'));
  truthy(hasAnyKey(h, '2023-Oct', '2023-Nov', '2023-Dec'));
  truthy(hasAnyKey(h, '2023-Oct', '2023-Nov'));
  return falsy(hasAnyKey(h, '2023-Jan', '2023-Feb', '2023-Mar'));
})();

// ---------------------------------------------------------------------------
// --- test extractKey()
(() => {
  var h, h2, val1, val2;
  h = {
    Nov: {
      Dining: {
        amt: 200
      },
      Hardware: {
        amt: 50
      }
    },
    Dec: {
      Dining: {
        amt: 300
      },
      Insurance: {
        amt: 150
      }
    }
  };
  val1 = extractKey(h, 'Nov');
  equal(val1, {
    Dining: {
      amt: 200
    },
    Hardware: {
      amt: 50
    }
  });
  equal(h, {
    Dec: {
      Dining: {
        amt: 300
      },
      Insurance: {
        amt: 150
      }
    }
  });
  h2 = {
    fName: 'John',
    lName: 'Deighan'
  };
  val2 = extractKey(h2, 'fName');
  equal(val2, 'John');
  return equal(h2, {
    lName: 'Deighan'
  });
})();

// ---------------------------------------------------------------------------
equal(keys({
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
  return equal(keys(hJan, hFeb, hMar), ['Gas', 'Dining', 'Insurance', 'Starbucks']);
})();

// ---------------------------------------------------------------------------
// --- test forEachItem()
(() => {
  var lWords, result;
  lWords = ['bridge', 'highway', 'garbage'];
  result = forEachItem(lWords, (item, h) => {
    return item;
  });
  return equal(result, lWords);
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
  return equal(result, ['bridge', 'garbage']);
})();

(() => {
  var lWords, result;
  lWords = ['bridge', 'highway', 'garbage'];
  result = forEachItem(lWords, (item, h) => {
    return item.toUpperCase();
  });
  return equal(result, ['BRIDGE', 'HIGHWAY', 'GARBAGE']);
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
  return equal(result, ['bridge', 'highway']);
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
  return equal(result, ['bridge', 'highway']);
})();

(() => {
  var lWords;
  lWords = ['bridge', 'highway', 'garbage'];
  return fails(() => {
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
  return equal(result, ['X 3', 'X 4']);
})();

// ---------------------------------------------------------------------------
(() => {
  var obj;
  obj = addToHash({}, [2024, 'Mar', 'Eat Out', 'Starbucks'], 23);
  equal(obj, {
    '2024': {
      Mar: {
        'Eat Out': {
          Starbucks: 23
        }
      }
    }
  });
  return equal(obj[2024]['Mar']['Eat Out']['Starbucks'], 23);
})();

(() => {
  var obj;
  obj = {};
  addToHash(obj, 'Mar', 23);
  return equal(obj, {
    Mar: 23
  });
})();

(() => {
  var obj;
  obj = {};
  addToHash(obj, 2, 23);
  return equal(obj, {
    '2': 23
  });
})();

// ---------------------------------------------------------------------------
// --- test chomp()
equal(chomp('abc'), 'abc');

equal(chomp('abc\n'), 'abc');

equal(chomp('abc\r\n'), 'abc');

// ---------------------------------------------------------------------------
// --- test flattenToHash()
(() => {
  equal(flattenToHash({
    a: 1,
    b: 2
  }), {
    a: 1,
    b: 2
  });
  equal(flattenToHash([
    {
      a: 1
    },
    {
      b: 2
    }
  ]), {
    a: 1,
    b: 2
  });
  equal(flattenToHash([
    {
      a: 1
    },
    [
      {
        b: 2
      }
    ]
  ]), {
    a: 1,
    b: 2
  });
  equal(flattenToHash([
    [
      {
        a: 1
      }
    ],
    {
      b: 2
    }
  ]), {
    a: 1,
    b: 2
  });
  equal(flattenToHash([
    [
      {
        a: 1,
        c: 3
      }
    ],
    {
      b: 2,
      d: 4
    }
  ]), {
    a: 1,
    b: 2,
    c: 3,
    d: 4
  });
  lItems = [
    {
      a: 1,
      b: 2
    },
    [
      {
        c: 3
      },
      {
        d: 4
      },
      [
        {
          e: 5
        }
      ]
    ]
  ];
  return equal(flattenToHash(lItems), {
    a: 1,
    b: 2,
    c: 3,
    d: 4,
    e: 5
  });
})();

// ---------------------------------------------------------------------------
// --- test sortArrayOfHashes()
(() => {
  equal(sortArrayOfHashes([
    {
      a: 1
    },
    {
      a: 3
    },
    {
      a: 2
    }
  ], 'a'), [
    {
      a: 1
    },
    {
      a: 2
    },
    {
      a: 3
    }
  ]);
  equal(sortArrayOfHashes([
    {
      name: 'John',
      age: 71
    },
    {
      name: 'Arathi',
      age: 35
    },
    {
      name: 'Lewis',
      age: 33
    },
    {
      name: 'Ben',
      age: 39
    }
  ], 'name'), [
    {
      name: 'Arathi',
      age: 35
    },
    {
      name: 'Ben',
      age: 39
    },
    {
      name: 'John',
      age: 71
    },
    {
      name: 'Lewis',
      age: 33
    }
  ]);
  return equal(sortArrayOfHashes([
    {
      name: 'John',
      age: 71
    },
    {
      name: 'Arathi',
      age: 35
    },
    {
      name: 'Lewis',
      age: 33
    },
    {
      name: 'Ben',
      age: 39
    }
  ], 'age'), [
    {
      name: 'Lewis',
      age: 33
    },
    {
      name: 'Arathi',
      age: 35
    },
    {
      name: 'Ben',
      age: 39
    },
    {
      name: 'John',
      age: 71
    }
  ]);
})();

// ---------------------------------------------------------------------------
// --- test buildCmdLine()
(() => {
  equal(buildCmdLine('doit'), 'doit');
  equal(buildCmdLine('doit', {
    debug: true
  }), 'doit -debug=true');
  equal(buildCmdLine('doit', {
    glob: '*'
  }), 'doit -glob=*');
  equal(buildCmdLine('npx doit', {
    glob: '*.coffee',
    d: true,
    f: true,
    g: false
  }), 'npx doit -glob=*.coffee -g=false -df');
  return equal(buildCmdLine('npx doit', {
    glob: '*.coffee',
    d: true,
    f: true,
    g: false
  }, ['willy', 'wonka', 'this is it']), 'npx doit -glob=*.coffee -g=false -df willy wonka "this is it"');
})();

// ---------------------------------------------------------------------------
// --- test execCmd()
(() => {
  like(execCmd("echo abc"), "abc");
  return like(execCmd('echo my word'), 'my word');
})();

// ---------------------------------------------------------------------------
// --- test npmLogLevel()
(() => {
  return equal(npmLogLevel(), "silent");
})();