#!/bin/bash

CLIENT_DIR=$1
COMMIT_COUNT=$2
PREFIX=$3

cd $CLIENT_DIR
for ((i=1; i<=$COMMIT_COUNT; i++))
do
  echo $i > $PREFIX$i.txt;
  svn add $PREFIX$i.txt;
  svn ci -m "add $PREFIX$i";
done
