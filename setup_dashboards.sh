#!/bin/bash

if [[ $# -eq 0 ]]
then
	echo "Usage:"
	echo "Please provide the baseport of your TorQ-Air stack as the first argument"
	echo "And the path to your Kx Dashboards 'dash' folder as the second"
	exit 0
fi

baseport=$1
dashFolder=$2

RDBPORT=$(($baseport + 2))
HDBPORT=$(($baseport + 3))
BOARDPORT=$(($baseport + 10))

declare -a connections=("rdb.json" "boards.json")
declare -a dashboards=("slide1.json" "slide2.json" "slide3.json" "slide4.json")

all=( "${dashboards[@]}" "${connections[@]}" )

# Replaces placeholder port numbers in all files in /dashboards
for item in "${all[@]}"
do
	sed -i s/RDBPORT/$RDBPORT/g dashboards/$item
	sed -i s/HDBPORT/$HDBPORT/g dashboards/$item 
	sed -i s/BOARDPORT/$BOARDPORT/g dashboards/$item 
done

# Moves rdb.json and boards.json to the connections folder in Kx dashboards
for conn in "${connections[@]}"
do
	cp dashboards/$conn $dashFolder/data/connections
done

