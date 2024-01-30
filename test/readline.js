// readline.js

import fs from 'node:fs';

export let undef = undefined;   // a synonym
export let defined = (x) => (x !== undef)

let lookahead = undef;
let ungetc = (ch) => lookahead = ch;

let buffer = Buffer.alloc(1);

export let getc = (fd) => {

	if (defined(lookahead)) {
		let ch = lookahead;
		lookahead = undef;
		return ch;
		}

	if (fs.readSync(fd, buffer, 0, 1) == 1) {
		let ch = String.fromCharCode(buffer[0]);
		return (ch == '\r') ? getc(fd) : ch;
		}
	else {
		return undef;
		}
	}

export let readline = (fd) => {

	let ch = getc(fd);
	if (!defined(ch)) {
		return undef;   // no more lines
		}
	else if (ch === '\n') {
		// --- normally means an empty line
		//     unless there's nothing past it
		ch = getc(fd);
		if (!defined(ch)) {
			return undef;
			}
		ungetc(ch)
		return '';
		}
	let lChars = [];
	while (ch && (ch != '\n')) {
		lChars.push(ch);
		ch = getc(fd);
		}
	return lChars.join('');
	}
