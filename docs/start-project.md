start-project
=============

The `start-project` command does the following:

1. Takes the name of the project as argument
2. `mkdir <proj>`
3. `cd <proj>`
4. `npm init -y`
5. replace package.json:
	- Look upwards in directory for `.package.json` file
	- Replace `<something>` tags with command line parameters
	- Prompt for missing tags
6. `npm install` - to install packages found in `.package.json`
7. `git init`
8. `git branch -m main`
9. `mkdir test src src/lib src/bin`


