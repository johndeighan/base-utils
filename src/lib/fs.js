// fs.coffee
import pathLib from 'node:path';

import urlLib from 'url';

import fs from 'fs';

import NReadLines from 'n-readlines';

import {
  globSync as glob
} from 'glob';

import {
  undef,
  defined,
  nonEmpty,
  toBlock,
  toArray,
  getOptions,
  isString,
  isNumber,
  isHash,
  isArray,
  isIterable,
  fromJSON,
  toJSON,
  OL,
  forEachItem
} from '@jdeighan/base-utils';

import {
  fileExt,
  workingDir,
  myself,
  mydir,
  mkpath,
  withExt,
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
  parentDir,
  parallelPath,
  subPath,
  fileDirPath,
  mkDirsForFile
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
  dbg
} from '@jdeighan/base-utils/debug';

import {
  toTAML,
  fromTAML
} from '@jdeighan/base-utils/taml';

import {
  allLinesIn,
  forEachLineInFile
} from '@jdeighan/base-utils/readline';

export {
  fileExt,
  workingDir,
  myself,
  mydir,
  mkpath,
  withExt,
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
  parentDir,
  parallelPath,
  subPath,
  fileDirPath,
  mkDirsForFile,
  allLinesIn,
  forEachLineInFile
};

// ---------------------------------------------------------------------------
export var getPkgJsonDir = () => {
  var dir, lDirs, path, pkgJsonDir, root;
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
export var getTextFileContents = (filePath) => {
  var hResult, inMeta, lLines, lMetaLines, line, metadata, numLines, ref;
  // --- handles metadata if present
  dbgEnter('getTextFileContents', filePath);
  lMetaLines = undef;
  inMeta = false;
  lLines = [];
  numLines = 0;
  ref = allLinesIn(filePath);
  for (line of ref) {
    if ((numLines === 0) && (line === '---')) {
      lMetaLines = ['---'];
      inMeta = true;
    } else if (inMeta) {
      if (line === '---') {
        inMeta = false;
      } else {
        lMetaLines.push(line);
      }
    } else {
      lLines.push(line);
    }
    numLines += 1;
  }
  if (defined(lMetaLines)) {
    metadata = fromTAML(toBlock(lMetaLines));
  } else {
    metadata = undef;
  }
  hResult = {metadata, lLines};
  dbgReturn('getTextFileContents', hResult);
  return hResult;
};

// ---------------------------------------------------------------------------
export var allFilesIn = function*(dir, hOptions = {}) {
  var eager, ent, hContents, hFile, i, len, path, recursive, ref;
  // --- yields hFile with keys:
  //        path, type, root, dir, base, fileName,
  //        name, stub, ext, purpose
  //        (if eager) metadata, lLines
  // --- dir must be a directory
  // --- Valid options:
  //        recursive - descend into subdirectories
  //        eager - read the file and add keys metadata, contents
  dbgEnter('allFilesIn', dir, hOptions);
  ({recursive, eager} = getOptions(hOptions, {
    recursive: true,
    eager: false
  }));
  dir = mkpath(dir);
  assert(isDir(dir), `Not a directory: ${dir}`);
  hOptions = {
    withFileTypes: true,
    recursive
  };
  ref = fs.readdirSync(dir, hOptions);
  for (i = 0, len = ref.length; i < len; i++) {
    ent = ref[i];
    dbg("ENT:", ent);
    if (ent.isFile()) {
      path = mkpath(ent.path, ent.name);
      dbg(`PATH = ${path}`);
      hFile = parsePath(path);
      assert(isHash(hFile), `hFile = ${OL(hFile)}`);
      if (eager) {
        hContents = getTextFileContents(path);
        Object.assign(hFile, hContents);
      }
      dbg('hFile', hFile);
      yield hFile;
    }
  }
  dbgReturn('allFilesIn');
};

// ---------------------------------------------------------------------------
export var dirContents = function(dirPath, pattern = '*', hOptions = {}) {
  var absolute, cwd, dirsOnly, dot, filesOnly, lPaths;
  ({absolute, cwd, dot, filesOnly, dirsOnly} = getOptions(hOptions, {
    absolute: true,
    dot: false,
    filesOnly: false,
    dirsOnly: false
  }));
  assert(!(filesOnly && dirsOnly), "Incompatible options");
  lPaths = glob(pattern, {
    absolute,
    cwd: dirPath,
    dot
  });
  if (filesOnly) {
    return lPaths.filter((path) => {
      return isFile(path);
    });
  } else if (dirsOnly) {
    return lPaths.filter((path) => {
      return isDir(path);
    });
  } else {
    return lPaths;
  }
};

// ---------------------------------------------------------------------------
export var forEachFileInDir = (dir, func, hContext = {}) => {
  var ent, i, len, ref;
  ref = fs.readdirSync(dir, {
    withFileTypes: true
  });
  // --- callback will get parms (filePath, hContext)
  //     DOES NOT RECURSE INTO SUBDIRECTORIES
  for (i = 0, len = ref.length; i < len; i++) {
    ent = ref[i];
    if (ent.isFile()) {
      func(ent.name, dir, hContext);
    }
  }
};

// ---------------------------------------------------------------------------
//   slurp - read a file into a string
export var slurp = (...lParts) => {
  var block, filePath, hOptions, lLines, line, maxLines, ref;
  // --- last argument can be an options hash
  //     Valid options:
  //        maxLines: <int>
  dbgEnter('slurp', lParts);
  assert(lParts.length > 0, "No parameters");
  if (isHash(lParts[lParts.length - 1])) {
    hOptions = lParts.pop();
    assert(lParts.length > 0, "Options hash but no parameters");
    ({maxLines} = hOptions);
  }
  filePath = mkpath(...lParts);
  if (defined(maxLines)) {
    dbg(`maxLines = ${maxLines}`);
    lLines = [];
    ref = allLinesIn(filePath);
    for (line of ref) {
      lLines.push(line);
      if (lLines.length === maxLines) {
        break;
      }
    }
    dbg('lLines', lLines);
    block = toBlock(lLines);
  } else {
    block = fs.readFileSync(filePath, 'utf8').toString().replaceAll('\r', '');
  }
  dbg('block', block);
  dbgReturn('slurp', block);
  return block;
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
export var FileWriter = class FileWriter {
  constructor(filePath1) {
    this.filePath = filePath1;
    assert(isString(this.filePath), `Not a string: ${this.filePath}`);
    this.writer = fs.createWriteStream(this.filePath);
  }

  DESTROY() {
    if (defined(this.writer)) {
      this.end();
    }
  }

  write(...lStrings) {
    var i, len, str;
    assert(defined(this.writer), "Write after end()");
    for (i = 0, len = lStrings.length; i < len; i++) {
      str = lStrings[i];
      assert(isString(str), `Not a string: '${str}'`);
      this.writer.write(str);
    }
  }

  writeln(...lStrings) {
    var i, len, str;
    assert(defined(this.writer), "Write after end()");
    for (i = 0, len = lStrings.length; i < len; i++) {
      str = lStrings[i];
      assert(isString(str), `Not a string: '${str}'`);
      this.writer.write(str);
      this.writer.write("\n");
    }
  }

  end() {
    this.writer.end();
    this.writer = undef;
  }

};

// ---------------------------------------------------------------------------
export var FileWriterSync = class FileWriterSync {
  constructor(filePath1) {
    this.filePath = filePath1;
    assert(isString(this.filePath), `Not a string: ${this.filePath}`);
    this.fullPath = mkpath(this.filePath);
    assert(isString(this.fullPath), `Bad path: ${this.filePath}`);
    this.fd = fs.openSync(this.fullPath, 'w');
  }

  DESTROY() {
    if (defined(this.fd)) {
      this.end();
    }
  }

  write(...lStrings) {
    var i, len, str;
    assert(defined(this.fd), "Write after end()");
    for (i = 0, len = lStrings.length; i < len; i++) {
      str = lStrings[i];
      if (isNumber(str)) {
        fs.writeSync(this.fd, str.toString());
      } else {
        assert(isString(str), `Not a string: '${str}'`);
        fs.writeSync(this.fd, str);
      }
    }
  }

  writeln(...lStrings) {
    this.write(...lStrings);
    this.write("\n");
  }

  end() {
    fs.closeSync(this.fd);
    this.fd = undef;
  }

};

//# sourceMappingURL=fs.js.map
