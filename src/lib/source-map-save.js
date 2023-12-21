// source-map-save.coffee
var hSourceMaps;

import deasync from 'deasync';

import {
  readFileSync,
  existsSync
} from 'node:fs';

import {
  SourceMapConsumer
} from 'source-map';

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

import {
  mkpath
} from '@jdeighan/base-utils/ll-fs';

// --- cache to hold previously fetched file contents
hSourceMaps = {}; // { filepath => rawMap, ... }


// ---------------------------------------------------------------------------
// This lib uses mozilla's source-map library
// ---------------------------------------------------------------------------
export var getRawMap = (mapFilePath) => {
  var rawMap;
  if (hSourceMaps.hasOwnProperty(mapFilePath)) {
    return hSourceMaps[mapFilePath];
  } else {
    rawMap = readFileSync(mapFilePath, 'utf8');
    hSourceMaps[mapFilePath] = rawMap;
    return rawMap;
  }
};

// ---------------------------------------------------------------------------
// --- returns {source, line, column, name}
export var mapPos = function(rawMap, hPos) {
  var hResult, promise;
  // --- hPos should be {line, column}
  hResult = undef;
  promise = SourceMapConsumer.with(rawMap, null, (consumer) => {
    hResult = consumer.originalPositionFor(hPos);
    console.log("GOT RESULT");
    return console.log(hResult);
  });
  return deasync.loopWhile(function() {
    return notdefined(hResult);
  });
};

// ---------------------------------------------------------------------------
export var mapSourcePos = (hFileInfo, line, column, debug = false) => {
  var dir, ext, fileName, filePath, hMapped, mapFilePath, rawMap, stub;
  if (!isInteger(line, {
    min: 0
  })) {
    if (debug) {
      console.log(`mapSourcePos: invalid line ${line}`);
    }
    return undef;
  }
  if (!isInteger(column, {
    min: 0
  })) {
    if (debug) {
      console.log(`mapSourcePos: invalid column ${column}`);
    }
    return undef;
  }
  ({dir, stub, ext, fileName, filePath} = hFileInfo);
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
  mapFilePath = `${dir}/${stub}.js.map`;
  if (!existsSync(mapFilePath)) {
    if (debug) {
      console.log(`CANNOT MAP - MISSING MAP FILE ${mapFilePath}`);
    }
    return;
  }
  if (isEmpty(dir) || isEmpty(stub)) {
    if (debug) {
      console.log(`CANNOT MAP - dir='${dir}', stub='${stub}'`);
    }
    return;
  }
  rawMap = getRawMap(mapFilePath); // get from cache if available
  if (debug) {
    console.log(`MAP FILE FOUND: '${mapFilePath}'`);
  }
  // --- hMapped is {source, line, column, name}
  hMapped = mapPos(rawMap, {line, column});
  return hMapped;
  return hMapped = undef;
};

//# sourceMappingURL=source-map-save.js.map
