// readline.coffee
import fs from 'node:fs';

import NReadLines from 'n-readlines';

import {
  undef,
  defined,
  forEachItem
} from '@jdeighan/base-utils';

import {
  assert
} from '@jdeighan/base-utils/exceptions';

// ---------------------------------------------------------------------------
export var allLinesIn = function*(filePath) {
  var buffer, reader;
  reader = new NReadLines(filePath);
  while (buffer = reader.next()) {
    yield buffer.toString().replaceAll('\r', '');
  }
};

// ---------------------------------------------------------------------------
// --- reader.close() fails with error if EOF reached
export var forEachLineInFile = (filePath, func, hContext = {}) => {
  var linefunc;
  // --- func gets (line, hContext)
  //     hContext will include keys:
  //        filePath
  //        lineNum - first line is line 1
  linefunc = (line, hContext) => {
    hContext.filePath = filePath;
    hContext.lineNum = hContext.index + 1;
    return func(line, hContext);
  };
  return forEachItem(allLinesIn(filePath), linefunc, hContext);
};

//# sourceMappingURL=readline.js.map
