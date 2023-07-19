// taml.test.coffee
var h;

import test from 'ava';

import {
  undef,
  defined,
  notdefined,
  pass,
  escapeStr,
  OL
} from '@jdeighan/base-utils';

import {
  isTAML,
  toTAML,
  fromTAML
} from '@jdeighan/base-utils/taml';

// ---------------------------------------------------------------------------
test("line 14", (t) => {
  return t.is(toTAML([]), '---\n[]');
});

test("line 15", (t) => {
  return t.is(toTAML({}), '---\n{}');
});

test("line 16", (t) => {
  return t.is(toTAML([1, 2]), '---\n- 1\n- 2');
});

test("line 17", (t) => {
  return t.is(toTAML(['1', '2']), '---\n- "1"\n- "2"');
});

test("line 18", (t) => {
  return t.is(toTAML({
    a: 1,
    b: 2
  }), '---\na: 1\nb: 2');
});

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

test("line 19", (t) => {
  return t.is(toTAML(h), '---\nh:\n\t- a: 1\n\t- b: 2');
});
