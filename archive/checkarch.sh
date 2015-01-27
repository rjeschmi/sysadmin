#!/bin/bash

LOGFILE=/var/lib/archive/archivelogfile
MYDIR=/soldata1/Runs

# if the 'if' clause below is -ne then it shows you the runs which need to be archived
# if the 'if' clause below is -eq then it shows you the ones already archived but have
# not yet been trimmed
echo "Runs not yet archived :"
for arun in *HWUSI* *ILLUMINA*
do 
	grep $arun /var/lib/archive/archivelogfile > /dev/null 2>&1
	gret=$?
	if [ $gret -ne 0 ]
	then
		grep $arun sizes.cooked
	fi
done

echo "Runs archived but not yet trimmed:"
for arun in *HWUSI* *ILLUMINA*
do 
	grep $arun /var/lib/archive/archivelogfile > /dev/null 2>&1
	gret=$?
	if [ $gret -eq 0 ]
	then
		grep $arun sizes.cooked
	fi
done

