#!/bin/bash

MOTIVATION=("u should be proud of urself" "u r da man, man" "u da best" "look at u go" "nice work, yay" "u amazinggggggg" "u did good, kid")

BASEDIR=~/y
TODAY=$(date --iso-8601)
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

print_tasks() {
	cd $BASEDIR/today
	for f in *; do
		echo -e "${GREEN}Today:   ${NC} $f";
	done
	cd $BASEDIR

	cd $BASEDIR/tomorrow
	for f in *; do
		echo -e "${BLUE}Tomorrow:${NC} $f";
	done
	cd $BASEDIR

	cd $BASEDIR/done
	for f in *; do
		echo -e "${YELLOW}Done:    ${NC} $f";
	done
	cd $BASEDIR
}

print_later() {
	cd $BASEDIR/later
	for f in *; do
		echo -e ${RED}Later:${NC} $f;
	done
	cd $BASEDIR
}

print_motivation() {
	MOTIVOUT=${MOTIVATION[$(shuf -i 0-6 -n 1)]}
	echo -e ${YELLOW}********************************
	echo -e ${YELLOW}$MOTIVOUT
	echo -e ${YELLOW}********************************
	printf \\n
}

feierabend() {
	echo -e "${GREEN}here's what u did today"
	printf \\n
        cd $BASEDIR/done
        for f in *; do
                echo -e "${YELLOW}Done:    ${NC} $f";
        done
        cd $BASEDIR
	print_motivation
	echo "Good night!"
}

show_usage() {
	echo "y - the existential task manager"
	echo "Usage: y -> show all tasks"
	echo "       y do ([today][tomorrow][later]) Fix printer -> Create new task, defaults to 'today'."
	echo "       y done Fix printer -> mark task as done"
	echo "       y later -> take a look at your backlog"
	echo "       y feierabend -> done for the day"
	exit 0
}

if [ -z $1 ]; then	# if no arguments given, print all tasks today and tomorrow
	print_tasks
	exit 0
fi

if [ $1 == "do" ]; then
	if [ -z $2 ]; then
		show_usage
		exit 1
	fi
	if [ $2 == "today" ]; then
		CURRENTDIR="today"
		TASK=$3
	fi
	if [ $2 == 'tomorrow' ]; then
		CURRENTDIR="tomorrow"
		TASK=$3
	fi
	if [ $2 == 'later' ]; then
		CURRENTDIR="later"
		TASK=$3
	fi
	if [ $2 != 'today' ] && [ $2 != 'tomorrow' ] && [ $2 != 'later' ]; then
		CURRENTDIR="today"
		TASK=$2	
	fi
	if [ -e $BASEDIR/$CURRENTDIR/$TASK ]; then
	       echo "DEBUG: task exists, opening in editor."
	       vi $BASEDIR/$CURRENTDIR/$TASK
	       print_tasks
	       exit 0
       fi
	touch $BASEDIR/$CURRENTDIR/$TASK
	echo -e "'$TASK' added for ${GREEN}$CURRENTDIR!${NC}"
#	print_tasks	# do we really want that?
	exit 0
fi

if [ $1 == "done" ]; then
       CURRENTDIR="today"
	mv $BASEDIR/$CURRENTDIR/$2 $BASEDIR/done/
	printf \\n
	echo "Done: $2."
	printf \\n
	print_motivation
#	print_tasks		# not so sure bout dat
	exit 0
fi

if [ $1 == "later" ]; then
	print_later
	exit 0
fi

if [ $1 == "procrastinate" ]; then
	echo "STILL IN THE WORKS"
	exit 0
fi

if [ $1 == "feierabend" ]; then
	feierabend
	exit 0
#fi
#
#if [ $1 == "--help" ] || [ $1 == "-h" ]; then
#	show_usage

else
	show_usage
fi
