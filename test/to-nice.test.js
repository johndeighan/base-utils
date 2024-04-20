// to-nice.test.coffee
import {
  undef
} from '@jdeighan/base-utils';

import {
  UnitTester,
  equal,
  like,
  notequal,
  truthy,
  falsy,
  fails,
  succeeds
} from '@jdeighan/base-utils/utest';

import * as lib from '@jdeighan/base-utils/to-nice';

Object.assign(global, lib);

// ---------------------------------------------------------------------------
// --- test needsQuotes
falsy(needsQuotes("abc"));

falsy(needsQuotes("\"Hi\", Alice's sheep said."));

truthy(needsQuotes("- item"));

truthy(needsQuotes("   - item"));

truthy(needsQuotes("name:"));

truthy(needsQuotes("   name:"));

truthy(needsQuotes("name : John"));

// --- whitespace is always made explicit
equal(formatString("a word"), "a˳word");

equal(formatString("\t\tword"), "→  →  word");

equal(formatString("first\nsecond"), "first▼second");

equal(formatString("first\r\nsecond\r\n"), "first◄▼second◄▼");

equal(formatString("abc"), "abc");

equal(formatString("mary's lamb"), 'mary\'s˳lamb');

equal(formatString("mary's \"stuff\""), 'mary\'s˳"stuff"');

// --- If it looks like an array element, add quotes
equal(formatString("- item"), "«-˳item»");

equal(formatString("   - item"), "«˳˳˳-˳item»");

equal(formatString("-    item"), "«-˳˳˳˳item»");

// ---------------------------------------------------------------------------
// --- test indentBlock
equal(indentBlock(`this
that`, 2, '>'), `>>this
>>that`);

// ---------------------------------------------------------------------------
// --- repeat formatString() tests using toNICE()
(() => {
  var aFunc, func2, u;
  // --- define a function:
  aFunc = () => {
    return 42;
  };
  // --- transform value using toNICE() automatically
  u = new UnitTester();
  u.transformValue = (str) => {
    return toNICE(str);
  };
  u.equal("a word", "a˳word");
  u.equal("\t\tword", "→  →  word");
  u.equal("first\nsecond", "first▼second");
  u.equal("abc", "abc");
  u.equal("mary's lamb", 'mary\'s˳lamb');
  u.equal("mary's \"stuff\"", 'mary\'s˳"stuff"');
  u.equal(undef, ".undef.");
  u.equal(null, ".null.");
  u.equal(0/0, '.NaN.');
  u.equal(42, "42");
  u.equal(true, '.true.');
  u.equal(false, '.false.');
  u.equal((() => {
    return 42;
  }), '[Function]');
  u.equal(aFunc, '[Function aFunc]');
  func2 = (x) => {};
  u.equal(func2, "[Function func2]");
  u.equal(['a', 'b'], `- a
- b`);
  u.equal([1, 2], `- 1
- 2`);
  u.equal(['1', '2'], `- «1»
- «2»`);
  u.equal({
    a: 1,
    b: 2
  }, `a: 1
b: 2`);
  u.equal({
    a: 'a',
    b: 'b'
  }, `a: a
b: b`);
  u.equal([
    {
      a: 1
    },
    'abc'
  ], `-
	a: 1
- abc`);
  u.equal({
    a: [1, 2],
    b: 'abc'
  }, `a:
	- 1
	- 2
b: abc`);
  u.equal({
    a: 1,
    b: 'abc',
    f: func2
  }, `a: 1
b: abc
f: [Function func2]`);
  return u.equal({
    key: 'wood',
    value: [
      "a word",
      {
        a: 1,
        b: 2
      },
      undef,
      [1,
      2,
      "mary's lamb",
      "mary's \"stuff\""]
    ],
    items: ["\ta", 2, "\t\tb\n"]
  }, `key: wood
value:
	- a˳word
	-
		a: 1
		b: 2
	- .undef.
	-
		- 1
		- 2
		- mary\'s˳lamb
		- mary\'s˳"stuff"
items:
	- →  a
	- 2
	- →  →  b▼`);
})();

// ---------------------------------------------------------------------------
// --- test toNICE() with options
(() => {
  var h;
  // --- Create a hash
  h = {};
  h.mFirst = 'xyz';
  h.aSecond = 'mno';
  h.xThird = 'abc';
  // --- Without sorting, keys should come in insert order
  equal(toNICE(h), `mFirst: xyz
aSecond: mno
xThird: abc`);
  // --- delimit with label
  equal(toNICE(h, 'delimit label=BLOCK width=20'), `-----  BLOCK  ------
mFirst: xyz
aSecond: mno
xThird: abc
--------------------`);
  // --- sort keys alphabetically
  equal(toNICE(h, {
    sortKeys: true
  }), `aSecond: mno
mFirst: xyz
xThird: abc`);
  // --- sort keys in a specific order
  return equal(toNICE(h, {
    sortKeys: ['xThird']
  }), `xThird: abc
aSecond: mno
mFirst: xyz`);
})();