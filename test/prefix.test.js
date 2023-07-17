// prefix.test.coffee
var un;

import test from 'ava';

import {
  undef,
  defined,
  notdefined,
  pass,
  escapeStr
} from '@jdeighan/base-utils';

import {
  getPrefix
} from '@jdeighan/base-utils/prefix';

un = (str) => {
  return escapeStr(str, {
    '®': "\n",
    '→': "\t",
    '˳': " "
  });
};

// ---------------------------------------------------------------------------
test("line 16", (t) => {
  return t.is(getPrefix(2), un('˳˳˳˳˳˳˳˳'));
});

test("line 17", (t) => {
  return t.is(getPrefix(2, 'plain'), un('│˳˳˳│˳˳˳'));
});

test("line 18", (t) => {
  return t.is(getPrefix(2, 'withArrow'), un('│˳˳˳└─>˳'));
});

test("line 19", (t) => {
  return t.is(getPrefix(2, 'noLastVbar'), un('│˳˳˳˳˳˳˳'));
});

test("line 20", (t) => {
  return t.is(getPrefix(2), un('˳˳˳˳˳˳˳˳'));
});
