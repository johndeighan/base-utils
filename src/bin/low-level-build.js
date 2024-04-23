#!/usr/bin/env node
// low-level-build.coffee
var doLog, echo, fileFilter, hBin, hFile, hFilesProcessed, hJson, hMetaData, jsPath, key, nCoffee, nPeggy, ref, ref1, ref2, relPath, short_name, stub, tla, value, x;

import {
  globSync
} from 'glob';

import {
  undef,
  defined,
  notdefined,
  isEmpty,
  nonEmpty,
  OL,
  hasKey,
  execCmd,
  toBlock,
  add_s,
  npmLogLevel,
  fileExt,
  withExt,
  newerDestFilesExist
} from '@jdeighan/base-utils';

import {
  assert
} from '@jdeighan/base-utils/exceptions';

import {
  LOG
} from '@jdeighan/base-utils/log';

import {
  setDebugging
} from '@jdeighan/base-utils/debug';

import {
  slurp,
  barf,
  isFakeFile,
  isProjRoot,
  slurpPkgJSON,
  barfPkgJSON
} from '@jdeighan/base-utils/fs';

import {
  readTextFile,
  allFilesMatching
} from '@jdeighan/base-utils/read-file';

import {
  brew,
  brewFile
} from '@jdeighan/base-utils/coffee';

import {
  peggifyFile
} from '@jdeighan/base-utils/peggy';

hFilesProcessed = {
  coffee: 0,
  peggy: 0
};

echo = npmLogLevel() !== 'silent';

doLog = (str) => {
  if (echo) {
    console.log(str);
  }
};

doLog("-- low-level-build --");

// ---------------------------------------------------------------------------
// 1. Make sure we're in a project root directory
assert(isProjRoot('.', 'strict'), "Not in package root dir");

// ---------------------------------------------------------------------------
// --- A file (either *.coffee or *.peggy) is out of date unless both:
//        - a *.js file exists that's newer than the original file
//        - a *.js.map file exists that's newer than the original file
// --- But ignore files inside node_modules
fileFilter = ({filePath}) => {
  var jsFile, mapFile;
  if (filePath.match(/node_modules/)) {
    return false;
  }
  jsFile = withExt(filePath, '.js');
  mapFile = withExt(filePath, '.js.map');
  if ((fileExt(filePath) === '.peggy') && isFakeFile(jsFile)) {
    return true;
  }
  return !newerDestFilesExist(filePath, jsFile, mapFile);
};

ref = allFilesMatching('**/*.coffee', {fileFilter});
// ---------------------------------------------------------------------------
// 2. Search project for *.coffee files and compile them
//    unless newer *.js and *.js.map files exist
for (hFile of ref) {
  ({relPath} = hFile);
  doLog(relPath);
  brewFile(relPath);
  hFilesProcessed.coffee += 1;
}

ref1 = allFilesMatching('**/*.peggy', {fileFilter});
// ---------------------------------------------------------------------------
// 3. Search src folder for *.peggy files and compile them
//    unless newer *.js and *.js.map files exist OR it needs rebuilding
for (hFile of ref1) {
  ({relPath} = hFile);
  doLog(relPath);
  peggifyFile(relPath);
  hFilesProcessed.peggy += 1;
}

// ---------------------------------------------------------------------------
hBin = {}; // --- keys to add in package.json / bin


// ---------------------------------------------------------------------------
// --- generate a 3 letter acronym if file stub is <str>-<str>-<str>
tla = (stub) => {
  var _, a, b, c, lMatches, result;
  if (lMatches = stub.match(/^([a-z])(?:[a-z]*)\-([a-z])(?:[a-z]*)\-([a-z])(?:[a-z]*)$/)) {
    [_, a, b, c] = lMatches;
    result = a + b + c;
    return result;
  } else {
    return undef;
  }
};

ref2 = allFilesMatching('./src/bin/**/*.coffee');
// ---------------------------------------------------------------------------
// 4. For every *.coffee file in the 'src/bin' directory that
//       has key "shebang" set:
//       - save <stub>: <jsPath> in hBin
//       - if has a tla, save <tla>: <jsPath> in hBin
for (x of ref2) {
  ({relPath, stub} = x);
  [hMetaData] = readTextFile(relPath);
  if (hMetaData != null ? hMetaData.shebang : void 0) {
    jsPath = withExt(relPath, '.js');
    hBin[stub] = jsPath;
    short_name = tla(stub);
    if (defined(short_name)) {
      hBin[short_name] = jsPath;
    }
  }
}

// ---------------------------------------------------------------------------
// 5. Add sub-keys to key 'bin' in package.json
//    (create if not exists)
if (nonEmpty(hBin)) {
  hJson = slurpPkgJSON();
  if (!hasKey(hJson, 'bin')) {
    doLog("   - add key 'bin'");
    hJson.bin = {};
  }
  for (key in hBin) {
    value = hBin[key];
    if (hJson.bin[key] !== value) {
      doLog(`   - add bin/${key} = ${value}`);
      hJson.bin[key] = value;
    }
  }
  barfPkgJSON(hJson);
}

nCoffee = hFilesProcessed.coffee;

if (nCoffee > 0) {
  doLog(`(${nCoffee} coffee file${add_s(nCoffee)} compiled)`);
}

nPeggy = hFilesProcessed.peggy;

if (nPeggy > 0) {
  doLog(`(${nPeggy} peggy file${add_s(nPeggy)} compiled)`);
}
