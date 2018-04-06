#!/bin/bash

#ALLARGS=$@
#echo "ALLARGS ist" $ALLARGS
#ALLARGS=${ cut -c 1-3 < $ALLARGS}
#echo "ALLARGS ist jetzt" $ALLARGS
#exit 0
MOTIVATION=("u should be proud of urself" "u r da man, man" "u da best" "look at u go" "yay")
BASEDIR=~/y/
TODAY=$(date --iso-8601)
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color

print_tasks() {
#	ls -lG --time-style=long-iso $BASEDIR/today
#	echo -e ${GREEN}$(ls -1 $BASEDIR/today)${NC} #${GREEN}TODAY${NC}
	cd $BASEDIR/today
	for f in *; do
		echo -e "${GREEN}Today:   ${NC} $f";
	done
	cd $BASEDIR

	cd $BASEDIR/tomorrow
	for f in *; do
		echo -e ${BLUE}Tomorrow:${NC} $f;
	done
	cd $BASEDIR
#	echo -e ${BLUE}$(ls -1 $BASEDIR/tomorrow) #${BLUE}TOMORROW${NC}
}

print_later() {
	cd $BASEDIR/later
	for f in *; do
		echo -e ${RED}Later:${NC} $f;
	done
	cd $BASEDIR
}

if [ -z $1 ]; then	# if no arguments given, print all tasks today and tomorrow
	print_tasks
	exit 0
fi

if [ $1 == "do" ]; then
	if [ -z $2 ]; then
		echo -e "${RED}No task or date given - exiting."
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
	print_tasks
	exit 0
fi

if [ $1 == "done" ]; then
       CURRENTDIR="today"
	mv $BASEDIR/$CURRENTDIR/$2 $BASEDIR/done/
	printf \\n
	echo "Done: $2."
	MOTIVOUT=${MOTIVATION[$(shuf -i 0-3 -n 1)]}
	echo -e ${YELLOW}$MOTIVOUT
	printf \\n
	print_tasks
	exit 0
fi

if [ $1 == "later" ]; then
	print_later
	exit 0
fi

#
#else
#	echo "Unrecognized option $1"
#	exit 1
#fi
