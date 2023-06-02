// taml.test.coffee
import test from 'ava';

import {
  assert,
  croak
} from '@jdeighan/base-utils/exceptions';

import {
  undef,
  untabify
} from '@jdeighan/base-utils';

import {
  LOG
} from '@jdeighan/base-utils/log';

import {
  isTAML,
  toTAML,
  fromTAML,
  fixValStr
} from '@jdeighan/base-utils/taml';

// ---------------------------------------------------------------------------
test("line 13", (t) => {
  return t.truthy(isTAML("---\n- first\n- second"));
});

test("line 16", (t) => {
  return t.falsy(isTAML("x---\n5"));
});

test("line 19", (t) => {
  return t.falsy(isTAML("---x\n5"));
});

test("line 22", (t) => {
  return t.is(toTAML({
    a: 1
  }), "---\na: 1");
});

test("line 25", (t) => {
  return t.is(toTAML({
    a: 1,
    b: 2
  }), "---\na: 1\nb: 2");
});

test("line 28", (t) => {
  return t.is(toTAML([
    1,
    'abc',
    {
      a: 1
    }
  ]), "---\n- 1\n- abc\n-\n   a: 1");
});

test("line 32", (t) => {
  return t.is(toTAML({
    a: 1,
    b: 2
  }), `---
a: 1
b: 2`);
});

test("line 39", (t) => {
  return t.is(toTAML(['a', 'b']), `---
- a
- b`);
});

test("line 46", (t) => {
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

test("line 57", (t) => {
  return t.deepEqual(fromTAML("---\n- a\n- b"), ['a', 'b']);
});

test("line 60", (t) => {
  return t.deepEqual(fromTAML(`---
title:
\ten: Hello, she said.`), {
    title: {
      en: 'Hello, she said.'
    }
  });
});

test("line 72", (t) => {
  return t.deepEqual(fromTAML(`---
a: 1
b: 2`), {
    a: 1,
    b: 2
  });
});

test("line 84", (t) => {
  return t.is(toTAML(undef), "---\nundef");
});

test("line 87", (t) => {
  return t.is(toTAML(null), "---\nnull");
});

test("line 90", (t) => {
  return t.is(toTAML({
    a: 1
  }), "---\na: 1");
});

test("line 93", (t) => {
  return t.is(toTAML({
    a: 1,
    b: 2
  }), "---\na: 1\nb: 2");
});

test("line 96", (t) => {
  return t.is(toTAML([
    1,
    'abc',
    {
      a: 1
    }
  ]), "---\n- 1\n- abc\n-\n   a: 1");
});

test("line 99", (t) => {
  return t.is(toTAML({
    a: 1,
    b: 2
  }), `---
a: 1
b: 2`);
});

test("line 106", (t) => {
  return t.is(toTAML(['a', 'b']), `---
- a
- b`);
});

test("line 113", (t) => {
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

test("line 124", (t) => {
  return t.is(toTAML(['xyz', 42, false, 'false', undef]), `---
- xyz
- 42
- false
- 'false'
- undef`);
});

// ---------------------------------------------------------------------------
// Test sorting keys

// --- Default is to sort keys
test("line 139", (t) => {
  return t.is(toTAML({
    c: 3,
    b: 2,
    a: 1
  }), `---
a: 1
b: 2
c: 3`);
});

// --- sortKeys array specifies order
test("line 149", (t) => {
  return t.is(toTAML({
    c: 3,
    b: 2,
    a: 1
  }, {
    sortKeys: ['b', 'a', 'c']
  }), `---
b: 2
a: 1
c: 3`);
});

test("line 157", (t) => {
  return t.is(toTAML({
    c: 3,
    b: 2,
    a: 1
  }, {
    sortKeys: ['c', 'b', 'a']
  }), `---
c: 3
b: 2
a: 1`);
});

// --- Keys not in the sortKeys array are put at end alphabetically
test("line 167", (t) => {
  return t.is(toTAML({
    e: 5,
    d: 4,
    c: 3,
    b: 2,
    a: 1
  }, {
    sortKeys: ['c', 'b', 'a']
  }), `---
c: 3
b: 2
a: 1
d: 4
e: 5`);
});

test("line 177", (t) => {
  var hProc;
  hProc = {
    code: function(block) {
      return `${block};`;
    },
    html: function(block) {
      return block.replace('<p>', '<p> ');
    },
    Script: function(block) {
      return elem('script', undef, block, "\t");
    }
  };
  return t.is(toTAML(hProc), `---
Script: '[Function: Script]'
code: '[Function: code]'
html: '[Function: html]'`);
});

// ---------------------------------------------------------------------------
test("line 12", (t) => {
  return t.is(fixValStr(""), "");
});

test("line 15", (t) => {
  return t.is(fixValStr("5"), "5");
});

test("line 18", (t) => {
  return t.is(fixValStr("'abc'"), "'abc'");
});

test("line 21", (t) => {
  return t.is(fixValStr('"5"'), '"5"');
});

test("line 24", (t) => {
  return t.is(fixValStr('abc'), "'abc'");
});

test("line 27", (t) => {
  return t.is(fixValStr("ab'cd"), "'ab''cd'");
});
