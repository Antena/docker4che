#!/bin/bash
set -v

/etc/init.d/postgresql restart
sleep 5s
/var/local/dcm4chee/dcm4chee-2.18.0-psql/bin/run.sh