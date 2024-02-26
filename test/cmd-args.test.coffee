# cmd-args.test.coffee

import {LOG} from '@jdeighan/base-utils'
import {UnitTester} from '@jdeighan/base-utils/utest'
import {parse} from '@jdeighan/base-utils/cmd-args'

u = new UnitTester()
u.transformValue = (str) => return parse(str)

# ---------------------------------------------------------------------------

u.equal '-a', {
	a: true
	}
u.equal '-X', {
	X: true
	}
u.equal '  -b', {
	b: true
	}
u.equal '-c\t', {
	c: true
	}
u.equal '-ab=title', {
	ab: 'title'
	}
u.equal '-label=Expenses', {
	label: 'Expenses'
	}
u.equal '-title="My Budget"', {
	title: 'My Budget'
	}
u.equal '-a -b', {
	a: true
	b: true
	}
u.equal '-ab',   {
	a: true
	b: true
	}
u.equal "-a -title=works", {
	a:true
	title:"works"
	}
u.equal "-a -m -title=works -n=5", {
	a:true
	m:true
	title:"works"
	n:"5"
	}
u.equal "-am -title=works -n=5", {
	a:true
	m:true
	title:"works"
	n:"5"
	}
u.equal "-am -title='it works' -n=5", {
	a:true
	m:true
	title:"it works"
	n:"5"
	}
u.equal "-am Willy Wonka", {
	a:true
	m:true
	_:['Willy', 'Wonka']
	}

u.equal "'do that' -am \"do this\"", {
	a:true
	m:true
	_:['do that', 'do this']
	}

u.throws () => parse('--')
