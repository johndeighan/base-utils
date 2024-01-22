// source-map.coffee
var hSourceMaps;

import {
  readFileSync,
  existsSync
} from 'node:fs';

import {
  SourceMapConsumer
} from 'source-map-js';

import {
  undef,
  pass,
  defined,
  notdefined,
  alldefined,
  ll_assert,
  isEmpty,
  nonEmpty,
  deepCopy,
  getOptions,
  isInteger,
  isString
} from '@jdeighan/base-utils';

import {
  isFile,
  fileExt,
  mkpath,
  parsePath
} from '@jdeighan/base-utils/ll-fs';

// --- cache to hold previously fetched file contents
hSourceMaps = {}; // { filepath => hMap, ... }


// ---------------------------------------------------------------------------
// This lib uses the library source-map-js
// ---------------------------------------------------------------------------
export var getMap = (mapFilePath) => {
  var hMap, rawMap;
  // --- get from cache if available
  if (hSourceMaps.hasOwnProperty(mapFilePath)) {
    return hSourceMaps[mapFilePath];
  } else {
    rawMap = readFileSync(mapFilePath, 'utf8');
    hMap = hSourceMaps[mapFilePath] = JSON.parse(rawMap);
    return hMap;
  }
};

// ---------------------------------------------------------------------------
// --- Valid keys:

//   - version: Which version of the source map spec this map is following.
//   - sources: An array of URLs to the original source files.
//   - names: An array of identifiers which can be referrenced by individual mappings.
//   - sourceRoot: Optional. The URL root from which all sources are relative.
//   - sourcesContent: Optional. An array of contents of the original source files.
//   - mappings: A string of base64 VLQs which contain the actual mappings.
//   - file: Optional. The generated file this source map is associated with.
export var dumpMap = (hMap) => {
  var hJson;
  hJson = {
    version: hMap.version,
    sources: hMap.sources,
    names: hMap.names,
    sourceRoot: hMap.sourceRoot,
    sourcesContent: defined(hMap.sourcesContent),
    mappings: defined(hMap.mappings),
    file: hMap.file
  };
  console.log(JSON.stringify(hJson, null, 3));
};

// ---------------------------------------------------------------------------
export var mapLineNum = (jsPath, line) => {
  // --- Temporarily, since it's broken,
  //     we simply return the original line number
  return line;
};

//	hMapped = mapSourcePos(jsPath, line, 0)
//	return hMapped.line

// ---------------------------------------------------------------------------
export var mapSourcePos = (jsPath, line, column, hOptions = {}) => {
  var debug, hMap, hMapped, mapFilePath, smc;
  // --- Can map only if:
  //        1. ext is .js
  //        2. <jsPath>.map exists

  //     returns {source, line, column, name}
  ({debug} = getOptions(hOptions, {
    debug: false
  }));
  jsPath = mkpath(jsPath);
  ll_assert(isFile(jsPath), `no such file ${jsPath}`);
  if (fileExt(jsPath) !== '.js') {
    if (debug) {
      console.log(`${jsPath} is not a JS file`);
    }
    return undef;
  }
  ll_assert(isInteger(line, {
    min: 0
  }), `line ${line} not an integer`);
  ll_assert(isInteger(column, {
    min: 0
  }), `column ${column} not an integer`);
  mapFilePath = jsPath + '.map';
  if (isFile(mapFilePath)) {
    if (debug) {
      console.log(`map file ${mapFilePath} found`);
    }
  } else {
    if (debug) {
      console.log(`map file ${mapFilePath} not found`);
    }
    return undef;
  }
  // --- get from cache if available
  hMap = getMap(mapFilePath);
  ll_assert(defined(hMap), `Unable to get map from ${mapFilePath}`);
  if (debug) {
    dumpMap(hMap);
  }
  smc = new SourceMapConsumer(hMap);
  if (debug) {
    console.log(smc.sources);
  }
  // --- hMapped is {source, line, column, name}
  hMapped = smc.originalPositionFor({line, column});
  if (debug) {
    console.log(hMapped);
  }
  return hMapped;
};

//# sourceMappingURL=source-map.js.map
