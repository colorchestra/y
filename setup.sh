#!/bin/bash

BASEDIR=~/y
DATADIR=$BASEDIR/data/

echo "Creating data directory..."
mkdir $DATADIR

echo "Creating daily directories..."
for d in today tomorrow later done archive; do
	if ! [[ -e $DATADIR/$d ]]; then
		mkdir $DATADIR/$d
	fi
done

echo "Creating nocolor symlink..."
ln -s y.sh y-nocolor.sh

echo "Removing old stuff from .bashrc..."
sed -i '/alias y=/d' ~/.bashrc
sed -i '/y\/completion.sh/d' ~/.bashrc

echo "Writing new aliases to .bashrc..."
echo "alias y='$BASEDIR/y.sh'" >> ~/.bashrc

echo "Writing completion stuff to .bashrc..."
echo "source $BASEDIR/completion.sh" >> ~/.bashrc

echo "Please run `source ~/.bashrc` to enable bash completion (or start a new shell, or log out and back in)"
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
