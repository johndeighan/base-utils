// ll-v8-stack.coffee
import pathLib from 'node:path';

import {
  undef,
  defined,
  notdefined,
  alldefined
} from '@jdeighan/base-utils/ll-utils';

import {
  assert,
  croak
} from '@jdeighan/base-utils/exceptions';

import {
  mapSourcePos
} from '@jdeighan/base-utils/source-map';

// ---------------------------------------------------------------------------
// Stack Frames have the keys:
//    type - eval | native | constructor | method | function | script
//    filePath
//    fileName
//    functionName
//    objTye, methodName - if type == 'method'
//    isAsync - true if an async function/method
//    line
//    column

// ---------------------------------------------------------------------------
export var nodeStr = (hNode) => {
  var column, fileName, line, type;
  ({type, fileName, line, column} = hNode);
  return `${type} at ${fileName}:${line}:${column}`;
};

// ---------------------------------------------------------------------------
// --- export only for unit tests
export var extractFileName = (filePath) => {
  var lMatches;
  if (lMatches = filePath.match(/[\/\\]([^\/\\]+)$/)) {
    return lMatches[1];
  } else {
    return filePath;
  }
};

// ---------------------------------------------------------------------------
export var getV8Stack = (hOptions = {}) => {
  var debug, lStackFrames, oldLimit, oldPreparer;
  // --- ignores any stack frames from this module
  debug = hOptions.debug || false;
  oldLimit = Error.stackTraceLimit;
  oldPreparer = Error.prepareStackTrace;
  Error.stackTraceLimit = 2e308;
  Error.prepareStackTrace = (error, lCallSites) => {
    var column, filePath, fileURL, functionName, hFrame, hParsed, i, lFrames, len, line, methodName, oSite, objType, pos, thisVal, type;
    lFrames = [];
    for (i = 0, len = lCallSites.length; i < len; i++) {
      oSite = lCallSites[i];
      fileURL = oSite.getFileName();
      if (defined(fileURL)) {
        hParsed = parseFileURL(fileURL);
        filePath = hParsed.source;
      }
      if ((typeof filePath === 'string') && (filePath.length > 0)) {
        // --- Ignore any stack entries from this module
        pos = filePath.indexOf('ll-v8-stack.js');
        if (pos >= 0) {
          if (debug) {
            console.log(`SKIP: filePath = '${filePath}'`);
          }
          continue;
        }
      }
      objType = oSite.getTypeName();
      thisVal = oSite.getThis();
      functionName = oSite.getFunctionName();
      methodName = oSite.getMethodName();
      line = oSite.getLineNumber();
      column = oSite.getColumnNumber();
      // --- Set type
      if (oSite.isEval()) {
        type = 'eval';
      } else if (oSite.isNative()) {
        type = 'native';
      } else if (oSite.isConstructor()) {
        type = 'constructor';
      } else if (defined(methodName)) {
        type = 'method';
      } else {
        type = 'function';
      }
      if (debug) {
        console.log('-'.repeat(40));
        console.log(`type = '${type}'`);
        console.log(`objType = '${objType}'`);
        console.log(`filePath = '${filePath}'`);
        console.log(`functionName = '${functionName}'`);
        console.log(`methodName = '${methodName}'`);
        console.log(`at ${line}:${column}`);
      }
      // --- Ignore this entry and any before it
      if (objType === 'ModuleJob') {
        break;
      }
      hFrame = {
        type,
        filePath,
        fileName: extractFileName(filePath),
        functionName,
        line,
        column,
        isAsync: oSite.isAsync()
      };
      if (type === 'method') {
        hFrame.objType = objType;
        hFrame.methodName = methodName;
      }
      // --- If main body of a script, stop here
      if ((type === 'function') && notdefined(functionName)) {
        hFrame.type = 'script';
        delete hFrame.functionName;
        lFrames.push(hFrame);
        break;
      }
      hParsed = pathLib.parse(filePath);
      hFrame.dir = hParsed.dir;
      hFrame.stub = hParsed.name;
      hFrame.ext = hParsed.ext;
      mapSourcePos(hFrame);
      lFrames.push(hFrame);
    }
    return lFrames;
  };
  lStackFrames = new Error().stack;
  assert(lStackFrames.length > 0, "lStackFrames is empty!");
  // --- reset to previous values
  Error.stackTraceLimit = oldLimit;
  Error.prepareStackTrace = oldPreparer;
  return lStackFrames;
};

// ---------------------------------------------------------------------------
export var parseFileURL = (url) => {
  var _, dir, ext, fileName, hParsed, lMatches, pathStr, stub;
  assert(defined(url), "url is undef in parseFileURL()");
  lMatches = url.match(/^file:\/\/(.*)$/);
  if (defined(lMatches)) {
    [_, pathStr] = lMatches;
    ({
      dir,
      base: fileName,
      name: stub,
      ext
    } = pathLib.parse(pathStr));
    if (defined(dir) && (dir.indexOf('/') === 0)) {
      dir = dir.substr(1); // --- strip leading '/'
    }
    return {
      dir,
      fileName,
      source: `${dir}/${fileName}`,
      stub,
      ext
    };
  } else {
    lMatches = url.match(/^node:internal\/(.*)$/);
    if (defined(lMatches)) {
      hParsed = {
        source: 'node'
      };
    } else {
      croak(`Invalid file url: '${url}'`);
    }
  }
  return hParsed;
};

// ---------------------------------------------------------------------------
export var getMyOutsideCaller = () => {
  var err, fileName, hNode, i, lStack, len;
  try {
    // --- Returned object has keys:
    //        type - eval | native | constructor | method | function
    //        functionName
    //        objType, methodName - if a method
    //        line
    //        column
    //        isAsync - if an async function
    lStack = getV8Stack();
  } catch (error1) {
    err = error1;
    console.log(`ERROR in getV8Stack(): ${err.message}`);
    return undef;
  }
  fileName = undef;
  for (i = 0, len = lStack.length; i < len; i++) {
    hNode = lStack[i];
    if (fileName === undef) {
      fileName = hNode.fileName;
    } else if (hNode.fileName !== fileName) {
      return hNode;
    }
  }
  return undef;
};

// ---------------------------------------------------------------------------
export var getMyDirectCaller = () => {
  var err, lStack;
  try {
    // --- Returned object has keys:
    //        type - eval | native | constructor | method | function
    //        functionName
    //        objType, methodName - if a method
    //        line
    //        column
    //        isAsync - if an async function
    lStack = getV8Stack();
  } catch (error1) {
    err = error1;
    console.log(`ERROR in getV8Stack(): ${err.message}`);
    return undef;
  }
  return lStack[1];
};

//# sourceMappingURL=ll-v8-stack.js.map
