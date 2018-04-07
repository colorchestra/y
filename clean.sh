#!/bin/bash
BASEDIR=~/y/

for i in today tomorrow later done; do rm -rf $BASEDIR/$i/*; done

exit 0
