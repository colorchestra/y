#!/bin/bash

# find the data directory: new and legacy
for dir in "$HOME/.local/share/y" "$HOME/y/data"; do
	if [ -d "$dir" ]; then
		DATADIR="$dir"
		# TODO log as debug
		#echo "Found datadir: $dir"
		break
	fi
done
if [ -z "$DATADIR" ]; then
	echo "No data directory could be found! Aborting."
	exit 1
fi

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

print_tasks() {
	if [[ ! -d "$DATADIR/$1" ]]; then
		echo "Directory '$1' not found! Exiting."
		exit 1
	fi
	cd "$DATADIR"/"$1" || exit 1
	for f in *; do
		NAME=$f
		COMMENTSTRING=""
		if [[ ! -d $f ]]; then
			if [[ $NAME == "! "* ]]; then
				NAME=$(echo "$NAME" | cut -c3-)
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
		if [ -n "$COMMENTSTRING" ]; then echo -e "$COMMENTSTRING"; fi
	done
}

add_task() {
	DAY="$1"
	shift
	TASK="$*"
	if _check_if_task_exists "$DAY" "$TASK"; then	# open in editor if task already exists
		if [[ -z $EDITOR ]]; then
			export EDITOR=vi
		fi
		echo "Task '$TASK' exists, opening in $EDITOR..."
		$EDITOR "$DATADIR"/"$DAY"/"$TASK"
		exit 0
	fi
	if [[ $DAY == "today" ]] && _check_if_task_exists 'tomorrow' "$TASK"; then  # if tasks exists in tomorrow, move to today
		echo "Task exists tomorrow - moving it to today"
		mv "$DATADIR"/tomorrow/"$TASK" "$DATADIR"/today/"$TASK"
	fi
	# input validation should be good enough...
	if [[ "$TASK" =~ ^\. ]] || [[ "$TASK" =~ [\*\/\;] ]]; then
		echo "Error: a task name can not start with a . or contain any of the following characters: * / ;. Exiting."
		exit 1
	fi
	touch "$DATADIR"/"$DAY"/"$TASK"		# create task
	echo -e "'$TASK' added for ${GREEN}$DAY!${NC}"
	}

# helper functions, wow!
_check_if_task_started() {
	if [[ ! "$(find "$DATADIR/started" -maxdepth 1 -type f)" ]]; then
	   return 1
	else
	   return 0 
	fi
	}

_check_if_task_exists() {
	# $1 is the day, rest is task name
	day_to_check="$1"
	shift
	task_to_check="$*"

	if [[ -e "$DATADIR"/"$day_to_check"/"$task_to_check" ]]; then
	   return 0
	else
	   return 1 
	fi
}

_error_task_doesnt_exist() {
	if [ -z "$1" ]; then
		echo -e "${RED}Error${NC}: task doesn't exist!"
	else
		echo -e "${RED}Error${NC}: task '$*' doesn't exist!"
	fi
	exit 1
}

prioritize() {
	# we're given a task starting with '! ', assuming we want to deprioritize
	if [[ "$TASK" == "! "* ]] ; then
		if [[ -e "$DATADIR/today/$TASK" ]]; then
			mv "$DATADIR"/today/"$TASK" "$DATADIR"/today/"$(echo "$TASK" | cut -c3-)"
			echo "De-prioritized task '$(echo "$TASK" | cut -c3-)'."
		else
			echo -e "${RED}Error${NC}: task '$*' doesn't exist!"
		fi
	# if no !, check if we have a matching prioritized task to deprioritize
	elif [[ -e "$DATADIR/today/! ${TASK}" ]] ; then
		mv "${DATADIR}/today/! ${TASK}" "${DATADIR}/today/${TASK}"
		echo "De-prioritized task ${TASK}"
	# if not, prioritize
	else
		mv "$DATADIR"/today/"$TASK" "$DATADIR"/today/!\ "$TASK"
		echo "Prioritized task '! $TASK'."
	fi
}

next_day() {
	# $1 for "today" or "yesterday"
	cd "$DATADIR"/done || exit 1
	if [[ "$1" == "yesterday" ]]; then
		DATE_OF_WORKDAY="$(date --date yesterday --iso-8601)"
	else
		DATE_OF_WORKDAY="$(date --iso-8601)"
	fi
	if [[ ! -d "$DATADIR"/archive/"$DATE_OF_WORKDAY" ]]; then
		mkdir "$DATADIR"/archive/"$DATE_OF_WORKDAY"
	fi	
	if [[ ! "$(find . -maxdepth 1 -type f)" ]]; then
		echo "u did absolutely nothing $1."  
	else
		echo -e "${GREEN}here's what u did ${1}${NC}"
		printf \\n					# show all files from 'done'
        	for f in *; do
			if ! [[ -d $f ]]; then
				for (( c=0; c < ${#f}; c++ )); do	# super flashy magic effect thingy
				 # TODO shellcheck
				 # shellcheck disable=SC2059
					printf "${f:$c:1}"
					sleep 0.05
				done
				printf \\n
				mv "$f" "$DATADIR"/archive/"$DATE_OF_WORKDAY"
				sleep 0.5s
			fi
        	done
		echo -e "${YELLOW}Well done! 😊${NC}"
	fi
    find "$DATADIR/tomorrow" -type f ! -name ".*" -exec mv "{}" "$DATADIR/today/" \; 2> /dev/null # move task from tomorrow to today

    cd "$DATADIR" || exit 1
	COMMITMESSAGE="End of day $(date '+%F %T')"
	echo "======== Begin Git log for commit '$COMMITMESSAGE' ========" >> "${DATADIR}/git.log"
	git add --all >> "${DATADIR}/git.log"
	printf "+ git commit... "
	COMMITOUTPUT=$(git commit -m "$COMMITMESSAGE")
	# TODO
	# shellcheck disable=SC2181
	if [[ $? -eq 0 ]]; then
		printf "${GREEN}%12s${NC}\n" "Successful"
		echo "$COMMITOUTPUT" >> "${DATADIR}/git.log"
		if [[ $(git remote show) ]] ; then
			printf "+ git push... "
			PUSHOUTPUT=$(git push -u origin 2>&1)
			if [[ $? -eq 0 ]]; then
				printf "${GREEN}%14s${NC}\n" "Successful"
				echo "$COMMITOUTPUT" >> "${DATADIR}/git.log"
			else
				printf "${RED}%10s${NC}\n" "Failed"
				echo "$PUSHOUTPUT" >> "${DATADIR}/git.log"
				echo "$PUSHOUTPUT"
			fi
		fi

	else
		printf "${RED}%8s${NC}\n" "Failed"
		echo "$COMMITOUTPUT" >> "${DATADIR}/git.log"
		echo "$COMMITOUTPUT"
	fi
	echo "========== End Git log for commit '$COMMITMESSAGE' ========" >> "${DATADIR}/git.log"
	printf \\n
	if [[ "$1" == "yesterday" ]]; then
		echo "Have a great day! 🌞"
	else
		echo "Remember to stop your timetracking."
		echo "Good night! 🌙"
	fi
}

procrastinate() {
	_check_if_task_exists 'today' "$TASK" || _error_task_doesnt_exist "$TASK"
	if ! _check_if_task_exists 'tomorrow' "$TASK"; then
		mv "$DATADIR"/today/"$TASK" "$DATADIR"/tomorrow/"$TASK"
		echo -e "'$TASK' moved to ${BLUE}tomorrow${NC}."
	else
		echo "'$TASK' already exists tomorrow!"
	fi
}

clean() {
    read -rp "Are you SURE you want to irrecoverably delete ALL of your entries? (yes/no) " cleanyn
    case $cleanyn in
         [Yy]*) for i in 'today' 'tomorrow' 'done' 'archive' 'started'; do rm -rf "${DATADIR:?}"/"${i}"/*; done
         rm "${DATADIR}/git.log"
             echo "All entries deleted."
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
}

# main script starts here!
# first: check if work has been started on anything / "focus mode"
if _check_if_task_started; then
	if [ -z "$1" ]; then
		echo -e "${BOLD}Focus!${NC}"
		print_tasks started "Currently working on: " "$MAGENTA"
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
	 			mv "$DATADIR"/started/* "$DATADIR"/today/
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
if [ -z "$1" ]; then	# if no arguments given, print all tasks today and tomorrow
			# use the following syntax: directory name, day in "readable case" and name of color variable
	print_tasks 'today' 'Today:' "$GREEN"
	print_tasks 'tomorrow' 'Tomorrow:' "$BLUE"
	print_tasks 'done' 'Done:' "$YELLOW"
	exit 0
fi

### "normal" mode without any started tasks
case "$1" in 
	do)

		case "$2" in
			today|tomorrow)		# parse day
				DAY=$2
				shift; shift
				add_task "$DAY" "$@"
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
		shift; TASK="$*"
		_check_if_task_exists 'today' "$TASK" || _error_task_doesnt_exist "$TASK"
		mv "$DATADIR"/today/"$TASK" "$DATADIR"/done/
		echo "Done: $TASK."
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
		shift; TASK="$*"
		# create and start task if it doesn't exist
		_check_if_task_exists 'today' "$TASK" || add_task 'today' "$TASK"

		mv "$DATADIR"/today/"$TASK" "$DATADIR"/started/
		echo "Started work on task $TASK."
		;;
	prioritize|prio)
		shift; TASK="$*"
		prioritize
		exit 0
		;;
	procrastinate|proc)
		shift; TASK="$*"
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
        cd "$DATADIR" || exit 1
        echo "Pulling fresh data from $(git remote get-url --push origin)..."
        git pull
        exit 0
        ;;
	vanish|rm)
		if [[ "$2" == "today" || "$2" == "tomorrow" ]]; then
			DAY="$2"
			shift; shift
		else
			DAY="today"
			shift
		fi
		TASK="$*"
		cd "$DATADIR"/"$DAY" || exit 1

		if rm "$TASK"; then
			echo -e "Task '$TASK' has vanished."
			exit 0
		else
			echo "Removing task failed!"
			exit 1
		fi
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
