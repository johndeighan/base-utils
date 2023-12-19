// log.test.coffee
var Node1, Node2, fourSpaces, node1, node2, subtype, type;

import test from 'ava';

import {
  undef,
  defined,
  notdefined,
  pass,
  jsType
} from '@jdeighan/base-utils';

import {
  getPrefix
} from '@jdeighan/base-utils/prefix';

import {
  logWidth,
  sep_dash,
  sep_eq,
  setLogWidth,
  resetLogWidth,
  debugLogging,
  setStringifier,
  resetStringifier,
  stringify,
  tamlStringify,
  orderedStringify,
  LOG,
  LOGVALUE,
  LOGTAML,
  LOGJSON,
  clearAllLogs,
  getMyLogs,
  echoLogsByDefault
} from '@jdeighan/base-utils/log';

fourSpaces = '    ';

echoLogsByDefault(false);

// ---------------------------------------------------------------------------
test("line 23", (t) => {
  return t.deepEqual(orderedStringify(['a', 42, [1, 2]]), `---
- a
- 42
- - 1
  - 2`);
});

// ---------------------------------------------------------------------------
test("line 35", (t) => {
  return t.is(logWidth, 42);
});

test("line 37", (t) => {
  setLogWidth(5);
  t.is(logWidth, 5);
  t.is(sep_dash, '-----');
  return resetLogWidth();
});

test("line 43", (t) => {
  setLogWidth(5);
  t.is(logWidth, 5);
  t.is(sep_eq, '=====');
  return resetLogWidth();
});

// ---------------------------------------------------------------------------
test("line 51", (t) => {
  return t.is(getPrefix(0), '');
});

test("line 52", (t) => {
  return t.is(getPrefix(1), fourSpaces);
});

test("line 53", (t) => {
  return t.is(getPrefix(2), fourSpaces + fourSpaces);
});

// ---------------------------------------------------------------------------
test("line 57", (t) => {
  clearAllLogs('noecho');
  LOG("abc");
  return t.is(getMyLogs(), `abc`);
});

test("line 64", (t) => {
  clearAllLogs('noecho');
  LOG("abc");
  LOG("def");
  return t.is(getMyLogs(), `abc
def`);
});

test("line 73", (t) => {
  clearAllLogs('noecho');
  LOG("abc");
  LOG("def", getPrefix(1));
  LOG("ghi", getPrefix(2));
  return t.is(getMyLogs(), `abc
    def
        ghi`);
});

// ---------------------------------------------------------------------------
test("line 86", (t) => {
  clearAllLogs('noecho');
  LOGVALUE('x', undef);
  return t.is(getMyLogs(), `x = undef`);
});

test("line 93", (t) => {
  clearAllLogs('noecho');
  LOGVALUE('x', null);
  return t.is(getMyLogs(), `x = null`);
});

test("line 100", (t) => {
  clearAllLogs('noecho');
  LOGVALUE('x', 'abc');
  return t.is(getMyLogs(), `x = 'abc'`);
});

test("line 107", (t) => {
  clearAllLogs('noecho');
  LOGVALUE('x', 'abc def');
  return t.is(getMyLogs(), `x = 'abc˳def'`);
});

test("line 114", (t) => {
  clearAllLogs('noecho');
  LOGVALUE('x', '"abc"');
  return t.is(getMyLogs(), `x = '"abc"'`);
});

test("line 121", (t) => {
  clearAllLogs('noecho');
  LOGVALUE('x', "'abc'");
  return t.is(getMyLogs(), `x = "'abc'"`);
});

test("line 128", (t) => {
  clearAllLogs('noecho');
  LOGVALUE('x', "'\"abc\"'");
  return t.is(getMyLogs(), `x = <'"abc"'>`);
});

// --- long string
test("line 137", (t) => {
  clearAllLogs('noecho');
  LOGVALUE('x', 'a'.repeat(80));
  return t.is(getMyLogs(), `x = \"\"\"
	${'a'.repeat(80)}
	\"\"\"`);
});

// --- multi line string
test("line 148", (t) => {
  clearAllLogs('noecho');
  LOGVALUE('x', 'abc\ndef');
  return t.is(getMyLogs(), `x = 'abc®def'`);
});

// --- hash (OL doesn't fit)
test("line 157", (t) => {
  clearAllLogs('noecho');
  setLogWidth(5);
  LOGVALUE('h', {
    xyz: 42,
    abc: 99
  });
  resetLogWidth();
  return t.is(getMyLogs(), `h =
	---
	abc: 99
	xyz: 42`);
});

// --- hash (OL fits)
test("line 171", (t) => {
  clearAllLogs('noecho');
  LOGVALUE('h', {
    xyz: 42,
    abc: 99
  });
  return t.is(getMyLogs(), `h = {"xyz":42,"abc":99}`);
});

// --- array  (OL doesn't fit)
test("line 180", (t) => {
  clearAllLogs('noecho');
  setLogWidth(5);
  LOGVALUE('l', ['xyz', 42, false, undef]);
  resetLogWidth();
  return t.is(getMyLogs(), `l =
	---
	- xyz
	- 42
	- false
	- undef`);
});

// --- array (OL fits)
test("line 196", (t) => {
  clearAllLogs('noecho');
  LOGVALUE('l', ['xyz', 42, false, undef]);
  return t.is(getMyLogs(), `l = ["xyz",42,false,null]`);
});

// --- object
Node1 = class Node1 {
  constructor(str, level) {
    this.str = str;
    this.level = level;
    this.name = 'node1';
  }

};

node1 = new Node1('abc', 2);

test("line 210", (t) => {
  clearAllLogs('noecho');
  LOGVALUE('Node1', node1);
  return t.is(getMyLogs(), `Node1 =
	---
	level: 2
	name: node1
	str: abc`);
});

// --- object with toString method
Node2 = class Node2 {
  constructor(str, level) {
    this.str = str;
    this.level = level;
    this.name = 'node2';
  }

  toLogString() {
    return `HERE IT IS
str is ${this.str}
name is ${this.name}
level is ${this.level}
THAT'S ALL FOLKS!`;
  }

};

node2 = new Node2('abc', 2);

[type, subtype] = jsType(node2);

test("line 240", (t) => {
  clearAllLogs('noecho');
  LOGVALUE('Node2', node2);
  return t.is(getMyLogs(), `Node2 =
	HERE IT IS
	str is abc
	name is node2
	level is 2
	THAT'S ALL FOLKS!`);
});

test("line 252", (t) => {
  var hProc;
  clearAllLogs('noecho');
  hProc = {
    code: function(block) {
      return `${block};`;
    },
    html: function(block) {
      return block.replace('<p>', '<p> ').replace('</p>', ' </p>');
    },
    Script: function(block) {
      return elem('script', undef, block, "\t");
    }
  };
  LOGVALUE('hProc', hProc);
  return t.is(getMyLogs(), `hProc =
	---
	Script: "[Function: Script]"
	code: "[Function: code]"
	html: "[Function: html]"`);
});

test("line 271", (t) => {
  clearAllLogs('noecho');
  setLogWidth(5);
  LOGTAML('lItems', ['xyz', 42, false, undef]);
  resetLogWidth();
  return t.is(getMyLogs(), `lItems = <<<
   ---
   - xyz
   - 42
   - false
   - undef`);
});

test("line 284", (t) => {
  clearAllLogs('noecho');
  setLogWidth(5);
  LOGJSON('lItems', ['xyz', 42, false, undef]);
  resetLogWidth();
  return t.is(getMyLogs(), `lItems =
[
   "xyz",
   42,
   false,
   null
]`);
});

//# sourceMappingURL=log.test.js.map
