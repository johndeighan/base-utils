// v8-stack.coffee
var assert, sep_dash, sep_eq;

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
  assert(nonEmpty(stackStr), "stackStr is empty!");
  // --- reset to previous value
  Error.stackTraceLimit = oldLimit;
  if (internalDebugging) {
    console.log("STACK STRING:");
    console.log(stackStr);
  }
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
  var err, hNode, ref, stackStr;
  if (internalDebugging) {
    console.log("in getMyDirectCaller()");
  }
  try {
    stackStr = getV8StackStr(depth);
  } catch (error) {
    err = error;
    console.log(sep_eq);
    console.log(`ERROR in getV8Stack(): ${err.message}`);
    console.log(sep_eq);
    // --- unfortunately, process.exit() prevents the above console logs
    //		process.exit()
    return undef;
  }
  ref = stackFrames(stackStr);
  for (hNode of ref) {
    if (hNode.depth === depth) {
      return hNode;
    }
  }
  return undef;
};

// ---------------------------------------------------------------------------
export var getMyOutsideCaller = () => {
  var err, hNode, orgstate, ref, source, stackStr, state;
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
    // --- unfortunately, process.exit() prevents the above console logs
    //		process.exit()
    return undef;
  }
  try {
    // --- states:
    //        1 - no source yet
    //        2 - source is this module
    //        3 - source is calling module
    //        4 - source is caller outside calling module
    state = 1;
    source = undef;
    ref = stackFrames(stackStr);
    for (hNode of ref) {
      orgstate = state;
      switch (state) {
        case 1:
          source = hNode.source;
          state = 2;
          break;
        case 2:
          if (hNode.source !== source) {
            source = hNode.source;
            state = 3;
          }
          break;
        case 3:
          if (hNode.source !== source) {
            if (internalDebugging) {
              console.log("   RETURN:");
              console.log(hNode);
            }
            return hNode;
          }
      }
      if (internalDebugging) {
        console.log(`   ${orgstate} => ${state}`);
      }
    }
  } catch (error) {
    err = error;
    console.log(sep_eq);
    console.log(`ERROR in stackFrames(): ${err.message}`);
    console.log(sep_eq);
    // --- unfortunately, process.exit() prevents the above console logs
    //		process.exit()
    return undef;
  }
  return result;
};

// ---------------------------------------------------------------------------
export var getMyOutsideSource = function() {
  var caller;
  caller = getMyOutsideCaller();
  if (caller) {
    return caller.source;
  } else {
    return undef;
  }
};

// ---------------------------------------------------------------------------
export var nodeStr = (node) => {
  var err, errmsg;
  try {
    switch (node.type) {
      case 'function':
      case 'method':
        return `${node.funcName}() ${getFilePos(node)}`;
      case 'script':
        return `script ${node.hFile.filename} ${getFilePos(node)}`;
      default:
        return `Unknown node type: '${node.type}'`;
    }
  } catch (error) {
    err = error;
    errmsg = `ERROR: ${err.message} in: '${JSON.stringify(node)}'`;
    console.log(errmsg);
    return errmsg;
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
  var curDepth, hNode, i, len, line, ref;
  //     generator of nodes

  //     Each node has keys:
  //        isAsync
  //        depth (starting at 0)

  //        source - full path name to source file
  //        dir - directory part of source
  //        filename - filename part of source
  //        lineNum
  //        colNum

  //        type = 'function | method | script
  //           script
  //              scriptName
  //           function
  //              funcName
  //           method
  //              objName
  //              funcName
  //        desc - type plus script/function/method name
  assert(nonEmpty(stackStr), "stackStr is empty in stackFrames()");
  curDepth = 0;
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
};

// ---------------------------------------------------------------------------
export var dumpNode = (hNode) => {
  console.log(`   source = ${hNode.source}`);
  console.log(`   desc = ${hNode.desc}`);
};

// ---------------------------------------------------------------------------
export var parseLine = (line, depth) => {
  var _, async, colNum, fileURL, fromWhere, h, hNode, lMatches, lParts, lineNum, module, type;
  assert(defined(line), "line is undef in parseLine()");
  line = line.trim();
  if (internalDebugging) {
    console.log(`LINE: '${shorten(line)}'`);
  }
  if (line === 'Error') {
    if (internalDebugging) {
      console.log("   - no match (was 'Error')");
    }
    return undef;
  }
  lMatches = line.match(/^at\s+(async\s+)?(\S+)(?:\s*\(([^)]+)\))?$/); // func | object.method | file URL
  // containing file | node:internal
  assert(defined(lMatches), `BAD LINE: '${line}'`);
  [_, async, fromWhere, fileURL] = lMatches;
  // --- check for NodeJS internal functions
  if (defined(fileURL) && (lMatches = fileURL.match(/^node:internal\/(.*):(\d+):(\d+)$/))) {
    [_, module, lineNum, colNum] = lMatches;
    hNode = {
      isAsync: !!async,
      depth,
      source: 'node',
      lineNum,
      colNum,
      desc: `node ${module}`
    };
    if (internalDebugging) {
      dumpNode(hNode);
    }
    return hNode;
  }
  // --- Parse file URL, set lParts, set type
  if (fromWhere.indexOf('file://') === 0) {
    assert(isEmpty(fileURL), "two file URLs present");
    type = 'script';
    h = parseFileURL(fromWhere);
  } else {
    lParts = isFunctionName(fromWhere);
    assert(defined(lParts), `Bad line: '${line}'`);
    if (lParts.length === 1) {
      type = 'function';
    } else {
      type = 'method';
    }
    h = parseFileURL(fileURL);
  }
  // --- construct hNode
  hNode = {
    isAsync: !!async,
    depth,
    source: h.source,
    dir: h.dir,
    filename: h.base,
    lineNum: h.lineNum,
    colNum: h.colNum,
    type
  };
  switch (type) {
    case 'script':
      hNode.scriptName = hNode.base;
      hNode.desc = `script ${h.base}`;
      break;
    case 'function':
      hNode.funcName = lParts[0];
      hNode.desc = `function ${lParts[0]}`;
      break;
    case 'method':
      hNode.objName = lParts[0];
      hNode.funcName = lParts[1];
      hNode.desc = `method ${lParts[0]}.${lParts[1]}`;
  }
  if (internalDebugging) {
    dumpNode(hNode);
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
  assert(defined(url), "url is undef in parseFileURL()");
  lMatches = url.match(/^file:\/\/(.*):(\d+):(\d+)$/);
  assert(defined(lMatches), `Invalid file URL: ${url}`);
  [_, pathStr, lineNum, colNum] = lMatches;
  hParsed = pathLib.parse(pathStr);
  hParsed.lineNum = parseInt(lineNum, 10);
  hParsed.colNum = parseInt(colNum, 10);
  ({dir, base} = hParsed);
  if (defined(dir) && (dir.indexOf('/') === 0)) {
    hParsed.dir = dir.substr(1);
    hParsed.source = `${hParsed.dir}/${base}`;
  } else {
    hParsed.source = `./${base}`;
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
