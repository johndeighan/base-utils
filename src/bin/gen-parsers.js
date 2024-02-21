#!/usr/bin/env node
;
var fileName, filePath, hFile, hOptions, newName, ref;

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

// ---------------------------------------------------------------------------
LOG("Generate parser files");

hOptions = {
  recursive: true,
  eager: false,
  regexp: /\.peggy$/
};

ref = allFilesIn('./src/grammar', hOptions);
for (hFile of ref) {
  ({fileName, filePath} = hFile);
  newName = withExt(fileName, '.js');
  execCmd(`peggy --format es ${filePath}`);
  LOG(`${fileName} => ${newName}`);
}

//# sourceMappingURL=gen-parsers.js.map
