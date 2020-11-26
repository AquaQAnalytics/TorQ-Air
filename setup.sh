#!/bin/bash

baseport=$1
dashFolder=$2

RDBPORT=$(($baseport + 2))
HDBPORT=$(($baseport + 3))
BOARDPORT=$(($baseport + 10))

declare -a connections=("rdb.json" "boards.json")
declare -a dashboards=("Slide1.json" "slide2.json" "Slide3.json" "slide4.json")

all=( "${dashboards[@]}" "${connections[@]}" )

for item in "${all[@]}"
do
	sed -i s/RDBPORT/$RDBPORT/g dashboards/$item
	sed -i s/HDBPORT/$HDBPORT/g dashboards/$item 
	sed -i s/BOARDPORT/$BOARDPORT/g dashboards/$item 
done

for conn in "${connections[@]}"
do
	cp dashboards/$conn $dashFolder/data/connections
done

