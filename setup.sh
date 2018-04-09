#!/bin/bash

BASEDIR=~/y
DATADIR=$BASEDIR/data/

for d in today tomorrow later done; do
	if ! [[ -e $DATADIR/$d ]]; then
		mkdir $DATADIR/$d
	fi
done

sed -i '/alias y=/d' ~/.bashrc
echo "alias y='$BASEDIR/y.sh'" >> ~/.bashrc
