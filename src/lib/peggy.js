// peggy.coffee
var generate, hPeggyOptions;

import peggy from 'peggy';

({generate} = peggy);

import {
  undef,
  OL
} from '@jdeighan/base-utils';

import {
  assert
} from '@jdeighan/base-utils/exceptions';

import {
  isFile
} from '@jdeighan/base-utils/fs';

hPeggyOptions = {
  allowedStartRules: ['*'],
  format: 'es',
  output: 'source-and-map'
};

// ---------------------------------------------------------------------------
export var peggify = (peggyCode, source) => {
  var err, h, srcNode;
  assert(isFile(source), `Not a file: ${OL(source)}`);
  try {
    hPeggyOptions.grammarSource = source;
    srcNode = generate(peggyCode, hPeggyOptions);
    h = srcNode.toStringWithSourceMap();
    return [h.code, h.map.toString()];
  } catch (error) {
    err = error;
    console.log(`ERROR: ${err.message}`);
    return [undef, undef];
  }
};

//# sourceMappingURL=peggy.js.map
