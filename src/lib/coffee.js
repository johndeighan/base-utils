// coffee.coffee
import fs from 'fs';

import CoffeeScript from 'coffeescript';

import {
  undef,
  defined,
  notdefined,
  getOptions,
  toBlock,
  OL,
  words,
  removeKeys
} from '@jdeighan/base-utils';

import {
  assert,
  croak
} from '@jdeighan/base-utils/exceptions';

import {
  dbgEnter,
  dbgReturn,
  dbg
} from '@jdeighan/base-utils/debug';

import {
  isUndented
} from '@jdeighan/base-utils/indent';

import {
  toTAML
} from '@jdeighan/base-utils/taml';

import {
  barf,
  barfAST
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

// ---------------------------------------------------------------------------
export var removeExtraKeys = (hAST) => {
  removeKeys(hAST, words('loc range extra start end', 'directives comments tokens'));
  return hAST;
};

// ---------------------------------------------------------------------------
export var astToTAML = (hAST, full = false) => {
  var lSortBy;
  if (!full) {
    removeExtraKeys(hAST);
  }
  lSortBy = ['type', 'params', 'body', 'left', 'operator', 'right'];
  return toTAML(hAST, {
    sortKeys: lSortBy
  });
};

// ---------------------------------------------------------------------------
// --- Valid options:
//        full - retain all keys
//        format - undef=JS value, else 'taml'
export var toAST = function(coffeeCode, hOptions = {}) {
  var ast, err, format, full, hAST;
  dbgEnter("toAST", coffeeCode);
  assert(isUndented(coffeeCode), "code has indentation");
  ({full, format} = getOptions(hOptions, {
    full: false,
    format: undef
  }));
  try {
    hAST = CoffeeScript.compile(coffeeCode, {
      ast: true
    });
    assert(defined(hAST), "hAST is empty");
  } catch (error) {
    err = error;
    LOG(`ERROR in CoffeeScript: ${err.message}`);
    LOG('-'.repeat(78));
    LOG(`${OL(coffeeCode)}`);
    LOG('-'.repeat(78));
    croak(`ERROR in CoffeeScript: ${err.message}`);
  }
  switch (format) {
    case undef:
      if (!full) {
        removeExtraKeys(hAST);
      }
      ast = hAST;
      break;
    case 'taml':
      ast = astToTAML(hAST, full);
      break;
    default:
      croak("Invalid format");
  }
  dbgReturn("toAST", ast);
  return ast;
};

// ---------------------------------------------------------------------------
export var toASTFile = function(coffeeCode, filePath, hOptions = {}) {
  var hAST;
  hAST = toAST(coffeeCode, hOptions);
  barfAST(hAST, filePath);
};

//# sourceMappingURL=coffee.js.map
