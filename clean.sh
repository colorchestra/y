#!/bin/bash
BASEDIR=~/y/
DATADIR=$BASEDIR/data

read -p "Are you SURE you want to irrecoverably delete ALL of your entries? (yes/no) " yn
case $yn in
         [Yy]* ) for i in today tomorrow later done; do rm -rf $DATADIR/$i/*; done
		 rm $BASEDIR/git.log
                 echo "All entries deleted."
                 exit 0
                 ;;  
         * ) echo "Aborting."
                 exit 1
                 ;;
esac

