#!/bin/sh -e

DIR=$1
COMMIT_COUNT=$2
PREFIX=$3

cd $DIR

for i in `seq $COMMIT_COUNT`;
do
  file="$PREFIX$i.txt"
  date +%N > $file
  svn add --force $file
  svn ci -m "add $file"
  echo "ja"
done
