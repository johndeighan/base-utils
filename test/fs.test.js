// fs.test.coffee
var dir, testDir, testPath;

import test from 'ava';

import {
  setDebugging
} from '@jdeighan/base-utils/debug';

import {
  isFile,
  isDir,
  mkpath,
  mkdirSync,
  slurp,
  barf,
  forEachFileInDir
} from '@jdeighan/base-utils/fs';

dir = process.cwd(); // should be root directory of @jdeighan/base-utils

testDir = mkpath(dir, 'test');

testPath = mkpath(dir, 'test', 'readline.txt');

// ---------------------------------------------------------------------------
test("line 15", (t) => {
  return t.is(mkpath("abc", "def"), "abc/def");
});

test("line 16", (t) => {
  return t.is(mkpath("c:\\Users", "johnd"), "c:/Users/johnd");
});

test("line 17", (t) => {
  return t.is(mkpath("C:\\Users", "johnd"), "c:/Users/johnd");
});

test("line 19", (t) => {
  return t.truthy(isFile(mkpath(dir, 'package.json')));
});

test("line 20", (t) => {
  return t.falsy(isFile(mkpath(dir, 'doesNotExist.txt')));
});

test("line 21", (t) => {
  return t.truthy(isDir(mkpath(dir, 'src')));
});

test("line 22", (t) => {
  return t.truthy(isDir(mkpath(dir, 'test')));
});

test("line 23", (t) => {
  return t.falsy(isDir(mkpath(dir, 'doesNotExist')));
});

test("line 25", (t) => {
  return t.truthy(isFile(dir, 'package.json'));
});

test("line 26", (t) => {
  return t.falsy(isFile(dir, 'doesNotExist.txt'));
});

test("line 27", (t) => {
  return t.truthy(isDir(dir, 'src'));
});

test("line 28", (t) => {
  return t.truthy(isDir(dir, 'test'));
});

test("line 29", (t) => {
  return t.falsy(isDir(dir, 'doesNotExist'));
});

test("line 31", (t) => {
  return t.is(slurp(testPath, {
    maxLines: 2
  }), `abc
def`);
});

test("line 36", (t) => {
  return t.is(slurp(testPath, {
    maxLines: 3
  }), `abc
def
ghi`);
});

test("line 42", (t) => {
  return t.is(slurp(testPath, {
    maxLines: 1000
  }), `abc
def
ghi
jkl
mno`);
});

// --- Test without building path first
test("line 52", (t) => {
  return t.is(slurp(dir, 'test', 'readline.txt', {
    maxLines: 2
  }), `abc
def`);
});

test("line 57", (t) => {
  return t.is(slurp(dir, 'test', 'readline.txt', {
    maxLines: 3
  }), `abc
def
ghi`);
});

test("line 63", (t) => {
  return t.is(slurp(dir, 'test', 'readline.txt', {
    maxLines: 1000
  }), `abc
def
ghi
jkl
mno`);
});
