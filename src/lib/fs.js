// fs.coffee
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
  toArray,
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
} from '@jdeighan/base-utils/taml';

import {
  fixPath,
  mydir,
  mkpath,
  resolve,
  parsePath
} from '@jdeighan/base-utils/ll-fs';

export {
  fixPath,
  mydir,
  mkpath,
  resolve,
  parsePath
};

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
export var allLinesIn = function*(filepath) {
  var buffer, reader;
  reader = new NReadLines(filepath);
  while ((buffer = reader.next())) {
    yield buffer.toString().replace(/\r/g, '');
  }
};

export var lineIterator = allLinesIn; // for backward compatibility


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
  return forEachItem(allLinesIn(filepath), linefunc, hContext);
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
    assert(isFile(source), `source ${source} not a file or directory`);
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
export var getTextFileContents = (filePath) => {
  var hResult, inMeta, lLines, lMetaLines, line, metadata, numLines, ref;
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
  var eager, ent, hContents, hFileInfo, i, len1, path, recursive, ref;
  // --- yields hFileInfo with keys:
  //        filepath, filename, stub, ext, metadata, contents
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
  for (i = 0, len1 = ref.length; i < len1; i++) {
    ent = ref[i];
    dbg("ENT:", ent);
    if (ent.isFile()) {
      path = mkpath(ent.path, ent.name);
      dbg(`PATH = ${path}`);
      hFileInfo = parseSource(path);
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
export var FileProcessor = class FileProcessor {
  constructor(dir1, hOptions = {}) {
    this.dir = dir1;
    // --- Valid options:
    //        debug
    //        recursive

    // --- convert dir to a full path
    assert(isString(this.dir), "Source not a string");
    this.dir = pathLib.resolve(this.dir);
    assert(isDir(this.dir), `Not a directory: ${this.dir}`);
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
  // --- called at beginning of @procAll()
  begin() {
    this.log("begin() called");
  }

  // ..........................................................
  // --- called at end of @procAll()
  end() {
    this.log("end() called");
  }

  // ..........................................................
  filter(hFileInfo) {
    return true; // by default, handle all files in dir
  }

  
    // ..........................................................
  procAll() {
    var count, hFileInfo, name, ref;
    this.begin();
    this.log(`process all files in '${this.dir}'`);
    count = 0;
    ref = allFilesIn(this.dir, {
      recursive: this.recursive
    });
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
    this.log(`${count} files processed`);
    this.end();
  }

  // ..........................................................
  beginFile(hFileInfo) {} // by default, does nothing

  
    // ..........................................................
  procFile(hFileInfo) {
    var line, lineNum, ref, result;
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
  handleLine(line, lineNum, hFileInfo) {}

};

//# sourceMappingURL=fs.js.map
