#!/usr/bin/env node
;
var DEBUG, fileName, filePath, hFile, hOptions, newName, newPath, ref;

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
hOptions = {
  pattern: '**/*.peggy'
};

ref = allFilesIn('./src/**/*.peggy');
for (hFile of ref) {
  ({fileName, filePath} = hFile);
  newName = withExt(fileName, '.js');
  newPath = withExt(filePath, '.js');
  execCmd(`peggy -m --format es ${filePath}`);
  if (DEBUG) {
    LOG(`${filePath} => ${newName}`);
  }
}

//# sourceMappingURL=gen-parsers.js.map
