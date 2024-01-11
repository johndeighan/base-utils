// ll-fs.coffee
import pathLib from 'node:path';

import urlLib from 'url';

import fs from 'fs';

import {
  undef,
  nonEmpty
} from '@jdeighan/base-utils';

// ---------------------------------------------------------------------------
//     convert \ to /
// --- convert "C:..." to "c:..."
export var fixPath = (path) => {
  path = path.replaceAll('\\', '/');
  if (path.charAt(1) === ':') {
    return path.charAt(0).toLowerCase() + path.substring(1);
  }
  return path;
};

// ---------------------------------------------------------------------------
// --- Should be called like: mydir(import.meta.url)
//     returns the directory that the current file is in
export var mydir = (url) => {
  var dir, path;
  path = urlLib.fileURLToPath(url);
  dir = pathLib.dirname(path);
  return fixPath(dir);
};

// ---------------------------------------------------------------------------
export var mkpath = (...lParts) => {
  var root, str;
  lParts = lParts.filter((x) => {
    return nonEmpty(x);
  });
  if (lParts.length === 0) {
    throw new Error("mkpath(): empty input");
  }
  if (lParts[0].match(/[\/\\]$/)) {
    root = lParts.shift().toLowerCase();
    str = root + lParts.join('/');
  } else {
    str = lParts.join('/');
  }
  return fixPath(str);
};

// ---------------------------------------------------------------------------
export var resolve = (...lParts) => {
  return fixPath(pathLib.resolve(...lParts));
};

// ---------------------------------------------------------------------------
// --- Returned object has keys:
//        root, dir, lDirs, filename, fileName, stub, ext
//        NOTE: unable to determine if it's a file or directory
export var parsePath = (...lParts) => {
  var base, dir, ext, name, path, root;
  path = mkpath(...lParts);
  if (path.match(/^\./)) {
    throw new Error(`parsePath() got '${path}' - you should resolve first`);
  }
  ({root, dir, base, name, ext} = pathLib.parse(path));
  return {
    root,
    dir,
    lDirs: dir.split(/[\/\\]/),
    fileName: base,
    filename: base,
    stub: name,
    ext
  };
};

//# sourceMappingURL=ll-fs.js.map
