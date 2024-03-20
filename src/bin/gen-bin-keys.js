#!/usr/bin/env node
// gen-bin-keys.coffee
var fileName, filePath, h, hBin, hJson, jsCode, jsPath, key, ref, ref1, shebang, short_name, stub, tla, value;

import {
  undef,
  defined,
  notdefined,
  isEmpty,
  nonEmpty,
  OL,
  execCmd,
  hasKey,
  withExt,
  newerDestFilesExist
} from '@jdeighan/base-utils';

import {
  assert,
  croak
} from '@jdeighan/base-utils/exceptions';

import {
  LOG
} from '@jdeighan/base-utils/log';

import {
  isFile,
  isDir,
  mkpath,
  rmFile,
  isProjRoot,
  slurp,
  allFilesMatching,
  slurpJSON,
  barf,
  barfJSON
} from '@jdeighan/base-utils/fs';

shebang = "#!/usr/bin/env node";

// ---------------------------------------------------------------------------
tla = (stub) => {
  var _, a, b, c, lMatches, result;
  if (lMatches = stub.match(/^([a-z])(?:[a-z]*)\-([a-z])(?:[a-z]*)\-([a-z])(?:[a-z]*)$/)) {
    [_, a, b, c] = lMatches;
    result = a + b + c;
    return result;
  } else {
    return undef;
  }
};

// ---------------------------------------------------------------------------
// 1. makes sure current directory is project root
// 2. compile *.coffee files in src/bin if not up to date
// 3. Add shebang line to *.js files in src/bin if missing
// 4. Add subkeys under 'bin' key in package.json if missing
// ---------------------------------------------------------------------------

// 1. Error if current directory is not a project root directory
assert(isProjRoot('strict'), "Not in package root dir");

ref = allFilesMatching('./src/bin/**/*.coffee');
// 2 . For every *.coffee file in the 'src/bin' directory:
//       - compile to JS if no corresponding JS file
//         OR if *.coffee file is newer than the JS file
for (h of ref) {
  ({filePath, fileName} = h);
  LOG(`FOUND ${fileName}`);
  jsPath = withExt(filePath, '.js');
  if (!newerDestFilesExist(h.filePath, jsPath)) {
    LOG("   - compile");
    execCmd(`npx coffee -cmb --no-header ${filePath}`);
  }
  assert(isFile(jsPath), `Missing JS file ${OL(jsPath)}`);
}

// 3 . For every *.js file in the 'src/bin' directory:
//       - add shebang line if missing
//       - save <stub>: <path> in hBin
hBin = {};

ref1 = allFilesMatching('./src/bin/**/*.js');
for (h of ref1) {
  ({filePath, fileName, stub} = h);
  LOG(`FOUND ${fileName}`);
  jsCode = slurp(filePath);
  if (!jsCode.startsWith(shebang)) {
    LOG("   - add shebang line");
    barf(shebang + "\n" + jsCode, filePath);
  }
  hBin[stub] = `./src/bin/${fileName}`;
  LOG(`   ${stub} => ${hBin[stub]}`);
  short_name = tla(stub);
  if (defined(short_name)) {
    hBin[short_name] = `./src/bin/${fileName}`;
    LOG(`   ${short_name} => ${hBin[stub]}`);
  }
}

// 4. Add sub-keys to key 'bin' in package.json
//    (create if not exists)
if (isEmpty(hBin)) {
  LOG("No bin keys to set");
} else {
  LOG("SET 'bin' sub-keys in package.json");
  hJson = slurpJSON("./package.json");
  if (!hasKey(hJson, 'bin')) {
    LOG("   - add key 'bin'");
    hJson.bin = {};
  }
  for (key in hBin) {
    value = hBin[key];
    if (notdefined(hJson.bin[key])) {
      LOG(`   - add bin/${key} = ${value}`);
      hJson.bin[key] = value;
    }
  }
  barfJSON(hJson, "./package.json");
}

LOG("DONE");