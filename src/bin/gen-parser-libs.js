#!/usr/bin/env node
// gen-parser-libs.coffee
var fileName, filePath, hFile, ref;

import {
  undef,
  defined,
  notdefined,
  execCmd
} from '@jdeighan/base-utils';

import {
  LOG
} from '@jdeighan/base-utils/log';

import {
  allFilesMatching,
  withExt
} from '@jdeighan/base-utils/fs';

ref = allFilesMatching('./src/lib/*.peggy');
// ---------------------------------------------------------------------------
for (hFile of ref) {
  ({fileName, filePath} = hFile);
  execCmd(`npx peggy -m --format es --allowed-start-rules * ${filePath}`);
  LOG(`${fileName} => ${withExt(fileName, '.js')}`);
}