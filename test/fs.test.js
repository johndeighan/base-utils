// fs.test.coffee
var dir;

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


// ---------------------------------------------------------------------------
test("line 13", (t) => {
  return t.is(mkpath("abc", "def"), "abc/def");
});

test("line 14", (t) => {
  return t.is(mkpath("c:\\Users", "johnd"), "c:/Users/johnd");
});

test("line 15", (t) => {
  return t.is(mkpath("C:\\Users", "johnd"), "c:/Users/johnd");
});

test("line 17", (t) => {
  return t.truthy(isFile(mkpath(dir, 'package.json')));
});

test("line 18", (t) => {
  return t.falsy(isFile(mkpath(dir, 'doesNotExist.txt')));
});

test("line 19", (t) => {
  return t.truthy(isDir(mkpath(dir, 'src')));
});

test("line 20", (t) => {
  return t.truthy(isDir(mkpath(dir, 'test')));
});

test("line 21", (t) => {
  return t.falsy(isDir(mkpath(dir, 'doesNotExist')));
});

test("line 23", (t) => {
  return t.truthy(isFile(dir, 'package.json'));
});

test("line 24", (t) => {
  return t.falsy(isFile(dir, 'doesNotExist.txt'));
});

test("line 25", (t) => {
  return t.truthy(isDir(dir, 'src'));
});

test("line 26", (t) => {
  return t.truthy(isDir(dir, 'test'));
});

test("line 27", (t) => {
  return t.falsy(isDir(dir, 'doesNotExist'));
});
