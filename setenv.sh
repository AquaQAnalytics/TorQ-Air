#!/bin/bash

# get absolute path to setenv.sh directory
if [ "-bash" = $0 ]; then
  dirpath="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
else
  dirpath="$(cd "$(dirname "$0")" && pwd)"
fi

export TORQHOME=${dirpath}
export KDBCONFIG=${TORQHOME}/config
export KDBCODE=${TORQHOME}/code
export KDBLOG=${TORQHOME}/logs
export KDBHTML=${TORQHOME}/html
export KDBLIB=${TORQHOME}/lib
export KDBHDB=${TORQHOME}/hdb
export KDBWDB=${TORQHOME}/wdbhdb
export KDBDQCDB=${TORQHOME}/dqe/dqcdb/database
export KDBDQEDB=${TORQHOME}/dqe/dqedb/database
export KDBTPLOG=${TORQHOME}/tplogs
export KDBBACKUP=${TORQHOME}/backup

# set rlwrap and qcon paths for use in torq.sh qcon flag functions
export RLWRAP="rlwrap"
export QCON="qcon"

# set the application specific configuration directory
export KDBAPPCONFIG=${TORQHOME}/appconfig
export KDBAPPCODE=${TORQHOME}/code


# set KDBBASEPORT to the default value for a TorQ Installation
export KDBBASEPORT=78500

