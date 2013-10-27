#!/bin/sh -e

# Bare Repository
BARE=$1

# Working Copy
WORK=$2

mkdir -p $BASE $WORK
svnadmin create $BARE
svn co file://$DIR/$BARE $WORK
