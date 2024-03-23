# object.test.coffee

import {undef, OL} from '@jdeighan/base-utils'
import {LOG} from '@jdeighan/base-utils/log'
import {
	u, equal, truthy, falsy, succeeds, throws,
	} from '@jdeighan/base-utils/utest'
import {peggyParse} from '@jdeighan/base-utils/peggy'
import * as lib from '@jdeighan/base-utils/object'
Object.assign(global, lib)

# ---------------------------------------------------------------------------

u.transformValue = (str) => return peggyParse(parse, str)

# ---------------------------------------------------------------------------

truthy parse

equal ".undef.", undef
equal ".null.", null
equal ".true.", true
equal ".false.", false

equal """
	fName: John
	lName: Deighan
	""", {
	fName: 'John'
	lName: 'Deighan'
	}

equal """
	first name:   John
	last name:    Deighan
	full name  :  John    Deighan
	""", {
	"first name": 'John'
	"last name":  'Deighan'
	"full name":  'John Deighan'
	}

equal """
	- John
	- Deighan
	""", [
	'John'
	'Deighan'
	]

equal """
	-   John
	-  Deighan
	-    John    Deighan
	""", [
	'John'
	'Deighan'
	'John Deighan'
	]

equal "«\"Hello\", that's what she said.»",
	"\"Hello\", that's what she said."

equal """
	- John
	- John Deighan
	- 42
	""", [
	"John"
	"John Deighan"
	42
	]
