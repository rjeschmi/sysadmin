#!/bin/bash

MYDIR=/soldata1/Runs
STATS=stats
OFILEEND=.fsize

pushd $MYDIR
for arun in *HWUSI* *ILLUMINA*
do 
	find $arun -type f -print0 | xargs -0 ls -l  | gawk '{ print $5}' > ${STATS}/${arun}${OFILEEND}
done 
popd
