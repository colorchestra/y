#!/bin/bash

MOTIVATION=("u should be proud of urself" "u r da man, man" "u da best" "look at u go" "nice work, yay" "u amazinggggggg" "u did good, kid")
DEMOTIVATION=("u lazy piece of shit" "weeeell done *slow clap*" "son i am disappoint")

GIT_REMOTE="git@vcs.meso.net:shah/y-tasks.git"
BASEDIR=~/y
DATADIR=$BASEDIR/data

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color


#echo "number of args: $#"
#echo "${@: -1}"
#echo $@
#if [[ ${@: -1} == "!" ]]; then
#	echo "neis"
#fi

print_tasks() {
	cd $DATADIR/today
	for f in *; do
		echo -e "${GREEN}Today:   ${NC} $f";
	done
	cd $DATADIR

	cd $DATADIR/tomorrow
	for f in *; do
		echo -e "${BLUE}Tomorrow:${NC} $f";
	done
	cd $DATADIR

	cd $DATADIR/done
	for f in *; do
		if ! [[ -d $f ]]; then
			echo -e "${YELLOW}Done:    ${NC} $f";
		fi
	done
	cd $DATADIR
}

print_later() {
	cd $DATADIR/later
	for f in *; do
		echo -e ${RED}Later:${NC} $f;
	done
	cd $DATADIR
}

print_motivation() {
	MOTIVOUT=${MOTIVATION[$(shuf -i 0-${#MOTIVATION[@]} -n 1)]}
	echo -e ${YELLOW}********************************
	echo -e ${YELLOW}$MOTIVOUT
	echo -e ${YELLOW}********************************${NC}
	printf \\n
}

#print_demotivation() {
#	DEMOTIVOUT="{DEMOTIVATION[$(shuf -i 
#}

feierabend() {
	echo -e "${GREEN}here's what u did today${NC}"
	printf \\n					# show all files from 'done'
	cd $DATADIR/done
        for f in *; do
		if ! [[ -d $f ]]; then
                	echo -e "${YELLOW}Done:    ${NC} $f";
		fi
        done
        cd $DATADIR
	print_motivation
	TODAYSDATE=$(date --iso-8601)			# mv all files from 'done' to a separate directory 
	find $DATADIR/done/ -maxdepth 1 -type f -exec mv {} $DATADIR/done/$TODAYSDATE \;
	mv $DATADIR/tomorrow/* $DATADIR/today/
	git add --all
	git commit -m "Feierabend $TODAYSDATE"
#	if [[ $GIT_REMOTE ]]; then
		git push origin master
#	fi
	echo "Good night!"
}

show_usage() {
	echo "y - the existentialist task manager"
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
		if [[ ${@: -1} == "!" ]]; then		# mark tasks as important
			TASK="${RED}!${NC}$TASK"
			echo $TASK
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
		printf \\n
		print_motivation
		exit 0
		;;

	procrastinate)
		TASK=$(echo "$@" | cut -c15-)
		if [[ -e $DATADIR/today/"$TASK" ]]; then
			mv $DATADIR/today/"$TASK" $DATADIR/tomorrow/"$TASK"
		else
			show_usage
		fi	
		echo -e "'$TASK' procrastinated until ${BLUE}tomorrow.${NC}"
		echo -e "${RED}u lazy piece of shit${NC}"
		exit 0
		;;
	later)
		print_later
		exit 0
		;;
	feierabend)
		feierabend
		exit 0
		;;
	clean)
		$BASEDIR/clean.sh
		echo "All entries deleted."
		exit 0
		;;
	*)
		show_usage
		exit 0
		;;
esac
