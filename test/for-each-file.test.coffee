# for-each-file.test.coffee

import {
	undef, defined, notdefined, execCmd, OL,
	} from '@jdeighan/base-utils'
import {LOG} from '@jdeighan/base-utils/log'
import {mkpath} from '@jdeighan/base-utils/fs'
import {
	equal, like, includes, matches, samelines, succeeds,
	} from '@jdeighan/base-utils/utest'

curdir = mkpath(process.cwd())

# ---------------------------------------------------------------------------

(() =>
	result = execCmd('npx for-each-file -debug=list -glob=test/test/**/*.txt -cmd="echo <file>"')
	samelines result, """
		CMD: "echo˳#{curdir}/test/test/file1.txt"
		CMD: "echo˳#{curdir}/test/test/file2.txt"
		CMD: "echo˳#{curdir}/test/test/file3.txt"
		"""
	)()

# ---------------------------------------------------------------------------

(() =>
	result = execCmd('npx for-each-file', {
		debug: 'list'
		glob: 'test/test/**/*.txt'
		})
	samelines result, """
		FILE: "#{curdir}/test/test/file1.txt"
		FILE: "#{curdir}/test/test/file2.txt"
		FILE: "#{curdir}/test/test/file3.txt"
		"""
	)()

# ---------------------------------------------------------------------------

(() =>
	result = execCmd('npx for-each-file', {
		debug: 'list'
		glob: 'test/test/**/*.txt'
		cmd: 'echo <file>'
		})
	samelines result, """
		CMD: "echo˳#{curdir}/test/test/file1.txt"
		CMD: "echo˳#{curdir}/test/test/file2.txt"
		CMD: "echo˳#{curdir}/test/test/file3.txt"
		"""
	)()

# ---------------------------------------------------------------------------

(() =>
	result = execCmd('npx for-each-file', {
		debug: 'list'
		glob: 'test/test/**/*.coffee'
		cmd: 'echo <file>'
		})
	samelines result, """
		CMD: "echo˳#{curdir}/test/test/subdir/test.coffee"
		CMD: "echo˳#{curdir}/test/test/test.coffee"
		"""
	)()

# ---------------------------------------------------------------------------

(() =>
	result = execCmd('npx for-each-file', {
		debug: 'list'
		glob: 'test/test/**/*.coffee'
		cmd: 'coffee -cmb --no-header <file>'
		})
	samelines result, """
		CMD: "coffee˳-cmb˳--no-header˳#{curdir}/test/test/subdir/test.coffee"
		CMD: "coffee˳-cmb˳--no-header˳#{curdir}/test/test/test.coffee"
		"""
	)()

# ---------------------------------------------------------------------------
# --- test -debug=json

(() =>
	result = execCmd('npx for-each-file', {
		debug: 'json'
		glob: 'test/test/**/*.coffee'
		cmd: 'coffee -cmb --no-header <file>'
		})
	succeeds () =>
		JSON.parse(result)
	)()

