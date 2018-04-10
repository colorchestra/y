#!/bin/bash

BASEDIR=~/y
DATADIR=$BASEDIR/data/

echo "Creating data directory..."
mkdir $DATADIR
cd $DATADIR
git init
cd $BASEDIR

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
