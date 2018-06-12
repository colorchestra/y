# y - the existentialist task manager

"Heeey - all I have to type is 'y'! Hey, Miss doesn't-find-me-sexually-attractive-anymore, I just tripled my productivity!" / " Y, y... let's see, so many letters to choose from. I'll pick 'y'! Y, y, y..."

– [Homer Simpson](https://youtu.be/R_rF4kcqLkI?t=1m50s)

## Features
+ Ask yourself: "y the hell am I doing this?" with every new task
+ Not-really-intuitive CLI interface
+ Super outdated file-based database
+ Automatic Git commits on Feierabend (and push if a remote is set)
+ Easy procrastination (you will be insulted)
+ Positive reinforcement if you get stuff done
+ Tasks can be marked as important if prepended with `! ` (exclamation mark and a space)
+ Tasks are marked with an asterisk if they contain text

## Usage
+ `y` -> show all tasks
+ `y do (today|tomorrow|later) Fix printer` -> Create new task, defaults to 'today', or move to today if it exists tomorrow or later
+ `y done Fix printer` -> mark task as done
+ `y do Fix printer` (if task already exists) -> open task in Vim to add notes (absolutely not compatible with any other editor, nu-uh, sorry) (not sorry)
+ `y procrastinate Fix printer` -> move task to tomorrow
+ `y superprocrastinate Fix printer` -> move task to backlog
+ `y later` -> take a look at your backlog
+ `y feierabend` -> done for the day

## Setup
+ Clone to your home directory
+ Run `setup.sh`

## Known issues
Nothing, this piece of software is perfect®

## To do

Autocompletion would be neat (and should work, because that's the only reason this thing is file based)

## Done
~~Git integration would be neat (e.g. automatic commits on feierabend)~~
