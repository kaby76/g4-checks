#!/bin/bash
# set -x
echo Computing coverage for grammars...
for i in `find . -name desc.xml | grep -v Generated\*`
do
  echo $i
  d=`dirname $i`
  pushd $d > /dev/null 2>&1
  rm -rf Generated-*
  trgen -t CSharp > /dev/null 2>&1
  for j in Generated-*
  do
    cd $j
    if [ ! -d ../examples ]
    then
      break
    fi
    make > /dev/null 2>&1
    files=`find ../examples -type f | grep -v .errors | grep -v .tree`
    if [ "" == "$files" ]
    then
      break;
    fi
    trcover $files > cover.html

    git diff . > diffs

    break
  done
  popd > /dev/null 2>&1  
done
