#!/bin/bash

# Script Start Date and Time (for use in file name)
date=`date +"%m-%d-%y_%T"`
has_multi="true"


# Function to check if a certain needed command is available, installing it if not there
checkfor() {
	if command -v $1 >/dev/null 2>&1 ; then
		echo "$1 found"
	else
		echo "$1 not found, installing now"
		sudo apt-get -y install $1 >> log/dependency_log_file_$date.txt
		echo "\n" >> log/dependency_log_file_$date.txt
	fi
}


# Function to check if a certain file that is needed is available
checkforfile() {
	if [ -f $2 ]; then
		echo "$1 found"
	else
		echo "$1 not found, must be installed"
		has_multi="false"
	fi		
}


# Usually there

# cat is part of the coreutils package
if command -v cat >/dev/null 2>&1 ; then
	echo "cat found"
else
	echo "cat not found, installing now"
	sudo apt-get -y install coreutils >> log/dependency_log_file_$date.txt
	echo "\n" >> log/dependency_log_file_$date.txt
fi

# Lscpu is part of the util-linux package
if command -v lscpu >/dev/null 2>&1 ; then
	echo "lscpu found"
else
	echo "lscpu not found, installing now"
	sudo apt-get -y install util-linux >> log/dependency_log_file_$date.txt
	echo "\n" >> log/dependency_log_file_$date.txt
fi

# nproc is part of the coreutils package
if command -v nproc >/dev/null 2>&1 ; then
	echo "nproc found"
else
	echo "nproc not found, installing now"
	sudo apt-get -y install coreutils >> log/dependency_log_file_$date.txt
	echo "\n" >> log/dependency_log_file_$date.txt
fi

checkfor "lshw"
checkfor "uname"
checkfor "dmidecode"
checkfor "wget"

# Numastat and Numactl come together in a package called numactl
checkfor "numactl"


# Commonly missing packages

# Lstopo is installed using hwloc instead of its name 
if command -v lstopo >/dev/null 2>&1 ; then
	echo "lstopo found"
else
	echo "lstopo not found, installing now"
	sudo apt-get -y install hwloc >> log/dependency_log_file_$date.txt
	echo "\n" >> log/dependency_log_file_$date.txt
fi

# Cpanm is installed using cpanminus instead of its name 
if command -v cpanm >/dev/null 2>&1 ; then
	echo "cpanm found"
else
	echo "cpanm not found, installing now"
	sudo apt-get -y install cpanminus >> log/dependency_log_file_$date.txt
	echo "\n" >> log/dependency_log_file_$date.txt
fi

# All these have the same package name as command
checkfor "stressapptest"
checkfor "fio"
checkfor "gcc"
checkfor "perl"
checkfor "make"
checkfor "git"
checkfor "ipmitool"


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
checkforfile "multichase main" "src/multichase/multichase"
checkforfile "multichase multiload" "src/multichase/multiload"
checkforfile "multichase fairness" "src/multichase/fairness"
checkforfile "multichase pingpong" "src/multichase/pingpong"

if [ $has_multi = "false" ]; then
	rm -rf "src/multichase"
	cd src/
	git clone https://github.com/google/multichase.git
	cd multichase/
	make
	cd ..
	cd ..
fi
	

# Excel::Writer::XLSX
sudo cpanm Excel::Writer::XLSX
