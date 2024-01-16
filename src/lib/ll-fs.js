// ll-fs.coffee
var normalize;

import pathLib from 'node:path';

import urlLib from 'url';

import fs from 'fs';

import {
  undef,
  LOG,
  isString
} from '@jdeighan/base-utils';

import {
  assert
} from '@jdeighan/base-utils/exceptions';

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

// ---------------------------------------------------------------------------
export var mkDir = (dirPath) => {
  var err;
  try {
    fs.mkdirSync(dirPath);
    return true;
  } catch (error) {
    err = error;
    if (err.code === 'EEXIST') {
      return false;
    } else {
      throw err;
    }
  }
};

// ---------------------------------------------------------------------------
export var touch = (filePath) => {
  fs.closeSync(fs.openSync(filePath, 'a'));
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
export var rename = (oldPath, newPath) => {
  fs.renameSync(oldPath, newPath);
};

// ---------------------------------------------------------------------------
// --- returns one of:
//        'missing'  - does not exist
//        'dir'      - is a directory
//        'file'     - is a file
//        'unknown'  - exists, but not a file or directory
export var pathType = (fullPath) => {
  assert(isString(fullPath), "not a string");
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
export var rmFile = (filePath) => {
  assert(isFile(filePath), `${filePath} is not a file`);
  fs.rmSync(filePath);
};

// ---------------------------------------------------------------------------
export var rmDir = (dirPath, recursive = true) => {
  assert(isDir(dirPath), `${dirPath} is not a directory`);
  fs.rmSync(dirPath, {recursive});
};

// ---------------------------------------------------------------------------
// --- path must exist
export var parsePath = (path) => {
  var base, dir, ext, lMatches, name, purpose, root;
  // --- NOTE: path may be a file URL, e.g. import.meta.url
  // --- returns {
  //        root
  //        dir
  //     if a file:
  //        fileName,
  //        filePath,
  //        stub
  //        ext
  //        purpose
  //        }
  assert(isString(path), "path not a string");
  if (path.match(/^file\:\/\//)) {
    path = urlLib.fileURLToPath(path);
  } else {
    // --- handles relative paths
    path = pathLib.resolve(path);
  }
  ({dir, root, base, name, ext} = pathLib.parse(path));
  if (isDir(path)) {
    return {
      root: normalize(root),
      dir: normalize(dir)
    };
  } else {
    assert(isFile(path), `path ${path} not a file or directory`);
    // --- check for a purpose
    if (lMatches = name.match(/\.([A-Za-z_]+)$/)) {
      purpose = lMatches[1];
    }
    return {
      root: normalize(root),
      dir: normalize(dir),
      fileName: base,
      filePath: `${normalize(dir)}/${base}`,
      stub: name,
      ext,
      purpose
    };
  }
};

export var parseSource = parsePath; // synonym

//# sourceMappingURL=ll-fs.js.map
