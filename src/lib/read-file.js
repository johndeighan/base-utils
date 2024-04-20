// read-file.coffee
import pathLib from 'node:path';

import NReadLines from 'n-readlines';

import {
  globSync as glob
} from 'glob';

import {
  undef,
  defined,
  notdefined,
  OL,
  getOptions,
  isFunction,
  isArray,
  isString,
  isRegExp,
  isEmpty,
  isIterable
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
  dbgEnter,
  dbgReturn,
  dbg,
  dbgYield,
  dbgResume
} from '@jdeighan/base-utils/debug';

import {
  isFile,
  mkpath,
  relpath,
  lStatFields
} from '@jdeighan/base-utils/fs';

import {
  isMetaDataStart,
  convertMetaData
} from '@jdeighan/base-utils/metadata';

// ---------------------------------------------------------------------------
// --- Valid options:
//        eager - if true, return lLines in place of reader
//        pattern - string or regexp lines must match
//        transform - function to apply to lines
export var readTextFile = (source, hOptions = {}) => {
  var eager, filePath, firstLine, getLine, hMetaData, inExtra, iterator, lMetaLines, lineMatches, nReader, numLinesRead, pattern, reader, result, tempLine, transform;
  // --- handles metadata if present
  //     source should be either:
  //        - a file path
  //        - an iterable
  dbgEnter('readTextFile', source);
  if (isString(source)) {
    assert(isFile(source), `Not a file: ${OL(source)}`);
    filePath = source;
  } else if (isIterable(source)) {
    // --- it has key [Symbol.iterator],
    //     which is a function
    iterator = source[Symbol.iterator]();
  } else {
    croak(`Not a file or iterable: ${OL(source)}`);
  }
  ({eager, pattern, transform} = getOptions(hOptions, {
    eager: false,
    pattern: undef,
    transform: undef
  }));
  dbg('eager', eager);
  dbg('pattern', pattern);
  dbg('transform', transform);
  // --- define an appropriate lineMatches function
  if (defined(pattern)) {
    if (isString(pattern)) {
      lineMatches = (line) => {
        return line.includes(pattern);
      };
    } else if (isRegExp(pattern)) {
      lineMatches = (line) => {
        return defined(line.match(pattern));
      };
    } else {
      croak("Bad pattern option");
    }
  } else {
    lineMatches = (line) => {
      return true;
    };
  }
  inExtra = false;
  if (defined(filePath)) {
    nReader = new NReadLines(filePath);
    getLine = () => {
      var buffer, result;
      buffer = nReader.next();
      if (buffer === false) {
        nReader = undef; // prevent further reads
        return undef;
      }
      result = buffer.toString().replaceAll('\r', '');
      if (result === '__END__') {
        inExtra = true;
        return undef;
      }
      dbg(`   getLine():  ${OL(result)}`);
      return result;
    };
  } else {
    getLine = () => {
      var done, result, value;
      ({value, done} = iterator.next());
      if (done) {
        iterator = undef; // prevent further reads
        return undef;
      }
      result = value || '';
      if (result === '__END__') {
        inExtra = true;
        return undef;
      }
      return result;
    };
  }
  // --- we need to get the first line to check if
  //     there's metadata. But if there is not,
  //     we need to return it by the reader
  firstLine = getLine();
  dbg('firstLine', firstLine);
  lMetaLines = undef;
  // --- Get metadata if present
  if (defined(firstLine) && isMetaDataStart(firstLine)) {
    dbg(`file has metadata: ${OL(firstLine)}`);
    lMetaLines = [firstLine];
    tempLine = getLine();
    while (tempLine && (tempLine !== lMetaLines[0])) {
      lMetaLines.push(tempLine);
      tempLine = getLine();
    }
    hMetaData = convertMetaData(lMetaLines);
    dbg('hMetaData', hMetaData);
  } else {
    dbg("file has no metadata");
    hMetaData = undef;
  }
  dbg('lMetaLines', lMetaLines);
  if (defined(lMetaLines)) {
    numLinesRead = lMetaLines.length + 1;
  } else {
    numLinesRead = 0;
  }
  reader = function*() {
    var line, matches, result;
    // --- NOTE lineMatches() returns true if empty pattern
    dbgEnter('reader');
    if (notdefined(hMetaData) && !inExtra && (matches = lineMatches(firstLine, pattern))) {
      dbg("yielding first line because no metadata");
      if (defined(transform)) {
        result = transform(firstLine);
      } else {
        result = firstLine;
      }
      dbgYield('reader', result);
      yield result;
      dbgResume('reader');
    }
    line = getLine();
    while (defined(line)) {
      if (matches = lineMatches(line, pattern)) {
        if (defined(transform) && !inExtra) {
          result = transform(line);
        } else {
          result = line;
        }
        dbgYield('reader', result);
        yield result;
        dbgResume('reader');
      }
      line = getLine();
    }
    dbgReturn('reader');
  };
  if (eager) {
    result = [hMetaData || {}, Array.from(reader()), numLinesRead];
  } else {
    result = [hMetaData || {}, reader, numLinesRead];
  }
  dbgReturn('readTextFile', result);
  return result;
};

// ---------------------------------------------------------------------------
// --- yield hFile with keys:
//        path, filePath
//        type
//        root
//        dir
//        base, fileName
//        name, stub
//        ext
//        purpose
//     ...plus stat fields
export var globFiles = function*(pattern = '*', hGlobOptions = {}) {
  var base, dir, ent, ext, filePath, hFile, i, j, key, lMatches, len, len1, name, purpose, ref, root, type;
  dbgEnter('globFiles', pattern, hGlobOptions);
  hGlobOptions = getOptions(hGlobOptions, {
    withFileTypes: true,
    stat: true
  });
  dbg('pattern', pattern);
  dbg('hGlobOptions', hGlobOptions);
  ref = glob(pattern, hGlobOptions);
  for (i = 0, len = ref.length; i < len; i++) {
    ent = ref[i];
    filePath = mkpath(ent.fullpath());
    ({root, dir, base, name, ext} = pathLib.parse(filePath));
    if (lMatches = name.match(/\.([A-Za-z_]+)$/)) {
      purpose = lMatches[1];
    } else {
      purpose = undef;
    }
    if (ent.isDirectory()) {
      type = 'dir';
    } else if (ent.isFile()) {
      type = 'file';
    } else {
      type = 'unknown';
    }
    hFile = {
      filePath,
      path: filePath,
      relPath: relpath(filePath),
      type,
      root,
      dir,
      base,
      fileName: base,
      name,
      stub: name,
      ext,
      purpose
    };
    for (j = 0, len1 = lStatFields.length; j < len1; j++) {
      key = lStatFields[j];
      hFile[key] = ent[key];
    }
    dbgYield('globFiles', hFile);
    yield hFile;
    dbgResume('globFiles');
  }
  dbgReturn('globFiles');
};

// ---------------------------------------------------------------------------
export var allFilesMatching = function*(pattern = '*', hOptions = {}) {
  var eager, fileFilter, filePath, h, hGlobOptions, hMetaData, lLines, numFiles, ref;
  // --- yields hFile with keys:
  //        path, filePath,
  //        type, root, dir, base, fileName,
  //        name, stub, ext, purpose
  //        (if eager) hMetaData, lLines
  // --- Valid options:
  //        hGlobOptions - options to pass to glob
  //        fileFilter - return path iff fileFilter(filePath) returns true
  //        eager - read the file and add keys hMetaData, lLines
  // --- Valid glob options:
  //        ignore - glob pattern for files to ignore
  //        dot - include dot files/directories (default: false)
  //        cwd - change working directory
  dbgEnter('allFilesMatching', pattern, hOptions);
  ({hGlobOptions, fileFilter, eager} = getOptions(hOptions, {
    hGlobOptions: {
      ignore: "node_modules"
    },
    fileFilter: (h) => {
      var path;
      ({
        filePath: path
      } = h);
      return isFile(path) && !path.match(/\bnode_modules\b/i) && !path.match(/\bDropbox\b/i);
    },
    eager: false
  }));
  dbg(`pattern = ${OL(pattern)}`);
  dbg(`hGlobOptions = ${OL(hGlobOptions)}`);
  dbg(`eager = ${OL(eager)}`);
  numFiles = 0;
  ref = globFiles(pattern, hGlobOptions);
  for (h of ref) {
    ({filePath} = h);
    dbg(`GLOB: ${OL(filePath)}`);
    if (eager && isFile(filePath)) {
      [hMetaData, lLines] = readTextFile(filePath, 'eager');
      assert(isArray(lLines), "Bad return from readTextFile");
      h.hMetaData = hMetaData;
      h.lLines = lLines;
    }
    if (fileFilter(h)) {
      dbgYield('allFilesMatching', h);
      yield h;
      dbgResume('allFilesMatching');
      numFiles += 1;
    }
  }
  dbg(`${numFiles} files matched`);
  dbgReturn('allFilesMatching');
};

// ---------------------------------------------------------------------------
export var getShebang = (hMetaData) => {
  var shebang;
  shebang = hMetaData.shebang;
  if (shebang === true) {
    return "#!/usr/bin/env node";
  } else if (isString(shebang)) {
    return shebang;
  } else if (isEmpty(shebang)) {
    return undef;
  } else {
    return croak(`Bad shebang: ${OL(shebang)}`);
  }
};
