// fs.coffee
var fileFilter, lDirs;

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
  words,
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
  jsType,
  hasKey
} from '@jdeighan/base-utils';

import {
  fileExt,
  workingDir,
  myself,
  mydir,
  mkpath,
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
  fileDirPath,
  mkDirsForFile,
  getFileStats,
  lStatFields,
  newerDestFilesExist
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
  fileDirPath,
  mkDirsForFile,
  getFileStats,
  newerDestFilesExist
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
export var isProjRoot = (hOptions = {}) => {
  var strict;
  ({strict} = getOptions(hOptions, {
    strict: false
  }));
  if (!isFile("./package.json")) {
    return false;
  }
  if (strict) {
    if (!isFile("./package-lock.json")) {
      return false;
    }
    if (!isDir("./node_modules")) {
      return false;
    }
    if (!isDir("./.git")) {
      return false;
    }
    if (!isFile("./.gitignore")) {
      return false;
    }
    if (!isDir("./src")) {
      return false;
    }
    if (!isDir("./src/lib")) {
      return false;
    }
    if (!isDir("./src/bin")) {
      return false;
    }
    if (!isDir("./test")) {
      return false;
    }
    if (!isFile("./README.md")) {
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
export var getTextFileContents = (filePath) => {
  var hResult, inMeta, lLines, lMetaLines, line, metadata, numLines, ref;
  // --- handles metadata if present
  dbgEnter('getTextFileContents', filePath);
  assert(isFile(filePath), `Not a file: ${OL(filePath)}`);
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
  if (nonEmpty(lMetaLines)) {
    metadata = fromTAML(toBlock(lMetaLines));
  } else {
    metadata = undef;
  }
  hResult = {metadata, lLines};
  dbgReturn('getTextFileContents', hResult);
  return hResult;
};

// ---------------------------------------------------------------------------
// --- yield hFile with keys:
//        path, filePath
//        type
//        root
//        dir
//        base, fileName
//        name, stub
//        ext
//        purpose
//     ...plus stat fields
export var globFiles = function*(pattern = '*', hGlobOptions = {}) {
  var base, dir, ent, ext, filePath, hFile, i, j, key, lMatches, len, len1, name, purpose, ref, root, type;
  dbgEnter('globFiles', pattern, hGlobOptions);
  hGlobOptions = getOptions(hGlobOptions, {
    withFileTypes: true,
    stat: true
  });
  dbg('pattern', pattern);
  dbg('hGlobOptions', hGlobOptions);
  ref = glob(pattern, hGlobOptions);
  for (i = 0, len = ref.length; i < len; i++) {
    ent = ref[i];
    filePath = mkpath(ent.fullpath());
    ({root, dir, base, name, ext} = pathLib.parse(filePath));
    if (lMatches = name.match(/\.([A-Za-z_]+)$/)) {
      purpose = lMatches[1];
    } else {
      purpose = undef;
    }
    if (ent.isDirectory()) {
      type = 'dir';
    } else if (ent.isFile()) {
      type = 'file';
    } else {
      type = 'unknown';
    }
    hFile = {
      filePath,
      path: filePath,
      relPath: relpath(filePath),
      type,
      root,
      dir,
      base,
      fileName: base,
      name,
      stub: name,
      ext,
      purpose
    };
    for (j = 0, len1 = lStatFields.length; j < len1; j++) {
      key = lStatFields[j];
      hFile[key] = ent[key];
    }
    dbgYield('globFiles', hFile);
    yield hFile;
    dbgResume('globFiles');
  }
  dbgReturn('globFiles');
};

// ---------------------------------------------------------------------------
// --- return true to include file
fileFilter = (filePath) => {
  return isFile(filePath) && notdefined(filePath.match(/\bnode_modules\b/));
};

// ---------------------------------------------------------------------------
export var allFilesMatching = function*(pattern = '*', hOptions = {}) {
  var eager, filePath, h, hContents, hGlobOptions, numFiles, ref;
  // --- yields hFile with keys:
  //        path, filePath,
  //        type, root, dir, base, fileName,
  //        name, stub, ext, purpose
  //        (if eager) metadata, lLines
  // --- Valid options:
  //        hGlobOptions - options to pass to glob
  //        fileFilter - return path iff fileFilter(filePath) returns true
  //        eager - read the file and add keys metadata, lLines
  // --- Valid glob options:
  //        ignore - glob pattern for files to ignore
  //        dot - include dot files/directories (default: false)
  //        cwd - change working directory
  dbgEnter('allFilesMatching', pattern, hOptions);
  ({hGlobOptions, fileFilter, eager} = getOptions(hOptions, {
    hGlobOptions: {
      ignore: "node_modules"
    },
    fileFilter: (h) => {
      var path;
      ({
        filePath: path
      } = h);
      return isFile(path) && !path.match(/\bnode_modules\b/);
    },
    eager: false
  }));
  dbg(`pattern = ${OL(pattern)}`);
  dbg(`hGlobOptions = ${OL(hGlobOptions)}`);
  dbg(`eager = ${OL(eager)}`);
  numFiles = 0;
  ref = globFiles(pattern, hGlobOptions);
  for (h of ref) {
    ({filePath} = h);
    dbg(`GLOB: ${OL(filePath)}`);
    if (eager && isFile(filePath)) {
      hContents = getTextFileContents(filePath);
      Object.assign(h, hContents);
    }
    if (fileFilter(h)) {
      dbgYield('allFilesMatching', h);
      yield h;
      numFiles += 1;
      dbgResume('allFilesMatching');
    }
  }
  dbg(`${numFiles} files matched`);
  dbgReturn('allFilesMatching');
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
  assert(isFile(filePath), `Not a file: ${OL(filePath)}`);
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
//   barfPkgJSON - write a string to a file
export var barfPkgJSON = (hJson) => {
  barfJSON(hJson, getPkgJsonPath());
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
export var allLinesInEx = function*(filePath) {
  var buffer, hMetaData, lMetaData, line, metaDataStart, nLines, reader;
  dbgEnter('allLinesInEx', filePath);
  reader = new NReadLines(filePath);
  nLines = 0;
  metaDataStart = undef; // if defined, we're in metadata
  lMetaData = [];
  while (buffer = reader.next()) {
    line = buffer.toString().replaceAll('\r', '');
    if (nLines === 0) {
      if (isMetaDataStart(line)) {
        dbg(`metadata: ${OL(line)}`);
        metaDataStart = line;
        lMetaData.push(line);
      } else {
        dbg("no metadata");
      }
    } else if (defined(metaDataStart)) {
      if (line === metaDataStart) {
        // --- end line for metadata
        metaDataStart = undef;
        hMetaData = convertMetaData(lMetaData, line);
        dbgYield('allLinesInEx', hMetaData);
        yield hMetaData;
        dbgResume('allLinesInEx');
      } else {
        dbg(`metadata: ${OL(line)}`);
        lMetaData.push(line);
      }
    } else {
      dbgYield('allLinesInEx', line);
      yield line;
      dbgResume('allLinesInEx');
    }
    nLines += 1;
  }
  dbgReturn('allLinesInEx');
};

// ---------------------------------------------------------------------------
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
