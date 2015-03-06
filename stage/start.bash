#!/bin/bash
set -v

/etc/init.d/postgresql restart
sleep 5s
/var/local/dcm4chee/dcm4chee-2.17.1-psql/bin/run.sh