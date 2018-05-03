#!/bin/bash

MOTIVATION=("u should be proud of urself" "u r da man, man" "u da best" "look at u go" "nice work, yay" "u amazinggggggg" "u did good, kid" "this shit is bananas, B-A-N-A-N-A-S!" "the best there ever was" "u the real mvp")
DEMOTIVATION=("u lazy piece of shit" "weeeell done *slow clap*" "son i am disappoint" "lauch")

BASEDIR=~/y
DATADIR=$BASEDIR/data

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[1;34m'
NC='\033[0m' # No Color

#print_tasks() {
#	cd $DATADIR/today
#	for f in *; do
#		if [[ $f == "! "* ]]; then
#			OUTPUTSTRING=$(echo -e "${GREEN}Today:  ${RED}!${NC}$(echo $f | cut -c2-)");
#		else
#			OUTPUTSTRING=$(echo -e "${GREEN}Today:   ${NC} $f");
#		fi
#		if [[ -s $f ]]; then
#			OUTPUTSTRING=$(echo -e "$OUTPUTSTRING *")
#		fi
#		echo -e "$OUTPUTSTRING"
#	done
#	cd $DATADIR
#
#	cd $DATADIR/tomorrow
#	for f in *; do
#		echo -e "${BLUE}Tomorrow:${NC} $f";
#	done
#	cd $DATADIR
#
#	cd $DATADIR/done
#	for f in *; do
#		if ! [[ -d $f ]]; then
#			echo -e "${YELLOW}Done:    ${NC} $f";
#		fi
#	done
#	cd $DATADIR
#}
print_tasks() {
	cd $DATADIR/$1
	for f in *; do
#		SPACES=$(printf "%16s\n" "$1")
		if [[ $f == "! "* ]]; then
#			OUTPUTSTRING=$(echo -e "$3$2:  ${RED}!${NC}$(echo $f | cut -c2-)");
			OUTPUTSTRING=$(echo -e "$3$2:  ${RED}!${NC}$(echo $f | cut -c2-)");
		else
			OUTPUTSTRING=$(echo -e "$3$2:   ${NC} $f");
		fi
		if [[ -s $f ]]; then
			OUTPUTSTRING=$(echo -e "$OUTPUTSTRING *")
		fi
		echo -e "$OUTPUTSTRING"
#		printf "%12s %s\n" $2 "$OUTPUTSTRING"
		OUTPUTSTRING=""
	done
}




print_later() {
	cd $DATADIR/later
	for f in *; do
		echo -e ${RED}Later:${NC} $f;
	done
	cd $DATADIR
}

print_motivation() {
	MOTIVOUT=${MOTIVATION[$(shuf -i 0-$((${#MOTIVATION[@]}-1)) -n 1)]}
	printf \\n
	echo -e ${YELLOW}********************************
	echo -e ${YELLOW}$MOTIVOUT
	echo -e ${YELLOW}********************************${NC}
	printf \\n
}

print_demotivation() {
	DEMOTIVOUT=${DEMOTIVATION[$(shuf -i 0-$((${#DEMOTIVATION[@]}-1)) -n 1)]}
	printf \\n
	echo -e ${RED}********************************
	echo -e ${RED}$DEMOTIVOUT
	echo -e ${RED}********************************${NC}
	printf \\n

}

feierabend() {
	cd $DATADIR/done
	TODAYSDATE=$(date --iso-8601)
	if [[ ! -d $TODAYSDATE ]]; then
		mkdir $TODAYSDATE
	fi	
	if [[ ! $(find . -maxdepth 1 -type f) ]]; then
		echo "u did absolutely nothing today."  
		printf \\n
		print_demotivation
	else
		echo -e "${GREEN}here's what u did today${NC}"
		printf \\n					# show all files from 'done'
        	for f in *; do
			if ! [[ -d $f ]]; then
                		echo -e "${YELLOW}Done:    ${NC} $f";
				mv "$f" $TODAYSDATE
			fi
        	done
		print_motivation
	fi
        cd $DATADIR
	if [[ ! -z "$(ls -A $DATADIR/tomorrow)" ]]; then
		mv $DATADIR/tomorrow/* $DATADIR/today/
	fi
	COMMITMESSAGE="Feierabend $(date '+%F %T')"
	echo "======== Begin Git log for commit '$COMMITMESSAGE' ========" >> $BASEDIR/git.log
	git add --all >> $BASEDIR/git.log
	echo "+ git commit"
	git commit -m "$COMMITMESSAGE" >> $BASEDIR/git.log
	if [[ $(git remote show) ]]; then
		echo "+ git push"
		git push >> $BASEDIR/git.log
	fi
	echo "======== End Git log for commit '$COMMITMESSAGE' ========" >> $BASEDIR/git.log
	printf \\n
	echo "Remember to stop tracking your time"
	echo "Good night!"
}

procrastinate() {
	if [[ -e $DATADIR/today/"$TASK" ]]; then
		mv $DATADIR/today/"$TASK" $DATADIR/$1/"$TASK"
	elif [[ -e $DATADIR/tomorrow/"$TASK" ]] && [[ $1 == "later" ]]; then
		mv $DATADIR/tomorrow/"$TASK" $DATADIR/later/"$TASK"
	else
		show_usage
	fi	
	echo -e "'$TASK' procrastinated until ${BLUE}$1.${NC}"
	print_demotivation
	exit 0

}
show_usage() {
	echo "y - the existentialist task manager"
	echo "Usage: y -> show all tasks"
	echo "       y do ([today][tomorrow][later]) Fix printer -> Create new task, defaults to 'today'."
	echo "       y done Fix printer -> mark task as done"
	echo "       y do (if task already exists) -> open task in Vim to add notes"
	echo "       y procrastinate Fix printer -> move task to tomorrow"
	echo "       y superprocrastinate Fix printer -> move task to backlog"
	echo "       y later -> take a look at your backlog"
	echo "       y feierabend -> done for the day"
	exit 0
}

if [ -z $1 ]; then	# if no arguments given, print all tasks today and tomorrow
#	print_tasks	# old
# use the following syntax: directory name, day in "readable case" and name of color variable
	print_tasks today Today $GREEN
	print_tasks tomorrow Tomorrow $BLUE
#	print_tasks later Later $RED 	# in case one wants that...
	exit 0
fi

case "$1" in 
	do)
		case "$2" in
			today|tomorrow|later)		# parse day
				DAY=$2
				TASK=$(echo "$@" | cut -c${#2}- | cut -c6- ) 	# cut 'y do' and day
				;;
			*)
				DAY=today
				TASK=$(echo "$@"| cut -c4-) 			# cut 'y do'
				;;
		esac
		if [[ -e $DATADIR/$DAY/$TASK ]]; then	# open in editor if task already exists
			echo "DEBUG: task exists, opening in editor"
			vi $DATADIR/$DAY/"$TASK"
			exit 0
		fi
		if [[ $DAY == "today" ]] && [[ -e $DATADIR/later/$TASK ]]; then  # if tasks exists in later, move to today
			echo "Task exists in backlog - moving it to today"
			mv $DATADIR/later/"$TASK" $DATADIR/today/"$TASK"
		fi
		touch $DATADIR/$DAY/"$TASK"		# create task
		echo -e "'$TASK' added for ${GREEN}$DAY!${NC}"
		exit 0
		;;
	done)
		TASK=$(echo "$@" | cut -c6-)
		if ! [[ -e $DATADIR/today/"$TASK" ]]; then
			echo "No such task!"
			exit 1
		fi
		mv $DATADIR/today/"$TASK" $DATADIR/done/
		printf \\n
		echo "Done: $TASK."
		print_motivation
		;;

	procrastinate)
		TASK=$(echo "$@" | cut -c15-)
		procrastinate tomorrow
		exit 0
		;;
	superprocrastinate)
		TASK=$(echo "$@" | cut -c20-)
		procrastinate later
		exit 0
		;;
	later)
#		print_later
		print_tasks later Later $RED
		exit 0
		;;
	feierabend)
		feierabend
		exit 0
		;;
	clean)
		$BASEDIR/clean.sh
		exit 0
		;;
	vanish)				# unfinished - do not use
		cd $DATADIR/today/
		rm "$@"
		echo "harharhar"
		exit 0
		;;

	--help|-h)
		show_usage
		exit 0
		;;

	*)	echo "Not a valid command."
		show_usage
		exit 0
		;;
esac
