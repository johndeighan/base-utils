var A, B, D;

A = function() {
  var ref, results, x;
  ref = B();
  results = [];
  for (x of ref) {
    results.push(output(x));
  }
  return results;
};

B = function*() {
  output(13);
  yield 5;
  return (yield* D());
};

D = function*() {
  yield 1;
  return (yield 2);
};