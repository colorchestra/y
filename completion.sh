_y() {
    local cur prev opts
    COMREPLY=()
    cur="${COMP_WORDS[COMP_CWORD]}"
    prev="${COMP_WORDS[COMP_CWORD-1]}"
    opts="do done procrastinate proc prio prioritize vanish rm feierabend start stop"
    case "${prev}" in
	    done|procrastinate|proc|start)
		IFS=$'\n' tmp=( $(compgen -W "$(ls ~/y/data/today)" -- "${COMP_WORDS[$COMP_CWORD]}" ))
                COMPREPLY=( "${tmp[@]// /\ }" )
		return 0
		;;
	    do)
		IFS=$'\n' tmp=( $(compgen -W "$(ls ~/y/data/today && ls ~/y/data/tomorrow)" -- "${COMP_WORDS[$COMP_CWORD]}" ))
                COMPREPLY=( "${tmp[@]// /\ }" )
		return 0
		;;

		prio|prioritize)
			# simplified: iterate filenames, strip leading "! " into 's', match prefix, and push appropriate completion
			local match_cur="$cur"
			local mode=0  # 0=return original, 1=return with leading "! ", 2=return stripped only (prev == '!')
			if [[ "${COMP_WORDS[COMP_CWORD-1]}" == '!' ]]; then
				mode=2
				match_cur="$cur"
			elif [[ "$cur" == '!'* ]]; then
				# user typed bang in same word: remove leading '!' and optional space
				mode=1
				match_cur="${cur#\!}"
				match_cur="${match_cur# }"
			else
				mode=0
				match_cur="$cur"
			fi

			# iterate files and match stripped names by prefix
			local f s out
			while IFS= read -r f; do
				[[ -z "$f" ]] && continue
				if [[ "$f" == '! '* ]]; then
					s="${f#\! }"
				else
					s="$f"
				fi
				# prefix match
				if [[ "$s" == "$match_cur"* ]]; then
					if [[ $mode -eq 1 ]]; then
						out="! ${s}"
					elif [[ $mode -eq 2 ]]; then
						out="${s}"
					else
						out="${f}"
					fi
					COMPREPLY+=( "$out" )
				fi
			done < <(ls -1 ~/y/data/today 2>/dev/null)

			return 0
			;;

	vanish|rm)		# extremely ghetto
		opts="today tomorrow"
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
