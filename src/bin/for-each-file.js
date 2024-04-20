#!/usr/bin/env node
// for-each-file.coffee

// --- Using option -d or -l prevents any execution
//        therefore option -cmd is not required
//        but if provided, allows output of command
//        that would be executed
var cmdStr, debug, dir, execute, fullDebug, genOutput, getCmd, glob, hCmdArgs, handleFile, handleGlob, i, j, lFileRecs, lFiles, lPromises, lResults, len, len1, result, sep, str;

import {
  undef,
  defined,
  notdefined,
  nonEmpty,
  OL,
  execCmd,
  isNonEmptyString,
  sortArrayOfHashes
} from '@jdeighan/base-utils';

import {
  LOG,
  LOGVALUE
} from '@jdeighan/base-utils/log';

import {
  setDebugging,
  dbgEnter,
  dbgReturn,
  dbg
} from '@jdeighan/base-utils/debug';

import {
  assert,
  croak
} from '@jdeighan/base-utils/exceptions';

import {
  parseCmdArgs
} from '@jdeighan/base-utils/parse-cmd-args';

import {
  isFile,
  mkpath,
  pushCWD,
  popCWD
} from '@jdeighan/base-utils/fs';

import {
  allFilesMatching
} from '@jdeighan/base-utils/read-file';

// --- Any setting of debug prevents execution
debug = undef; // --- 'full' | 'list' | 'json'

fullDebug = false; // --- set true if debug == 'full'

cmdStr = undef;

// --- Keep track of all promises created
//     so at the end, we can use Promise.allSettled()
lPromises = [];

// --- An array of {filePath, cmd, output, err}
lFileRecs = [];

sep = '-'.repeat(40);

// ---------------------------------------------------------------------------
genOutput = () => {
  var hRec, i, j, len, len1;
  // --- Sort alphabetically by filePath
  lFileRecs = sortArrayOfHashes(lFileRecs, 'filePath');
  if (fullDebug) {
    LOG("lFileRecs:");
    LOG('-'.repeat(42));
    LOG(JSON.stringify(lFileRecs, null, 3));
    LOG('-'.repeat(42));
  }
  switch (debug) {
    case 'json':
      LOG(JSON.stringify(lFileRecs, null, 3));
      break;
    case 'full':
    case 'list':
      for (i = 0, len = lFileRecs.length; i < len; i++) {
        hRec = lFileRecs[i];
        if (defined(hRec.cmd)) {
          LOG(`CMD: ${OL(hRec.cmd)}`);
        } else {
          LOG(`FILE: ${OL(hRec.filePath)}`);
        }
      }
      break;
    default:
      for (j = 0, len1 = lFileRecs.length; j < len1; j++) {
        hRec = lFileRecs[j];
        LOG(`FILE: ${OL(hRec.filePath)}`);
        LOG(`CMD: ${OL(hRec.cmd)}`);
        if (defined(hRec.output)) {
          LOG(sep);
          LOG(hRec.output);
          LOG(sep);
        } else if (defined(hRec.err)) {
          LOG(hRec.err.message);
        }
      }
  }
};

// ---------------------------------------------------------------------------
execute = (hRec) => {
  var err;
  try {
    hRec.output = execCmd(hRec.cmd);
  } catch (error) {
    err = error;
    if (fullDebug) {
      LOG(`   ERROR: ${err.message}`);
    }
    hRec.err = err;
  }
};

// ---------------------------------------------------------------------------
getCmd = (filePath) => {
  return cmdStr.replaceAll('<file>', filePath);
};

// ---------------------------------------------------------------------------
handleFile = (filePath) => {
  var cmd, hRec;
  if (fullDebug) {
    LOG(`HANDLE FILE: ${OL(filePath)}`);
  }
  assert(isFile(filePath), `Not a file: ${OL(filePath)}`);
  hRec = {filePath};
  if (defined(cmdStr)) {
    cmd = hRec.cmd = getCmd(filePath);
    if (fullDebug) {
      LOG(`   CMD: ${OL(cmd)}`);
    }
  }
  lFileRecs.push(hRec);
  if (notdefined(debug) && isNonEmptyString(cmd)) {
    execute(hRec);
  }
};

// ---------------------------------------------------------------------------
handleGlob = (glob) => {
  var filePath, hFile, ref;
  if (fullDebug) {
    LOG(`HANDLE GLOB: ${OL(glob)}`);
  }
  ref = allFilesMatching(glob);
  for (hFile of ref) {
    ({filePath} = hFile);
    handleFile(filePath);
  }
};

// ---------------------------------------------------------------------------
// --- Usage:
//    for-each-file <glob> -cmd="coffee -cm <file>"
hCmdArgs = parseCmdArgs({
  hExpect: {
    dir: 'string', // --- dir to search in, def = current dir
    debug: /^full|list|json$/,
    _: [0, Number.MAX_VALUE],
    glob: 'string',
    cmd: 'string' // --- command to run (replace '<file>')
  }
});

({
  // --- NOTE: debug, fullDebug and cmdStr are global vars
  _: lFiles,
  debug,
  dir,
  glob,
  cmd: cmdStr
} = hCmdArgs);

if (debug === 'full') {
  fullDebug = true;
}

if (fullDebug) {
  LOG("DEBUGGING ON in for-each-file");
  LOGVALUE('hCmdArgs', hCmdArgs);
}

assert(defined(debug) || defined(cmdStr), "-cmd option required unless debugging or listing");

if (defined(dir)) {
  pushCWD(dir);
  if (fullDebug) {
    LOG(`set current dir = ${OL(dir)}`);
  }
}

// --- First, cycle through all non-options files
//     NOTE: any filename that contains '*' or '?'
//           is treated as a glob
if (defined(lFiles)) {
  for (i = 0, len = lFiles.length; i < len; i++) {
    str = lFiles[i];
    if (str.includes('*') || str.includes('?')) {
      handleGlob(str);
    } else {
      handleFile(mkpath(str));
    }
  }
}

// --- Next, use option -glob if defined
if (defined(glob)) {
  handleGlob(glob);
}

if (defined(dir)) {
  if (fullDebug) {
    LOG("Restore original current directory");
  }
  popCWD();
}

if (lPromises.length > 0) {
  await (lResults = Promise.allSettled(lPromises));
  for (j = 0, len1 = lResults.length; j < len1; j++) {
    result = lResults[j];
    LOG(result.status);
  }
}

genOutput();