#!/bin/bash
BASEDIR=~/y/
DATADIR=$BASEDIR/data

for i in today tomorrow later done; do rm -rf $DATADIR/$i/*; done

exit 0
