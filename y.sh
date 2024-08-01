#!/bin/bash

# Constants
MOTIVATION=("u should be proud of urself" "u r da man, man" "u da best" "look at u go" "nice work, yay" "u amazinggggggg" "u did good, kid" "this shit is bananas, B-A-N-A-N-A-S!" "the best there ever was" "u the real mvp" "now go treat yoself")
DEMOTIVATION=("u lazy piece of shit" "weeeell done *slow clap*" "son i am disappoint" "lauch" "u suck" "all you had to do was follow the damn train!" "the fuck is wrong with you" "try harder, pal" "congratulations on your spectacular failure" "hope ur proud of urself")
HEADLINE=("Frisch ans Werk, Freund!" "Morgenstund hat Gold im Mund!" "Wer wagt, gewinnt!" "Müßiggang ist aller Laster Anfang!" "Wer wagt, gewinnt!" "Den Tüchtigen gehört die Welt!" "Gib jedem Tag die Chance, der produktivste deines Lebens zu werden!" "Ich arbeite gern für meinen Konzern!" "You gotta do what you gotta do 👍" "Wir haben uns alle lieb im Betrieb!" "Der frühe Vogel fängt den Wurm!" "Die schönste Zeit... ist die Arbeit!" "Frage nicht, was dein Arbeitsplatz für dich tun kann - frage, was du für deinen Arbeitsplatz tun kannst!" "Die schönste Musik? - Der Sound der Fabrik!")

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
	MAGENTA='\033[1;35m'
	BOLD='\033[1m'
	NC='\033[0m' # No Color
fi

# Configuration
## turn on cringe mode if you want the cringey motivational thingsies
CRINGE_MODE=0

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
            # print the first line of a file, but not for 'done' tasks
			if [[ -s $f ]] && [[ $1 != "done" ]]; then
				COMMENTSTRING=$(printf "%15s ↳ $(head -1 "$f")")
			fi
		fi
		echo -e "$OUTPUTSTRING"
		if [ ! -z "$COMMENTSTRING" ]; then echo -e "$COMMENTSTRING"; fi
	done
}

print_motivation() {
	if [[ $CRINGE_MODE != 0 ]] then
		MOTIVOUT=${MOTIVATION[$(shuf -i 0-$((${#MOTIVATION[@]}-1)) -n 1)]}
		printf \\n
		echo -e ${YELLOW}$MOTIVOUT${NC}
		printf \\n
	fi
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
		if [[ -z $EDITOR ]]; then
			EDITOR=vi
		fi
		echo "Task '$TASK' exists, opening in $EDITOR..."
		$EDITOR $DATADIR/$DAY/"$TASK"
		exit 0
	fi
	if [[ $DAY == "today" ]] && [[ -e $DATADIR/tomorrow/"$TASK" ]]; then  # if tasks exists in tomorrow, move to today
		echo "Task exists tomorrow - moving it to today"
		mv $DATADIR/tomorrow/"$TASK" $DATADIR/today/"$TASK"
	fi
	# experimental ghetto input validation
	if [[ "$TASK" =~ ^\. ]] || [[ "$TASK" =~ [\*\/\;] ]]; then
		echo "Error: a task name can not start with a . or contain any of the following characters: * / ;. Exiting."
		exit 1
	fi
	touch $DATADIR/$DAY/"$TASK"		# create task
	echo -e "'$TASK' added for ${GREEN}$DAY!${NC}"
	}

# helper functions, wow!
_check_if_task_started() {
	if [ -z "$( ls -A $DATADIR/started )" ]; then
	   return 1
	else
	   return 0 
	fi
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

#feierabend() {
next_day() {
	# $1 for "today" or "yesterday"
	cd $DATADIR/done
	if [[ "$1" == "yesterday" ]] then
		DATE_OF_WORKDAY=$(date --date yesterday --iso-8601)
	else
		DATE_OF_WORKDAY=$(date --iso-8601)
	fi
	if [[ ! -d $DATADIR/archive/$DATE_OF_WORKDAY ]]; then
		mkdir $DATADIR/archive/$DATE_OF_WORKDAY
	fi	
	if [[ ! $(find . -maxdepth 1 -type f) ]]; then
		echo "u did absolutely nothing $1."  
		print_demotivation
	else
		echo -e "${GREEN}here's what u did ${1}${NC}"
		printf \\n					# show all files from 'done'
        	for f in *; do
			if ! [[ -d $f ]]; then
				for (( c=0; c < ${#f}; c++ )); do	# super flashy magic effect thingy
					printf "${f:$c:1}"
					sleep 0.05
				done
				printf \\n
				mv "$f" $DATADIR/archive/$DATE_OF_WORKDAY
				sleep 0.5s
			fi
        	done
		print_motivation
	fi
    find "$DATADIR/tomorrow" -type f ! -name ".*" -exec mv "{}" "$DATADIR/today/" \; 2> /dev/null # move task from tomorrow to today

    cd $DATADIR
	COMMITMESSAGE="End of day $(date '+%F %T')"
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
	if [[ "$1" == "yesterday" ]] then
		echo "Have a great day! 🌞"
	else
		echo "Remember to stop your timetracking."
		echo "Good night!"
	fi
}

procrastinate() {
	if [[ -e $DATADIR/today/"$TASK" ]]; then
		if [[ ! -e $DATADIR/tomorrow/"$TASK" ]]; then
			mv $DATADIR/today/"$TASK" $DATADIR/tomorrow/"$TASK"
			echo -e "'$TASK' moved to ${BLUE}tomorrow${NC}."
		else
			echo "'$TASK' already exists tomorrow!"
		fi
	else
		show_usage
	fi	
	exit 0

}

clean() {
    read -p "Are you SURE you want to irrecoverably delete ALL of your entries? (yes/no) " cleanyn
    case $cleanyn in
         [Yy]*) for i in today tomorrow done archive started; do rm -rf "$DATADIR"/$i/*; done
         rm $BASEDIR/git.log
             echo "All entries deleted."
             exit 0
             ;;
         *) echo "Aborting."
            exit 1
            ;;
   esac
}

show_usage() {
	echo "y - the existentialist task manager"
	echo "Usage: y -> show all tasks"
	echo "       y do (today|tomorrow) Fix printer -> Create new task, defaults to 'today'."
	echo "       y done Fix printer -> mark task as done"
	echo "       y do Fix printer (if task already exists) -> open task in Vim to add notes"
	echo "       y procrastinate Fix printer -> move task to tomorrow"
	echo "       y prioritize Fix printer -> toggle mark task as important"
	echo "       y vanish today|tomorrow Fix printer -> delete task"
	echo "       y gumo -> starting the day"
	echo "       y feierabend -> done for the day"
	exit 0
}

# main script starts here!
# first: check if work has been started on anything / "focus mode"
if _check_if_task_started; then
	if [ -z $1 ]; then
		echo -e ${BOLD}Focus!${NC}
		print_tasks started "Currently working on: " $MAGENTA
		exit 0
	else
		case "$1" in 
			do|edit)
				echo "tbd: edit tasks or add new ones while in focus mode"
				exit 1
				;;
			done)
				echo "tbd: mark task as done and stop focus mode"
				exit 1
				;;
			stop)
	 			mv $DATADIR/started/* $DATADIR/today/
				echo "Stopped working on your task."
				exit 0
				;;
			*)	
				echo "Not a valid command."
				echo "You're currently working on a task. Use \`y stop\` to stop work on it."
				exit 1
		esac
	fi
fi

# now for "normal mode" where no task has been started
if [ -z $1 ]; then	# if no arguments given, print all tasks today and tomorrow
			# use the following syntax: directory name, day in "readable case" and name of color variable
	if [[ $CRINGE_MODE != 0 ]] then
		HEADLINEOUT=${HEADLINE[$(shuf -i 0-$((${#HEADLINE[@]}-1)) -n 1)]}
		echo -e ${BOLD}$HEADLINEOUT${NC}
	fi
	print_tasks today Today: $GREEN
	print_tasks tomorrow Tomorrow: $BLUE
	print_tasks done Done: $YELLOW
	exit 0
fi

### "normal" mode without any started tasks
case "$1" in 
	do)

		case "$2" in
			today|tomorrow)		# parse day
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
            add_task today "$TASK"
		fi
		mv $DATADIR/today/"$TASK" $DATADIR/done/
		printf \\n
		echo "Done: $TASK."
		print_motivation
		;;

	start)
		if _check_if_task_started; then
			echo "You're already working on a task!"
			exit 1
		fi
		if [ -z "$2" ]; then
			echo "Error: no task name given"
			show_usage
			exit 1
		fi
		shift; TASK="$@"
		# create and start task if it doesn't exist
		if ! [[ -e $DATADIR/today/"$TASK" ]]; then
            add_task today "$TASK"
		fi
		mv $DATADIR/today/"$TASK" $DATADIR/started/
		printf \\n
		echo "Started work on task $TASK."
		;;

	prioritize|prio)	# still janky and beta
		shift; TASK="$@"
		prioritize
		exit 0
		;;
	procrastinate|proc)
		shift; TASK="$@"
		procrastinate
		exit 0
		;;
	feierabend)
		next_day today
		exit 0
		;;
	gumo)
		next_day yesterday
		exit 0
		;;
    clean)
        clean
        exit 0
        ;;
     pull)
        cd "$DATADIR"
        echo "Pulling fresh data from $(git remote get-url --push origin)..."
        git pull
        exit 0
        ;;
	vanish|rm)				# unfinished - do not use
		if [[ "$2" == "today" || "$2" == "tomorrow" ]]; then
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
