// fs.coffee
var fileFilter, lDirs;

import pathLib from 'node:path';

import urlLib from 'url';

import fs from 'fs';

import NReadLines from 'n-readlines';

import {
  open
} from 'node:fs/promises';

import {
  undef,
  defined,
  notdefined,
  nonEmpty,
  words,
  truncateStr,
  toBlock,
  toArray,
  getOptions,
  isNonEmptyString,
  isString,
  isNumber,
  isInteger,
  deepCopy,
  isHash,
  isArray,
  isIterable,
  isRegExp,
  removeKeys,
  fromJSON,
  toJSON,
  OL,
  forEachItem,
  jsType,
  hasKey,
  fileExt,
  withExt,
  newerDestFilesExist,
  centeredText
} from '@jdeighan/base-utils';

import {
  workingDir,
  myself,
  mydir,
  mkpath,
  samefile,
  relpath,
  mkDir,
  clearDir,
  touch,
  isFile,
  isDir,
  rename,
  pathType,
  rmFile,
  rmDir,
  parsePath,
  dirListing,
  parentDir,
  parallelPath,
  subPath,
  dirContents,
  fileDirPath,
  mkDirsForFile,
  getFileStats,
  lStatFields
} from '@jdeighan/base-utils/ll-fs';

import {
  assert,
  croak
} from '@jdeighan/base-utils/exceptions';

import {
  LOG,
  LOGVALUE
} from '@jdeighan/base-utils/log';

import {
  dbgEnter,
  dbgReturn,
  dbg,
  dbgYield,
  dbgResume
} from '@jdeighan/base-utils/debug';

import {
  toTAML,
  fromTAML
} from '@jdeighan/base-utils/taml';

import {
  isMetaDataStart,
  convertMetaData
} from '@jdeighan/base-utils/metadata';

export {
  fileExt,
  workingDir,
  myself,
  mydir,
  mkpath,
  samefile,
  relpath,
  mkDir,
  clearDir,
  touch,
  isFile,
  isDir,
  rename,
  pathType,
  rmFile,
  rmDir,
  parsePath,
  withExt,
  parentDir,
  parallelPath,
  subPath,
  lStatFields,
  fileDirPath,
  mkDirsForFile,
  getFileStats,
  newerDestFilesExist,
  dirContents,
  dirListing
};

lDirs = [];

// ---------------------------------------------------------------------------
export var pushCWD = (dir) => {
  lDirs.push(process.cwd());
  process.chdir(dir);
};

// ---------------------------------------------------------------------------
export var popCWD = () => {
  var dir;
  assert(lDirs.length > 0, "directory stack is empty");
  dir = lDirs.pop();
  process.chdir(dir);
};

// ---------------------------------------------------------------------------
export var isProjRoot = (dir = '.', hOptions = {}) => {
  var dirPath, filePath, i, j, lExpectedDirs, lExpectedFiles, len, len1, name, strict;
  ({strict} = getOptions(hOptions, {
    strict: false
  }));
  filePath = `${dir}/package.json`;
  if (!isFile(filePath)) {
    return false;
  }
  if (!strict) {
    return true;
  }
  lExpectedFiles = ['package-lock.json', 'README.md', '.gitignore'];
  for (i = 0, len = lExpectedFiles.length; i < len; i++) {
    name = lExpectedFiles[i];
    filePath = `${dir}/${name}`;
    if (!isFile(filePath)) {
      return false;
    }
  }
  lExpectedDirs = ['node_modules', '.git', 'src', 'src/lib', 'src/bin', 'test'];
  for (j = 0, len1 = lExpectedDirs.length; j < len1; j++) {
    name = lExpectedDirs[j];
    dirPath = `${dir}/${name}`;
    if (!isDir(dirPath)) {
      return false;
    }
  }
  return true;
};

// ---------------------------------------------------------------------------
export var getPkgJsonDir = () => {
  var dir, path, pkgJsonDir, root;
  pkgJsonDir = undef;
  // --- First, get the directory this file is in
  dir = mydir(import.meta.url);
  // --- parse into parts
  ({root, lDirs} = parsePath(dir));
  // --- search upward for package.json
  while (lDirs.length > 0) {
    path = mkpath(root, lDirs, 'package.json');
    if (isFile(path)) {
      return mkpath(root, lDirs);
    }
    lDirs.pop();
    dir = mkpath('..', dir);
  }
};

// ---------------------------------------------------------------------------
export var getPkgJsonPath = () => {
  var filePath;
  filePath = mkpath(process.cwd(), 'package.json');
  assert(isFile(filePath), "Missing pacakge.json at cur dir");
  return filePath;
};

// ---------------------------------------------------------------------------
export var isFakeFile = (filePath) => {
  var firstLine, reader;
  if (!fs.existsSync(filePath)) {
    throw new Error(`file ${filePath} does not exist`);
  }
  reader = new NReadLines(filePath);
  firstLine = reader.next().toString();
  return firstLine.match(/\/\/\s*fake/);
};

// ---------------------------------------------------------------------------
// --- return true to include file
fileFilter = (filePath) => {
  return isFile(filePath) && notdefined(filePath.match(/\bnode_modules\b/));
};

// ---------------------------------------------------------------------------
//   slurp - read a file into a string
export var slurp = (filePath, hOptions) => {
  var block;
  dbgEnter('slurp', filePath, hOptions);
  assert(isNonEmptyString(filePath), "empty path");
  filePath = mkpath(filePath);
  assert(isFile(filePath), `Not a file: ${OL(filePath)}`);
  block = fs.readFileSync(filePath, 'utf8').toString().replaceAll('\r', '');
  dbgReturn('slurp', block);
  return block;
};

// ---------------------------------------------------------------------------
//   slurpJSON - read a file into a hash
export var slurpJSON = (filePath) => {
  return fromJSON(slurp(filePath));
};

// ---------------------------------------------------------------------------
//   slurpTAML - read a file into a hash
export var slurpTAML = (filePath) => {
  return fromTAML(slurp(filePath));
};

// ---------------------------------------------------------------------------
//   slurpPkgJSON - read package.json into a hash
export var slurpPkgJSON = () => {
  var pkgJsonPath;
  pkgJsonPath = getPkgJsonPath();
  assert(isFile(pkgJsonPath), `Missing package.json at cur dir ${OL(process.cwd())}`);
  return slurpJSON(pkgJsonPath);
};

// ---------------------------------------------------------------------------
//   barf - write a string to a file
//          will ensure that all necessary directories exist
export var barf = (text, ...lParts) => {
  var filePath;
  assert(lParts.length > 0, "Missing file path");
  filePath = mkpath(...lParts);
  mkDirsForFile(filePath);
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
  assert(isHash(ds) || isArray(ds), "ds not a hash or array");
  barf(toTAML(ds), ...lParts);
};

// ---------------------------------------------------------------------------
//   barfAST - write AST to a file
//      Valid options:
//         full = write out complete AST
export var barfAST = (hAST, filePath, hOptions = {}) => {
  var full, hCopy, lSortBy;
  ({full} = getOptions(hOptions, {
    full: false
  }));
  lSortBy = words("type params body left right");
  if (full) {
    barf(toTAML(hAST, {
      sortKeys: lSortBy
    }), filePath);
  } else {
    hCopy = deepCopy(hAST);
    removeKeys(hCopy, words('start end extra declarations loc range tokens comments', 'assertions implicit optional async generate hasIndentedBody'));
    barf(toTAML(hCopy, {
      sortKeys: lSortBy
    }), filePath);
  }
};

// ---------------------------------------------------------------------------
//   barfPkgJSON - write a string to a file
export var barfPkgJSON = (hJson) => {
  barfJSON(hJson, getPkgJsonPath());
};

// ---------------------------------------------------------------------------
export var FileWriter = class {
  constructor(filePath1, hOptions) {
    this.filePath = filePath1;
    this.hOptions = getOptions(hOptions, {
      async: false
    });
    this.async = this.hOptions.async;
    this.fullPath = mkpath(this.filePath);
  }

  // ..........................................................
  convert(item) {
    // --- convert arbitrary value into a string
    switch (jsType(item)[0]) {
      case 'string':
        return item;
      case 'number':
        return item.toString();
      default:
        return OL(item);
    }
  }

  // ..........................................................
  async write(...lItems) {
    var i, item, j, k, lStrings, len, len1, len2, str;
    lStrings = [];
    for (i = 0, len = lItems.length; i < len; i++) {
      item = lItems[i];
      lStrings.push(this.convert(item));
    }
    // --- open on first use
    if (this.async) {
      if (notdefined(this.writer)) {
        this.fd = (await open(this.fullPath, 'w'));
        this.writer = this.fd.createWriteStream();
      }
      for (j = 0, len1 = lStrings.length; j < len1; j++) {
        str = lStrings[j];
        this.writer.write(str);
      }
    } else {
      if (notdefined(this.fd)) {
        this.fd = fs.openSync(this.fullPath, 'w');
      }
      for (k = 0, len2 = lStrings.length; k < len2; k++) {
        str = lStrings[k];
        fs.writeSync(this.fd, str);
      }
    }
  }

  // ..........................................................
  async writeln(...lItems) {
    await this.write(...lItems, "\n");
  }

  // ..........................................................
  DESTROY() {
    this.end();
  }

  // ..........................................................
  async close() {
    if (this.async) {
      if (defined(this.writer)) {
        await this.writer.close();
        this.writer = undef;
      }
    } else {
      if (defined(this.fd)) {
        fs.closeSync(this.fd);
        this.fd = undef;
      }
    }
  }

};
