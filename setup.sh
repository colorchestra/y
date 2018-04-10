#!/bin/bash

BASEDIR=~/y
DATADIR=$BASEDIR/data/

echo "Creating data directory..."
mkdir $DATADIR

echo "Creating daily directories..."
for d in today tomorrow later done; do
	if ! [[ -e $DATADIR/$d ]]; then
		mkdir $DATADIR/$d
	fi
done

echo "Removing old aliases from .bashrc..."
sed -i '/alias y=/d' ~/.bashrc

echo "Writing new aliases to .bashrc..."
echo "alias y='$BASEDIR/y.sh'" >> ~/.bashrc

echo "Done."

read -p "Do you have an existing 'data' directory, e.g. in a Git repo? (yes/no)" yn
case $yn in
	[Yy]* ) echo "Please manually copy your data directory now."		# to do: automatically clone if repo link is inserted
		exit 0
		;;

	* ) cd $DATADIR
	git init
	exit 0
	;;
