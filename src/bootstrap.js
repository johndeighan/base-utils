// Generated by CoffeeScript 2.7.0
// bootstrap.coffee

// --- NOTE: CoffeeScript must be installed globally and locally

// --- We want to run low-level-build.js,
//     however that requires:
//        - src/lib .coffee files must be compiled
//        - src/bin/low-level-build.coffee must be compiled
//        - some fake JS files, corresponding to peggy files, must exist
var err, filePath, i, len, ref;

import {
  globSync
} from 'glob';

import {
  brewFile,
  withExt,
  normalize,
  createFakeFiles
} from './bootstrap-utils.js';

// ---------------------------------------------------------------------------
// --- Compile all coffee files in src/lib and src/bin
console.log("-- bootstrap --");

try {
  ref = globSync('./src/lib/*.coffee');
  // --- Compile all *.coffee files in src/lib
  for (i = 0, len = ref.length; i < len; i++) {
    filePath = ref[i];
    brewFile(filePath);
  }
  // --- Compile src/bin/low-level-build.coffee
  brewFile('./src/bin/low-level-build.coffee');
  // --- Create fake *.js file for each *.peggy file
  //     These will be rebuilt in low-level-build.coffee
  createFakeFiles();
} catch (error) {
  err = error;
  console.error(err);
  process.exit();
}