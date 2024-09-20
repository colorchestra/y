#!/bin/bash

BASEDIR=~/y
DATADIR=$BASEDIR/data/

printf "Creating nocolor symlink... "
if [ ! -h "$BASEDIR/y-nocolor.sh" ]; then
	ln -s y.sh y-nocolor.sh
	printf "Successful.\n"
else
	printf "Symlink already exists!\n"
fi

echo "Removing old stuff from .bashrc... "
sed -i '/alias y=/d' ~/.bashrc
sed -i '/y\/completion.sh/d' ~/.bashrc
# todo: feedback

printf "Writing new aliases to .bashrc... "
if echo "alias y='$BASEDIR/y.sh'" >> ~/.bashrc; then
	printf "Successful.\n"
else
	printf "Error!\n"
fi

printf "Writing completion stuff to .bashrc... "
if echo "source $BASEDIR/completion.sh" >> ~/.bashrc; then
	printf "Successful.\n"
else
	printf "Error!\n"
fi

read -rp "Do you have an existing y data directory, e.g. in a Git repo? (yes/no) " yn
case $yn in
	[Yy]* ) echo "Please manually copy/clone your data directory now."		# to do: automatically clone if repo link is inserted
		;;

	* ) 	echo "A local Git repository will be initialized. If you want, set a remote."

		printf "Creating data directory... "
		if [ ! -d "$DATADIR" ]; then
			mkdir "$DATADIR"
			printf "Successful.\n"	# naja...
		else
			printf "Directory already exists!\n"
		fi
		
		cd "$DATADIR" || exit 1

		printf "Creating daily directories...\n"
		for d in 'today' 'tomorrow' 'done' 'archive' 'started'; do
			if ! [[ -d "$d" ]]; then
				mkdir "$d"
				printf "    Directory '$d' created.\n"
			else
				printf "    Directory '$d' already exists!\n"

			fi
		done
		git init
		cd "$BASEDIR" || exit 1
		;;
esac

echo "Please run 'source ~/.bashrc' to enable bash completion (or start a new shell, or log out and back in)"
echo "Done."
exit
