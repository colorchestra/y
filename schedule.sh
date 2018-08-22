#!/bin/bash

BASEDIR=~/y
DATADIR=$BASEDIR/data

schedule_task() {
        if [[ ! $(which at) ]]; then
                echo "'at' appears not to be installed. Task scheduling depends on it."
        fi
        SCHEDTIME="$2"
        SCHEDDATE="$3"
        shift; shift; shift
        TASK="$@"
        $BASEDIR/y.sh do later "$TASK"
        echo "$BASEDIR/y.sh do tomorrow $TASK" | at $SCHEDTIME $SCHEDDATE | tail -1 | echo > "$DATADIR"/later/"$TASK"

}
