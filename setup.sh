#!/bin/bash

BASEDIR=~/y
DATADIR=$BASEDIR/data/

printf "Creating data directory... "
if [ ! -e "$DATADIR" ]; then
	mkdir "$DATADIR"
	printf "Successful.\n"
else
	printf "Directory already exists!\n"
fi

printf "Creating daily directories... "
for d in today tomorrow later done archive; do
	if ! [[ -e "$DATADIR/$d" ]]; then
		mkdir "$DATADIR/$d"
	else
		printf "Directory '$d' already exists! "

	fi
done
printf \\n

printf "Creating nocolor symlink... "
if [ ! -h "$BASEDIR/y-nocolor.sh" ]; then
	ln -s y.sh y-nocolor.sh
	printf "Successful.\n"
else
	printf "Symlink already exists!\n"
fi

echo "Removing old stuff from .bashrc..."
sed -i '/alias y=/d' ~/.bashrc
sed -i '/y\/completion.sh/d' ~/.bashrc

echo "Writing new aliases to .bashrc..."
echo "alias y='$BASEDIR/y.sh'" >> ~/.bashrc

echo "Writing completion stuff to .bashrc..."
echo "source $BASEDIR/completion.sh" >> ~/.bashrc

echo "Please run 'source ~/.bashrc' to enable bash completion (or start a new shell, or log out and back in)"
echo "Done."

read -p "Do you have an existing y data directory, e.g. in a Git repo? (yes/no) " yn
case $yn in
	[Yy]* ) echo "Please manually copy/clone your data directory now."		# to do: automatically clone if repo link is inserted
		exit 0
		;;

	* ) 	echo "A local Git repository will be initialized. If you want, set a remote."
		cd $DATADIR
		git init
		exit 0
		;;
esac
