// for-each-file.test.coffee
var curdir;

import {
  undef,
  defined,
  notdefined,
  execCmd,
  LOG,
  OL
} from '@jdeighan/base-utils';

import {
  mkpath
} from '@jdeighan/base-utils/fs';

import {
  equal,
  like,
  includes,
  matches,
  samelines,
  succeeds
} from '@jdeighan/base-utils/utest';

curdir = mkpath(process.cwd());

// ---------------------------------------------------------------------------
(() => {
  var result;
  result = execCmd('npx for-each-file -debug=list -glob=test/test/**/*.txt -cmd="echo <file>"');
  return samelines(result, `CMD: 'echo˳${curdir}/test/test/file1.txt'
CMD: 'echo˳${curdir}/test/test/file2.txt'
CMD: 'echo˳${curdir}/test/test/file3.txt'`);
})();

// ---------------------------------------------------------------------------
(() => {
  var result;
  result = execCmd('npx for-each-file', {
    debug: 'list',
    glob: 'test/test/**/*.txt'
  });
  return samelines(result, `FILE: '${curdir}/test/test/file1.txt'
FILE: '${curdir}/test/test/file2.txt'
FILE: '${curdir}/test/test/file3.txt'`);
})();

// ---------------------------------------------------------------------------
(() => {
  var result;
  result = execCmd('npx for-each-file', {
    debug: 'list',
    glob: 'test/test/**/*.txt',
    cmd: 'echo <file>'
  });
  return samelines(result, `CMD: 'echo˳${curdir}/test/test/file1.txt'
CMD: 'echo˳${curdir}/test/test/file2.txt'
CMD: 'echo˳${curdir}/test/test/file3.txt'`);
})();

// ---------------------------------------------------------------------------
(() => {
  var result;
  result = execCmd('npx for-each-file', {
    debug: 'list',
    glob: 'test/test/**/*.coffee',
    cmd: 'echo <file>'
  });
  return samelines(result, `CMD: 'echo˳${curdir}/test/test/subdir/test.coffee'
CMD: 'echo˳${curdir}/test/test/test.coffee'`);
})();

// ---------------------------------------------------------------------------
(() => {
  var result;
  result = execCmd('npx for-each-file', {
    debug: 'list',
    glob: 'test/test/**/*.coffee',
    cmd: 'coffee -cmb --no-header <file>'
  });
  return samelines(result, `CMD: 'coffee˳-cmb˳--no-header˳${curdir}/test/test/subdir/test.coffee'
CMD: 'coffee˳-cmb˳--no-header˳${curdir}/test/test/test.coffee'`);
})();

// ---------------------------------------------------------------------------
// --- test -debug=json
(() => {
  var result;
  result = execCmd('npx for-each-file', {
    debug: 'json',
    glob: 'test/test/**/*.coffee',
    cmd: 'coffee -cmb --no-header <file>'
  });
  return succeeds(() => {
    return JSON.parse(result);
  });
})();