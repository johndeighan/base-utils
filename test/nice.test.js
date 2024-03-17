// nice.test.coffee
var func2, u;

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
  throws,
  succeeds
} from '@jdeighan/base-utils/utest';

import {
  formatString,
  toNICE
} from '@jdeighan/base-utils/nice';

// ---------------------------------------------------------------------------

// --- whitespace is always made explicit
equal(formatString("a word"), "'a˳word'");

equal(formatString("\t\tword"), "'→→word'");

equal(formatString("first\nsecond"), "'first▼second'");

equal(formatString("first\r\nsecond\r\n"), "'first◄▼second◄▼'");

// --- strings are surrounded by quote marks that
//     don't clash with internal characters
equal(formatString("abc"), "'abc'");

equal(formatString("mary's lamb"), '"mary\'s˳lamb"');

equal(formatString("mary's \"stuff\""), '«mary\'s˳"stuff"»');

// ---------------------------------------------------------------------------
// --- repeat formatString() tests using toNICE()

// --- transform value using toNICE() automatically
u = new UnitTester();

u.transformValue = (str) => {
  return toNICE(str);
};

u.equal("a word", "'a˳word'");

u.equal("\t\tword", "'→→word'");

u.equal("first\nsecond", "'first▼second'");

u.equal("abc", "'abc'");

u.equal("mary's lamb", '"mary\'s˳lamb"');

u.equal("mary's \"stuff\"", '«mary\'s˳"stuff"»');

u.equal(undef, "undef");

u.equal(null, "null");

u.equal(0/0, 'NaN');

u.equal(42, "42");

u.equal(true, 'true');

u.equal(false, 'false');

u.equal((() => {
  return 42;
}), '[Function]');

func2 = (x) => {};

u.equal(func2, "[Function func2]");

u.equal(['a', 'b'], `- 'a'
- 'b'`);

u.equal([1, 2], `- 1
- 2`);

u.equal({
  a: 1,
  b: 2
}, `a: 1
b: 2`);

u.equal({
  a: 'a',
  b: 'b'
}, `a: 'a'
b: 'b'`);

u.equal([
  {
    a: 1
  },
  'abc'
], `-
	a: 1
- 'abc'`);

u.equal({
  a: [1, 2],
  b: 'abc'
}, `a:
	- 1
	- 2
b: 'abc'`);

u.equal({
  a: 1,
  b: 'abc',
  f: func2
}, `a: 1
b: 'abc'
f: [Function func2]`);

u.equal({
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
}, `key: 'wood'
value:
	- 'a˳word'
	-
		a: 1
		b: 2
	- undef
	-
		- 1
		- 2
		- "mary\'s˳lamb"
		- «mary\'s˳"stuff"»
items:
	- '→a'
	- 2
	- '→→b▼'`);