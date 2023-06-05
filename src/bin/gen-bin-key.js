#!/usr/bin/env node
;
var LOG, binDir, dir, hBin, hJson, key, pkgJsonPath, value;

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
  // import {LOG} from '@jdeighan/base-utils/log'
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

binDir = mkpath(dir, 'src', 'bin');

LOG = (str) => {
  return console.log(str);
};

// ---------------------------------------------------------------------------

// 1. Error if current directory has no `package.json` file
assert(isFile(pkgJsonPath), "Not in package root dir");

LOG("package.json exists");

if (!isDir(binDir)) {
  console.log(`No ${binDir} dir, exiting`);
  process.exit();
}

LOG(`dir ${binDir} exists`);

// 3. For every *.coffee file in the 'bin' directory:
//       - error if no corresponding JS file
//       - save stub and filename in hBin
//    For every *.js file in the 'bin' directory:
//       - error if JS file doesn't start with a shebang line
hBin = {};

forEachFileInDir(binDir, (fname) => {
  var _, coffeeFileName, coffeePath, jsCode, jsFileName, jsPath, lMatches, stub;
  if (lMatches = fname.match(/^(.*)\.coffee$/)) {
    [_, stub] = lMatches;
    jsFileName = `${stub}.js`;
    jsPath = mkpath(dir, 'src', 'bin', jsFileName);
    coffeeFileName = `${stub}.coffee`;
    coffeePath = mkpath(dir, 'src', 'bin', coffeeFileName);
    LOG(`FOUND ${fname}`);
    // --- Check that corresponding *.js file exists
    assert(isFile(jsPath), `Missing file ${jsPath}`);
    // --- Check that *.js file has shebang line
    jsCode = slurp(jsPath);
    assert(jsCode.startsWith("#!/usr/bin/env node"), "Missing shebang");
    hBin[stub] = `./src/bin/${jsFileName}`;
    return LOG(`   ${stub} => ${hBin[stub]}`);
  }
});

// 4. Add sub-keys to key 'bin' in package.json (create if not exists)
if (isEmpty(hBin)) {
  LOG("No bin keys to set");
} else {
  LOG("SET 'bin' key in package.json");
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

LOG("DONE");
