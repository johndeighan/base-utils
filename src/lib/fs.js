// fs.coffee
import fs from 'fs';

import NReadLines from 'n-readlines';

import {
  undef,
  defined,
  nonEmpty,
  isHash,
  toBlock
} from '@jdeighan/base-utils';

import {
  assert,
  croak
} from '@jdeighan/base-utils/exceptions';

import {
  dbgEnter,
  dbgReturn,
  dbg
} from '@jdeighan/base-utils/debug';

import {
  toTAML,
  fromTAML
} from '@jdeighan/base-utils/taml';

// ---------------------------------------------------------------------------
export var mkpath = (...lParts) => {
  var _, drive, lMatches, rest, str;
  dbgEnter('mkpath', lParts);
  lParts = lParts.filter((x) => {
    return nonEmpty(x);
  });
  str = lParts.join('/');
  str = str.replaceAll('\\', '/');
  if (lMatches = str.match(/^([A-Z])\:(.*)$/)) {
    [_, drive, rest] = lMatches;
    str = `${drive.toLowerCase()}:${rest}`;
  }
  dbgReturn('mkpath', str);
  return str;
};

// ---------------------------------------------------------------------------
export var getPkgJsonPath = () => {
  var filePath;
  filePath = mkpath(process.cwd(), 'package.json');
  assert(isFile(filePath), "Missing pacakge.json at cur dir");
  return filePath;
};

// ---------------------------------------------------------------------------
export var isFile = (...lParts) => {
  var filePath, result;
  dbgEnter('isFile', lParts);
  filePath = mkpath(...lParts);
  dbg(`filePath is '${filePath}'`);
  try {
    result = fs.lstatSync(filePath).isFile();
    dbgReturn('isFile', result);
    return result;
  } catch (error) {
    dbgReturn('isFile', false);
    return false;
  }
};

// ---------------------------------------------------------------------------
export var isDir = (...lParts) => {
  var dirPath, result;
  dbgEnter('isDir', lParts);
  dirPath = mkpath(...lParts);
  dbg(`dirPath is '${dirPath}'`);
  try {
    result = fs.lstatSync(dirPath).isDirectory();
    dbgReturn('isDir', result);
    return result;
  } catch (error) {
    dbgReturn('isDir', false);
    return false;
  }
};

// ---------------------------------------------------------------------------
export var rmFileSync = (filepath) => {
  assert(isFile(filepath), `${filepath} is not a file`);
  fs.rmSync(filepath);
};

// ---------------------------------------------------------------------------
export var mkdirSync = (dirpath) => {
  var err;
  try {
    fs.mkdirSync(dirpath);
  } catch (error) {
    err = error;
    if (err.code === 'EEXIST') {
      console.log('Directory exists. Please choose another name');
    } else {
      console.log(err);
    }
    process.exit(1);
  }
};

// ---------------------------------------------------------------------------
export var fromJSON = (strJson) => {
  // --- string to data structure
  return JSON.parse(strJson);
};

// ---------------------------------------------------------------------------
export var toJSON = (hJson) => {
  // --- data structure to string
  return JSON.stringify(hJson, null, "\t");
};

// ---------------------------------------------------------------------------
//   slurp - read a file into a string
export var slurp = (...lParts) => {
  var buffer, contents, filePath, hOptions, lLines, maxLines, nLines, reader;
  // --- last argument can be an options hash
  //     Valid options:
  //        maxLines: <int>
  assert(lParts.length > 0, "No parameters");
  if (isHash(lParts[lParts.length - 1])) {
    hOptions = lParts.pop();
    assert(lParts.length > 0, "Options hash but no parameters");
    ({maxLines} = hOptions);
  }
  filePath = mkpath(...lParts);
  if (defined(maxLines)) {
    lLines = [];
    reader = new NReadLines(filePath);
    nLines = 0;
    while ((buffer = reader.next()) && (nLines < maxLines)) {
      nLines += 1;
      // --- text is split on \n chars,
      //     we also need to remove \r chars
      lLines.push(buffer.toString().replace(/\r/g, ''));
    }
    contents = toBlock(lLines);
  } else {
    contents = fs.readFileSync(filePath, 'utf8').toString();
  }
  return contents;
};

// ---------------------------------------------------------------------------
//   slurpJSON - read a file into a hash
export var slurpJSON = (...lParts) => {
  return fromJSON(slurp(...lParts));
};

// ---------------------------------------------------------------------------
//   slurpTAML - read a file into a hash
export var slurpTAML = (...lParts) => {
  return fromTAML(slurp(...lParts));
};

// ---------------------------------------------------------------------------
//   slurpPkgJSON - read package.json into a hash
export var slurpPkgJSON = (...lParts) => {
  var pkgJsonPath;
  if (lParts.length === 0) {
    pkgJsonPath = getPkgJsonPath();
  } else {
    pkgJsonPath = mkpath(...lParts);
    assert(isFile(pkgJsonPath), "Missing package.json at cur dir");
  }
  return slurpJSON(pkgJsonPath);
};

// ---------------------------------------------------------------------------
//   barf - write a string to a file
export var barf = (text, ...lParts) => {
  var filePath;
  assert(lParts.length > 0, "Missing file path");
  filePath = mkpath(...lParts);
  fs.writeFileSync(filePath, text);
};

// ---------------------------------------------------------------------------
//   barfJSON - write a string to a file
export var barfJSON = (hJson, ...lParts) => {
  assert(isHash(hJson), "hJson not a hash");
  barf(toJSON(hJson), ...lParts);
};

// ---------------------------------------------------------------------------
//   barfTAML - write a string to a file
export var barfTAML = (ds, ...lParts) => {
  assert(isHash(hJson), "hJson not a hash");
  barf(toTAML(ds), ...lParts);
};

// ---------------------------------------------------------------------------
//   barfPkgJSON - write a string to a file
export var barfPkgJSON = (hJson, ...lParts) => {
  var pkgJsonPath;
  if (lParts.length === 0) {
    pkgJsonPath = getPkgJsonPath();
  } else {
    pkgJsonPath = mkpath(...lParts);
    assert(isFile(pkgJsonPath), "Missing package.json at cur dir");
  }
  barfJSON(hJson, pkgJsonPath);
};

// ---------------------------------------------------------------------------
export var forEachFileInDir = (dir, func) => {
  var ent, i, len, ref;
  ref = fs.readdirSync(dir, {
    withFileTypes: true
  });
  // --- callback will get parms (filename, dir)
  //     NOT RECURSIVE
  for (i = 0, len = ref.length; i < len; i++) {
    ent = ref[i];
    if (ent.isFile()) {
      func(ent.name, dir);
    }
  }
};

// ---------------------------------------------------------------------------
export var hasPackageJson = (...lParts) => {
  return isFile(...lParts);
};
