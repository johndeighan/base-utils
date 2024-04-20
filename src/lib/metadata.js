// metadata.coffee
var hMetaDataTypes;

import {
  undef,
  defined,
  notdefined,
  OL,
  isHash,
  isString,
  isArray,
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
  LOG
} from '@jdeighan/base-utils/log';

import {
  dbgEnter,
  dbgReturn,
  dbg
} from '@jdeighan/base-utils/debug';

import {
  fromTAML
} from '@jdeighan/base-utils/taml';

import {
  fromNICE
} from '@jdeighan/base-utils/from-nice';

// --- { <start>: <converter>, ... }
hMetaDataTypes = {
  '---': (block) => {
    return fromTAML(`---\n${block}`);
  },
  '!!!': (block) => {
    return fromNICE(block);
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
  return defined(str) && defined(hMetaDataTypes[str]);
};

// ---------------------------------------------------------------------------
// --- input can be a string or array of strings
// --- input will include start line, but not end line
export var convertMetaData = (input) => {
  var block, result, start;
  dbgEnter('convertMetaData', input);
  // --- convert input to an array
  input = toArray(input);
  // --- set vars start and block
  assert(input.length > 0, "Empty array");
  start = input[0];
  block = toBlock(input.slice(1));
  dbg('start', start);
  dbg('block', block);
  assert(defined(hMetaDataTypes[start]), `Bad metadata start: ${OL(start)}`);
  // --- NOTE: block should not include the start line
  result = hMetaDataTypes[start](block);
  dbgReturn('convertMetaData', result);
  return result;
};
