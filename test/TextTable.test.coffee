# TextTable.test.coffee

import {u} from '@jdeighan/base-utils/utest'
import {TextTable} from '@jdeighan/base-utils/TextTable'

# -------------------------------------------------------------

(() =>
	table = new TextTable('l r%.2f r%.2f')
	table.addLabels ['Category', 'Jan', 'Feb']
	table.addSep()
	table.addData ['Computer', 23.5, 50.9]
	table.addData ['Science',  99, 53]
	table.addSep()
	table.addTotals()
	str = table.asString()
	u.equal str, """
		Category  Jan    Feb
		-------- ------ ------
		Computer  23.50  50.90
		Science   99.00  53.00
		-------- ------ ------
		         122.50 103.90
		"""
	)()

# -------------------------------------------------------------

(() =>
	table = new TextTable('r r%.4f r%.4f')
	table.addLabels ['Category', 'January', 'February']
	table.addSep()
	table.addData ['Computer', 23.5, 50.9]
	table.addData ['Science',  99, 53]
	table.addSep('=')
	table.addTotals()
	str = table.asString()
	u.equal str, """
		Category January  February
		-------- -------- --------
		Computer  23.5000  50.9000
		 Science  99.0000  53.0000
		======== ======== ========
		         122.5000 103.9000
		"""
	)()
