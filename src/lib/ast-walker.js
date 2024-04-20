// ast-walker.coffee
var hAllHandlers, lBuiltins;

import {
  undef,
  pass,
  defined,
  notdefined,
  OL,
  deepCopy,
  isString,
  nonEmpty,
  isArray,
  isHash,
  isArrayOfHashes,
  toBlock,
  getOptions,
  removeKeys,
  words
} from '@jdeighan/base-utils';

import {
  assert,
  croak
} from '@jdeighan/base-utils/exceptions';

import {
  LOG,
  LOGVALUE
} from '@jdeighan/base-utils/log';

import {
  dbg,
  dbgEnter,
  dbgReturn
} from '@jdeighan/base-utils/debug';

import {
  slurp,
  barf,
  isDir
} from '@jdeighan/base-utils/fs';

import {
  fromTAML,
  toTAML
} from '@jdeighan/base-utils/taml';

import {
  indented
} from '@jdeighan/base-utils/indent';

import {
  toAST
} from '@jdeighan/base-utils/coffee';

import {
  Context
} from '@jdeighan/base-utils/context';

lBuiltins = words('global clearImmediate setImmediate clearInterval', 'clearTimeout setInterval setTimeout', 'queueMicrotask structuredClone atob btoa', 'performance navigator fetch crypto');

hAllHandlers = fromTAML(`---
File:
	lWalkTrees:
		- program
Program:
	lWalkTrees:
		- body
ArrayExpression:
	lWalkTrees:
		- elements
AssignmentExpression:
	lDefined:
		- left
	lUsed:
		- right
AssignmentPattern:
	lDefined:
		- left
	lWalkTrees:
		- right
BinaryExpression:
	lUsed:
		- left
		- right
BlockStatement:
	lWalkTrees:
		- body
ClassBody:
	lWalkTrees:
		- body
ClassDeclaration:
	lWalkTrees:
		- body
ClassMethod:
	lWalkTrees:
		- body
ExpressionStatement:
	lWalkTrees:
		- expression
IfStatement:
	lWalkTrees:
		- test
		- consequent
		- alternate
LogicalExpression:
	lWalkTrees:
		- left
		- right
SpreadElement:
	lWalkTrees:
		- argument
SwitchStatement:
	lWalkTrees:
		- cases
SwitchCase:
	lWalkTrees:
		- test
		- consequent
TemplateLiteral:
	lWalkTrees:
		- expressions
TryStatement:
	lWalkTrees:
		- block
		- handler
		- finalizer
UnaryExpression:
	lWalkTrees:
		- argument
WhileStatement:
	lWalkTrees:
		- test
		- body`);

// ---------------------------------------------------------------------------
// ---------------------------------------------------------------------------
export var ASTWalker = class ASTWalker {
  constructor(from) {
    // --- from can be an AST or CoffeeScript code
    dbgEnter("ASTWalker", from);
    if (isString(from)) {
      this.ast = toAST(from);
    } else {
      this.ast = from;
    }
    // --- @ast can be a hash or array of hashes
    if (isHash(this.ast)) {
      dbg("tree was hash - constructing list from it");
      this.ast = [this.ast];
    }
    assert(isArrayOfHashes(this.ast), `not array of hashes: ${OL(this.ast)}`);
    // --- Info to accumulate
    this.lImportedSymbols = [];
    this.lExportedSymbols = [];
    this.lUsedSymbols = [];
    this.lMissingSymbols = [];
    this.context = new Context();
    dbgReturn("ASTWalker");
  }

  // ..........................................................
  addImport(name, lib) {
    dbgEnter("addImport", name, lib);
    this.check(name);
    if (this.lImportedSymbols.includes(name)) {
      LOG(`Duplicate import: ${name}`);
    } else {
      this.lImportedSymbols.push(name);
    }
    this.context.addGlobal(name);
    dbgReturn("addImport");
  }

  // ..........................................................
  addExport(name, lib) {
    dbgEnter("addExport", name);
    this.check(name);
    if (this.lExportedSymbols.includes(name)) {
      LOG(`Duplicate export: ${name}`);
    } else {
      this.lExportedSymbols.push(name);
    }
    dbgReturn("addExport");
  }

  // ..........................................................
  addDefined(name, value = {}) {
    dbgEnter("addDefined", name);
    this.check(name);
    if (this.context.atGlobalLevel()) {
      this.context.addGlobal(name);
    } else {
      this.context.add(name);
    }
    dbgReturn("addDefined");
  }

  // ..........................................................
  addUsed(name, value = {}) {
    dbgEnter("addUsed", name);
    this.check(name);
    if (!lBuiltins.includes(name)) {
      if (!this.lUsedSymbols.includes(name)) {
        this.lUsedSymbols.push(name);
      }
      if (!this.context.has(name) && !this.lMissingSymbols.includes(name)) {
        this.lMissingSymbols.push(name);
      }
    }
    dbgReturn("addUsed");
  }

  // ..........................................................
  walkTree(tree, level = 0) {
    var i, len, node;
    dbgEnter("walkTree");
    if (isArray(tree)) {
      for (i = 0, len = tree.length; i < len; i++) {
        node = tree[i];
        this.walkTree(node, level);
      }
    } else {
      assert(isHash(tree, ['type']), `bad tree: ${OL(tree)}`);
      this.visit(tree, level);
    }
    dbgReturn("walkTree");
  }

  // ..........................................................
  getHandlers(node, level) {
    var hHandlers, lDefined, lUsed, lWalkTrees, result, type;
    ({type} = node);
    hHandlers = hAllHandlers[type];
    if (defined(hHandlers)) {
      ({lWalkTrees, lDefined, lUsed} = hHandlers);
      result = [type, lWalkTrees, lDefined, lUsed];
    } else {
      result = [undef];
    }
    // console.log result
    return result;
  }

  // ..........................................................
  // --- return true if handled, false if not
  handle(node, level) {
    var i, j, k, key, l, lDefined, lUsed, lWalkTrees, len, len1, len2, len3, subnode, tree, type;
    dbgEnter("handle", node, level);
    [type, lWalkTrees, lDefined, lUsed] = this.getHandlers(node, level);
    if (notdefined(type)) {
      dbgReturn("handle", false);
      return false;
    }
    if (defined(lDefined)) {
      for (i = 0, len = lDefined.length; i < len; i++) {
        key = lDefined[i];
        subnode = node[key];
        if (subnode.type === 'Identifier') {
          this.addDefined(subnode.name);
        } else {
          this.walkTree(subnode, level + 1);
        }
      }
    }
    if (defined(lUsed)) {
      for (j = 0, len1 = lUsed.length; j < len1; j++) {
        key = lUsed[j];
        subnode = node[key];
        if (subnode.type === 'Identifier') {
          this.addUsed(subnode.name);
        } else {
          this.walkTree(subnode, level + 1);
        }
      }
    }
    if (defined(lWalkTrees)) {
      for (k = 0, len2 = lWalkTrees.length; k < len2; k++) {
        key = lWalkTrees[k];
        subnode = node[key];
        if (isArray(subnode)) {
          for (l = 0, len3 = subnode.length; l < len3; l++) {
            tree = subnode[l];
            this.walkTree(tree, level + 1);
          }
        } else if (defined(subnode)) {
          this.walkTree(subnode, level + 1);
        }
      }
    }
    dbgReturn("handle", true);
    return true;
  }

  // ..........................................................
  visit(node, level) {
    var arg, argument, body, callee, computed, declaration, hSpec, i, id, importKind, imported, j, k, l, lParmNames, left, len, len1, len2, len3, len4, lib, local, m, name, object, param, parm, property, ref, ref1, ref2, right, source, spec, specifiers, type;
    dbgEnter("ASTWalker.visit", node, level);
    assert(defined(node), "node is undef");
    if (this.handle(node, level)) {
      dbgReturn("ASTWalker.visit");
      return;
    }
    switch (node.type) {
      case 'CallExpression':
        ({callee} = node);
        if (callee.type === 'Identifier') {
          this.addUsed(callee.name);
        } else {
          this.walkTree(callee, level + 1);
        }
        ref = node.arguments;
        for (i = 0, len = ref.length; i < len; i++) {
          arg = ref[i];
          if (arg.type === 'Identifier') {
            this.addUsed(arg.name);
          } else {
            this.walkTree(arg, level + 1);
          }
        }
        break;
      case 'CatchClause':
        param = node.param;
        if (defined(param) && (param.type === 'Identifier')) {
          this.addDefined(param.name);
        }
        this.walkTree(node.body, level + 1);
        break;
      case 'ExportNamedDeclaration':
        ({specifiers, declaration} = node);
        if (defined(declaration)) {
          ({type, id, left, body} = declaration);
          switch (type) {
            case 'ClassDeclaration':
              if (defined(id)) {
                this.addExport(id.name);
              } else if (defined(body)) {
                this.walkTree(node.body, level + 1);
              }
              break;
            case 'AssignmentExpression':
              if (left.type === 'Identifier') {
                this.addExport(left.name);
              }
          }
          this.walkTree(declaration, level + 1);
        }
        if (defined(specifiers)) {
          for (j = 0, len1 = specifiers.length; j < len1; j++) {
            spec = specifiers[j];
            name = spec.exported.name;
            this.addExport(name);
          }
        }
        break;
      case 'For':
        if (defined(node.name) && (node.name.type === 'Identifier')) {
          this.addDefined(node.name.name);
        }
        if (defined(node.index) && (node.name.type === 'Identifier')) {
          this.addDefined(node.index.name);
        }
        this.walkTree(node.source, level + 1);
        this.walkTree(node.body, level + 1);
        break;
      case 'FunctionExpression':
      case 'ArrowFunctionExpression':
        lParmNames = [];
        if (defined(node.params)) {
          ref1 = node.params;
          for (k = 0, len2 = ref1.length; k < len2; k++) {
            parm = ref1[k];
            switch (parm.type) {
              case 'Identifier':
                lParmNames.push(parm.name);
                break;
              case 'AssignmentPattern':
                ({left, right} = parm);
                if (left.type === 'Identifier') {
                  lParmNames.push(left.name);
                }
                if (right.type === 'Identifier') {
                  this.addUsed(right.name);
                } else {
                  this.walkTree(right, level + 1);
                }
            }
          }
        }
        this.context.beginScope('<unknown>', lParmNames);
        this.walkTree(node.params, level + 1);
        this.walkTree(node.body, level + 1);
        this.context.endScope();
        break;
      case 'ImportDeclaration':
        ({specifiers, source, importKind} = node);
        if ((importKind === 'value') && (source.type === 'StringLiteral')) {
          lib = source.value; // e.g. '@jdeighan/coffee-utils'
          for (l = 0, len3 = specifiers.length; l < len3; l++) {
            hSpec = specifiers[l];
            ({type, imported, local, importKind} = hSpec);
            if ((type === 'ImportSpecifier') && defined(imported) && (imported.type === 'Identifier')) {
              this.addImport(imported.name, lib);
            }
          }
        }
        break;
      case 'NewExpression':
        if (node.callee.type === 'Identifier') {
          this.addUsed(node.callee.name);
        }
        ref2 = node.arguments;
        for (m = 0, len4 = ref2.length; m < len4; m++) {
          arg = ref2[m];
          if (arg.type === 'Identifier') {
            this.addUsed(arg.name);
          } else {
            this.walkTree(arg); // --- ???
          }
        }
        break;
      case 'MemberExpression':
        // --- has keys:
        //        type = 'MemberExpression'
        //        computed: boolean
        //        object
        //        optional: boolean
        //        property
        //        shorthand: boolean

        // NOTE: Because we need to treat it differently
        //       depending on whether computes is true or false,
        //       we cannot handle this in hAllHandlers
        ({object, property, computed} = node);
        if (object.type === 'Identifier') {
          this.addUsed(object.name);
        } else {
          this.walkTree(object);
        }
        if (computed) { // --- e.g hItem[expr], not hItem.name
          if (property.type === 'Identifier') {
            this.addUsed(property.name);
          } else {
            this.walkTree(property);
          }
        }
        break;
      case 'ReturnStatement':
        ({argument} = node);
        if (defined(argument)) {
          if (argument.type === 'Identifier') {
            this.addUsed(argument.name);
          } else {
            this.walkTree(argument);
          }
        }
    }
    dbgReturn("ASTWalker.visit");
  }

  // ..........................................................
  walk() {
    var hInfo, i, lNotNeeded, len, node, ref;
    dbgEnter("walk", this.ast);
    ref = this.ast;
    for (i = 0, len = ref.length; i < len; i++) {
      node = ref[i];
      this.visit(node, 0);
    }
    // --- get symbols to return

    // --- not needed if:
    //        1. in lImported
    //        2. not in lUsedSymbols
    //        3. not in lExportedSymbols
    lNotNeeded = this.lImportedSymbols.filter((name) => {
      return !this.lUsedSymbols.includes(name) && !this.lExportedSymbols.includes(name);
    });
    hInfo = {
      lImported: this.lImportedSymbols.sort(),
      lExported: this.lExportedSymbols.sort(),
      lUsed: this.lUsedSymbols.sort(),
      lMissing: this.lMissingSymbols.sort(),
      lNotNeeded: lNotNeeded.sort()
    };
    dbgReturn("walk", hInfo);
    return hInfo;
  }

  // ..........................................................
  check(name) {
    assert(nonEmpty(name), "empty name");
  }

  // ..........................................................
  barfAST(filePath, hOptions = {}) {
    var astCopy, full, lSortBy;
    ({full} = getOptions(hOptions));
    lSortBy = words("type params body left right");
    if (full) {
      return barf(toTAML(this.ast, {
        sortKeys: lSortBy
      }), filepath);
    } else {
      astCopy = deepCopy(this.ast);
      removeKeys(astCopy, words('start end extra declarations loc range tokens comments', 'assertions implicit optional async generate hasIndentedBody'));
      return barf(toTAML(astCopy, {
        sortKeys: lSortBy
      }), filepath);
    }
  }

};

// ---------------------------------------------------------------------------
export var analyzeCoffeeCode = (code) => {
  var walker;
  walker = new ASTWalker(code);
  return walker.walk();
};

// ---------------------------------------------------------------------------
export var analyzeCoffeeFile = (filePath) => {
  var walker;
  walker = new ASTWalker(slurp(filePath));
  return walker.walk();
};
