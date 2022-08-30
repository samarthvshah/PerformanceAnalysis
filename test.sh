#!/bin/bash

# Install Pip
if command -v conda >/dev/null 2>&1 ; then
	echo "conda found"
	echo "conda found\n" >> log/dependency_log_file_$date.txt
else
	echo "conda not found, installing now"
	echo "conda not found, installing now" >> log/dependency_log_file_$date.txt
	wget -P /tmp https://repo.anaconda.com/archive/Anaconda3-2020.02-Linux-x86_64.sh
	bash /tmp/Anaconda3-2020.05-Linux-x86_64.sh
	echo "\n" >> log/dependency_log_file_$date.txt	
fi
