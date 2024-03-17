// base-build.coffee

// --- build this library
// --- NOTE: If this file is modified or deleted, you must execute:
//           npx coffee -cmb --no-header ./src/base-build.coffee
//           npm run build
// --- We want to run low-level-build.js, however that requires:
//        - libraries must be compiled
//        - low-level-build.coffee must be compiled
var compile, filePath, i, len, ref;

import {
  execSync
} from 'node:child_process';

import fs from 'node:fs';

import {
  globSync
} from 'glob';

// ---------------------------------------------------------------------------
// --- These 3 functions are duplicates of those in base-utils.coffee
//     however, we can't be sure that has been compiled
export var execCmd = (cmdLine) => {
  var err;
  try {
    execSync(cmdLine, {
      encoding: 'utf8',
      windowsHide: true
    });
  } catch (error) {
    err = error;
    console.log(`ERROR: exec of '${cmdLine}' failed`);
    process.exit();
  }
};

// ---------------------------------------------------------------------------
export var withExt = (path, newExt) => {
  var _, lMatches, pre;
  if (newExt.indexOf('.') !== 0) {
    newExt = '.' + newExt;
  }
  if (lMatches = path.match(/^(.*)\.[^\.]+$/)) {
    [_, pre] = lMatches;
    return pre + newExt;
  }
  console.log(`Bad path: '${path}'`);
  return process.exit();
};

// ---------------------------------------------------------------------------
export var newerDestFilesExist = (srcPath, ...lDestPaths) => {
  var destModTime, destPath, i, len, srcModTime;
  for (i = 0, len = lDestPaths.length; i < len; i++) {
    destPath = lDestPaths[i];
    if (!fs.existsSync(destPath)) {
      return false;
    }
    srcModTime = fs.statSync(srcPath).mtimeMs;
    destModTime = fs.statSync(destPath).mtimeMs;
    if (destModTime < srcModTime) {
      return false;
    }
  }
  return true;
};

// ---------------------------------------------------------------------------
compile = (filePath) => {
  var jsPath, mapPath;
  jsPath = withExt(filePath, '.js');
  mapPath = withExt(filePath, '.js.map');
  if (newerDestFilesExist(filePath, jsPath, mapPath)) {
    return;
  }
  console.log(filePath.replaceAll('\\', '/'));
  execCmd(`npx coffee -cmb --no-header ${filePath}`);
};

// ---------------------------------------------------------------------------
console.log("-- base-build --");

ref = globSync('./src/lib/*.coffee');
// --- Compile all *.coffee files in src/lib
for (i = 0, len = ref.length; i < len; i++) {
  filePath = ref[i];
  compile(filePath);
}

// --- Compile low-level-build.coffee
compile("src/bin/low-level-build.coffee");

//# sourceMappingURL=base-build.js.map
