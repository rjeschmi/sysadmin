#!/usr/bin/env python


VOLUME=$1
echo "checking for volume $1"
psql -A -U bacula_ro -h 192.168.160.18 -t -c"select count(*) from media where volumename like '$VOLUME' limit 1;" bacula
