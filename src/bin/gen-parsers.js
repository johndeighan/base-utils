#!/usr/bin/env node
;
var DEBUG, oldcode;

import {
  // gen-parsers.coffee
  undef,
  defined,
  notdefined,
  LOG,
  execCmd
} from '@jdeighan/base-utils';

import {
  allFilesIn,
  withExt
} from '@jdeighan/base-utils/fs';

DEBUG = false;

// ---------------------------------------------------------------------------
execCmd("npx peggy -m --format es src/lib/cmd-args.peggy");

execCmd("npx peggy -m --format es src/lib/pll-parser.peggy");

// ---------------------------------------------------------------------------
oldcode = () => {
  var fileName, filePath, hFile, hOptions, newName, newPath, ref, results;
  hOptions = {
    pattern: '**/*.peggy'
  };
  ref = allFilesIn('./src/**/*.peggy');
  results = [];
  for (hFile of ref) {
    ({fileName, filePath} = hFile);
    newName = withExt(fileName, '.js');
    newPath = withExt(filePath, '.js');
    execCmd(`peggy -m --format es --allowed-start-rules * ${filePath}`);
    if (DEBUG) {
      results.push(LOG(`${filePath} => ${newName}`));
    } else {
      results.push(void 0);
    }
  }
  return results;
};

//# sourceMappingURL=gen-parsers.js.map
