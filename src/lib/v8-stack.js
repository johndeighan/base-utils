// v8-stack.coffee
var dir;

import pathLib from 'node:path';

import fs from 'fs';

import {
  undef,
  defined,
  notdefined,
  isEmpty,
  nonEmpty,
  OL,
  isIdentifier,
  isFunctionName,
  getOptions
} from '@jdeighan/base-utils';

import {
  mydir
} from '@jdeighan/base-utils/ll-fs';

import {
  nodeStr,
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

//# sourceMappingURL=v8-stack.js.map
