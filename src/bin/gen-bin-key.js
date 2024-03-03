#!/usr/bin/env node
;
var LOG, binDir, dir, fileName, filePath, hBin, hFile, hJson, jsCode, jsFileName, jsPath, key, pkgJsonPath, ref, stub, value;

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
  rmFile,
  withExt,
  slurp,
  allFilesMatching,
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

ref = allFilesMatching('*.coffee', {
  cwd: binDir
});
for (hFile of ref) {
  ({fileName, filePath, stub} = hFile);
  jsFileName = withExt(fileName, '.js');
  jsPath = withExt(filePath, '.js');
  assert(isFile(jsPath), `Missing file ${jsFileName}`);
  jsCode = slurp(jsPath);
  assert(jsCode.startsWith("#!/usr/bin/env node"), "Missing shebang");
  LOG(`FOUND ${fileName}`);
  hBin[stub] = `./src/bin/${jsFileName}`;
  LOG(`   ${stub} => ${hBin[stub]}`);
}

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

//# sourceMappingURL=gen-bin-key.js.map
