// cmd-args.test.coffee
import * as lib from '@jdeighan/base-utils/cmd-args';

Object.assign(global, lib);

import {
  pparse
} from '@jdeighan/base-utils/peggy';

import * as ulib from '@jdeighan/base-utils/utest';

Object.assign(global, ulib);

u.transformValue = (str) => {
  return pparse(parse, str);
};

// ---------------------------------------------------------------------------
equal('-a', {
  a: true
});

equal('-X', {
  X: true
});

equal('  -b', {
  b: true
});

equal('-c\t', {
  c: true
});

equal('-ab=title', {
  ab: 'title'
});

equal('-label=Expenses', {
  label: 'Expenses'
});

equal('-title="My Budget"', {
  title: 'My Budget'
});

equal('-a -b', {
  a: true,
  b: true
});

equal('-ab', {
  a: true,
  b: true
});

equal("-a -title=works", {
  a: true,
  title: "works"
});

equal("-a -m -title=works -n=5", {
  a: true,
  m: true,
  title: "works",
  n: "5"
});

equal("-am -title=works -n=5", {
  a: true,
  m: true,
  title: "works",
  n: "5"
});

equal("-am -title='it works' -n=5", {
  a: true,
  m: true,
  title: "it works",
  n: "5"
});

equal("-am Willy Wonka", {
  a: true,
  m: true,
  _: ['Willy', 'Wonka']
});

equal("'do that' -am \"do this\"", {
  a: true,
  m: true,
  _: ['do that', 'do this']
});

fails(() => {
  return pparse(parse, '--');
});