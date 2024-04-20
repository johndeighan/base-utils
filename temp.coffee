# temp.coffee

import {isFile} from '@jdeighan/base-utils/fs'

if isFile("./.gitignore")
	console.log ".gitignore exists"
else
	console.log ".gitignore DOES NOT EXIST"
