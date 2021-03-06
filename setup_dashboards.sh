#!/bin/bash

if [[ $# -eq 0 ]]
then
	echo "Usage: Please provide the baseport of your TorQ-Air stack as an argument"
	exit 0
fi

baseport=$1
RDBPORT=$(($baseport + 2))
HDBPORT=$(($baseport + 3))
BOARDPORT=$(($baseport + 10))
dashboards=("boards.json" "rdb.json" "slide1.json" "slide2.json" "slide3.json" "slide4.json")

# Replaces default port numbers in all files in /dashboards
for item in "${dashboards[@]}"
do
	if [ ! -f dashboards/$item ]
	then
		echo "$item not found, exiting program"
		echo "Ensure you are running this from the TorQ root folder"
		exit 1
	fi
	sed -i s/24027/$RDBPORT/g dashboards/$item
	sed -i s/24028/$HDBPORT/g dashboards/$item 
	sed -i s/24035/$BOARDPORT/g dashboards/$item 
done
