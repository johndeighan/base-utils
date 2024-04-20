// analyze.coffee
var ast, code, h, hOptions;

import {
  untabify
} from '@jdeighan/base-utils';

import {
  setDebugging
} from '@jdeighan/base-utils/debug';

import {
  toAST
} from '@jdeighan/base-utils/coffee';

import {
  toTAML
} from '@jdeighan/base-utils/taml';

import {
  analyzeCoffeeCode
} from '@jdeighan/base-utils/ast-walker';

code = `export toBlock = (lItems) ->
	return lItems.join("\n")`;

ast = toAST(code);

hOptions = {
  sortKeys: ['type']
};

console.log(untabify(toTAML(ast, hOptions)));

h = analyzeCoffeeCode(code);

console.log(untabify(toTAML(h)));