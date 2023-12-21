// fs.coffee
var allFilesIn;

import pathLib from 'node:path';

import urlLib from 'url';

import fs from 'fs';

import {
  readFile,
  writeFile,
  rm,
  rmdir //  rmSync, rmdirSync,
} from 'node:fs/promises';

import NReadLines from 'n-readlines';

import {
  undef,
  defined,
  nonEmpty,
  toBlock,
  getOptions,
  isString,
  isHash,
  isArray,
  isIterable
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
} from '@jdeighan/base-utils/ll-taml';

import {
  fixPath,
  mydir,
  mkpath,
  parsePath
} from '@jdeighan/base-utils/ll-fs';

// ---------------------------------------------------------------------------
export var getFullPath = (...lPaths) => {
  return fixPath(pathLib.resolve(...lPaths).replaceAll("\\", "/"));
};

// ---------------------------------------------------------------------------
export var allDirs = function*(root, lDirs) {
  var len, results;
  len = lDirs.length;
  results = [];
  while (len > 0) {
    yield mkpath(root, lDirs);
    results.push(lDirs);
  }
  return results;
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
    dir = pathLib.resolve('..', dir);
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
//    file functions
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
export var rmFile = async(filepath) => {
  await rm(filepath);
};

// ---------------------------------------------------------------------------
export var rmFileSync = (filepath) => {
  assert(isFile(filepath), `${filepath} is not a file`);
  fs.rmSync(filepath);
};

// ---------------------------------------------------------------------------
//    directory functions
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
export var rmDir = async(dirpath) => {
  await rmdir(dirpath, {
    recursive: true
  });
};

// ---------------------------------------------------------------------------
export var rmDirSync = (dirpath) => {
  fs.rmdirSync(dirpath, {
    recursive: true
  });
};

// ---------------------------------------------------------------------------
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
export var hasPackageJson = (...lParts) => {
  return isFile(...lParts);
};

// ---------------------------------------------------------------------------
export var forEachFileInDir = (dir, func, hContext = {}) => {
  var ent, i, len1, ref;
  ref = fs.readdirSync(dir, {
    withFileTypes: true
  });
  // --- callback will get parms (filepath, hContext)
  //     DOES NOT RECURSE INTO SUBDIRECTORIES
  for (i = 0, len1 = ref.length; i < len1; i++) {
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
export var lineIterator = function*(filepath) {
  var buffer, reader;
  reader = new NReadLines(filepath);
  while ((buffer = reader.next())) {
    yield buffer.toString().replace(/\r/g, '');
  }
};

// ---------------------------------------------------------------------------
export var forEachLineInFile = (filepath, func, hContext = {}) => {
  var linefunc;
  // --- func gets (line, hContext) - lineNum starts at 1
  //     hContext will include keys:
  //        filepath
  //        lineNum - first line is line 1
  linefunc = (line, hContext) => {
    hContext.filepath = filepath;
    hContext.lineNum = hContext.index + 1;
    return func(line, hContext);
  };
  return forEachItem(lineIterator(filepath), linefunc, hContext);
};

// ---------------------------------------------------------------------------
export var parseSource = (source) => {
  var dir, hInfo, hSourceInfo, lMatches;
  // --- returns {
  //        dir
  //        fileName, filename
  //        filePath, filepath
  //        stub
  //        ext
  //        purpose
  //        }
  // --- NOTE: source may be a file URL, e.g. import.meta.url
  dbgEnter('parseSource', source);
  assert(isString(source), "parseSource(): source not a string");
  if (source.match(/^file\:\/\//)) {
    source = urlLib.fileURLToPath(source);
  }
  if (isDir(source)) {
    hSourceInfo = {
      dir: source,
      filePath: source,
      filepath: source
    };
  } else {
    assert(isFile(source), "source not a file or directory");
    hInfo = pathLib.parse(source);
    dir = hInfo.dir;
    if (dir) {
      hSourceInfo = {
        dir: dir.replaceAll("\\", "/"),
        filePath: mkpath(dir, hInfo.base),
        filepath: mkpath(dir, hInfo.base),
        fileName: hInfo.base,
        filename: hInfo.base,
        stub: hInfo.name,
        ext: hInfo.ext
      };
    } else {
      hSourceInfo = {
        fileName: hInfo.base,
        filename: hInfo.base,
        stub: hInfo.name,
        ext: hInfo.ext
      };
    }
    // --- check for a 'purpose'
    if (lMatches = hSourceInfo.stub.match(/\.([A-Za-z_]+)$/)) {
      hSourceInfo.purpose = lMatches[1];
    }
  }
  dbgReturn('parseSource', hSourceInfo);
  return hSourceInfo;
};

// ---------------------------------------------------------------------------
allFilesIn = function*(src) {
  var ent, i, len1, ref;
  // --- yields hFileInfo with keys:
  //        filepath, filename, stub, ext
  // --- src must be full path to a file or directory
  dbgEnter('allFilesIn', src);
  if (isDir(src)) {
    dbg(`DIR: ${src}`);
    ref = fs.readdirSync(src, {
      withFileTypes: true
    });
    for (i = 0, len1 = ref.length; i < len1; i++) {
      ent = ref[i];
      dbg("ENT:", ent);
      if (ent.isFile()) {
        yield parseSource(mkpath(src, ent.name));
      } else if (ent.isDirectory()) {
        yield* allFilesIn(ent.name);
      }
    }
  } else if (isFile(src)) {
    dbg(`FILE: ${src}`);
    yield parseSource(src);
  } else {
    croak("Source not a file or directory");
  }
  dbgReturn('allFilesIn');
};

// ---------------------------------------------------------------------------
export var FileProcessor = class FileProcessor {
  constructor(src1, hOptions = {}) {
    this.src = src1;
    // --- Valid options:
    //        debug

    // --- convert src to a full path
    assert(isString(this.src), "Source not a string");
    this.src = pathLib.resolve(this.src);
    this.hOptions = getOptions(hOptions);
    this.debug = !!this.hOptions.debug;
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
  // --- called at beginning of @procAll()
  init() {
    this.log("init() called");
  }

  // ..........................................................
  filter(hFileInfo) {
    return true; // by default, handle all files in dir
  }

  
    // ..........................................................
  procAll() {
    var hFileInfo, ref;
    if (this.debug) {
      this.log("calling init()");
    }
    this.init();
    // --- NOTE: If @src is a file, allFilesIn() will
    //           only yield a single hFileInfo
    this.log(`process all files in '${this.src}'`);
    ref = allFilesIn(this.src);
    for (hFileInfo of ref) {
      this.log(hFileInfo);
      if (this.filter(hFileInfo)) {
        this.log(`Handle file ${hFileInfo.filepath}`);
        this.handleFile(hFileInfo);
      } else {
        this.log(`Removed by filter: ${hFileInfo.filepath}`);
      }
    }
  }

  // ..........................................................
  // --- default handleFile() calls handleLine() for each line
  handleFile(hFileInfo) {
    var line, lineNum, ref, result;
    lineNum = 1;
    ref = lineIterator(hFileInfo.filepath);
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
  handleLine(line, lineNum, hFileInfo) {}

};

//# sourceMappingURL=fs.js.map
