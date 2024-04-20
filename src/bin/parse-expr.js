#!/usr/bin/env node
// parse-expr.coffee
var err, exprStr, hAST, hExpr;

import {
  undef,
  defined,
  notdefined,
  OL,
  centeredText
} from '@jdeighan/base-utils';

import {
  LOG
} from '@jdeighan/base-utils/log';

import {
  setDebugging
} from '@jdeighan/base-utils/debug';

import {
  toTAML
} from '@jdeighan/base-utils/taml';

import {
  toNICE
} from '@jdeighan/base-utils/to-nice';

import {
  toAST
} from '@jdeighan/base-utils/coffee';

import {
  getExpr
} from './parse-utils.js';

import {
  parse
} from './program.js';

import {
  pparse
} from '@jdeighan/base-utils/peggy';

// ---------------------------------------------------------------------------
exprStr = getExpr();

LOG(`PARSE: ${OL(exprStr)}`);

try {
  LOG(centeredText('CoffeeScript AST', 64, 'char=-'));
  hAST = toAST(exprStr);
  hExpr = hAST.program.body[0];
  // LOG JSON.stringify(hExpr, null, 3)
  console.log(toNICE(hExpr, 'numSpaces=3'));
} catch (error) {
  err = error;
  LOG(`FAILED: ${OL(err.message)}`);
}

try {
  LOG(centeredText('Using Peggy parser', 64, 'char=-'));
  console.log("parsing...");
  hAST = pparse(parse, exprStr);
  console.log("done parsing");
  hExpr = hAST.program.body[0];
  // LOG JSON.stringify(hExpr, null, 3)
  console.log(toNICE(hExpr, 'numSpaces=3'));
} catch (error) {
  err = error;
  LOG(`FAILED: ${OL(err.message)}`);
}