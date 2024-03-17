// coffee.coffee
var hCoffeeOptions;

import assert from 'node:assert';

import fs from 'fs';

import CoffeeScript from 'coffeescript';

hCoffeeOptions = {
  bare: true,
  header: false,
  sourceMap: true
};

// ---------------------------------------------------------------------------
export var brew = function(coffeeCode, filePath, hOptions = {
    quiet: false
  }) {
  var err, h;
  assert(fs.existsSync(filePath), `Not a file: ${filePath}`);
  try {
    hCoffeeOptions.filename = filePath;
    h = CoffeeScript.compile(coffeeCode, hCoffeeOptions);
    return [h.js.trim(), h.v3SourceMap];
  } catch (error) {
    err = error;
    console.log(`ERROR: ${err.message}`);
    return [void 0, void 0];
  }
};

//# sourceMappingURL=coffee.js.map
