// fs.coffee
import pathLib from 'node:path';

import urlLib from 'url';

import fs from 'fs';

import NReadLines from 'n-readlines';

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
  toJSON
} from '@jdeighan/base-utils';

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
  myself,
  mydir,
  mkpath,
  mkDir,
  touch,
  isFile,
  isDir,
  pathType,
  rmFile,
  rmDir,
  parsePath,
  parseSource
} from '@jdeighan/base-utils/ll-fs';

export {
  myself,
  mydir,
  mkpath,
  mkDir,
  touch,
  isFile,
  isDir,
  pathType,
  rmFile,
  rmDir,
  parsePath,
  parseSource
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
  var eager, ent, hContents, hFileInfo, i, len, path, recursive, ref;
  // --- yields hFileInfo with keys:
  //        filePath, fileName, stub, ext, metadata, contents
  // --- dir must be a directory
  // --- Valid options:
  //        recursive - descend into subdirectories
  //        eager - read the file and add keys metadata, contents
  dbgEnter('allFilesIn', dir, hOptions);
  ({recursive, eager} = getOptions(hOptions, {
    recursive: true,
    eager: false
  }));
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
      hFileInfo = parseSource(path);
      assert(defined(hFileInfo), "allFilesIn(): hFileInfo = undef");
      if (eager) {
        hContents = getTextFileContents(hFileInfo.filePath);
        Object.assign(hFileInfo, hContents);
      }
      dbg('hFileInfo', hFileInfo);
      yield hFileInfo;
    }
  }
  dbgReturn('allFilesIn');
};

// ---------------------------------------------------------------------------
export var allLinesIn = function*(filePath) {
  var buffer, reader;
  reader = new NReadLines(filePath);
  while ((buffer = reader.next())) {
    yield buffer.toString().replace(/\r/g, '');
  }
};

export var lineIterator = allLinesIn; // for backward compatibility


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
export var forEachItem = (iter, func, hContext = {}) => {
  var err, index, item, lItems, result;
  // --- func() gets (item, hContext)
  assert(isIterable(iter), "not an iterable");
  lItems = [];
  index = 0;
  for (item of iter) {
    hContext.index = index;
    index += 1;
    try {
      result = func(item, hContext);
      if (defined(result)) {
        lItems.push(result);
      }
    } catch (error) {
      err = error;
      reader.close();
      if (isString(err)) {
        return lItems;
      } else {
        throw err; // rethrow the error
      }
    }
  }
  return lItems;
};

// ---------------------------------------------------------------------------
export var forEachLineInFile = (filePath, func, hContext = {}) => {
  var linefunc;
  // --- func gets (line, hContext) - lineNum starts at 1
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

// ---------------------------------------------------------------------------
export var FileProcessor = class FileProcessor {
  constructor(path1, hOptions = {}) {
    this.path = path1;
    // --- path can be a file or directory
    // --- Valid options:
    //        debug
    //        recursive
    assert(isString(this.path), "path not a string");
    // --- determine type of path
    this.pathType = pathType(this.path);
    assert((this.pathType === 'dir') || (this.pathType === 'file'), `path type ${this.pathType} must be dir or file`);
    // --- convert path to a full path
    this.path = mkpath(this.path);
    this.hOptions = getOptions(hOptions);
    this.debug = !!this.hOptions.debug;
    this.recursive = !!this.hOptions.recursive;
    this.log("constructed");
  }

  // ..........................................................
  log(obj) {
    if (this.debug) {
      if (isString(obj)) {
        console.log(`DEBUG: ${obj}`);
      } else {
        console.log(obj);
      }
    }
  }

  // ..........................................................
  // --- called at beginning of @go()
  begin() {
    this.log("begin() called");
  }

  // ..........................................................
  // --- called at end of @go()
  end() {
    this.log("end() called");
  }

  // ..........................................................
  filter(hFileInfo) {
    return true; // by default, handle all files in dir
  }

  
    // ..........................................................
  procAll() {
    var count, hFileInfo, hOpt, name, ref;
    this.begin();
    count = 0;
    if (this.pathType === 'file') {
      hFileInfo = parseSource(this.path);
      name = hFileInfo.fileName;
      count = 1;
      this.log(`[${count}] ${name} - Handle`);
      this.handleFile(hFileInfo);
    } else {
      this.log(`process all files in '${this.path}'`);
      hOpt = {
        recursive: this.recursive
      };
      ref = allFilesIn(this.path, hOpt);
      for (hFileInfo of ref) {
        name = hFileInfo.fileName;
        count += 1;
        if (this.filter(hFileInfo)) {
          this.log(`[${count}] ${name} - Handle`);
          this.handleFile(hFileInfo);
        } else {
          this.log(`[${count}] ${name} - Skip`);
        }
      }
    }
    this.log(`${count} files processed`);
    this.end();
  }

  // ..........................................................
  // --- synonum for @procAll()
  go() {
    this.procAll();
  }

  // ..........................................................
  beginFile(hFileInfo) {} // by default, does nothing

  
    // ..........................................................
  procFile(hFileInfo) {
    var line, lineNum, ref, result;
    assert(defined(hFileInfo), "procFile(): hFileInfo = undef");
    lineNum = 1;
    ref = allLinesIn(hFileInfo.filePath);
    for (line of ref) {
      result = this.handleLine(line, lineNum, hFileInfo);
      switch (result) {
        case 'abort':
          return;
      }
      lineNum += 1;
    }
  }

  // ..........................................................
  endFile(hFileInfo) {} // by default, does nothing

  
    // ..........................................................
  // --- default handleFile() calls handleLine() for each line
  handleFile(hFileInfo) {
    this.beginFile(hFileInfo);
    this.procFile(hFileInfo);
    this.endFile(hFileInfo);
  }

  // ..........................................................
  handleLine(line, lineNum, hFileInfo) {} // by default, does nothing

};

//# sourceMappingURL=fs.js.map
