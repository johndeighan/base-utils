// source-map.test.coffee

// --- 3 files are used:
//        ./test/source-map/base-utils.coffee
//        ./test/source-map/base-utils.js
//        ./test/source-map/base-utils.js.map
var hMap, jsPath, mapPath;

import pathLib from 'node:path';

import {
  hasKey
} from '@jdeighan/base-utils';

import {
  mkpath
} from '@jdeighan/base-utils/ll-fs';

import {
  getMap,
  mapSourcePos,
  mapLineNum
} from '@jdeighan/base-utils/source-map';

import {
  utest
} from '@jdeighan/base-utils/utest';

jsPath = mkpath("./test/source-map/base-utils.test.js");

mapPath = jsPath + '.map';

hMap = getMap(mapPath);

// console.log hMap
utest.truthy(15, hasKey(hMap, 'sourceRoot'));

utest.truthy(16, hasKey(hMap, 'sources'));

// --- This should work, but currently does not
// hResult = mapSourcePos jsPath, 10, 0, 'debug'
// console.log hResult
// utest.equal 18, hResult.line, 7

//# sourceMappingURL=source-map.test.js.map
