#!/bin/sh

echo "changing folder:"
echo $1
cd $1
pwd
echo "that's the folder :)"
git svn rebase
