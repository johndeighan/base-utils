@jdeighan/base-utils/fs
=======================

[unit tests](../test/fs.test.coffee)

file system utilities
---------------------

Reading files
-------------

The simplest way to read the contents of a file is:

```coffee
contents = slurp 'file.txt'
```

`slurp()` is synchronous. You can limit the number of
lines read with:

```coffee
contents = slurp 'file.txt', {maxLines: 5}
```
or
```coffee
contents = slurp 'file.txt', 'maxlines=5'
```
If the file you're reading is in JSON or TAML format,
you can do:
```coffee
hJson = slurpJSON 'file.json'
hPkgJson = slurpPkgJSON()   # search from current dir upwards
hTaml = slurpTAML 'file.taml'
```

More complex alternatives are:

```coffee
# --- allLinesIn() is a generator
for line from allLinesIn('file.txt')
	console.log "LINE: #{line}"
```

and

```coffee
lineHandler = (line, hContext) =>
	{lineNum} = hContext
	console.log "Line #{lineNum}: '#{line}'"
foreachLineInFile 'file.txt', lineHandler

lineHandler = (line, hContext) =>
	{prefix, lineNum} = hContext
	console.log "#{prefix}[#{lineNum}] #{line}"
foreachLineInFile 'file.txt', lineHandler, {prefix: '> '}
```

Writing files
-------------

```coffee
writer = new FileWriter('file.txt')
writer.writeln 'abc'
writer.writeln 'def'
writer.close()

# --- The file will contain:
```text
abc
def
```

There is a `write()` methods which does not append a
newline character. Also, if you pass multiple parameters
to either `write()` or `writeln()`, they are all written
to the file and `writeln()` will only add a newline
character after the last parameter is written. Parameters
need not all be strings. By default, numbers are converted
to strings using the number's `toString()` method, and other
values are converted to strings using an internal algorithm.
However, you can control how values are converted to strings
by overriding the `convert()` method of FileWriter.

A FileWriter is, by default synchonous. However, you
can create it in async mode:

```coffee
writer = new FileWriter('file.txt', {async: true})
await writer.writeln 'abc'
await writer.writeln 'def'
await writer.close()

# --- The file will contain:
```text
abc
def
```
