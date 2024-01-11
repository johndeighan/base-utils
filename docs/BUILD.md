Creating the base-utils project
===============================

1.-
```bash
$ mkdir base-utils
$ cd base-utils
$ git init -b main
$ npm init
$ mkdir src
$ mkdir test
$ npm install js-yaml
$ npm install ava
```

NOTE: During 'npm init', make the package name '@jdeighan/base-utils'
      using your npm user name in place of 'jdeighan'

In the src/ folder, add your library, e.g. base-utils.coffee
In the test/ folder, add your unit tests, e.g.

```coffeescript
import test from 'ava'

import {
	haltOnError, logErrors, LOG, DEBUG, error, assert, croak,
	normalize, super_normalize,
	} from '@jdeighan/base-utils'

# ---------------------------------------------------------------------------

test 'foo', (t) => t.pass()

block = """
	abc\tdef
	\tabc     def
	"""

norm = normalize(block)
snorm = super_normalize(block)

test 'normalize', (t) => t.is(norm, "abc def\nabc def")
test 'super_normalize', (t) => t.is(snorm, "abc def abc def")
```

In your package.json file:

1. Add key to 'scripts' section:
	"test": "npm run build && rm -f ./test/*.js && coffee -c ./test && ava ./test/*.test.js && git status"
2. Add key "type": "module"
3. Add key "exports":
	{ ".": "./src/base-utils.js"}

Add a .gitignore file:

```text
node_modules/
```

Add a .npmrc file:

```text
engine-strict=true
loglevel=silent
```

Add a README.md file:

```text
Creating this project
=====================

```

```bash
$ git status
```

Should not include ANYTHING inside the node_modules folder

```bash
$ git add -A
$ git commit -m "initial commit"
```

All unit tests should pass using `npm test`
`git status` should show:

```text
On branch main
nothing to commit, working tree clean
```

Create a GitHub repo
====================

```bash
$ cd ..
$ gh repo create
```

The first command should put you in the parent folder

I followed instructions from:

	https://docs.github.com/en/get-started/importing-your-projects-to-github/importing-source-code-to-github/adding-locally-hosted-code-to-github

Unfortunately, they didn't work. To make it work, I had to cd to the
parent folder, then run 'gh repo create'.

At the initial prompt, you should select:

	Push an existing local repository to GitHub

After that, you won't see the prompt, just a '?'. Enter the name of
the folder, which will become the name of the repo.

Furthermore, later prompts also do not appear, so you should just
keep hitting 'Enter' and eventually you'll get your bash prompt
back and the repo will be created at GitHub.

Publishing on npm
=================

```bash
$ cd base-utils
$ publish
```

This is a synonum for `npm publish --access=public`
(in my .bashrc file)
