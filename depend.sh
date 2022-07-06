#!/bin/bash

# Script Start Date and Time (for use in file name)
date=`date +"%m-%d-%y_%T"`


# Function to check if a certain needed command is available, installing it if not there
checkfor() {
	if command -v $1 >/dev/null 2>&1 ; then
		echo "$1 found"
	else
		echo "$1 not found, installing now"
		sudo apt install $1 >> log/dependency_log_file_$date.txt
		echo "\n" >> log/dependency_log_file_$date.txt
	fi
}


# Function to check if a certain file that is needed is available
checkforfile() {
	if [ -f $2 ]; then
		echo "$1 found"
	else
		echo "$1 not found, must be manually installed"
	fi		
}


# Usually there
checkfor "cat"
checkfor "lscpu"
checkfor "lshw"
checkfor "uname"
checkfor "nproc"
checkfor "wget"


# Numastat and Numactl come together in a package called numactl
checkfor "numactl"


# Commonly missing packages
checkfor "lstopo"
checkfor "stressapptest"
checkfor "fio"
checkfor "gcc"
checkfor "perl"
checkfor "make"


# Checking for Stream files
if [ -f "src/Stream/stream" ]; then
	echo "stream found, still must be recompiled"
else
	echo "stream not found, must be manually installed"
	mkdir src/Stream
	
	if [ ! -f "src/Stream/stream.c" ]
	then
		wget -q -P src/Stream cs.virginia.edu/stream/FTP/Code/stream.c
	fi
fi	

# Recompiling stream with the gcc compiler on the system (precompiled does not work)
gcc -fopenmp -D_OPENMP src/Stream/stream.c -o src/Stream/stream


# Checking for multichase files
checkforfile "multichase main" "src/multichase-master/multichase"
checkforfile "multichase multiload" "src/multichase-master/multiload"
checkforfile "multichase fairness" "src/multichase-master/fairness"
checkforfile "multichase pingpong" "src/multichase-master/pingpong"

# Excel::Writer::XLSX

excel_out=$(perl -e "use Excel::Writer::XLSX")

if [ ! $excel_out = "" ]; then
	if [ command -v cpanm >/dev/null 2>&1 ]; then
		echo "cpanm found, installing Excel Writer"
	else
		echo "cpanm not found, installing now"
		sudo apt install cpanminus >> log/dependency_log_file_$date.txt
		echo "\n" >> log/dependency_log_file_$date.txt
	fi
	
	sudo cpanm Excel::Writer::XLSX
else
	echo "Excel Writer found"
fi
