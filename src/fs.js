// fs.coffee
import fs from 'fs';

import {
  nonEmpty
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
//   slurp - read a file into a string
export var slurp = (filepath) => {
  filepath = filepath.replace(/\//g, "\\");
  return fs.readFileSync(filepath, 'utf8').toString();
};

// ---------------------------------------------------------------------------
//   barf - write a string to a file
export var barf = (filepath, contents) => {
  fs.writeFileSync(filepath, contents);
};

// ---------------------------------------------------------------------------
//   slurpJson - read a file into a string
export var slurpJson = (filepath) => {
  var contents;
  filepath = filepath.replace(/\//g, "\\");
  contents = fs.readFileSync(filepath, 'utf8').toString();
  return JSON.parse(contents);
};

// ---------------------------------------------------------------------------
//   barfJson - write a string to a file
export var barfJson = (filepath, hJson) => {
  var contents;
  contents = JSON.stringify(hJson, null, "\t");
  fs.writeFileSync(filepath, contents);
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
