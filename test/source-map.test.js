// source-map.test.coffee

// --- 3 files are used:
//        ./source.coffee
//        ./source.js
//        ./source.js.map
var mapPath, rawMap;

import pathLib from 'node:path';

import {
  getRawMap,
  mapPos
} from '@jdeighan/base-utils/source-map';

import {
  utest
} from '@jdeighan/base-utils/utest';

mapPath = pathLib.resolve("./test/source.js.map");

rawMap = getRawMap(mapPath);

// console.log rawMap
utest.truthy(15, rawMap.match(/\bsourceRoot\b/));

utest.truthy(16, rawMap.match(/\bsources\b/));

utest.truthy(17, rawMap.match(/\#\ssource-map\.coffee/));

// --- This should work, but currently does not
// hResult = mapPos rawMap, {line: 10, column: 0}
// console.log hResult
// utest.equal 18, hResult.line, 7

//# sourceMappingURL=source-map.test.js.map
