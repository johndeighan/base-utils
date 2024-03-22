// coffee.coffee
import assert from 'node:assert';

import fs from 'fs';

import CoffeeScript from 'coffeescript';

import {
  undef,
  defined,
  getOptions,
  toBlock
} from '@jdeighan/base-utils';

import {
  barf
} from '@jdeighan/base-utils/fs';

// ---------------------------------------------------------------------------
export var brew = function(coffeeCode, filePath = undef) {
  var h, jsCode;
  coffeeCode = toBlock(coffeeCode); // allow passing array
  if (defined(filePath)) {
    assert(fs.existsSync(filePath), `Not a file: ${filePath}`);
    h = CoffeeScript.compile(coffeeCode, {
      bare: true,
      header: false,
      filename: filePath,
      sourceMap: true,
      filename: undef // must be filled in
    });
    jsCode = h.js;
    assert(defined(jsCode), "No JS code generated");
    return [jsCode.trim(), h.v3SourceMap];
  } else {
    jsCode = CoffeeScript.compile(coffeeCode, {
      bare: true,
      header: false,
      sourceMap: false
    });
    assert(defined(jsCode), "No JS code generated");
    return [jsCode.trim(), undef];
  }
};

// ---------------------------------------------------------------------------
export var brewFile = function(filePath) {
  var hMetaData, jsCode, lLines, sourceMap;
  ({hMetaData, lLines} = readTextFile(filePath));
  [jsCode, sourceMap] = brew(lLines, filePath);
  barf(jsCode, withExt(filePath, '.js'));
  barf(sourceMap, withExt(filePath, '.js.map'));
};

//# sourceMappingURL=coffee.js.map
