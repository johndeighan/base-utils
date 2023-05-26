// Generated by CoffeeScript 2.7.0
// gen-bin-key.coffee
var binDir, dir, hBin, hJson, key, pkgJsonPath, value;

import {
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
  barf,
  forEachFileInDir,
  slurpJson,
  barfJson
} from '@jdeighan/base-utils/fs';

// ---------------------------------------------------------------------------

// 1. Error if current directory has no `package.json` file
dir = process.cwd();

pkgJsonPath = mkpath(dir, 'package.json');

assert(isFile(pkgJsonPath), "Not in package root dir");

// 2. If no bin/ dir, exit
binDir = `${dir}\\bin`;

if (!isDir(binDir)) {
  console.log(`Missing directory ${binDir}`);
  process.exit();
}

// 4. For every *.coffee file in the `bin` directory:
//       - error if no corresponding JS file
//       - save stub and filename in hBin
//    For every *.js file
//       - add a shebang line if not already there
hBin = {};

forEachFileInDir(binDir, (fname) => {
  var _, ext, jsCode, jsFileName, jsPath, lMatches, stub;
  if (lMatches = fname.match(/^(.*)\.(coffee|js)$/)) {
    [_, stub, ext] = lMatches;
    jsFileName = `${stub}.js`;
    jsPath = mkpath(dir, 'bin', jsFileName);
    switch (ext) {
      case 'coffee':
        assert(isFile(jsPath), `Missing file ${jsPath}`);
        console.log(`FOUND ${fname} and ${jsFileName}`);
        return hBin[stub] = `./bin/${jsFileName}`;
      case 'js':
        jsCode = slurp(jsPath);
        if (!jsCode.startsWith("#!/usr/bin/env node")) {
          console.log(`Adding shebang line to ${jsFileName}`);
          rmFileSync(jsPath);
          return barf(jsPath, "#!/usr/bin/env node\n" + jsCode);
        }
    }
  }
});

// 5. Add sub-keys to key 'bin' in package.json (create if not exists)
if (nonEmpty(hBin)) {
  hJson = slurpJson(pkgJsonPath);
  if (!hJson.hasOwnProperty('bin')) {
    hJson.bin = {};
  }
  for (key in hBin) {
    value = hBin[key];
    hJson.bin[key] = value;
  }
  barfJson(pkgJsonPath, hJson);
}

console.log("DONE");
