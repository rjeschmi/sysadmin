#!/usr/bin/env python

import sys
import sqlalchemy
import pprint

pp = pprint.PrettyPrinter(indent=4)


for volume in sys.argv[1:]:

    engine = sqlalchemy.create_engine('postgresql://bacula_ro:bacula_ro@192.168.160.18/bacula')
    connection = engine.connect()
    result = connection.execute("select count(*) from media where volumename like '%s';" % volume ).first()

    if result['count'] == 0:
        print volume

