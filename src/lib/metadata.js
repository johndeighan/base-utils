// metadata.coffee
var hMetaDataTypes;

import {
  undef,
  defined,
  notdefined,
  LOG,
  OL,
  isHash,
  isString,
  isNonEmptyString,
  isFunction,
  toArray,
  toBlock
} from '@jdeighan/base-utils';

import {
  assert,
  croak
} from '@jdeighan/base-utils/exceptions';

import {
  fromTAML
} from '@jdeighan/base-utils/taml';

// --- { <start>: <converter>, ... }
hMetaDataTypes = {
  '---': (block) => {
    return fromTAML(block);
  }
};

// ---------------------------------------------------------------------------
export var addMetaDataType = (start, converter) => {
  assert(isString(start), "Missing start");
  assert(start.length === 3, `Bad 'start' key: ${OL(start)}`);
  assert((start[1] === start[0]) && (start[2] === start[0]), `Bad 'start' key: ${OL(start)}`);
  assert(isFunction(converter), "Non-function converter");
  hMetaDataTypes[start] = converter;
};

// ---------------------------------------------------------------------------
export var isMetaDataStart = (str) => {
  return defined(hMetaDataTypes[str]);
};

// ---------------------------------------------------------------------------
// --- blockOrArray will include start line,
//     but not end line
export var convertMetaData = (blockOrArray, start) => {
  var block;
  assert(defined(hMetaDataTypes[start]), `Bad metadata start: ${OL(start)}`);
  block = toBlock(blockOrArray);
  return hMetaDataTypes[start](block);
};

//# sourceMappingURL=metadata.js.map
