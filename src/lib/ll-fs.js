// ll-fs.coffee
var normalize;

import pathLib from 'node:path';

import urlLib from 'url';

import fs from 'fs';

import {
  pass,
  undef,
  defined,
  notdefined,
  LOG,
  isString,
  getOptions,
  ll_assert,
  ll_croak
} from '@jdeighan/base-utils';

// ---------------------------------------------------------------------------
export var fileExt = (path) => {
  var lMatches;
  ll_assert(isString(path), "fileExt(): path not a string");
  if (lMatches = path.match(/\.[A-Za-z0-9_]+$/)) {
    return lMatches[0];
  } else {
    return '';
  }
};

// ---------------------------------------------------------------------------
//   withExt - change file extention in a file name
export var withExt = (path, newExt) => {
  var _, lMatches, pre;
  ll_assert(newExt, "withExt(): No newExt provided");
  if (newExt.indexOf('.') !== 0) {
    newExt = '.' + newExt;
  }
  if (lMatches = path.match(/^(.*)\.[^\.]+$/)) {
    [_, pre] = lMatches;
    return pre + newExt;
  }
  return ll_croak(`Bad path: '${path}'`);
};

// ---------------------------------------------------------------------------
//     convert \ to /
// --- convert "C:..." to "c:..."
normalize = (path) => {
  path = path.replaceAll('\\', '/');
  if (path.charAt(1) === ':') {
    return path.charAt(0).toLowerCase() + path.substring(1);
  } else {
    return path;
  }
};

// ---------------------------------------------------------------------------
export var workingDir = function() {
  return normalize(process.cwd());
};

// ---------------------------------------------------------------------------
// --- Should be called like: myself(import.meta.url)
//     returns full path of current file
export var myself = (url) => {
  var path;
  path = urlLib.fileURLToPath(url);
  return normalize(path);
};

// ---------------------------------------------------------------------------
// --- Should be called like: mydir(import.meta.url)
//     returns the directory that the current file is in
export var mydir = (url) => {
  var dir, path;
  path = urlLib.fileURLToPath(url);
  dir = pathLib.dirname(path);
  return normalize(dir);
};

// ---------------------------------------------------------------------------
export var mkpath = (...lParts) => {
  var fullPath;
  fullPath = pathLib.resolve(...lParts);
  return normalize(fullPath);
};

// ---------------------------------------------------------------------------
// --- Since a disk's directory is kept in memory,
//     directory operations can be done synchronously
export var isDir = (dirPath) => {
  if (!fs.existsSync(dirPath)) {
    return false;
  }
  try {
    return fs.lstatSync(dirPath).isDirectory();
  } catch (error) {
    return false;
  }
};

// ---------------------------------------------------------------------------
export var mkDir = (dirPath, hOptions = {}) => {
  var err;
  hOptions = getOptions(hOptions, {
    clear: false
  });
  try {
    fs.mkdirSync(dirPath);
    return true;
  } catch (error) {
    err = error;
    if (err.code === 'EEXIST') {
      if (hOptions.clear) {
        clearDir(dirPath);
      }
      return false;
    } else {
      throw err;
    }
  }
};

// ---------------------------------------------------------------------------
export var dirContents = (dirPath) => {
  var ent, err, hOptions, i, lContents, len, ref;
  try {
    lContents = [];
    hOptions = {
      withFileTypes: true,
      recursive: false
    };
    ref = fs.readdirSync(dirPath, hOptions);
    for (i = 0, len = ref.length; i < len; i++) {
      ent = ref[i];
      if (ent.isFile() || ent.isDir()) {
        lContents.push(ent.name);
      }
    }
    return lContents;
  } catch (error) {
    err = error;
    return undef;
  }
};

// ---------------------------------------------------------------------------
export var clearDir = (dirPath) => {
  var ent, err, hOptions, i, len, ref;
  try {
    hOptions = {
      withFileTypes: true,
      recursive: true
    };
    ref = fs.readdirSync(dirPath, hOptions);
    for (i = 0, len = ref.length; i < len; i++) {
      ent = ref[i];
      if (ent.isFile()) {
        fs.rmSync(mkpath(ent.path, ent.name));
      }
    }
  } catch (error) {
    err = error;
    pass();
  }
};

// ---------------------------------------------------------------------------
export var rmDir = (dirPath, recursive = true) => {
  ll_assert(isDir(dirPath), `${dirPath} is not a directory`);
  fs.rmSync(dirPath, {recursive});
};

// ---------------------------------------------------------------------------
export var touch = (filePath) => {
  var fd;
  fd = fs.openSync(filePath, 'a');
  fs.closeSync(fd);
};

// ---------------------------------------------------------------------------
export var isFile = (filePath) => {
  if (!fs.existsSync(filePath)) {
    return false;
  }
  try {
    return fs.lstatSync(filePath).isFile();
  } catch (error) {
    return false;
  }
};

// ---------------------------------------------------------------------------
export var rename = (oldPath, newPath) => {
  fs.renameSync(oldPath, newPath);
};

// ---------------------------------------------------------------------------
export var rmFile = (filePath) => {
  ll_assert(isFile(filePath), `${filePath} is not a file`);
  fs.rmSync(filePath);
};

// ---------------------------------------------------------------------------
// --- returns one of:
//        'missing'  - does not exist
//        'dir'      - is a directory
//        'file'     - is a file
//        'unknown'  - exists, but not a file or directory
export var pathType = (fullPath) => {
  ll_assert(isString(fullPath), "not a string");
  if (fs.existsSync(fullPath)) {
    if (isFile(fullPath)) {
      return 'file';
    } else if (isDir(fullPath)) {
      return 'dir';
    } else {
      return 'unknown';
    }
  } else {
    return 'missing';
  }
};

// ---------------------------------------------------------------------------
export var parsePath = (path, shouldNotExist) => {
  var base, dir, ext, lMatches, name, purpose, root, type;
  // --- NOTE: path may be a file URL, e.g. import.meta.url
  //           path may be a relative path
  ll_assert(isString(path), `path is type ${typeof path}`);
  ll_assert(notdefined(shouldNotExist), "multiple arguments!");
  if (path.match(/^file\:\/\//)) {
    path = normalize(urlLib.fileURLToPath(path));
  } else {
    // --- handles relative paths
    path = normalize(pathLib.resolve(path));
  }
  type = pathType(path);
  ({root, dir, base, name, ext} = pathLib.parse(path));
  if (lMatches = name.match(/\.([A-Za-z_]+)$/)) {
    purpose = lMatches[1];
  } else {
    purpose = undef;
  }
  return {
    path,
    type,
    root,
    dir,
    base,
    fileName: base, // my preferred name
    name, // use this for directory name
    stub: name, // my preferred name
    ext,
    purpose
  };
};

// ---------------------------------------------------------------------------
export var parentDir = (path) => {
  var hParsed;
  hParsed = parsePath(path);
  return hParsed.dir;
};

//# sourceMappingURL=ll-fs.js.map
