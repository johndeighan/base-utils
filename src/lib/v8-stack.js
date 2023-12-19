// v8-stack.coffee
var dir;

import pathLib from 'node:path';

import fs from 'fs';

import {
  undef,
  defined,
  notdefined,
  assert,
  mydir,
  isEmpty,
  nonEmpty
} from '@jdeighan/base-utils/ll-utils';

import {
  OL,
  isIdentifier,
  isFunctionName,
  getOptions
} from '@jdeighan/base-utils';

import {
  mapSourcePos
} from '@jdeighan/base-utils/source-map';

import {
  getV8Stack,
  getMyDirectCaller,
  getMyOutsideCaller
} from '@jdeighan/base-utils/ll-v8-stack';

export {
  getV8Stack,
  getMyDirectCaller,
  getMyOutsideCaller
};

export var internalDebugging = false;

dir = mydir(import.meta.url); // directory this file is in


// ---------------------------------------------------------------------------
export var debugV8Stack = (flag = true) => {
  internalDebugging = flag;
};

// ---------------------------------------------------------------------------
export var isFile = (filePath) => {
  var err, result;
  try {
    result = fs.lstatSync(filePath).isFile();
    return result;
  } catch (error) {
    err = error;
    return false;
  }
};

// ---------------------------------------------------------------------------
export var nodeStr = (hNode) => {
  var column, fileName, line, type;
  ({type, fileName, line, column} = hNode);
  return `${type} at ${fileName}:${line}:${column}`;
};

// ---------------------------------------------------------------------------
export var getV8StackStr = async(hOptions = {}) => {
  var hNode, lParts, lStack;
  lStack = (await getV8Stack(hOptions));
  lParts = (function() {
    var i, len, results;
    results = [];
    for (i = 0, len = lStack.length; i < len; i++) {
      hNode = lStack[i];
      results.push(nodeStr(hNode));
    }
    return results;
  })();
  return lParts.join("\n");
};

// ---------------------------------------------------------------------------
export var shorten = (line) => {
  var pos, root;
  if (isEmpty(line)) {
    return '';
  }
  root = getRoot();
  if (isEmpty(root)) {
    return line;
  }
  pos = line.indexOf(root);
  if (pos === -1) {
    return line;
  } else {
    return line.replace(root, 'ROOT');
  }
};

// ---------------------------------------------------------------------------
export var getRoot = () => {
  var result;
  // --- Alternatively, we could search up in the directory tree
  //     for the directory that contains 'package.json'
  result = process.env.ProjectRoot;
  if (isEmpty(result)) {
    return undef;
  } else {
    return result;
  }
};

//# sourceMappingURL=v8-stack.js.map
