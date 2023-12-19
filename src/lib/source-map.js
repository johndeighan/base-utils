// source-map.coffee
var blockUntil, hSourceMaps;

import {
  readFileSync,
  existsSync
} from 'node:fs';

import {
  SourceMapConsumer
} from 'source-map';

import Sync from 'node-sync';

import {
  undef,
  pass,
  defined,
  notdefined,
  alldefined,
  isEmpty,
  nonEmpty,
  deepCopy
} from '@jdeighan/base-utils/ll-utils';

import {
  isInteger
} from '@jdeighan/base-utils';

hSourceMaps = {}; // { filepath => rawMap, ... }


// ---------------------------------------------------------------------------
export var getRawMap = (mapFile) => {
  var rawMap;
  if (hSourceMaps.hasOwnProperty(mapFile)) {
    return hSourceMaps[mapFile];
  } else {
    rawMap = readFileSync(mapFile, 'utf8');
    hSourceMaps[mapFile] = rawMap;
    return rawMap;
  }
};

// ---------------------------------------------------------------------------
blockUntil = (func, cb = undef) => {
  while (!func()) {
    pass();
  }
  if (!func()) {
    // --- check condition every 100 ms.
    setTimeout(blockUntil.bind(null, func, cb), 100);
  } else {
    cb();
  }
};

// Usage:   blockUntil(() => return cond, () => console.log('done'))
// ---------------------------------------------------------------------------
export var mapSourcePos = (hFrame, debug = false) => {
  var column, dir, ext, fileName, filePath, func, intvl, line, mapFile, promise, rawMap, stub;
  //     hFrame must have keys:
  //        line, column - both non-negative integers
  //        EITHER:
  //           dir, stub, ext
  //           dir, fileName
  //           filePath

    // --- Can map only if:
  //        1. ext is .js
  //        2. <stub>.coffee and <stub>.js.map exist in dir

  // --- Modifies hFrame if mapped
  ({dir, stub, ext, fileName, filePath, line, column} = hFrame);
  if (!isInteger(line, {
    min: 0
  }) || !isInteger(column, {
    min: 0
  })) {
    if (debug) {
      console.log(`CANNOT MAP - line=${line}, column=${column}`);
    }
    return;
  }
  if (!alldefined(dir, stub, ext)) {
    // --- Make sure filePath is defined
    if (notdefined(filePath) && alldefined(dir, fileName)) {
      filePath = `${dir}/${fileName}`;
    }
    if (notdefined(filePath)) {
      if (debug) {
        console.log("CANNOT MAP: Not all needed fields defined");
      }
      return;
    }
    ({dir, stub, ext} = parseSource(filePath));
  }
  if (ext !== '.js') {
    if (debug) {
      console.log(`CANNOT MAP: ext = '${ext}'`);
    }
    return;
  }
  mapFile = `${dir}/${stub}.js.map`;
  if (!existsSync(mapFile)) {
    if (debug) {
      console.log(`CANNOT MAP - MISSING MAP FILE ${mapFile}`);
    }
    return;
  }
  if (isEmpty(dir) || isEmpty(stub)) {
    if (debug) {
      console.log(`CANNOT MAP - dir='${dir}', stub='${stub}'`);
    }
    return;
  }
  rawMap = getRawMap(mapFile); // get from cache if available
  if (debug) {
    console.log(`MAP FILE FOUND: '${mapFile}'`);
  }
  // --- WAS await SourceMapConsumer...
  promise = SourceMapConsumer.with(rawMap, null, (consumer) => {
    var hMapped;
    hMapped = consumer.originalPositionFor(hFrame);
    if (defined(hMapped.line)) {
      hFrame.js_line = line;
      hFrame.js_column = column;
      hFrame.js_fileName = `${stub}${ext}`;
      hFrame.js_filePath = `${dir}/${stub}.js`;
      hFrame.filePath = `${dir}/${stub}.coffee`;
      hFrame.line = hMapped.line;
      return hFrame.column = hMapped.column;
    } else {
      console.log("MAP FAILED:");
      console.log("RAW MAP:");
      console.log(rawMap);
      console.log("STACK FRAME:");
      console.log(hFrame);
      console.log("MAPPED:");
      return console.log(hMapped);
    }
  });
  intvl = undef;
  func = () => {
    if (defined(hFrame.js_line)) {
      clearInterval(intvl);
    }
  };
  intvl = setInterval(func, 100);
  if (debug) {
    console.log("MAP TO:");
    console.log(hFrame);
  }
  return deepCopy(hFrame);
};

//# sourceMappingURL=source-map.js.map
