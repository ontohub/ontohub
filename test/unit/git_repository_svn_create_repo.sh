#!/bin/bash

DIR=$1
SERVERNAME=$2
CLIENTNAME=$3

mkdir -p $DIR
cd $DIR
svnadmin create $SERVERNAME
svn co file://$DIR/$SERVERNAME $CLIENTNAME
