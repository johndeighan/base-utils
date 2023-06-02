#!/usr/bin/env node
;
var binDir, dir, hBin, hJson, key, pkgJsonPath, value;

import {
  // gen-bin-key.coffee
  undef,
  isEmpty,
  nonEmpty
} from '@jdeighan/base-utils';

import {
  assert,
  croak
} from '@jdeighan/base-utils/exceptions';

import {
  isFile,
  isDir,
  mkpath,
  rmFileSync,
  mkdirSync,
  slurp,
  forEachFileInDir,
  slurpJSON,
  barfJSON
} from '@jdeighan/base-utils/fs';

dir = process.cwd();

pkgJsonPath = mkpath(dir, 'package.json');

binDir = mkpath(dir, 'bin');

// ---------------------------------------------------------------------------

// 1. Error if current directory has no `package.json` file
assert(isFile(pkgJsonPath), "Not in package root dir");

if (!isDir(binDir)) {
  console.log(`No ${binDir} dir, exiting`);
  process.exit();
}

// 4. For every *.coffee file in the 'bin' directory:
//       - error if no corresponding JS file
//       - save stub and filename in hBin
//    For every *.js file in the 'bin' directory:
//       - error if JS file doesn't start with a shebang line
hBin = {};

forEachFileInDir(binDir, (fname) => {
  var _, coffeeFileName, coffeePath, ext, jsCode, jsFileName, jsPath, lMatches, stub;
  if (lMatches = fname.match(/^(.*)\.(coffee|js)$/)) {
    console.log(`FOUND ${fname}`);
    [_, stub, ext] = lMatches;
    jsFileName = `${stub}.js`;
    jsPath = mkpath(dir, 'bin', jsFileName);
    coffeeFileName = `${stub}.coffee`;
    coffeePath = mkpath(dir, 'bin', coffeeFileName);
    if (ext === 'coffee') {
      assert(isFile(jsPath), `Missing file ${jsPath}`);
      return hBin[stub] = `./bin/${jsFileName}`;
    } else if (ext === 'js') {
      jsCode = slurp(jsPath);
      return assert(jsCode.startsWith("#!/usr/bin/env node"), "Missing shebang");
    }
  }
});

// 5. Add sub-keys to key 'bin' in package.json (create if not exists)
if (isEmpty(hBin)) {
  console.log("No bin keys to set");
} else {
  console.log("SET 'bin' key in package.json");
  hJson = slurpJSON(pkgJsonPath);
  if (!hJson.hasOwnProperty('bin')) {
    hJson.bin = {};
  }
  for (key in hBin) {
    value = hBin[key];
    hJson.bin[key] = value;
  }
  barfJSON(hJson, pkgJsonPath);
}

console.log("DONE");
