#!/bin/bash

# Script Start Date and Time (for use in file name)
date=`date +"%m-%d-%y_%H-%M-%S"`
file=$1

echo "Sensors Data\n" > $file

i=2

while [ $i -gt 1 ]
do
	date >> $file
	sensors >> $file
#	echo "loop index: $i" >> $file
	echo "\n" >> $file
	sleep 1 
#	i=`exec $i + 1`
done

