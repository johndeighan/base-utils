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

# -------------------------------------------------------------
# --- Without a format spec, numbers default to 2 dec places

(() =>
	table = new TextTable('l r r')
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
# --- support option parseNumbers

(() =>
	table = new TextTable('l r r','parseNumbers')
	table.addLabels ['Category', 'Jan', 'Feb']
	table.addSep()
	table.addData ['Computer', '23.5', '50.9']
	table.addData ['Science',  '99', '53']
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
# --- Make sure headers contribute to col widths

(() =>
	table = new TextTable('l r r r r')
	table.addLabels ["Category","Dec˳2023","Jan˳2024","Feb˳2024","Average"]
	table.addSep()
	table.addData ["Insurance",null,null,400,133.33]
	table.addData ["Electric",126,126,126,126]
	table.addData ["Water",35,50,40,42]
	table.addData ["Eat˳Out",24,44,24,31]
	table.addSep()
	table.addTotals()

	str = table.asString()
	u.equal str, """
		Category  Dec˳2023 Jan˳2024 Feb˳2024 Average
		--------- -------- -------- -------- -------
		Insurance                     400.00  133.33
		Electric    126.00   126.00   126.00  126.00
		Water        35.00    50.00    40.00   42.00
		Eat˳Out      24.00    44.00    24.00   31.00
		--------- -------- -------- -------- -------
		            185.00   220.00   590.00  332.33
		"""
	)()
