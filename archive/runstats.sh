#!/bin/bash

MYDIR=/soldata1/Runs
STATS=run.stats

pushd $MYDIR
echo "Run            DirSize  #Files  AvgSize  Min   Max" > $STATS
for arun in *HWUSI* *ILLUMINA*
do 
	myout=`find $arun -type f -print0 | xargs -0 ls -l  | gawk '{if(min==""){min=max=$5}; if($5>max) {max=$5}; if($5< min) {min=$5}; total+=$5; count+=1} END {print total, count, total/count, min, max}'`
	echo $arun $myout
done >> $STATS
popd
