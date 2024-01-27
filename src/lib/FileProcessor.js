  // FileProcessor.coffee
import {
  globSync as glob
} from 'glob';

import {
  undef,
  defined,
  notdefined,
  getOptions,
  add_s,
  isString,
  isHash,
  toJSON,
  hasKey,
  hasAnyKey,
  addNewKey,
  toBlock,
  toArray
} from '@jdeighan/base-utils';

import {
  toTAML
} from '@jdeighan/base-utils/taml';

import {
  assert,
  croak
} from '@jdeighan/base-utils/exceptions';

import {
  mkpath,
  mkDir,
  pathType,
  parsePath,
  subPath,
  allLinesIn,
  slurp,
  barf,
  isFile
} from '@jdeighan/base-utils/fs';

import {
  dbgEnter,
  dbgReturn,
  dbg
} from '@jdeighan/base-utils/debug';

import {
  indented
} from '@jdeighan/base-utils/indent';

// ---------------------------------------------------------------------------
export var FileProcessor = class FileProcessor {
  constructor(path1, pattern = '*', hOptions = {}) {
    this.path = path1;
    this.pattern = pattern;
    // --- path can be a file or directory
    //     if it's a file, then pattern and hGlobOptions are ignored
    // --- Valid options
    //        allowOverwrite - allow overwrite of original files
    //        hGlobOptions - options to pass to glob()
    // --- Valid glob options:
    //        ignore - glob pattern for files to ignore
    //        dot - include dot files/directories (default: false)
    dbgEnter('FileProcessor', this.path, this.pattern, hOptions);
    assert(isString(this.path), "path not a string");
    this.hOptions = getOptions(hOptions, {
      allowOverwrite: false,
      hGlobOptions: getOptions(hOptions.hGlobOptions, {
        absolute: true,
        cwd: this.path,
        dot: false
      })
    });
    // --- determine type of path
    this.path = mkpath(this.path); // --- convert to full path
    this.pathType = pathType(this.path);
    dbg(`path ${this.path} is a ${this.pathType}`);
    if (this.pathType === 'dir') {
      this.hGlobOptions = hOptions.hGlobOptions;
    } else if (this.pathType !== 'file') {
      croak(`invalid path '${this.path}'`);
    }
    this.lUserData = []; // --- filled in by readAll()
    dbgReturn('FileProcessor');
  }

  // ..........................................................
  getUserData() {
    return this.lUserData;
  }

  // ..........................................................
  getSortedUserData() {
    var compareFunc;
    compareFunc = (a, b) => {
      if (a.filePath < b.filePath) {
        return -1;
      } else if (a.filePath > b.filePath) {
        return 1;
      } else {
        return 0;
      }
    };
    return this.lUserData.toSorted(compareFunc);
  }

  // ..........................................................
  dumpdata(h) {
    var taml;
    dbgEnter('dumpdata', h);
    taml = toTAML(h, '!useTabs !useDashes indent=1');
    console.log(taml);
    dbgReturn('dumpdata');
  }

  // ..........................................................
  dumpUserData(format = 'nice') {
    var fileName, h, i, len, ref, str;
    // --- formats: 'nice', 'json', 'taml'
    dbgEnter('dumpUserData', format);
    switch (format.toLowerCase()) {
      case 'nice':
        ref = this.lUserData;
        for (i = 0, len = ref.length; i < len; i++) {
          h = ref[i];
          ({fileName} = parsePath(h.filePath));
          dbg(`dump info for file '${fileName}'`);
          str = '-'.repeat(10);
          console.log(`${str} ${fileName} ${str}`);
          this.dumpdata(h);
        }
        break;
      case 'json':
        console.log(toJSON(this.lUserData, '!useTabs'));
        break;
      case 'taml':
        console.log(toTAML(this.lUserData, '!useTabs'));
        break;
      default:
        croak(`Bad format: ${format}`);
    }
    dbgReturn('dumpUserData');
  }

  // ..........................................................
  readAll() {
    var filePath, h, hFile, i, len, numFiles, ref;
    dbgEnter('readAll');
    dbg(`pathType = ${this.pathType}`);
    numFiles = 0;
    switch (this.pathType) {
      case 'file':
        hFile = parsePath(this.path);
        if (this.filterFile(this.path)) {
          dbg(`[${numFiles}] ${hFile.fileName} - Handle`);
          h = this.handleFile(this.path);
          if (defined(h)) {
            assert(isHash(h), "handleFile() returned non-hash");
            addNewKey(h, 'filePath', hFile.filePath);
            this.lUserData.push(h);
          }
          numFiles += 1;
        } else {
          dbg(`[${numFiles}] ${hFile.fileName} - Skip`);
        }
        break;
      case 'dir':
        dbg(`pattern = '${this.pattern}'`);
        dbg('hGlobOptions', this.hGlobOptions);
        ref = glob(this.pattern, this.hGlobOptions);
        for (i = 0, len = ref.length; i < len; i++) {
          filePath = ref[i];
          if (isFile(filePath)) {
            dbg(`filePath = '${filePath}'`);
            hFile = parsePath(filePath);
            if (this.filterFile(filePath)) {
              dbg(`[${numFiles}] ${filePath} - Handle`);
              h = this.handleFile(filePath);
              if (defined(h)) {
                assert(isHash(h), "handleFile() returned non-hash");
                addNewKey(h, 'filePath', filePath);
                this.lUserData.push(h);
              }
              numFiles += 1;
            } else {
              dbg(`[${numFiles}] ${hFile.fileName} - Skip`);
            }
          }
        }
    }
    dbg(`${numFiles} file${add_s(numFiles)} processed`);
    dbgReturn('readAll');
  }

  // ..........................................................
  filterFile(filePath) {
    dbgEnter('filterFile', filePath);
    dbgReturn('filterFile');
    return true; // by default, handle all files in dir
  }

  
    // ..........................................................
  handleFile(filePath) {
    // --- does nothing, returns nothing
    dbgEnter('handleFile', filePath);
    dbgReturn('handleFile');
  }

  // ..........................................................
  writeAll() {
    var hUserData, i, len, newpath, ref;
    ref = this.lUserData;
    // --- Cycle through @lUserData, rewriting files as needed
    //     Items in @lUserData are hashes with key 'filePath'
    //        and whatever was returned from @handleFile()
    for (i = 0, len = ref.length; i < len; i++) {
      hUserData = ref[i];
      newpath = this.writeFileTo(hUserData);
      if (defined(newpath)) {
        this.writeFile(newpath, hUserData);
      }
    }
  }

  // ..........................................................
  // SHOULD OVERRIDE if you want to write files anywhere
  //    other than the default 'temp' subfolder

  // --- return undef to not write this file
  writeFileTo(hUserData) {
    // --- by default, write to a parallel directory
    return subPath(hUserData.filePath, 'temp');
  }

  // ..........................................................
  // --- SHOULD OVERRIDE if you intend to write files
  writeFile(path, hUserData) {} // by default, does nothing

};


  // ---------------------------------------------------------------------------
// --- path may be a new path
export var LineProcessor = class LineProcessor extends FileProcessor {
  dumpdata(hUserData) {
    var lLines, lineNum;
    ({lineNum, lLines} = hUserData);
    console.log(`LINE ${lineNum}:`);
    console.log(toTAML(lLines));
  }

  // ..........................................................
  handleFile(filePath) {
    var h, lLines, line, lineNum, ref, result;
    dbgEnter('handleFile', filePath);
    assert(isString(filePath), "not a string");
    lLines = []; // --- array of hashes
    lineNum = 1;
    ref = allLinesIn(filePath);
    for (line of ref) {
      dbg(`LINE: '${line}'`);
      // --- handleLine should return undef to ignore line
      //     otherwise, a hash which:
      //        cannot contain key 'lineNum'
      //        may contain keys:
      //           newLine - to later overwrite the line
      //           delete - to later delete the line
      h = this.handleLine(line, lineNum, filePath);
      if (defined(h)) {
        dbg("returned by handleLine()", h);
        addNewKey(h, 'lineNum', lineNum);
        lLines.push(h);
      } else {
        dbg(`line '${line}' ignored`);
      }
      lineNum += 1;
    }
    result = {lLines};
    dbgReturn('handleFile', result);
    return result;
  }

  // ..........................................................
  // --- SHOULD OVERRIDE, to save data for a given line
  handleLine(line, lineNum, filePath) {} // by default, returns nothing

  
    // ..........................................................
  writeFile(newPath, hUserData) {
    var filePath, hLine, i, lLines, lOutput, len, text;
    dbgEnter('writeFile', newPath, hUserData);
    ({lLines, filePath} = hUserData);
    if (!this.hOptions.allowOverwrite) {
      assert(newPath !== filePath, "Attempt to write org file");
    }
    lOutput = [];
    for (i = 0, len = lLines.length; i < len; i++) {
      hLine = lLines[i];
      text = this.writeLine(hLine);
      if (defined(text)) {
        assert(isString(text), "text not a string");
        lOutput.push(text);
      }
    }
    // --- Now write out the text in lOutput
    if (lOutput.length > 0) {
      barf(toBlock(lOutput), newPath);
    }
    dbgReturn('writeFile');
  }

  // ..........................................................
  // --- SHOULD OVERRIDE, to write data for a given line
  writeLine(hLine) {} // --- by default, returns nothing

};

//# sourceMappingURL=FileProcessor.js.map