#!/usr/bin/env node
;
var binDir, dir, hBin, hJson, key, pkgJsonPath, value;

import {
  // gen-bin-key.coffee
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

// 4. For every *.coffee file in the 'bin' directory:
//       - error if no corresponding JS file
//       - save stub and filename in hBin
//       - add shebang line if not present
//    For every *.js file in the 'bin' directory:
//       - add shebang line if not present
hBin = {};

forEachFileInDir(binDir, (fname) => {
  var _, coffeeCode, coffeeFileName, coffeePath, ext, firstLine, flag, jsCode, jsFileName, jsPath, lMatches, pos, stub;
  if (lMatches = fname.match(/^(.*)\.(coffee|js)$/)) {
    console.log(`FOUND ${fname}`);
    [_, stub, ext] = lMatches;
    console.log(`NOTE: ext = ${ext}`);
    jsFileName = `${stub}.js`;
    jsPath = mkpath(dir, 'bin', jsFileName);
    coffeeFileName = `${stub}.coffee`;
    coffeePath = mkpath(dir, 'bin', coffeeFileName);
    if (ext === 'coffee') {
      assert(isFile(jsPath), `Missing file ${jsPath}`);
      hBin[stub] = `./bin/${jsFileName}`;
      // --- Add shebang line if not present
      coffeeCode = slurp(coffeePath);
      pos = coffeeCode.indexOf('\n');
      if (pos === -1) {
        firstLine = coffeeCode;
      } else {
        firstLine = coffeeCode.substring(0, pos);
      }
      if (firstLine.indexOf("#!/usr/bin/env node") === -1) {
        console.log(`   - adding shebang line to ${coffeeFileName}`);
        //				rmFileSync coffeePath
        return barf(coffeePath, "`#!/usr/bin/env node\n`\n" + coffeeCode);
      } else {
        return console.log("   - file has shebang line");
      }
    } else if (ext === 'js') {
      console.log("HAS js ext");
      jsCode = slurp(jsPath);
      console.log("AFTER slurp");
      flag = jsCode.startsWith("#!/usr/bin/env node");
      console.log(`FLAG = ${flag}`);
      if (flag) {
        console.log("   - has shebang line if ! flag console.log " - adding(shebang(line(to)))); //{jsFileName}"
        //				rmFileSync jsPath
        return barf(jsPath, "#!/usr/bin/env node\n" + jsCode);
      }
    }
  }
});

// 5. Add sub-keys to key 'bin' in package.json (create if not exists)
if (nonEmpty(hBin)) {
  console.log("SET 'bin' key in package.json");
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
