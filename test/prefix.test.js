// prefix.test.coffee
var un;

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

import {
  utest
} from '@jdeighan/base-utils/utest';

un = (str) => {
  return escapeStr(str, {
    '▼': "\n",
    '→': "\t",
    '˳': " "
  });
};

// ---------------------------------------------------------------------------
utest.equal(getPrefix(2), un('˳˳˳˳˳˳˳˳'));

utest.equal(getPrefix(2, 'plain'), un('│˳˳˳│˳˳˳'));

utest.equal(getPrefix(2, 'withArrow'), un('│˳˳˳└─>˳'));

utest.equal(getPrefix(2, 'noLastVbar'), un('│˳˳˳˳˳˳˳'));

utest.equal(getPrefix(2), un('˳˳˳˳˳˳˳˳'));

//# sourceMappingURL=prefix.test.js.map
