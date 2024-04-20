// coffee-utils.coffee

// ---------------------------------------------------------------------------
export var allExportsFrom = function(filePath) {
  var hMetaData, lMatches, regexp;
  regexp = /^\s*export\s+([A-Za-z_][A-Za-z0-9_]*)/;
  [hMetaData, lMatches] = readTextFile(filePath, {
    eager: true,
    pattern: regexp,
    wantMatches: true
  });
  return lMatches.map((lMatches) => {
    return lMatches[1];
  });
};

// ---------------------------------------------------------------------------
export var allExportsListing = (filePath) => {
  return Array.from(allExportsFrom(filePath));
};

// ---------------------------------------------------------------------------
// --- Returns number of usages found

// --- HOW TO SKIP imports !!!!!
export var symbolNumUsages = (symbol, dir, hOptions = {}) => {
  var fileHeader, filePath, from, hFile, isInternal, isTest, line, lineNum, log, nMatches, numInternalUsages, numTestUsages, numUsages, projHeader, ref, ref1, relPath, x;
  ({log, from} = getOptions(hOptions, {
    log: false,
    from: undef
  }));
  assert(isNonEmptyString(symbol), "Empty symbol");
  if (defined(from)) {
    from = mkpath(from);
  }
  assert(isDir(dir), `Not a directory: ${OL(dir)}`);
  numUsages = numTestUsages = numInternalUsages = 0;
  projHeader = false;
  ref = allFilesMatching(`${dir}/**/*.coffee`);
  for (hFile of ref) {
    ({relPath, filePath} = hFile);
    isTest = relPath.match(/[\\\/]test[\\\/]/);
    if (defined(from)) {
      isInternal = samefile(filePath, from);
    } else {
      isInternal = false;
    }
    nMatches = 0;
    fileHeader = false;
    ref1 = allMatchingLinesIn(relPath, symbol);
    for (x of ref1) {
      [line, lineNum] = x;
      // --- We found a match!
      if (isTest) {
        numTestUsages += 1;
      } else if (isInternal) {
        numInternalUsages += 1;
      } else {
        numUsages += 1;
      }
      if (log) {
        if (!projHeader) {
          LOG(centeredText(dir, 40, 'char=-'));
          projHeader = true;
        }
        if (!fileHeader) {
          LOG(`FILE: ${relPath}`);
          fileHeader = true;
        }
        LOG(`   ${lineNum}: ${truncateStr(line, 64)}`);
      }
    }
  }
  return [numUsages, numTestUsages, numInternalUsages];
};
