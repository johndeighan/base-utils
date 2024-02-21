// fs.coffee
import pathLib from 'node:path';

import urlLib from 'url';

import fs from 'fs';

import NReadLines from 'n-readlines';

import {
  globSync as glob
} from 'glob';

import {
  open
} from 'node:fs/promises';

import {
  undef,
  defined,
  notdefined,
  nonEmpty,
  toBlock,
  toArray,
  getOptions,
  isNonEmptyString,
  isString,
  isNumber,
  isInteger,
  isHash,
  isArray,
  isIterable,
  isRegExp,
  fromJSON,
  toJSON,
  OL,
  forEachItem,
  jsType
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
  mkDirsForFile
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
  var eager, ent, hContents, hFile, i, len, path, recursive, ref, regexp;
  // --- yields hFile with keys:
  //        path, filePath,
  //        type, root, dir, base, fileName,
  //        name, stub, ext, purpose
  //        (if eager) metadata, lLines
  // --- dir must be a directory
  // --- Valid options:
  //        recursive - descend into subdirectories
  //        eager - read the file and add keys metadata, contents
  //        regexp - only if fileName matches regexp
  dbgEnter('allFilesIn', dir, hOptions);
  ({recursive, eager, regexp} = getOptions(hOptions, {
    recursive: true,
    eager: false,
    regexp: undef
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
      if (defined(regexp)) {
        assert(isRegExp(regexp), "Not a regular expression");
        if (hFile.fileName.match(regexp)) {
          yield hFile;
        }
      } else {
        yield hFile;
      }
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
export var slurp = (filePath, hOptions) => {
  var block, lLines, line, maxLines, ref;
  // --- Valid options:
  //        maxLines: <int>
  dbgEnter('slurp', filePath, hOptions);
  assert(isNonEmptyString(filePath), "empty path");
  ({maxLines} = getOptions(hOptions, {
    maxLines: undef
  }));
  if (defined(maxLines)) {
    assert(isInteger(maxLines), "maxLines must be an integer");
  }
  filePath = mkpath(filePath);
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
  assert(isFile(pkgJsonPath), "Missing package.json at cur dir");
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
export var allLinesIn = function*(filePath) {
  var buffer, reader;
  reader = new NReadLines(filePath);
  while (buffer = reader.next()) {
    yield buffer.toString().replaceAll('\r', '');
  }
};

// ---------------------------------------------------------------------------
// --- reader.close() fails with error if EOF reached
export var forEachLineInFile = (filePath, func, hContext = {}) => {
  var linefunc;
  // --- func gets (line, hContext)
  //     hContext will include keys:
  //        filePath
  //        lineNum - first line is line 1
  linefunc = (line, hContext) => {
    hContext.filePath = filePath;
    hContext.lineNum = hContext.index + 1;
    return func(line, hContext);
  };
  return forEachItem(allLinesIn(filePath), linefunc, hContext);
};

// ---------------------------------------------------------------------------
export var FileWriter = class FileWriter {
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

//# sourceMappingURL=fs.js.map
