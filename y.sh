#!/bin/bash

MOTIVATION=("u should be proud of urself" "u r da man, man" "u da best" "look at u go" "nice work, yay" "u amazinggggggg" "u did good, kid" "this shit is bananas, B-A-N-A-N-A-S!" "the best there ever was" "u the real mvp" "now go treat yoself")
DEMOTIVATION=("u lazy piece of shit" "weeeell done *slow clap*" "son i am disappoint" "lauch" "u suck" "all you had to do was follow the damn train!" "the fuck is wrong with you" "try harder, pal" "congratulations on your spectacular failure" "hope ur proud of urself")
HEADLINE=("Frisch ans Werk, Freund!" "Wer wagt, gewinnt!" "Müßiggang ist aller Laster Anfang!" "Wer wagt, gewinnt!" "Den Tüchtigen gehört die Welt!" "Gib jedem Tag die Chance, der produktivste deines Lebens zu werden!" "Ich arbeite gern für meinen Konzern!" "You gotta do what you gotta do" "Wir haben uns alle lieb im Betrieb!" "Der frühe Vogel fängt den Wurm!")

BASEDIR=~/y
DEFAULTDATADIR=$BASEDIR/data

if [ -z $DATADIR ]; then
	DATADIR="$DEFAULTDATADIR"
fi	

# echo "DEBUG: current DATADIR: $DATADIR"

DOLLARNULL=$(echo "$0" | sed 's/.*\///')
if [[ ! "$DOLLARNULL" == *nocolor* ]]; then

	RED='\033[0;31m'
	GREEN='\033[0;32m'
	YELLOW='\033[1;33m'
	BLUE='\033[1;34m'
	BOLD='\033[1m'
	NC='\033[0m' # No Color
fi

print_tasks() {
	if [[ ! -d "$DATADIR/$1" ]]; then
		echo "Directory '$1' not found! Exiting."
		exit 1
	fi
	cd $DATADIR/$1
	for f in *; do
		NAME=$f
		COMMENTSTRING=""
		if [[ ! -d $f ]]; then
			if [[ $NAME == "! "* ]]; then
				NAME=$(echo $NAME | cut -c3-)
				OUTPUTSTRING=$(printf "%s%-10s${RED}! ${NC}%s\n" "$3" "$2" "$NAME")
			else
				OUTPUTSTRING=$(printf "%s%-12s${NC}%s\n" "$3" "$2" "$NAME")
			fi
			if [[ -s $f ]]; then
				COMMENTSTRING=$(printf "%15s ↳ $(head -1 "$f")")
			fi
		fi
		echo -e "$OUTPUTSTRING"
		if [ ! -z "$COMMENTSTRING" ]; then echo -e "$COMMENTSTRING"; fi
	done
}

print_motivation() {
	MOTIVOUT=${MOTIVATION[$(shuf -i 0-$((${#MOTIVATION[@]}-1)) -n 1)]}
	printf \\n
	echo -e ${YELLOW}$MOTIVOUT${NC}
	printf \\n
}

print_demotivation() {
	DEMOTIVOUT=${DEMOTIVATION[$(shuf -i 0-$((${#DEMOTIVATION[@]}-1)) -n 1)]}
	printf \\n
	echo -e ${RED}$DEMOTIVOUT${NC}
	printf \\n
}

add_task() {
	DAY="$1"
	shift
	TASK="$@"
	if [[ -e $DATADIR/$DAY/"$TASK" ]]; then	# open in editor if task already exists
		echo "Task '$TASK' exists, opening in editor..."
		vi $DATADIR/$DAY/"$TASK"
		exit 0
	fi
	for SOURCEDAY in "tomorrow" "later"; do
		if [[ $DAY == "today" ]] && [[ -e $DATADIR/$SOURCEDAY/"$TASK" ]]; then  # if tasks exists in tomorrow or later, move to today
			echo "Task exists in $SOURCEDAY - moving it to today"
			mv $DATADIR/$SOURCEDAY/"$TASK" $DATADIR/today/"$TASK"
		fi
	done
	# experimental ghetto input validation
	if [[ "$TASK" =~ ^\. ]] || [[ "$TASK" =~ [\*\/\;] ]]; then
		echo "Error: a task name can not start with a . or contain any of the following characters: * / ;. Exiting."
		exit 1
	fi
	touch $DATADIR/$DAY/"$TASK"		# create task
	echo -e "'$TASK' added for ${GREEN}$DAY!${NC}"
	}

prioritize() {
	if ! [[ -e $DATADIR/today/"$TASK" ]]; then
		echo "No such task!"
		exit 1
	else
		if [[ "$TASK" == "! "* ]]; then
			mv "$DATADIR/today/$TASK" "$DATADIR/today/$(echo $TASK | cut -c3-)"
			echo "De-prioritized task '$(echo $TASK | cut -c3-)'."
			exit 0
		else
			mv "$DATADIR/today/$TASK" "$DATADIR/today/! $TASK"
			echo "Prioritized task '! $TASK'."
			exit
		fi
	fi
}

feierabend() {
	cd $DATADIR/done
	TODAYSDATE=$(date --iso-8601)
	if [[ ! -d $DATADIR/archive/$TODAYSDATE ]]; then
		mkdir $DATADIR/archive/$TODAYSDATE
	fi	
	if [[ ! $(find . -maxdepth 1 -type f) ]]; then
		echo "u did absolutely nothing today."  
		print_demotivation
	else
		echo -e "${GREEN}here's what u did today${NC}"
		printf \\n					# show all files from 'done'
        	for f in *; do
			if ! [[ -d $f ]]; then
				for (( c=0; c < ${#f}; c++ )); do	# super flashy magic effect thingy
					printf "${f:$c:1}"
					sleep 0.05
				done
				printf \\n
				mv "$f" $DATADIR/archive/$TODAYSDATE
				sleep 0.5s
			fi
        	done
		print_motivation
	fi
        cd $DATADIR
	if [[ ! -z "$(ls -A $DATADIR/tomorrow)" ]]; then
		mv $DATADIR/tomorrow/* $DATADIR/today/
	fi

# unfinished 'show task age' thing 
# the idea is to mark all tasks as important that are older than a week. this could be done on feierabend.
#	CURRTIME=$(date +%s)
#	for f in $DATADIR/today/*; do
#		if [[ ! "$f" == "! *" ]]; then
#			CHANGETIME=$(stat -c %Y "$f")
#			echo "last change: $CHANGETIME, now: $CURRTIME"
#		fi
#	done	

	COMMITMESSAGE="Feierabend $(date '+%F %T')"
	echo "======== Begin Git log for commit '$COMMITMESSAGE' ========" >> $BASEDIR/git.log
	git add --all >> $BASEDIR/git.log
	printf "+ git commit... "
	COMMITOUTPUT=$(git commit -m "$COMMITMESSAGE")
	if [[ $? -eq 0 ]]; then
		printf "${GREEN}%12s${NC}\n" "Successful"
		echo "$COMMITOUTPUT" >> $BASEDIR/git.log
		if [[ $(git remote show) ]] ; then
			printf "+ git push... "
			PUSHOUTPUT=$(git push -u origin master 2>&1)
			if [[ $? -eq 0 ]]; then
				printf "${GREEN}%14s${NC}\n" "Successful"
				echo "$COMMITOUTPUT" >> $BASEDIR/git.log
			else
				printf "${RED}%10s${NC}\n" "Failed"
				echo "$PUSHOUTPUT" >> $BASEDIR/git.log
				echo "$PUSHOUTPUT"
			fi
		fi

	else
		printf "${RED}%8s${NC}\n" "Failed"
		echo "$COMMITOUTPUT" >> $BASEDIR/git.log
		echo "$COMMITOUTPUT"
	fi
	echo "========== End Git log for commit '$COMMITMESSAGE' ========" >> $BASEDIR/git.log
	printf \\n
	echo "Remember to stop your timetracking."
	echo "Good night!"
}

procrastinate() {
	SOURCEDAY="today"
	TARGETDAY=$1
	if [[ ! -e $DATADIR/today/"$TASK" ]] && [[ -e $DATADIR/tomorrow/"$TASK" ]]; then	# if task doesn't exist today but only tomorrow, move from tomorrow to later
		SOURCEDAY="tomorrow"
		TARGETDAY="later"
	fi
	if [[ -e $DATADIR/$SOURCEDAY/"$TASK" ]]; then
		if [[ ! -e $DATADIR/$TARGETDAY/"$TASK" ]]; then
			mv $DATADIR/$SOURCEDAY/"$TASK" $DATADIR/$TARGETDAY/"$TASK"
			echo -e "'$TASK' procrastinated until ${BLUE}$TARGETDAY.${NC}"
			print_demotivation
		else
			echo "'$TASK' already exists $TARGETDAY!"
		fi
	else
		show_usage
	fi	
	exit 0

}
show_usage() {
	echo "y - the existentialist task manager"
	echo "Usage: y -> show all tasks"
	echo "       y do (today|tomorrow|later]) Fix printer -> Create new task, defaults to 'today'."
	echo "       y done Fix printer -> mark task as done"
	echo "       y do Fix printer (if task already exists) -> open task in Vim to add notes"
	echo "       y procrastinate Fix printer -> move task to tomorrow"
	echo "       y superprocrastinate Fix printer -> move task to backlog"
	echo "       y prioritize Fix printer -> toggle mark task as important"
	echo "       y vanish today|tomorrow|later Fix printer -> delete task"
	echo "       y later -> take a look at your backlog"
	echo "       y feierabend -> done for the day"
	exit 0
}

if [ -z $1 ]; then	# if no arguments given, print all tasks today and tomorrow
			# use the following syntax: directory name, day in "readable case" and name of color variable
	HEADLINEOUT=${HEADLINE[$(shuf -i 0-$((${#HEADLINE[@]}-1)) -n 1)]}
	echo -e ${BOLD}$HEADLINEOUT${NC}
	print_tasks today Today: $GREEN
	print_tasks tomorrow Tomorrow: $BLUE
	print_tasks done Done: $YELLOW
#	print_tasks later Later $RED 	# in case one wants that...
	exit 0
fi

case "$1" in 
	do)

		case "$2" in
			today|tomorrow|later)		# parse day
				DAY=$2
				shift; shift
				add_task $DAY "$@"
				exit 0
				;;

			"")
				echo "Error: no task name given"
				show_usage
				exit 1
				;;
			*)
				DAY=today
				shift
				add_task $DAY "$@"
				;;
		esac
		;;


	done)
		if [ -z "$2" ]; then
			echo "Error: no task name given"
			show_usage
			exit 1
		fi
		shift; TASK="$@"
		if ! [[ -e $DATADIR/today/"$TASK" ]]; then
			TASK=$(echo "! $TASK")
		fi
		if ! [[ -e $DATADIR/today/"$TASK" ]]; then
			echo "No such task!"
			exit 1
		fi
		mv $DATADIR/today/"$TASK" $DATADIR/done/
		printf \\n
		echo "Done: $TASK."
		print_motivation
		;;

	prioritize|prio)	# still janky and beta
		shift; TASK="$@"
		prioritize
		exit 0
		;;
	procrastinate)
		shift; TASK="$@"
		procrastinate tomorrow
		exit 0
		;;
	superprocrastinate)
		shift; TASK="$@"
		procrastinate later
		exit 0
		;;
	later)
		print_tasks later Later: $RED
		exit 0
		;;
	schedule|sched)
		"$BASEDIR"/schedule.sh "$@"
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
	vanish|rm)				# unfinished - do not use
		if [[ "$2" == "today" || "$2" == "tomorrow" || "$2" == "later" ]]; then
			DAY="$2"
			shift; shift
			TASK="$@"
			cd "$DATADIR"/"$DAY"
			rm "$TASK"
			if [[ $? -eq 0 ]]; then
				echo -e "Task '$TASK' has vanished."
			else	# debug
				echo "rm has returned non-zero"
			fi
			exit 0
		else
			echo "nö"
			exit 1
		fi
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
		exit 1
		;;
esac
