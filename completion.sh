#!/bin/bash
# i have no idea what i'm doing

_y() {
    local cur prev opts
    COMREPLY=()
    cur="${COMP_WORDS[COMP_CWORD]}"
    prev="${COMP_WORDS[COMP_CWORD-1]}"
    opts="do done procrastinate superprocrastinate prio prioritize vanish rm later feierabend"
    case "${prev}" in
	    done|procrastinate|superprocrastinate|prio|prioritize)
		IFS=$'\n' tmp=( $(compgen -W "$(ls ~/y/data/today)" -- "${COMP_WORDS[$COMP_CWORD]}" ))
                COMPREPLY=( "${tmp[@]// /\ }" )
		return 0
		;;
	    do)
		IFS=$'\n' tmp=( $(compgen -W "$(ls ~/y/data/today && ls ~/y/data/tomorrow)" -- "${COMP_WORDS[$COMP_CWORD]}" ))
                COMPREPLY=( "${tmp[@]// /\ }" )
		return 0
		;;
	vanish)		# extremely ghetto
		opts="today tomorrow later"
		case "${prev}" in
			today)
				IFS=$'\n' tmp=( $(compgen -W "$(ls ~/y/data/today)" -- "${COMP_WORDS[$COMP_CWORD]}" ))
                		COMPREPLY=( "${tmp[@]// /\ }" )
				return 0
				;;
			"")
				return 1
				;;
		esac
		;;

	*)
		;;
esac

    COMPREPLY=( $(compgen -W "${opts}" -- ${cur}) )
#    return 0

}

complete -F _y y
