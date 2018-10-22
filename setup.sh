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
echo "alias y='$BASEDIR/y.sh'" >> ~/.bashrc
if [ $? -eq 0 ]; then
	printf "Successful.\n"
else
	printf "Error!\n"
fi

printf "Writing completion stuff to .bashrc... "
echo "source $BASEDIR/completion.sh" >> ~/.bashrc
if [ $? -eq 0 ]; then
	printf "Successful.\n"
else
	printf "Error!\n"
fi

read -p "Do you have an existing y data directory, e.g. in a Git repo? (yes/no) " yn
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
		
		cd "$DATADIR"

		printf "Creating daily directories...\n"
		for d in today tomorrow later done archive; do
			if ! [[ -d "$d" ]]; then
				mkdir "$d"
				printf "    Directory '$d' created.\n"
			else
				printf "    Directory '$d' already exists!\n"

			fi
		done
		git init
		cd "$BASEDIR"
		;;
esac

echo "Please run 'source ~/.bashrc' to enable bash completion (or start a new shell, or log out and back in)"
echo "Done."
exit
