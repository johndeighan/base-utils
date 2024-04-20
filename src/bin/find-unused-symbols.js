#!/usr/bin/env node
// find-unused-symbols.coffee
var compareFunc, debug, dir, dirName, filePath, h, hFileInfo, hFiles, hOpt, hProjects, i, j, k, lFiles, lSymbols, len, len1, len2, n1, n2, n3, pattern, ref, ref1, ref2, root, symbol, x;

import {
  undef,
  defined,
  notdefined,
  OL,
  isEmpty,
  nonEmpty,
  isNonEmptyString,
  centeredText,
  truncateStr,
  isArrayOfStrings,
  keys
} from '@jdeighan/base-utils';

import {
  assert,
  croak
} from '@jdeighan/base-utils/exceptions';

import {
  LOG,
  LOGVALUE
} from '@jdeighan/base-utils/log';

import {
  parseCmdArgs
} from '@jdeighan/base-utils/parse-cmd-args';

import {
  dirContents,
  isProjRoot,
  mkpath,
  isFile,
  fileExt
} from '@jdeighan/base-utils/fs';

import {
  allFilesMatching
} from '@jdeighan/base-utils/read-file';

import {
  analyzeCoffeeFile
} from '@jdeighan/base-utils/ast-walker';

import {
  fmt,
  proj
} from './bin-utils.js';

({
  // ---------------------------------------------------------------------------
  // --- Usage:
  //    find-unused-symbols <filePath> [-root=<dir>] [-debug]
  _: lFiles,
  root,
  debug
} = parseCmdArgs({
  hExpect: {
    _: [
      1,
      1 // file whose exports to search for
    ],
    root: 'string',
    debug: 'boolean'
  }
}));

if (notdefined(root)) {
  root = '..';
}

filePath = lFiles[0];

assert(fileExt(filePath) === '.coffee', `Not a coffee file: ${OL(filePath)}`);

assert(isFile(filePath), `Not a file: ${OL(filePath)}`);

hFileInfo = analyzeCoffeeFile(filePath);

lSymbols = hFileInfo.lExported;

if (debug) {
  LOGVALUE('debug', true);
  LOGVALUE('root', root);
  LOGVALUE('filePath', filePath);
  LOGVALUE('lSymbols', lSymbols);
}

// --- Cycle through every directory inside the root directory
//     that contains a package.json file
hProjects = {}; // --- { <proj>: {<filePath>: <hInfo>}}

ref = dirContents(root, 'dirsOnly');
for (dirName of ref) {
  dir = `${root}/${dirName}`;
  if (isProjRoot(dir)) {
    LOG(`PROJ ROOT: ${dir}`, 'max=15');
    hFiles = hProjects[dir] = {};
    pattern = `${dir}/**/*.coffee`;
    ref1 = allFilesMatching(pattern, 'eager');
    for (x of ref1) {
      ({filePath} = x);
      LOG(`PATH: ${filePath}`, 'max=15');
    }
  }
}

// hFiles[path] = analyzeCoffeeFile(path).lUsed

//if debug
//	LOGVALUE 'hProjects', hProjects
process.exit();

h = {};

hOpt = {
  log: debug,
  from: file
};

for (i = 0, len = lSymbols.length; i < len; i++) {
  symbol = lSymbols[i];
  LOG(centeredText(symbol, 64, 'char=='));
  for (j = 0, len1 = lProjects.length; j < len1; j++) {
    dir = lProjects[j];
    h[symbol] = [n1, n2, n3] = symbolNumUsages(symbol, dir, hOpt);
    if (n1 + n2 + n3 > 0) {
      LOG(fmt(n1, n2, n3, proj(dir)));
    }
  }
}

compareFunc = (a, b) => {
  if (h[a][0] < h[b][0]) {
    return -1;
  } else if (h[b][0] < h[a][0]) {
    return 1;
  } else {
    return 0;
  }
};

ref2 = keys(h).sort(compareFunc);
for (k = 0, len2 = ref2.length; k < len2; k++) {
  symbol = ref2[k];
  [n1, n2, n3] = h[symbol];
  LOG(fmt(n1, n2, n3, symbol));
}