#!/bin/bash

$BASEDIR=~/y
$DATADIR=$BASEDIR/data/

for d in today tomorrow later done; do
	mkdir $DATADIR/$d
done
