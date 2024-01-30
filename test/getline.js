// getline.js

import fs from 'node:fs';

let buffer = Buffer.alloc(1);

let getc = (fd) => {

	if (fs.readSync(fd, buffer, 0, 1) == 1) {
		return String.fromCharCode(buffer[0]);
		}
	else {
		return undefined;
		}
	}

export let readline = (fd) => {

	let lChars = [];
	let ch = getc(fd);
	while (ch && (ch != '\n')) {
		if (ch != '\r') {
			lChars.push(ch);
			}
		ch = getc(fd);
		}
	return (lChars.length == 0) ? undefined : lChars.join('');
	}
