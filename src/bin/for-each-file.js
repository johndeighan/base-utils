#!/usr/bin/env node
;
var cmdStr, debug, dir, filePath, glob, hCmdArgs, hFile, hOptions, handleFile, i, lFiles, len, ref;

import {
  // for-each-file.coffee
  undef,
  defined,
  notdefined,
  nonEmpty,
  LOG,
  execCmd
} from '@jdeighan/base-utils';

import {
  assert
} from '@jdeighan/base-utils/exceptions';

import {
  parseCmdArgs
} from '@jdeighan/base-utils/parse-cmd-args';

import {
  allFilesIn
} from '@jdeighan/base-utils/fs';

debug = false;

cmdStr = undef;

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
  // --- NOTE: debug and cmdStr are global vars
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
for (i = 0, len = lFiles.length; i < len; i++) {
  filePath = lFiles[i];
  handleFile(filePath);
}

// --- Next, use glob if defined
if (defined(glob)) {
  hOptions = {
    pattern: glob,
    eager: false
  };
  ref = allFilesIn(dir, hOptions);
  for (hFile of ref) {
    handleFile(hFile.filePath);
  }
}

//# sourceMappingURL=for-each-file.js.map
