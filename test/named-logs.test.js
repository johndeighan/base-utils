// named-logs.test.coffee
import {
  undef,
  defined,
  notdefined,
  pass,
  escapeStr
} from '@jdeighan/base-utils';

import * as lib from '@jdeighan/base-utils/named-logs';

Object.assign(global, lib);

import {
  equal,
  truthy,
  falsy
} from '@jdeighan/base-utils/utest';

// ---------------------------------------------------------------------------
(function() {
  var logs;
  logs = new NamedLogs();
  logs.log('A', 'first log');
  logs.log('A', 'second log');
  return equal(logs.getLogs('A'), `first log
second log`);
})();

// ---------------------------------------------------------------------------
(function() {
  var logs;
  logs = new NamedLogs();
  logs.log('A', 'first log');
  logs.log('B', 'second log');
  equal(logs.getLogs('A'), `first log`);
  return equal(logs.getLogs('B'), `second log`);
})();

// ---------------------------------------------------------------------------
(function() {
  var logs;
  logs = new NamedLogs();
  logs.log('A', 'first log');
  logs.log('A', 'second log');
  logs.log('B', 'first log');
  logs.log('B', 'second log');
  logs.clear('A');
  equal(logs.getLogs('A'), '');
  return equal(logs.getLogs('B'), `first log
second log`);
})();

// ---------------------------------------------------------------------------
(function() {
  var logs;
  logs = new NamedLogs();
  logs.log('A', 'first log');
  logs.log('A', 'second log');
  logs.log('B', 'first log');
  logs.log('B', 'second log');
  logs.clearAllLogs();
  equal(logs.getLogs('A'), '');
  return equal(logs.getLogs('B'), '');
})();

// ---------------------------------------------------------------------------
(function() {
  var logs;
  logs = new NamedLogs();
  logs.log('A', 'first log');
  logs.log('A', 'second log');
  logs.log('B', 'first log');
  logs.log('B', 'second log');
  return equal(logs.getAllLogs(), `first log
second log
first log
second log`);
})();

// ---------------------------------------------------------------------------
// --- test: name can be undef
(function() {
  var logs;
  logs = new NamedLogs();
  logs.log(undef, 'first log');
  logs.log(undef, 'second log');
  logs.log('B', 'first log');
  logs.log('B', 'second log');
  return equal(logs.getLogs(undef), `first log
second log`);
})();

// ---------------------------------------------------------------------------
// --- test: using a filter function
(function() {
  var func, logs;
  logs = new NamedLogs();
  logs.log(undef, 'first log');
  logs.log(undef, 'junk');
  logs.log(undef, 'second log');
  logs.log('B', 'first log');
  logs.log('B', 'junk');
  logs.log('B', 'second log');
  func = (str) => {
    return str.match(/log/);
  };
  equal(logs.getLogs(undef, func), `first log
second log`);
  return equal(logs.getLogs('B', func), `first log
second log`);
})();