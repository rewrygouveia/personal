#!/bin/bash

cd /trb/applications/applications_logs
for i in `ls *.log.*`
do
   new=`echo $i | sed 's/.log./.log /g' | awk '{print $1}'`
   data=`stat -c %y $i | cut -d '.' -f1 | sed 's/ /_/g' | sed 's/:/-/g'`
   user=`stat -c %U $i`
   group=`stat -c %G $i`
   mv $i $new-$data
   gzip -v $new-$data
   if [ ! -d archivelog/ ]
      then mkdir archivelog/
      mv $new-$data.gz archivelog/
      else
      mv $new-$data.gz archivelog/
   fi
   chown -R $user.$group archivelog/
done
