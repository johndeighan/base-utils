// peggy.coffee
var generate, hPeggyOptions;

import peggy from 'peggy';

({generate} = peggy);

import {
  undef,
  OL,
  toBlock
} from '@jdeighan/base-utils';

import {
  assert
} from '@jdeighan/base-utils/exceptions';

import {
  isFile,
  slurp,
  barf,
  withExt,
  readTextFile
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

// ---------------------------------------------------------------------------
export var peggifyFile = (filePath) => {
  var jsCode, lLines, metadata, sourceMap;
  ({metadata, lLines} = readTextFile(filePath));
  [jsCode, sourceMap] = peggify(toBlock(lLines), filePath);
  barf(jsCode, withExt(filePath, '.js'));
  barf(sourceMap, withExt(filePath, '.js.map'));
};

//# sourceMappingURL=peggy.js.map
