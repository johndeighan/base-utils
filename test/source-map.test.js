// source-map.test.coffee

// --- 3 files are used:
//        ./test/source-map/base-utils.coffee
//        ./test/source-map/base-utils.js
//        ./test/source-map/base-utils.js.map
var hMap, hResult, jsPath, mapPath;

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
  UnitTester,
  equal,
  like,
  notequal,
  succeeds,
  throws,
  truthy,
  falsy
} from '@jdeighan/base-utils/utest';

jsPath = mkpath("./test/source-map/base-utils.test.js");

mapPath = jsPath + '.map';

hMap = getMap(mapPath);

truthy(hasKey(hMap, 'sourceRoot'));

truthy(hasKey(hMap, 'sources'));

hResult = mapSourcePos(jsPath, 10, 0);

equal(hResult.line, 6);

equal(mapLineNum(jsPath, 10), 6);

equal(mapLineNum(jsPath, 89), 27);

equal(mapLineNum(jsPath, 99), 28);

equal(mapLineNum(jsPath, 1361), 697);

//# sourceMappingURL=source-map.test.js.map
