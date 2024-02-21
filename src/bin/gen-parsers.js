#!/usr/bin/env node
;
var hFile, hOptions, ref;

import {
  // gen-parsers.coffee
  undef,
  defined,
  notdefined,
  LOG,
  execCmd
} from '@jdeighan/base-utils';

import {
  allFilesIn
} from '@jdeighan/base-utils/fs';

// ---------------------------------------------------------------------------
LOG("You are running the gen-parsers script");

hOptions = {
  recursive: true,
  eager: false,
  regexp: /\.peggy$/
};

ref = allFilesIn('./src/grammar', hOptions);
for (hFile of ref) {
  LOG(hFile.fileName);
  execCmd(`peggy --format es ${hFile.filePath}`);
}

//# sourceMappingURL=gen-parsers.js.map
