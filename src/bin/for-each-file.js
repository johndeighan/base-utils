#!/usr/bin/env node
;
var cmdStr, debug, dir, glob, hCmdArgs, handleFile, handleGlob, i, lFiles, len, name;

import {
  // for-each-file.coffee
  undef,
  defined,
  notdefined,
  nonEmpty,
  LOG,
  OL,
  execCmd
} from '@jdeighan/base-utils';

import {
  setDebugging
} from '@jdeighan/base-utils/debug';

import {
  assert
} from '@jdeighan/base-utils/exceptions';

import {
  parseCmdArgs
} from '@jdeighan/base-utils/parse-cmd-args';

import {
  allFilesMatching
} from '@jdeighan/base-utils/fs';

debug = false;

cmdStr = undef;

dir = undef;

setDebugging('allFilesMatching');

// ---------------------------------------------------------------------------
handleFile = (filePath) => {
  var cmd;
  if (debug) {
    if (defined(cmdStr)) {
      cmd = cmdStr.replaceAll('<file>', filePath);
      LOG(`CMD: ${cmd}`);
    } else {
      LOG(`FILE: ${filePath}`);
    }
  } else {
    cmd = cmdStr.replaceAll('<file>', filePath);
    execCmd(cmd);
  }
};

// ---------------------------------------------------------------------------
handleGlob = (glob) => {
  var filePath, hFile, hOptions, ref;
  if (debug) {
    LOG(`GLOB: ${OL(glob)}`);
  }
  hOptions = {
    pattern: glob,
    eager: false,
    cwd: dir
  };
  ref = allFilesMatching(glob, hOptions);
  for (hFile of ref) {
    ({filePath} = hFile);
    if (debug) {
      LOG(`   GLOB FILE: ${OL(filePath)}`);
    }
    handleFile(hFile.filePath);
  }
};

// ---------------------------------------------------------------------------
// --- Usage:
//    for-each-file *.coffee -cmd="coffee -cm <file>"
hCmdArgs = parseCmdArgs({
  hExpect: {
    _: [0, Number.MAX_VALUE],
    d: 'boolean', // debug mode - don't exec, just print
    dir: 'string', // dir to search in, def = current dir
    glob: 'string',
    cmd: 'string' // command to run (replace '<file>')
  }
});

({
  // --- NOTE: debug, cmdStr and dir are global vars
  _: lFiles,
  d: debug,
  dir,
  glob,
  cmd: cmdStr
} = hCmdArgs);

LOG("Running for-each-file");

if (debug) {
  LOG("DEBUGGING ON");
  LOG('hCmdArgs', hCmdArgs);
}

if (notdefined(dir)) {
  dir = process.cwd();
}

// --- First, cycle through all non-options files
//     NOTE: any filename that contains '*' or '?'
//           is treated as a glob
if (defined(lFiles)) {
  for (i = 0, len = lFiles.length; i < len; i++) {
    name = lFiles[i];
    if (name.includes('*') || name.includes('?')) {
      handleGlob(name);
    } else {
      handleFile(name);
    }
  }
}

// --- Next, use glob if defined
if (defined(glob)) {
  handleGlob(glob);
}

//# sourceMappingURL=for-each-file.js.map
