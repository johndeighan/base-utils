// ll-fs.coffee
var normalize;

import pathLib from 'node:path';

import urlLib from 'url';

import fs from 'fs';

import {
  pass,
  undef,
  LOG,
  isString,
  getOptions
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
  assert(isDir(dirPath), `${dirPath} is not a directory`);
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
