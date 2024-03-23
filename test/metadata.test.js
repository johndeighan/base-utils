// metadata.test.coffee
import {
  undef
} from '@jdeighan/base-utils';

import {
  u,
  equal
} from '@jdeighan/base-utils/utest';

import * as lib from '@jdeighan/base-utils/metadata';

Object.assign(global, lib);

u.transformValue = (block) => {
  return convertMetaData(block);
};

// ---------------------------------------------------------------------------
equal(`---
fileName: primitive-value
type: coffee
author: John Deighan
include: pll-parser`, {
  fileName: 'primitive-value',
  type: 'coffee',
  author: 'John Deighan',
  include: 'pll-parser'
});

equal(`!!!
fileName: primitive-value
type: coffee
author: John Deighan
include: pll-parser`, {
  fileName: 'primitive-value',
  type: 'coffee',
  author: 'John Deighan',
  include: 'pll-parser'
});