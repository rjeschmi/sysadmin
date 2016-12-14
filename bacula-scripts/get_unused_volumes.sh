#!/bin/bash
echo "use catalog=MyCatalog"
DELVOLUME=$(psql -A -U bacula_ro -h 127.0.0.1 -t -c"select volumename from media left join jobmedia using (mediaid) where jobmedia.mediaid is null and volumename like 'FranklinSAN%' limit 1;" bacula)
echo "delete volume=$DELVOLUME yes"
echo "quit"
