// v8-stack.coffee
var assert, mksource, sep_dash, sep_eq;

import pathLib from 'node:path';

import {
  undef,
  defined,
  notdefined,
  pass,
  OL,
  isIdentifier,
  isFunctionName,
  getOptions,
  isEmpty,
  nonEmpty
} from '@jdeighan/base-utils';

export var internalDebugging = false;

sep_eq = '============================================================';

sep_dash = '------------------------------------------------------------';

// ---------------------------------------------------------------------------
// assert() for use in this file only
assert = (cond, msg) => {
  if (!cond) {
    throw new Error(msg);
  }
  return true;
};

// ---------------------------------------------------------------------------
export var debugV8Stack = (flag = true) => {
  internalDebugging = flag;
};

// ---------------------------------------------------------------------------
export var getV8StackStr = (maxDepth = 2e308) => {
  var oldLimit, stackStr;
  oldLimit = Error.stackTraceLimit;
  Error.stackTraceLimit = maxDepth + 1;
  stackStr = new Error().stack;
  // --- reset to previous value
  Error.stackTraceLimit = oldLimit;
  return stackStr;
};

// ---------------------------------------------------------------------------
export var getV8Stack = (maxDepth = 2e308) => {
  var stackStr;
  stackStr = getV8StackStr(maxDepth);
  return Array.from(stackFrames(stackStr));
};

// ---------------------------------------------------------------------------
export var getMyself = (depth = 3) => {
  var hNode, ref, stackStr;
  stackStr = getV8StackStr(2);
  ref = stackFrames(stackStr);
  for (hNode of ref) {
    return hNode;
  }
  return croak("empty stack");
};

// ---------------------------------------------------------------------------
export var getMyDirectCaller = (depth = 3) => {
  var hNode, ref, stackStr;
  stackStr = getV8StackStr(depth);
  ref = stackFrames(stackStr);
  for (hNode of ref) {
    if (hNode.depth === depth) {
      return hNode;
    }
  }
};

// ---------------------------------------------------------------------------
export var getMyOutsideCaller = () => {
  var err, hNode, lSources, ref, result, source, stackStr;
  if (internalDebugging) {
    console.log("in getMyOutsideCaller()");
  }
  try {
    stackStr = getV8StackStr(10);
  } catch (error) {
    err = error;
    console.log(sep_eq);
    console.log(`ERROR in getV8Stack(): ${err.message}`);
    console.log(sep_eq);
    process.exit();
  }
  try {
    // --- list of distinct sources
    //     when we find the 3rd, we return it
    lSources = [];
    ref = stackFrames(stackStr);
    for (hNode of ref) {
      source = hNode.source;
      if (lSources.indexOf(source) === -1) {
        lSources.push(source);
      }
      if (lSources.length === 3) {
        result = hNode;
        break;
      }
    }
  } catch (error) {
    err = error;
    console.log(sep_eq);
    console.log(`ERROR in stackFrames(): ${err.message}`);
    console.log(sep_eq);
    process.exit();
  }
  return result;
};

// ---------------------------------------------------------------------------
export var nodeStr = (node) => {
  switch (node.type) {
    case 'function':
    case 'method':
      return `${node.funcName}() ${getFilePos(node)}`;
    case 'script':
      return `script ${node.hFile.base} ${getFilePos(node)}`;
  }
};

// ---------------------------------------------------------------------------
export var getFilePos = (node) => {
  var result;
  if (notdefined(node) || notdefined(node.hFile)) {
    return '';
  }
  result = node.hFile.base;
  if (defined(node.hFile.lineNum)) {
    result += `:${node.hFile.lineNum}`;
    if (defined(node.hFile.colNum)) {
      result += `:${node.hFile.colNum}`;
    }
  }
  return result;
};

// ---------------------------------------------------------------------------
// This is a generator
export var stackFrames = function*(stackStr) {
  var curDepth, err, hNode, i, len, line, ref, root;
  //     generator of nodes

  //     Each node has keys:
  //        type = function | method | script
  //        depth (starting at 0)
  //        source - full path name to source file
  //        isAsync
  //        funcName
  //        objName   - if a method call
  //        hFile
  //           root
  //           dir
  //           base
  //           ext
  //           name
  //           lineNum
  //           colNum
  curDepth = 0;
  if (internalDebugging && (root = getRoot())) {
    console.log(`ROOT = ${OL(root)}`);
  }
  try {
    ref = stackStr.split("\n");
    for (i = 0, len = ref.length; i < len; i++) {
      line = ref[i];
      hNode = parseLine(line, curDepth);
      if (defined(hNode)) {
        hNode.depth = curDepth;
        curDepth += 1;
        yield hNode;
      }
    }
  } catch (error) {
    err = error;
    console.log(`ERROR IN stackFrames(): ${err.message}`);
    throw err;
  }
};

// ---------------------------------------------------------------------------
mksource = (dir, base) => {
  return `${dir}/${base}`;
};

// ---------------------------------------------------------------------------
export var parseLine = (line, depth) => {
  var _, async, colNum, funcName, h, hNode, inFile, lMatches, lParts, lineNum, module, objName;
  line = line.trim();
  if (internalDebugging) {
    console.log(`LINE: '${shorten(line)}'`);
  }
  lMatches = line.match(/^at\s+(async\s+)?(\S+)(?:\s*\(([^)]+)\))?$/); // func | object.method | file URL
  // containing file
  if (!lMatches) {
    if (internalDebugging) {
      console.log("   - no match");
    }
    return undef;
  }
  [_, async, funcName, inFile] = lMatches;
  hNode = {
    isAsync: !!async
  };
  if (defined(funcName) && (funcName.indexOf('file://') === 0)) {
    if (internalDebugging) {
      console.log(`   - [${depth}] file URL`);
    }
    hNode.type = 'script';
    h = parseFileURL(funcName);
    hNode.hFile = h;
    hNode.source = mksource(h.dir, h.base);
  } else if (lParts = isFunctionName(funcName)) {
    if (lParts.length === 1) {
      hNode.type = 'function';
      hNode.funcName = funcName;
      if (internalDebugging) {
        console.log(`   - [${depth}] function ${funcName}`);
      }
    } else {
      hNode.type = 'method';
      [objName, funcName] = lParts;
      Object.assign(hNode, {objName, funcName});
      if (internalDebugging) {
        console.log(`   - [${depth}] method ${objName}.${funcName}`);
      }
    }
    if (defined(inFile)) {
      if (inFile.indexOf('file://') === 0) {
        h = parseFileURL(inFile);
        hNode.hFile = h;
        hNode.source = mksource(h.dir, h.base);
      } else if (lMatches = inFile.match(/^node:internal\/(.*):(\d+):(\d+)$/)) {
        [_, module, lineNum, colNum] = lMatches;
        hNode.hFile = {
          root: 'node',
          base: module,
          lineNum,
          colNum
        };
      }
    }
  }
  if (internalDebugging) {
    console.log(`   - from ${shorten(hNode.source)} - ${hNode.type}`);
  }
  return hNode;
};

// ---------------------------------------------------------------------------
export var parseFileURL = (url) => {
  var _, base, colNum, dir, hParsed, lMatches, lineNum, pathStr;
  // --- Return value will have these keys:
  //        root
  //        dir
  //        base
  //        ext
  //        name
  //        lineNum
  //        colNum
  lMatches = url.match(/^file:\/\/(.*):(\d+):(\d+)$/);
  assert(defined(lMatches), `Invalid file URL: ${url}`);
  [_, pathStr, lineNum, colNum] = lMatches;
  hParsed = pathLib.parse(pathStr);
  hParsed.lineNum = parseInt(lineNum, 10);
  hParsed.colNum = parseInt(colNum, 10);
  ({dir, base} = hParsed);
  if (defined(dir) && (dir.indexOf('/') === 0)) {
    hParsed.dir = dir.substr(1);
  }
  return hParsed;
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
  result = process.env.ProjectRoot;
  if (isEmpty(result)) {
    return undef;
  } else {
    return result;
  }
};

// ---------------------------------------------------------------------------
