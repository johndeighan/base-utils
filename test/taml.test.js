// taml.test.coffee
var curdir, h;

import {
  undef,
  defined,
  notdefined,
  pass,
  escapeStr,
  OL,
  spaces
} from '@jdeighan/base-utils';

import {
  mkpath
} from '@jdeighan/base-utils/ll-fs';

import * as lib from '@jdeighan/base-utils/taml';

Object.assign(global, lib);

import {
  UnitTester,
  equal,
  like,
  notequal,
  succeeds,
  throws,
  truthy,
  falsy
} from '@jdeighan/base-utils/utest';

curdir = mkpath(process.cwd()); // will have '/'


// ---------------------------------------------------------------------------
equal(llSplit("a: 53"), ["a: ", "53"]);

equal(llSplit("a: 53"), ["a: ", "53"]);

equal(llSplit("a  :   53"), ["a: ", "53"]);

equal(llSplit("- abc"), ["- ", "abc"]);

equal(llSplit("-   abc"), ["- ", "abc"]);

equal(llSplit("abc"), undef);

equal(llSplit("24"), undef);

equal(llSplit("'abc'"), undef);

// ---------------------------------------------------------------------------
// Leave these alone:
//    empty string
//    []
//    {}
//    number
//    "<str>"
//    '<str>'
//    true
//    false
equal(fixValStr(''), '');

equal(fixValStr('[]'), '[]');

equal(fixValStr('{}'), '{}');

equal(fixValStr('42'), '42');

equal(fixValStr('"abc"'), '"abc"');

equal(fixValStr("'abc'"), "'abc'");

equal(fixValStr('true'), 'true');

equal(fixValStr('false'), 'false');

// --- quote everything else
equal(fixValStr("abc"), "'abc'");

equal(fixValStr("it's"), "'it''s'");

// ---------------------------------------------------------------------------
equal(splitTaml('a: - abc'), ['a: ', '- ', "'abc'"]);

equal(splitTaml('-  a:   53'), ['- ', 'a: ', '53']);

equal(splitTaml('"abc"'), ['"abc"']);

equal(splitTaml('abc'), ["'abc'"]);

// ---------------------------------------------------------------------------
equal(toTAML([]), '---\n[]');

equal(toTAML({}), '---\n{}');

equal(toTAML([1, 2]), '---\n- 1\n- 2');

equal(toTAML(['1', '2']), `---
- "1"
- "2"`);

equal(toTAML({
  a: 1,
  b: 2
}), `---
a: 1
b: 2`);

equal(toTAML({
  a: 1,
  b: 2
}, '!useDashes'), `a: 1
b: 2`);

equal(toTAML({
  a: 1,
  b: 2
}, 'indent=3'), `\t\t\t---
\t\t\ta: 1
\t\t\tb: 2`);

equal(toTAML({
  a: 1,
  b: 2
}, 'indent=3 !useTabs'), `${spaces(6)}---
${spaces(6)}a: 1
${spaces(6)}b: 2`);

h = {
  h: [
    {
      a: 1
    },
    {
      b: 2
    }
  ]
};

equal(toTAML(h), '---\nh:\n\t- a: 1\n\t- b: 2');

// ---------------------------------------------------------------------------
(() => {
  var str;
  str = `---
- index: 0
	state: learning
- index: 1
	state: learning
- index: 2
	state: learning`;
  return equal(fromTAML(str), [
    {
      index: 0,
      state: 'learning'
    },
    {
      index: 1,
      state: 'learning'
    },
    {
      index: 2,
      state: 'learning'
    }
  ]);
})();

// ---------------------------------------------------------------------------
(() => {
  var str;
  str = `---
-
	label: Help
	url: /help
-
	label: Books
	url: /books`;
  return equal(fromTAML(str), [
    {
      label: 'Help',
      url: '/help'
    },
    {
      label: 'Books',
      url: '/books'
    }
  ]);
})();

// ---------------------------------------------------------------------------
(() => {
  var str;
  str = `---
-
	label: Help
	url: /help
-
	label: Books
	url: /books`;
  return equal(fromTAML(str), [
    {
      label: 'Help',
      url: '/help'
    },
    {
      label: 'Books',
      url: '/books'
    }
  ]);
})();

// ---------------------------------------------------------------------------
(() => {
  var str;
  str = `---
File:
	lWalkTrees:
		- program
WhileStatement:
	lWalkTrees:
		- test
		- body`;
  return equal(fromTAML(str), {
    File: {
      lWalkTrees: ['program']
    },
    WhileStatement: {
      lWalkTrees: ['test', 'body']
    }
  });
})();

// ---------------------------------------------------------------------------
(() => {
  var str;
  str = `---
type: function
funcName: main
source: ${curdir}/test/v8-stack.test.js`;
  return equal(fromTAML(str), {
    type: 'function',
    funcName: 'main',
    source: `${curdir}/test/v8-stack.test.js`
  });
})();